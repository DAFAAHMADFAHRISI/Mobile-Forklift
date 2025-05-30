import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:forklift_mobile/screens/user/feedback.dart';
import '../../services/auth_service.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;
  final String baseImageUrl = 'http://192.168.1.19:3000/uploads/pembayaran/';

  static const Color darkNavy = Color(0xFF1A1D29);
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color materialPink = Color(0xFFE91E63);
  static const Color materialPurple = Color(0xFF9C27B0);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);
  static const Color accentGray = Color(0xFFBDBDBD);
  static const Color placeholderGray = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Token tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse('http://192.168.1.25:3000/api/pesanan'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pesanan = data['data'] as List<dynamic>;
        setState(() {
          _orders =
              pesanan.map((item) => Map<String, dynamic>.from(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Riwayat Pemesanan',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: deepPurple,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Center(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isSelesai =
                          (order['status']?.toString().toLowerCase() ==
                              'selesai');
                      return InkWell(
                        onTap: isSelesai
                            ? () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserFeedback(
                                        idPemesanan: order['id_pemesanan']),
                                  ),
                                );
                              }
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        splashColor:
                            isSelesai ? materialPink.withOpacity(0.1) : null,
                        child: Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.only(bottom: 20),
                          color: isSelesai ? Colors.white : lightGray,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.receipt_long,
                                            color: deepPurple, size: 22),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Order #${order['id_pemesanan'] ?? '-'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: darkNavy,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            order['status'] ?? ''),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            order['status']
                                                        ?.toString()
                                                        .toLowerCase() ==
                                                    'selesai'
                                                ? Icons.check_circle
                                                : order['status']
                                                            ?.toString()
                                                            .toLowerCase() ==
                                                        'disewa'
                                                    ? Icons.block
                                                    : Icons.info,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (order['status'] ?? '-')
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Icon(Icons.local_shipping,
                                        color: materialPurple, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Unit: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: darkNavy)),
                                    Text(order['nama_unit'] ?? '-',
                                        style: TextStyle(color: darkNavy)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: materialPink, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Operator: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: darkNavy)),
                                    Text(order['nama_operator'] ?? '-',
                                        style: TextStyle(color: darkNavy)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month,
                                        color: accentGray, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Mulai: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: darkNavy)),
                                    Text(order['tanggal_mulai'] ?? '-',
                                        style: TextStyle(color: darkNavy)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: accentGray, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Selesai: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: darkNavy)),
                                    Text(order['tanggal_selesai'] ?? '-',
                                        style: TextStyle(color: darkNavy)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: materialPink, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Lokasi: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: darkNavy)),
                                    Text(order['lokasi_pengiriman'] ?? '-',
                                        style: TextStyle(color: darkNavy)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.business,
                                        color: materialPurple, size: 18),
                                    const SizedBox(width: 6),
                                    Text('Perusahaan: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: darkNavy)),
                                    Text(order['nama_perusahaan'] ?? '-',
                                        style: TextStyle(color: darkNavy)),
                                  ],
                                ),
                                if (isSelesai)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Center(
                                      child: Text(
                                        'Tap untuk beri feedback',
                                        style: TextStyle(
                                          color: materialPink,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return accentGreen;
      case 'disewa':
        return accentRed;
      case 'menunggu pembayaran':
        return materialPink;
      case 'menunggu konfirmasi':
        return deepPurple;
      case 'dikirim':
        return accentGreen;
      case 'selesai':
        return materialPink;
      default:
        return accentGray;
    }
  }
}
