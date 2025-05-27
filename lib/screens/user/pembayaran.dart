import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'payment_webview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Pembayaran extends StatefulWidget {
  final int jumlah;
  final String metode;
  final DateTime tanggalPembayaran;
  final int? idPemesanan;

  const Pembayaran({
    Key? key,
    required this.jumlah,
    required this.metode,
    required this.tanggalPembayaran,
    this.idPemesanan,
  }) : super(key: key);

  @override
  State<Pembayaran> createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jumlahController;
  late TextEditingController _metodeController;
  late TextEditingController _tanggalController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  XFile? _buktiPembayaran;
  Uint8List? _buktiPembayaranBytes;
  String? _buktiPembayaranName;

  @override
  void initState() {
    super.initState();
    _jumlahController = TextEditingController(text: widget.jumlah.toString());
    _metodeController = TextEditingController(text: widget.metode);
    _tanggalController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.tanggalPembayaran));
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _metodeController.dispose();
    _tanggalController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBuktiPembayaran() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final allowed = ['.png', '.jpg', '.jpeg'];
      if (!allowed.any((ext) => picked.name.toLowerCase().endsWith(ext))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Format file harus .png, .jpg, atau .jpeg')),
        );
        return;
      }
      setState(() {
        _buktiPembayaran = picked;
      });
    }
  }

  Future<void> _submitPembayaran() async {
    if (!_formKey.currentState!.validate()) return;
    if (_buktiPembayaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti pembayaran wajib diupload!')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final idPemesanan = widget.idPemesanan ?? 1;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/api/pembayaran/store'),
      );
      request.fields['id_pemesanan'] = idPemesanan.toString();
      request.fields['jumlah'] = _jumlahController.text;
      request.fields['metode'] = _metodeController.text;
      request.fields['tanggal_pembayaran'] = _tanggalController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'bukti_pembayaran',
        _buktiPembayaran!.path,
        filename: _buktiPembayaran!.name,
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil dibuat')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ?? 'Gagal membuat pembayaran')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final idPemesanan = widget.idPemesanan ?? 1;
      final url =
          Uri.parse('http://localhost:3000/api/payment/create-transaction');
      final body = {
        "id_pemesanan": idPemesanan.toString(),
        "jumlah": int.tryParse(_jumlahController.text) ?? 0,
        "metode": _metodeController.text,
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text
      };
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['status'] == true) {
        String? paymentUrl;
        if (data['data'] != null && data['data']['redirect_url'] != null) {
          paymentUrl = data['data']['redirect_url'];
        } else {
          paymentUrl =
              data['redirect_url'] ?? data['payment_url'] ?? data['snap_url'];
        }
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          if (kIsWeb) {
            final uri = Uri.parse(paymentUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Tidak bisa membuka link pembayaran: $paymentUrl')),
              );
            }
          } else {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentWebView(paymentUrl: paymentUrl!),
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Transaksi payment gateway berhasil dibuat, tapi link pembayaran tidak ditemukan')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message'] ??
                    'Gagal membuat transaksi payment gateway')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Pembayaran'), backgroundColor: Color(0xFFFFA500)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _jumlahController,
                decoration:
                    const InputDecoration(labelText: 'Jumlah Pembayaran'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Jumlah harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _metodeController,
                decoration:
                    const InputDecoration(labelText: 'Metode Pembayaran'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Metode harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                decoration:
                    const InputDecoration(labelText: 'Tanggal Pembayaran'),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: widget.tanggalPembayaran,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _tanggalController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nama Depan'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama depan harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nama Belakang'),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Nama belakang harus diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Email harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'No. HP harus diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickBuktiPembayaran,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Bukti Pembayaran'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA500)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buktiPembayaran != null
                          ? _buktiPembayaran!.name
                          : 'Belum ada file',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPembayaran,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Konfirmasi Pembayaran (Manual)'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFA500)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTransaction,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Bayar via Payment Gateway'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
