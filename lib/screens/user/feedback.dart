import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';

const Color darkNavy = Color(0xFF1A1D29);
const Color deepPurple = Color(0xFF2D1B69);
const Color materialPink = Color(0xFFE91E63);
const Color materialPurple = Color(0xFF9C27B0);
const Color lightGray = Color(0xFFF8F9FA);
const Color accentGreen = Color(0xFF4CAF50);
const Color accentRed = Color(0xFFF44336);
const Color accentGray = Color(0xFFBDBDBD);
const Color placeholderGray = Color(0xFFF5F5F5);

class UserFeedback extends StatefulWidget {
  final int idPemesanan;
  const UserFeedback({super.key, required this.idPemesanan});

  @override
  State<UserFeedback> createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  final _formKey = GlobalKey<FormState>();
  final _komentarController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;
  bool _success = false;
  String? _errorMsg;

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: deepPurple,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 18),
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long, color: deepPurple, size: 22),
                          const SizedBox(width: 10),
                          Text('ID Pemesanan: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: deepPurple)),
                          Text('${widget.idPemesanan}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: materialPink, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Rating',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => IconButton(
                                icon: Icon(
                                  Icons.star,
                                  size: 38,
                                  color: index < _rating
                                      ? materialPink
                                      : accentGray,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.comment,
                                  color: materialPurple, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Komentar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _komentarController,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar Anda di sini...',
                              filled: true,
                              fillColor: placeholderGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentGray),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: accentGray.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: materialPink, width: 2),
                              ),
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Komentar harus diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: accentRed, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMsg!,
                                    style: TextStyle(
                                        color: accentRed,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_success)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: accentGreen, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('Feedback berhasil dikirim!',
                                    style: TextStyle(
                                        color: accentGreen,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  _rating > 0) {
                                setState(() {
                                  _isLoading = true;
                                  _errorMsg = null;
                                  _success = false;
                                });
                                final token = await AuthService.getToken();
                                if (token == null) {
                                  setState(() {
                                    _isLoading = false;
                                    _errorMsg =
                                        'Token tidak ditemukan. Silakan login ulang.';
                                  });
                                  return;
                                }
                                final response = await http.post(
                                  Uri.parse(
                                      'http://10.0.0.8:3000/api/feedback/store'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $token',
                                  },
                                  body: json.encode({
                                    'id_pemesanan': widget.idPemesanan,
                                    'rating': _rating,
                                    'komentar': _komentarController.text,
                                  }),
                                );
                                if (response.statusCode == 201) {
                                  setState(() {
                                    _isLoading = false;
                                    _success = true;
                                  });
                                  await Future.delayed(
                                      const Duration(milliseconds: 900));
                                  if (mounted) Navigator.pop(context);
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                    _errorMsg =
                                        'Gagal mengirim feedback: \n${response.body}';
                                  });
                                }
                              } else if (_rating == 0) {
                                setState(() {
                                  _errorMsg = 'Pilih rating terlebih dahulu';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: materialPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        shadowColor: materialPink.withOpacity(0.3),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Kirim Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
