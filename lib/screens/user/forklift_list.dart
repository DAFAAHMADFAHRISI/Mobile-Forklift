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
    const orange = Color(0xFFFF9800);
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
                                              'http://10.251.130.109:3000/images/${forklift['gambar']}',
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
                                          child:
                                              Icon(Icons.forklift, size: 50)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      forklift['nama_unit'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
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
                                          fontSize: 12,
                                          color: Colors.grey[700]),
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
                                            fontSize: 12,
                                            color: Colors.black87),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    if (forklift['status'] == 'tersedia')
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: orange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, '/new-order',
                                                arguments: forklift);
                                          },
                                          child: const Text('Pesan Sekarang',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
