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

class _OrderHistoryState extends State<OrderHistory>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;
  final String baseImageUrl = 'http://192.168.1.19:3000/uploads/pembayaran/';
  late AnimationController _animationController;

  // Clean modern colors
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color iconPurple = Color(0xFF8B5CF6);
  static const Color iconPink = Color(0xFFEC4899);
  static const Color iconGreen = Color(0xFF10B981);
  static const Color iconOrange = Color(0xFFF59E0B);
  static const Color iconBlue = Color(0xFF3B82F6);
  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusOrange = Color(0xFFF59E0B);
  static const Color statusBlue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fetchOrderHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        Uri.parse('http://10.251.130.195:3000/api/pesanan'),
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
        _animationController.forward();
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
      backgroundColor: backgroundGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            onPressed: _fetchOrderHistory,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryPurple, primaryPink],
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Riwayat Pemesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: _orders.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> order = entry.value;

          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ),
                )),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: _buildOrderCard(order),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Memuat riwayat...',
              style: TextStyle(
                color: textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: statusRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchOrderHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: textMuted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Riwayat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Riwayat pemesanan akan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isSelesai = (order['status']?.toString().toLowerCase() == 'selesai');
    final status = order['status']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelesai
              ? () => _navigateToFeedback(order['id_pemesanan'])
              : null,
          borderRadius: BorderRadius.circular(20),
          splashColor: primaryPink.withOpacity(0.1),
          highlightColor: primaryPink.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(order, status),
                  const SizedBox(height: 24),
                  _buildOrderDetails(order),
                  if (isSelesai) _buildFeedbackPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order, String status) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: iconPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order['id_pemesanan'] ?? '-'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order['nama_unit'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusData = _getStatusData(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusData['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    return Column(
      children: [
        _buildDetailRow(
          Icons.person_outline_rounded,
          'Operator',
          order['nama_operator'] ?? '-',
          iconPink,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          Icons.calendar_today_outlined,
          'Mulai',
          _formatDate(order['tanggal_mulai']),
          iconGreen,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          Icons.event_outlined,
          'Selesai',
          _formatDate(order['tanggal_selesai']),
          iconOrange,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          Icons.location_on_outlined,
          'Lokasi',
          order['lokasi_pengiriman'] ?? '-',
          iconPurple,
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          Icons.business_outlined,
          'Perusahaan',
          order['nama_perusahaan'] ?? '-',
          iconBlue,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackPrompt() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryPink.withOpacity(0.1),
            primaryPurple.withOpacity(0.1)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryPink.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: primaryPink,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tap untuk memberikan feedback',
              style: TextStyle(
                color: primaryPink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: primaryPink,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Map<String, dynamic> _getStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return {'color': statusGreen};
      case 'disewa':
        return {'color': statusRed};
      case 'menunggu pembayaran':
        return {'color': statusOrange};
      case 'menunggu konfirmasi':
        return {'color': statusBlue};
      case 'dikirim':
        return {'color': statusGreen};
      case 'selesai':
        return {'color': primaryPink};
      default:
        return {'color': textMuted};
    }
  }

  Future<void> _navigateToFeedback(dynamic idPemesanan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFeedback(idPemesanan: idPemesanan),
      ),
    );
  }
}
