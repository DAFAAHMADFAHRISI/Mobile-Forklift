import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'order_history.dart';
import 'forklift_list.dart';
import '../../services/pesanan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daftar_operator.dart';
import 'pembayaran.dart';

class NewOrder extends StatefulWidget {
  final Map<String, dynamic>? selectedForklift;
  const NewOrder({this.selectedForklift, super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _perusahaanController = TextEditingController();
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  Map<String, dynamic>? _selectedForklift;
  Map<String, dynamic>? _selectedOperator;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedForklift != null) {
      _selectedForklift = widget.selectedForklift;
    }
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _perusahaanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
          // Reset tanggal selesai jika tanggal mulai diubah
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = null;
          }
        } else {
          if (_tanggalMulai != null && picked.isBefore(_tanggalMulai!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Tanggal selesai tidak boleh sebelum tanggal mulai'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _tanggalSelesai = picked;
          }
        }
      });
    }
  }

  int _getHargaPerJam() {
    if (_selectedForklift == null) return 0;
    final hargaRaw = _selectedForklift!['harga_per_jam'];
    if (hargaRaw == null) return 0;
    if (hargaRaw is int) return hargaRaw;
    if (hargaRaw is String) return int.tryParse(hargaRaw) ?? 0;
    return int.tryParse(hargaRaw.toString()) ?? 0;
  }

  String _getKapasitas() {
    if (_selectedForklift == null) return 'Tidak tersedia';
    final raw = _selectedForklift!['kapasitas'];
    if (raw == null) return 'Tidak tersedia';
    if (raw is int) return raw.toString();
    if (raw is String && raw.isNotEmpty) return raw;
    return raw.toString();
  }

  int _calculateTotal() {
    if (_selectedForklift == null ||
        _tanggalMulai == null ||
        _tanggalSelesai == null) {
      return 0;
    }
    final hargaInt = _getHargaPerJam();
    final duration = _tanggalSelesai!.difference(_tanggalMulai!).inHours;
    if (duration <= 0) return 0; // Durasi tidak boleh <= 0
    return hargaInt * duration;
  }

  int _getIdForklift() {
    if (_selectedForklift == null) return 0;
    final raw = _selectedForklift!['id'] ?? _selectedForklift!['id_unit'];
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return int.tryParse(raw.toString()) ?? 0;
  }

  int _getIdOperator() {
    if (_selectedOperator == null) return 0;
    final raw = _selectedOperator!['id_operator'] ?? _selectedOperator!['id'];
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return int.tryParse(raw.toString()) ?? 0;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi tanggal
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mulai dan selesai harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi urutan tanggal
    if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi durasi dan total
    if (_calculateTotal() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Durasi pemesanan tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi operator
    if (_selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih operator terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('DEBUG _selectedForklift: \\n');
    print(_selectedForklift);
    print('DEBUG _selectedOperator: \\n');
    print(_selectedOperator);
    setState(() => _isUploading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getInt('id_user') ?? 0;
      if (idUser == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User tidak ditemukan, silakan login ulang'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isUploading = false);
        return;
      }

      final success = await PesananService.submitPesanan(
        idUser: idUser,
        idUnit: _getIdForklift(),
        idOperator: _getIdOperator(),
        tanggalMulai: _tanggalMulai!.toIso8601String().split('T').first,
        tanggalSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
        lokasiPengiriman: _lokasiController.text,
        namaPerusahaan: _perusahaanController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Pembayaran(
                jumlah: _calculateTotal(),
                metode: 'Transfer Bank',
                tanggalPembayaran: DateTime.now(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membuat pemesanan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ForkliftList()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pemesanan Baru',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFFFFA500),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ForkliftList()),
              );
            },
          ),
        ),
        body: Container(
          color: const Color(0xFFF7F7F7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedForklift != null)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unit yang Dipilih',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(
                                'Nama Unit: ${_selectedForklift!['nama_unit']}',
                                style: TextStyle(fontSize: 15)),
                            Text('Kapasitas: ${_getKapasitas()}',
                                style: TextStyle(fontSize: 15)),
                            Text(
                                'Harga: Rp ${_getHargaPerJam() > 0 ? _getHargaPerJam() : 'Tidak tersedia'} / jam',
                                style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pilih Operator',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _selectedOperator == null
                                    ? const Text('Belum ada operator dipilih',
                                        style: TextStyle(color: Colors.grey))
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Nama: ${_selectedOperator!['nama_operator']}',
                                              style: TextStyle(fontSize: 15)),
                                          Text(
                                              'No HP: ${_selectedOperator!['no_hp']}',
                                              style: TextStyle(fontSize: 15)),
                                          Text(
                                              'Status: ${_selectedOperator!['status']}',
                                              style: TextStyle(fontSize: 15)),
                                        ],
                                      ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFA500),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(80, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DaftarOperator(),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _selectedOperator =
                                          Map<String, dynamic>.from(result);
                                    });
                                  }
                                },
                                child: const Text('Pilih'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Tanggal Mulai',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              _tanggalMulai == null
                                  ? 'Pilih tanggal'
                                  : '${_tanggalMulai!.day}/${_tanggalMulai!.month}/${_tanggalMulai!.year}',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: const Icon(Icons.calendar_today,
                                color: Color(0xFFFFA500)),
                            onTap: () => _selectDate(context, true),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Tanggal Selesai',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              _tanggalSelesai == null
                                  ? 'Pilih tanggal'
                                  : '${_tanggalSelesai!.day}/${_tanggalSelesai!.month}/${_tanggalSelesai!.year}',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: const Icon(Icons.calendar_today,
                                color: Color(0xFFFFA500)),
                            onTap: () => _selectDate(context, false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lokasi Pengiriman',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lokasiController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan lokasi pengiriman',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lokasi pengiriman harus diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama Perusahaan',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _perusahaanController,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nama perusahaan',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama perusahaan harus diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ringkasan Pemesanan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 16),
                          if (_selectedForklift != null) ...[
                            Text('Unit: ${_selectedForklift!['nama_unit']}',
                                style: TextStyle(fontSize: 15)),
                            Text('Kapasitas: ${_getKapasitas()}',
                                style: TextStyle(fontSize: 15)),
                            Text(
                                'Harga: Rp ${_getHargaPerJam() > 0 ? _getHargaPerJam() : 'Tidak tersedia'} / jam',
                                style: TextStyle(fontSize: 15)),
                          ],
                          if (_selectedOperator != null)
                            Text(
                                'Operator: ${_selectedOperator!['nama_operator']}',
                                style: TextStyle(fontSize: 15)),
                          if (_tanggalMulai != null &&
                              _tanggalSelesai != null) ...[
                            Text(
                                'Durasi: ${_tanggalSelesai!.difference(_tanggalMulai!).inHours} jam',
                                style: TextStyle(fontSize: 15)),
                            Text('Total: Rp ${_calculateTotal()}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 16)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA500),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Buat Pemesanan'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Error message area
                  if (_calculateTotal() == 0 &&
                      _tanggalMulai != null &&
                      _tanggalSelesai != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Durasi pemesanan tidak valid',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
