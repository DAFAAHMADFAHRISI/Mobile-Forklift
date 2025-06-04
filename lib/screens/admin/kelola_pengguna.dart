import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_theme.dart';
import '../../services/forklift_service.dart';

class KelolaPengguna extends StatefulWidget {
  const KelolaPengguna({super.key});

  @override
  State<KelolaPengguna> createState() => _KelolaPenggunaState();
}

class _KelolaPenggunaState extends State<KelolaPengguna> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await ForkliftService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Token tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse('http://192.168.100.91:3000/API/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data['data'].map((user) => {
                'id': user['id_user'],
                'nama': user['nama'],
                'email': user['email'],
                'role': user['role'],
                'no_hp': user['no_hp'],
                'alamat': user['alamat'],
              }));
        });
      } else {
        setState(() {
          _error = 'Gagal mengambil data pengguna';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> deleteUser(int id) async {
    setState(() => _isLoading = true);
    try {
      final token = await ForkliftService.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }
      final response = await http.delete(
        Uri.parse('http://192.168.100.91:3000/API/admin/users/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Widget _buildAvatar(String nama) {
    String inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 28, // Slightly larger avatar
      backgroundColor: AdminTheme.primaryDark.withOpacity(0.18),
      child: Text(
        inisial,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26, // Larger font size for initial
            color: Colors.deepPurple),
      ),
    );
  }

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
        elevation: 0,
      ),
      body: Container(
        decoration: AdminTheme.backgroundGradient,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)))
                : _users.isEmpty
                    ? const Center(
                        child: Text(
                        'Belum ada pengguna',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30), // Increased padding
                        itemCount: _users.length,
                        separatorBuilder: (context, index) => const SizedBox(
                            height: 20), // Reduced separator height
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  20), // Slightly less rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.15), // Darker shadow
                                  blurRadius: 15, // Slightly less blur
                                  offset: const Offset(
                                      0, 6), // Slightly less offset
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  Colors
                                      .white, // Solid white for better contrast
                                  Colors.grey[50]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                  color: Colors.black12
                                      .withOpacity(0.05)), // Lighter border
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20), // Increased padding
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Vertically center alignment
                                children: [
                                  _buildAvatar(user['nama'] ?? ''),
                                  const SizedBox(
                                      width: 20), // Increased spacing
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['nama'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  22, // Larger font size for name
                                              color: Colors.black87),
                                        ),
                                        const SizedBox(
                                            height: 6), // Increased spacing
                                        Text('Email: ${user['email']}',
                                            style: const TextStyle(
                                                fontSize:
                                                    15, // Slightly larger font
                                                color: Colors.black54)),
                                        Text('Peran: ${user['role']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54)),
                                        Text('No. HP: ${user['no_hp']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54)),
                                        Text('Alamat: ${user['alamat']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                  // Removed the edit IconButton
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color:
                                            Colors.red, // Solid red for delete
                                        size: 24), // Larger delete icon
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Konfirmasi Hapus',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          content: Text(
                                              'Apakah Anda yakin ingin menghapus pengguna ${user['nama']}?'), // More specific confirmation
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Batal',
                                                  style: TextStyle(
                                                      color: Colors.black54)),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Hapus',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await deleteUser(user['id']);
                                      }
                                    },
                                    tooltip:
                                        'Hapus Pengguna', // More descriptive tooltip
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 10), // Adjusted margin
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Implementasi tambah pengguna baru
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Fungsi tambah pengguna belum diimplementasikan')),
            );
          },
          backgroundColor: Colors.deepPurple,
          elevation: 10, // Increased elevation for a more prominent button
          child: const Icon(Icons.person_add,
              size: 32, color: Colors.white), // Changed icon to person_add
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)), // Slightly less rounded
        ),
      ),
    );
  }
}
