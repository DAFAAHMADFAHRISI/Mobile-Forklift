import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/forklift_service.dart';

class ForkliftList extends StatefulWidget {
  const ForkliftList({super.key});

  @override
  State<ForkliftList> createState() => _ForkliftListState();
}

class _ForkliftListState extends State<ForkliftList> {
  List<Map<String, dynamic>> _forklifts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableForklifts();
  }

  Future<void> _loadAvailableForklifts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final forklifts = await ForkliftService.getAvailableForklifts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Unit Forklift')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadAvailableForklifts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _forklifts.length,
                    itemBuilder: (context, index) {
                      final forklift = _forklifts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: forklift['gambar'] != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          'http://localhost:3000/images/${forklift['gambar']}',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                        child: Icon(Icons.forklift, size: 100),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.forklift, size: 100)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          forklift['nama_unit'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              forklift['status'] == 'tersedia'
                                                  ? Colors.green
                                                  : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          forklift['status'].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Kapasitas: ${forklift['kapasitas']} ton'),
                                  Text(
                                      'Harga: Rp ${forklift['harga_per_jam']}/jam'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Deskripsi:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(forklift['deskripsi'] ??
                                      'Tidak ada deskripsi'),
                                  const SizedBox(height: 16),
                                  if (forklift['status'] == 'tersedia')
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/new-order',
                                              arguments: forklift);
                                        },
                                        child: const Text('Pesan Sekarang'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
