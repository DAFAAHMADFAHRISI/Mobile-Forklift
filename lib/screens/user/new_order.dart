import 'package:flutter/material.dart';

class NewOrder extends StatefulWidget {
  const NewOrder({super.key});

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
                items:
                    _forklifts.map((forklift) {
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
                items:
                    _operators.map((operator) {
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implementasi simpan pemesanan
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pemesanan berhasil dibuat'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Buat Pemesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
