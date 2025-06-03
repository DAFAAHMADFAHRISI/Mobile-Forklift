import 'package:flutter/material.dart';
import 'admin_theme.dart';

class KelolaPengguna extends StatefulWidget {
  const KelolaPengguna({super.key});

  @override
  State<KelolaPengguna> createState() => _KelolaPenggunaState();
}

class _KelolaPenggunaState extends State<KelolaPengguna> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'nama': 'Admin Utama',
      'email': 'admin@example.com',
      'role': 'admin',
      'no_hp': '081234567890',
      'alamat': 'Jl. Admin No. 1',
    },
    {
      'id': 2,
      'nama': 'Pengguna Test',
      'email': 'user@example.com',
      'role': 'pengguna',
      'no_hp': '081234567891',
      'alamat': 'Jl. Pengguna No. 1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: Text('Kelola Pengguna', style: AdminTheme.appBarTitle),
          backgroundColor: AdminTheme.primaryDark,
          elevation: 0),
      body: Container(
        decoration: AdminTheme.backgroundGradient,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return Container(
              decoration: AdminTheme.cardBox,
              margin: const EdgeInsets.only(bottom: 16),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(user['nama']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user['email']}'),
                      Text('Peran: ${user['role']}'),
                      Text('No. HP: ${user['no_hp']}'),
                      Text('Alamat: ${user['alamat']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implementasi edit pengguna
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // TODO: Implementasi hapus pengguna
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementasi tambah pengguna baru
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
