import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'payment_webview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/midtrans_notification.dart';
import '../../services/pesanan_service.dart';

class Pembayaran extends StatefulWidget {
  final int jumlah;
  final String metode;
  final DateTime tanggalPembayaran;
  final int? idPemesanan;

  const Pembayaran({
    Key? key,
    required this.jumlah,
    required this.metode,
    required this.tanggalPembayaran,
    this.idPemesanan,
  }) : super(key: key);

  @override
  State<Pembayaran> createState() => _PembayaranState();
}

class _PembayaranState extends State<Pembayaran> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jumlahController;
  late TextEditingController _metodeController;
  late TextEditingController _tanggalController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  XFile? _buktiPembayaran;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _canPay = true;
  String? _orderError;
  final PesananService _pesananService = PesananService();
  MidtransNotification? _notification;
  String _status = 'Menunggu konfirmasi pembayaran...';

  // Enhanced color scheme
  static const Color darkNavy = Color(0xFF1A1D29);
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color materialPink = Color(0xFFE91E63);
  static const Color materialPurple = Color(0xFF9C27B0);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _validateOrderOwnership();
  }

  void _initializeControllers() {
    _jumlahController = TextEditingController(text: widget.jumlah.toString());
    _metodeController = TextEditingController(text: widget.metode);
    _tanggalController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.tanggalPembayaran));
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  Future<void> _validateOrderOwnership() async {
    // Ambil id_user login
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('id_user');
    // TODO: Ganti bagian ini jika kamu punya cara ambil data order by id_pemesanan
    // Misal: fetch detail order dari API, lalu cek id_user-nya
    // Untuk contoh ini, diasumsikan id_user order = idUser (karena tidak ada data order detail)
    // Jika tidak sama, set _canPay = false dan tampilkan pesan error
    // ---
    // Contoh: jika id_pemesanan bukan milik user login, blokir pembayaran
    // (Kamu bisa ganti logika ini sesuai kebutuhan)
    // ---
    // Jika kamu punya fungsi getOrderById, gunakan di sini
    // final order = await OrderService.getOrderById(widget.idPemesanan);
    // if (order['id_user'] != idUser) { ... }
    // ---
    // Untuk sekarang, asumsikan order valid (atau tambahkan pengecekan sesuai kebutuhanmu)
    // Jika ingin simulasi error:
    // if (widget.idPemesanan != null && widget.idPemesanan != idUser) {
    //   setState(() {
    //     _canPay = false;
    //     _orderError = 'Access denied. You can only access your own orders.';
    //   });
    // }
    // ---
    // Jika tidak ada error:
    setState(() {
      _canPay = true;
      _orderError = null;
    });
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _metodeController.dispose();
    _tanggalController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fadeController.dispose();
    _pesananService.stopPolling();
    super.dispose();
  }

  Future<void> _createTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final idPemesanan = widget.idPemesanan ?? 1;
      final url =
          Uri.parse('http://192.168.1.25:3000/api/payment/create-transaction');
      final body = {
        "id_pemesanan": idPemesanan.toString(),
        "jumlah": int.tryParse(_jumlahController.text) ?? 0,
        "metode": _metodeController.text,
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text
      };
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['status'] == true) {
        await _handlePaymentResponse(data);
      } else {
        _showErrorMessage(
            data['message'] ?? 'Gagal membuat transaksi payment gateway');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePaymentResponse(Map<String, dynamic> data) async {
    print('DEBUG payment response: $data');
    String? paymentUrl;
    String? orderIdMidtrans;

    if (data['data'] != null) {
      paymentUrl = data['data']['redirect_url'];
      orderIdMidtrans = data['data']['order_id'];
    }

    if (orderIdMidtrans != null && orderIdMidtrans.isNotEmpty) {
      _pesananService.startPolling(orderIdMidtrans, (notification) {
        setState(() {
          _notification = notification;
          _status = 'Pembayaran berhasil untuk order: ${notification.orderId}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Pembayaran sukses! kembali ke halaman Riwayat Pemesanan...',
                textAlign: TextAlign.center,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: successGreen,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/order-history');
        });
      });
    } else {
      _showErrorMessage(
          'Gagal mendapatkan orderId dari Midtrans. Tidak bisa melakukan polling status pembayaran.\nResponse: $data');
    }

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      if (kIsWeb) {
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showErrorMessage('Tidak bisa membuka link pembayaran: $paymentUrl');
        }
      } else {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebView(paymentUrl: paymentUrl!),
            ),
          );
        }
      }
    } else {
      _showErrorMessage(
          'Transaksi berhasil dibuat, tapi link pembayaran tidak ditemukan');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              darkNavy,
              deepPurple,
              materialPurple.withOpacity(0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildPaymentForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Enhanced back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),

          // Enhanced title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pembayaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Lengkapi data untuk melanjutkan pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Amount badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [materialPink, materialPurple],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: materialPink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Rp ${NumberFormat('#,###').format(widget.jumlah)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Payment summary card
              _buildPaymentSummaryCard(),
              const SizedBox(height: 24),

              // Customer information card
              _buildCustomerInfoCard(),
              const SizedBox(height: 32),

              // Payment button
              _buildPaymentButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      materialPink.withOpacity(0.3),
                      materialPurple.withOpacity(0.3)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ringkasan Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow('Jumlah Pembayaran',
              'Rp ${NumberFormat('#,###').format(widget.jumlah)}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Metode Pembayaran', widget.metode),
          const SizedBox(height: 12),
          _buildSummaryRow(
              'Tanggal',
              DateFormat('dd MMMM yyyy', 'id_ID')
                  .format(widget.tanggalPembayaran)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      materialPink.withOpacity(0.3),
                      materialPurple.withOpacity(0.3)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Customer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedTextField(
                  controller: _firstNameController,
                  label: 'Nama Depan',
                  icon: Icons.person,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama depan harus diisi'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedTextField(
                  controller: _lastNameController,
                  label: 'Nama Belakang',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama belakang harus diisi'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email harus diisi';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _phoneController,
            label: 'No. HP',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'No. HP harus diisi';
              if (v.length < 10) return 'No. HP minimal 10 digit';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: materialPink,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: materialPink,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: materialPink,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [successGreen, Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: successGreen.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: (!_canPay || _isLoading) ? null : _createTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Memproses...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Bayar via Payment Gateway',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
          if (_orderError != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _orderError!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
