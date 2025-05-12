import 'package:flutter/material.dart';

class UserFeedback extends StatefulWidget {
  const UserFeedback({super.key});

  @override
  State<UserFeedback> createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  final _formKey = GlobalKey<FormState>();
  final _komentarController = TextEditingController();
  int _rating = 0;
  int? _selectedOrderId;

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 1,
      'nama_unit': 'Forklift Diesel 3 Ton',
      'tanggal_mulai': '2024-03-20',
      'tanggal_selesai': '2024-03-25',
    },
    {
      'id': 2,
      'nama_unit': 'Forklift Listrik 2 Ton',
      'tanggal_mulai': '2024-03-21',
      'tanggal_selesai': '2024-03-23',
    },
  ];

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Order',
                  border: OutlineInputBorder(),
                ),
                value: _selectedOrderId,
                items:
                    _orders.map((order) {
                      return DropdownMenuItem(
                        value: order['id'] as int,
                        child: Text(
                          'Order #${order['id']} - ${order['nama_unit']} (${order['tanggal_mulai']} - ${order['tanggal_selesai']})',
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOrderId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih order';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Rating:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: index < _rating ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _komentarController,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Komentar harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _rating > 0) {
                      // TODO: Implementasi simpan feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback berhasil dikirim'),
                        ),
                      );
                      Navigator.pop(context);
                    } else if (_rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih rating terlebih dahulu'),
                        ),
                      );
                    }
                  },
                  child: const Text('Kirim Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
