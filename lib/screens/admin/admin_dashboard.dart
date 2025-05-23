import 'package:flutter/material.dart';
import 'package:forklift_mobile/screens/admin/kelola_pengguna.dart';
import 'package:forklift_mobile/screens/admin/kelola_forklift.dart';
import 'package:forklift_mobile/screens/admin/kelola_operator.dart';
import 'package:forklift_mobile/screens/admin/kelola_pemesanan.dart';
import 'package:forklift_mobile/screens/admin/verifikasi_pembayaran.dart';
import 'package:forklift_mobile/screens/admin/log_transaksi.dart';
import 'package:forklift_mobile/screens/admin/daftar_feedback.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implementasi logout
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            'Manajemen User',
            Icons.people,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KelolaPengguna()),
            ),
          ),
          _buildMenuCard(
            context,
            'Manajemen Unit',
            Icons.forklift,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KelolaForklift()),
            ),
          ),
          _buildMenuCard(
            context,
            'Manajemen Operator',
            Icons.person,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KelolaOperator()),
            ),
          ),
          _buildMenuCard(
            context,
            'Manajemen Pemesanan Baru',
            Icons.shopping_cart,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KelolaPemesanan()),
            ),
          ),
          _buildMenuCard(
            context,
            'Verifikasi Pembayaran',
            Icons.payment,
            Colors.amber,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VerifikasiPembayaran(),
              ),
            ),
          ),
          _buildMenuCard(
            context,
            'Log Transaksi',
            Icons.history,
            Colors.teal,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogTransaksi()),
            ),
          ),
          _buildMenuCard(
            context,
            'Feedback',
            Icons.feedback,
            Colors.pink,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DaftarFeedback()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
