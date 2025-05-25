import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/forklift_service.dart';
import 'package:forklift_mobile/screens/user/new_order.dart';
import 'about.dart';

class ForkliftList extends StatefulWidget {
  const ForkliftList({super.key});

  @override
  State<ForkliftList> createState() => _ForkliftListState();
}

class _ForkliftListState extends State<ForkliftList> {
  List<Map<String, dynamic>> _forklifts = [];
  bool _isLoading = true;
  String? _error;
  final Color maroonColor = const Color(0xFF800000);

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const About()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Daftar Unit Forklift',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: maroonColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const About()),
              );
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
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
                                                'http://192.168.1.19:3000/images/${forklift['gambar']}',
                                            fit: BoxFit.cover,
                                            width: 110,
                                            height: 90,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget: (context, url,
                                                    error) =>
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        forklift['nama_unit'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: forklift['status'] ==
                                                  'tersedia'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          forklift['status'] == 'tersedia'
                                              ? 'Tersedia'
                                              : 'Disewa',
                                          style: TextStyle(
                                            color:
                                                forklift['status'] == 'tersedia'
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
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
                                        style: TextStyle(
                                          color: maroonColor,
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
                                              backgroundColor: maroonColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewOrder(
                                                    selectedForklift: forklift,
                                                  ),
                                                ),
                                              );
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
      ),
    );
  }
}
