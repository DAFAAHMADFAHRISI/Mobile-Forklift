import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/forklift_service.dart';

class KelolaForklift extends StatefulWidget {
  const KelolaForklift({super.key});

  @override
  State<KelolaForklift> createState() => _KelolaForkliftState();
}

class _KelolaForkliftState extends State<KelolaForklift> {
  List<Map<String, dynamic>> _forklifts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadForklifts();
  }

  Future<void> _loadForklifts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final forklifts = await ForkliftService.getAllForklifts();
      setState(() {
        _forklifts = forklifts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteForklift(int id) async {
    try {
      final success = await ForkliftService.deleteForklift(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit berhasil dihapus')),
        );
        _loadForklifts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus unit: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800);
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Unit Forklift')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _forklifts.length,
                  itemBuilder: (context, index) {
                    final forklift = _forklifts[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.grey[200],
                                width: 110,
                                height: 90,
                                child: forklift['gambar'] != null
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            'http://localhost:3000/images/${forklift['gambar']}',
                                        fit: BoxFit.cover,
                                        width: 110,
                                        height: 90,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child: Icon(Icons.forklift,
                                                    size: 50)),
                                      )
                                    : const Center(
                                        child: Icon(Icons.forklift, size: 50)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          forklift['nama_unit'] ?? '-',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            color: orange,
                                            onPressed: () {
                                              // TODO: Implementasi edit unit
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20),
                                            color: Colors.red,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Konfirmasi Hapus'),
                                                  content: const Text(
                                                      'Apakah Anda yakin ingin menghapus unit ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteForklift(
                                                            forklift[
                                                                'id_unit']);
                                                      },
                                                      child:
                                                          const Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    forklift['status'] == 'tersedia'
                                        ? 'Tersedia'
                                        : 'Disewa',
                                    style: TextStyle(
                                      color: forklift['status'] == 'tersedia'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kapasitas: ${forklift['kapasitas']} ton',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Harga Mulai dari',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Rp ${forklift['harga_per_jam'] ?? '-'} / Jam',
                                    style: const TextStyle(
                                      color: orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (forklift['deskripsi'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      forklift['deskripsi'],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () {
          // TODO: Implementasi tambah unit baru
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
