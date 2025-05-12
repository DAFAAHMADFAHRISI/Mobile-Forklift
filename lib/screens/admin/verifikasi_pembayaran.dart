import 'package:flutter/material.dart';

class VerifikasiPembayaran extends StatefulWidget {
  const VerifikasiPembayaran({super.key});

  @override
  State<VerifikasiPembayaran> createState() => _VerifikasiPembayaranState();
}

class _VerifikasiPembayaranState extends State<VerifikasiPembayaran> {
  final List<Map<String, dynamic>> _payments = [
    {
      'id': 1,
      'order_id': 1,
      'nama_user': 'Pengguna Test',
      'total_pembayaran': 1800000,
      'metode_pembayaran': 'Transfer Bank',
      'bukti_transfer': 'bukti_transfer_1.jpg',
      'tanggal_pembayaran': '2024-03-19',
      'status_verifikasi': 'menunggu',
    },
    {
      'id': 2,
      'order_id': 2,
      'nama_user': 'Pengguna Test 2',
      'total_pembayaran': 720000,
      'metode_pembayaran': 'Transfer Bank',
      'bukti_transfer': 'bukti_transfer_2.jpg',
      'tanggal_pembayaran': '2024-03-20',
      'status_verifikasi': 'diterima',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Pembayaran')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
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
                        'Pembayaran #${payment['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(payment['status_verifikasi']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment['status_verifikasi'].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('ID Pemesanan: #${payment['order_id']}'),
                  Text('Pemesan: ${payment['nama_user']}'),
                  Text('Total: Rp ${payment['total_pembayaran']}'),
                  Text('Metode: ${payment['metode_pembayaran']}'),
                  Text('Tanggal: ${payment['tanggal_pembayaran']}'),
                  const SizedBox(height: 16),
                  if (payment['status_verifikasi'] == 'menunggu')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // TODO: Implementasi tolak pembayaran
                          },
                          child: const Text('Tolak'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implementasi terima pembayaran
                          },
                          child: const Text('Terima'),
                        ),
                      ],
                    ),
                  if (payment['bukti_transfer'] != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementasi lihat bukti transfer
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Lihat Bukti Transfer'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return Colors.orange;
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
