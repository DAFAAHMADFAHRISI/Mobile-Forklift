import 'package:flutter/material.dart';

class LogTransaksi extends StatefulWidget {
  const LogTransaksi({super.key});

  @override
  State<LogTransaksi> createState() => _LogTransaksiState();
}

class _LogTransaksiState extends State<LogTransaksi> {
  final List<Map<String, dynamic>> _logs = [
    {
      'id': 1,
      'tanggal': '2024-03-19 10:30:00',
      'tipe': 'pemesanan',
      'deskripsi': 'Pemesanan baru dibuat oleh Pengguna Test',
      'detail': {'order_id': 1, 'user_id': 1, 'total': 1800000},
    },
    {
      'id': 2,
      'tanggal': '2024-03-19 11:15:00',
      'tipe': 'pembayaran',
      'deskripsi': 'Pembayaran diterima untuk Pemesanan #1',
      'detail': {'payment_id': 1, 'order_id': 1, 'jumlah': 1800000},
    },
    {
      'id': 3,
      'tanggal': '2024-03-19 13:45:00',
      'tipe': 'pengiriman',
      'deskripsi': 'Forklift dikirim untuk Pemesanan #1',
      'detail': {'order_id': 1, 'forklift_id': 1, 'operator_id': 1},
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Transaksi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log['tipe'].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        log['tanggal'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(log['deskripsi']),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Detail:'),
                  const SizedBox(height: 4),
                  ...log['detail'].entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text('${entry.key}: ${entry.value}'),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
