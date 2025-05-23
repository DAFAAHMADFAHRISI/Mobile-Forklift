import 'package:flutter/material.dart';
import '../../services/pesanan_service.dart';
import '../../services/auth_service.dart'; // Assuming you have an auth service for token management

class KelolaPemesanan extends StatefulWidget {
  const KelolaPemesanan({super.key});

  @override
  State<KelolaPemesanan> createState() => _KelolaPemesananState();
}

class _KelolaPemesananState extends State<KelolaPemesanan> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  // Tambahkan daftar status sesuai ENUM backend
  final List<String> statusList = [
    'menunggu pembayaran',
    'menunggu konfirmasi',
    'dikirim',
    'selesai',
  ];

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  Future<void> _loadPesanan() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get token from auth service
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final pesanan = await PesananService.getPesanan(token);
      setState(() {
        _orders = pesanan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await PesananService.updateStatus(token, id, newStatus);
      // Reload the list after update
      await _loadPesanan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePesanan(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await PesananService.deletePesanan(token, id);
        await _loadPesanan();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dihapus')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Tambahkan fungsi untuk menampilkan dialog pilihan status
  Future<void> _showStatusPicker(String id) async {
    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Pilih Status Baru'),
          children: statusList.map((status) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, status),
              child: Text(status),
            );
          }).toList(),
        );
      },
    );

    if (selectedStatus != null) {
      await _updateStatus(id, selectedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pemesanan'),
        backgroundColor: orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPesanan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: orange))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                        ),
                        onPressed: _loadPesanan,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
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
                                        'Pemesanan #${order['id'] ?? 'null'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                order['status'] ?? ''),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            (order['status'] ?? '')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.delete_outline),
                                          onPressed: () => _deletePesanan(
                                              order['id'].toString()),
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                _buildInfoRow(
                                    'Pemesan', order['nama_user'] ?? '-'),
                                _buildInfoRow(
                                    'Unit', order['nama_unit'] ?? '-'),
                                _buildInfoRow(
                                    'Operator', order['nama_operator'] ?? '-'),
                                _buildInfoRow('Tanggal',
                                    '${order['tanggal_mulai'] ?? '-'} - ${order['tanggal_selesai'] ?? '-'}'),
                                _buildInfoRow('Lokasi',
                                    order['lokasi_pengiriman'] ?? '-'),
                                _buildInfoRow('Perusahaan',
                                    order['nama_perusahaan'] ?? '-'),
                                _buildInfoRow('Total',
                                    'Rp ${order['total_harga'] ?? '-'}'),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (order['status'] ==
                                        'menunggu pembayaran')
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: orange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => _showStatusPicker(
                                            order['id'].toString()),
                                        icon: const Icon(
                                            Icons.check_circle_outline),
                                        label:
                                            const Text('Verifikasi Pembayaran'),
                                      ),
                                    if (order['status'] ==
                                        'menunggu konfirmasi')
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => _updateStatus(
                                          order['id'].toString(),
                                          'dikirim',
                                        ),
                                        icon: const Icon(
                                            Icons.local_shipping_outlined),
                                        label:
                                            const Text('Konfirmasi Pengiriman'),
                                      ),
                                    if (order['status'] == 'dikirim')
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => _updateStatus(
                                          order['id'].toString(),
                                          'selesai',
                                        ),
                                        icon: const Icon(Icons.done_all),
                                        label: const Text('Selesaikan Pesanan'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu pembayaran':
        return const Color(0xFFFF9800); // Orange
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
