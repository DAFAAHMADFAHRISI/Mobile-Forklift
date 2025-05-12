import 'package:flutter/material.dart';

class KelolaOperator extends StatefulWidget {
  const KelolaOperator({super.key});

  @override
  State<KelolaOperator> createState() => _KelolaOperatorState();
}

class _KelolaOperatorState extends State<KelolaOperator> {
  final List<Map<String, dynamic>> _operators = [
    {
      'id': 1,
      'nama_operator': 'Budi Santoso',
      'status': 'tersedia',
      'no_hp': '081234567892',
      'pengalaman': '5 tahun',
    },
    {
      'id': 2,
      'nama_operator': 'Andi Wijaya',
      'status': 'dipesan',
      'no_hp': '081234567893',
      'pengalaman': '3 tahun',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Operator')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _operators.length,
        itemBuilder: (context, index) {
          final operator = _operators[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(operator['nama_operator']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${operator['status']}'),
                  Text('No. HP: ${operator['no_hp']}'),
                  Text('Pengalaman: ${operator['pengalaman']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Implementasi edit operator
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // TODO: Implementasi hapus operator
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementasi tambah operator baru
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
