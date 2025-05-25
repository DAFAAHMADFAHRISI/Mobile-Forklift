import 'package:flutter/material.dart';
import 'package:forklift_mobile/screens/user/forklift_list.dart';
import 'package:forklift_mobile/screens/user/daftar_unit.dart';
import 'package:forklift_mobile/screens/user/order_history.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Forklift Illustration
            Padding(
              padding: const EdgeInsets.only(
                  top: 32, left: 24, right: 24, bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://images.pexels.com/photos/1267338/pexels-photo-1267338.jpeg?auto=compress&w=800&q=80',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App Title
            const Text(
              'Forklift Mobile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Forklift Mobile adalah aplikasi yang memudahkan pengguna dalam mengelola dan memesan layanan forklift. Dengan aplikasi ini, Anda dapat melihat daftar unit forklift yang tersedia, melakukan pemesanan baru, melacak riwayat pemesanan, dan memberikan feedback untuk layanan yang telah digunakan.',
                style: const TextStyle(
                    fontSize: 16, height: 1.6, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Fitur Utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fitur Utama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Feature List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildFeatureListItem(
                    icon: Icons.person_outline,
                    title: 'Profil Pengguna',
                    description: 'Kelola informasi profil Anda',
                    color: Colors.blue,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DaftarUnit(),
                        ),
                      );
                    },
                    child: _buildFeatureListItem(
                      icon: Icons.list_alt,
                      title: 'Daftar Unit',
                      description: 'Lihat daftar unit forklift yang tersedia',
                      color: Colors.green,
                    ),
                  ),
                  _buildFeatureListItem(
                    icon: Icons.add_circle_outline,
                    title: 'Pemesanan Baru',
                    description: 'Buat pemesanan forklift baru',
                    color: Colors.orange,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistory(),
                        ),
                      );
                    },
                    child: _buildFeatureListItem(
                      icon: Icons.history,
                      title: 'Riwayat Pemesanan',
                      description: 'Lihat riwayat pemesanan Anda',
                      color: Colors.purple,
                    ),
                  ),
                  _buildFeatureListItem(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    description: 'Berikan masukan untuk layanan kami',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Kontak
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kontak',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildContactListItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'support@forklift.com',
                    color: Colors.red,
                  ),
                  _buildContactListItem(
                    icon: Icons.phone_outlined,
                    label: 'Telepon',
                    value: '(021) 1234-5678',
                    color: Colors.green,
                  ),
                  _buildContactListItem(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    value: 'Jakarta, Indonesia',
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForkliftList(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Ingin Melakukan Pemesanan?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureListItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactListItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            label + ':',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
