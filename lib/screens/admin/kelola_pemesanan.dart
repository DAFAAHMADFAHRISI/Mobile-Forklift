import 'package:flutter/material.dart';

class KelolaPemesanan extends StatefulWidget {
  const KelolaPemesanan({super.key});

  @override
  State<KelolaPemesanan> createState() => _KelolaPemesananState();
}

class _KelolaPemesananState extends State<KelolaPemesanan> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 1,
      'nama_user': 'Pengguna Test',
      'nama_unit': 'Forklift Diesel 3 Ton',
      'nama_operator': 'Budi Santoso',
      'tanggal_mulai': '2024-03-20',
      'tanggal_selesai': '2024-03-25',
      'lokasi_pengiriman': 'Jl. Industri No. 1',
      'nama_perusahaan': 'PT Test',
      'status': 'menunggu pembayaran',
      'total_harga': 1800000,
    },
    {
      'id': 2,
      'nama_user': 'Pengguna Test 2',
      'nama_unit': 'Forklift Listrik 2 Ton',
      'nama_operator': 'Andi Wijaya',
      'tanggal_mulai': '2024-03-21',
      'tanggal_selesai': '2024-03-23',
      'lokasi_pengiriman': 'Jl. Industri No. 2',
      'nama_perusahaan': 'PT Test 2',
      'status': 'dikirim',
      'total_harga': 720000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pemesanan')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
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
                        'Pemesanan #${order['id']}',
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
                          color: _getStatusColor(order['status']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order['status'].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Pemesan: ${order['nama_user']}'),
                  Text('Unit: ${order['nama_unit']}'),
                  Text('Operator: ${order['nama_operator']}'),
                  Text(
                    'Tanggal: ${order['tanggal_mulai']} - ${order['tanggal_selesai']}',
                  ),
                  Text('Lokasi: ${order['lokasi_pengiriman']}'),
                  Text('Perusahaan: ${order['nama_perusahaan']}'),
                  Text('Total: Rp ${order['total_harga']}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (order['status'] == 'menunggu pembayaran')
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implementasi verifikasi pembayaran
                          },
                          child: const Text('Verifikasi Pembayaran'),
                        ),
                      if (order['status'] == 'menunggu konfirmasi')
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implementasi konfirmasi pengiriman
                          },
                          child: const Text('Konfirmasi Pengiriman'),
                        ),
                    ],
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
      case 'menunggu pembayaran':
        return Colors.orange;
      case 'menunggu konfirmasi':
        return Colors.blue;
      case 'dikirim':
        return Colors.green;
      case 'selesai':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
