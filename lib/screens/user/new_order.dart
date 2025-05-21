import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'order_history.dart';

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

  final List<Map<String, dynamic>> _forklifts = [
    {
      'id': 1,
      'nama_unit': 'Forklift Diesel 3 Ton',
      'kapasitas': '3 ton',
      'harga_per_jam': 150000,
    },
    {
      'id': 2,
      'nama_unit': 'Forklift Listrik 2 Ton',
      'kapasitas': '2 ton',
      'harga_per_jam': 120000,
    },
  ];

  final List<Map<String, dynamic>> _operators = [
    {'id': 1, 'nama_operator': 'Budi Santoso', 'pengalaman': '5 tahun'},
    {'id': 2, 'nama_operator': 'Andi Wijaya', 'pengalaman': '3 tahun'},
  ];

  File? _buktiTransfer;
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
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  int _calculateTotal() {
    if (_selectedForklift == null ||
        _tanggalMulai == null ||
        _tanggalSelesai == null) {
      return 0;
    }

    final duration = _tanggalSelesai!.difference(_tanggalMulai!).inHours;
    return _selectedForklift!['harga_per_jam'] * duration;
  }

  Future<void> _pickBuktiTransfer() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        final extension = picked.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hanya file JPEG, JPG, dan PNG yang diperbolehkan'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final file = File(picked.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran file terlalu besar. Maksimal 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _buktiTransfer = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_buktiTransfer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti transfer harus diunggah'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // TODO: Implementasi upload bukti transfer dan simpan pemesanan
      await Future.delayed(const Duration(seconds: 2)); // Simulasi upload

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemesanan berhasil dibuat'),
          ),
        );
        // Navigate ke halaman riwayat pemesanan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderHistory()),
        );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pemesanan Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Unit Forklift',
                  border: OutlineInputBorder(),
                ),
                value: _selectedForklift,
                items: _forklifts.map((forklift) {
                  return DropdownMenuItem(
                    value: forklift,
                    child: Text(forklift['nama_unit']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedForklift = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih unit forklift';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Operator',
                  border: OutlineInputBorder(),
                ),
                value: _selectedOperator,
                items: _operators.map((operator) {
                  return DropdownMenuItem(
                    value: operator,
                    child: Text(operator['nama_operator']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOperator = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih operator';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tanggal Mulai'),
                subtitle: Text(
                  _tanggalMulai == null
                      ? 'Pilih tanggal'
                      : '${_tanggalMulai!.day}/${_tanggalMulai!.month}/${_tanggalMulai!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('Tanggal Selesai'),
                subtitle: Text(
                  _tanggalSelesai == null
                      ? 'Pilih tanggal'
                      : '${_tanggalSelesai!.day}/${_tanggalSelesai!.month}/${_tanggalSelesai!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Pengiriman',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi pengiriman harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _perusahaanController,
                decoration: const InputDecoration(
                  labelText: 'Nama Perusahaan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama perusahaan harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Pemesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedForklift != null) ...[
                        Text('Unit: ${_selectedForklift!['nama_unit']}'),
                        Text('Kapasitas: ${_selectedForklift!['kapasitas']}'),
                      ],
                      if (_selectedOperator != null)
                        Text(
                          'Operator: ${_selectedOperator!['nama_operator']}',
                        ),
                      if (_tanggalMulai != null && _tanggalSelesai != null) ...[
                        Text(
                          'Durasi: ${_tanggalSelesai!.difference(_tanggalMulai!).inHours} jam',
                        ),
                        Text('Total: Rp ${_calculateTotal()}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Transfer ke:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Bank BCA'),
                      const Text('No. Rekening: 1234567890'),
                      const Text('a.n. PT Forklift Rental'),
                      const SizedBox(height: 16),
                      const Text(
                        'Total Pembayaran:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rp ${_calculateTotal()}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Bukti Transfer:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_buktiTransfer != null)
                        Container(
                          height: 150,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_buktiTransfer!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickBuktiTransfer,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Pilih File'),
                          ),
                          if (_buktiTransfer != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(p.basename(_buktiTransfer!.path)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitOrder,
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buat Pemesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
