import 'package:flutter/material.dart';
import 'package:forklift_mobile/screens/user/profile.dart';
import 'package:forklift_mobile/screens/user/forklift_list.dart';
import 'package:forklift_mobile/screens/user/new_order.dart';
import 'package:forklift_mobile/screens/user/order_history.dart';
import 'package:forklift_mobile/screens/user/feedback.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengguna'),
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
            'Profil',
            Icons.person,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            ),
          ),
          _buildMenuCard(
            context,
            'Daftar Unit',
            Icons.forklift,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForkliftList()),
            ),
          ),
          _buildMenuCard(
            context,
            'Pemesanan Baru',
            Icons.add_shopping_cart,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewOrder()),
            ),
          ),
          _buildMenuCard(
            context,
            'Riwayat Pemesanan',
            Icons.history,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderHistory()),
            ),
          ),
          _buildMenuCard(
            context,
            'Feedback',
            Icons.feedback,
            Colors.pink,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserFeedback()),
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
