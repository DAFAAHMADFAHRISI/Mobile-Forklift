import 'package:flutter/material.dart';
import 'package:forklift_mobile/screens/auth/masuk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureKonfirmasiPassword = true;

  // Define custom colors
  static const Color darkNavy = Color(0xFF1A1D29);
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color materialPink = Color(0xFFE91E63);
  static const Color materialPurple = Color(0xFF9C27B0);
  static const Color lightGray = Color(0xFFF8F9FA);

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text(
          'Daftar Akun',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: darkNavy,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              darkNavy,
              deepPurple,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/Logo.jpg',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.13),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildTextField(_namaController, 'Nama Lengkap',
                          Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _emailController, 'Email', Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildTextField(_usernameController, 'Username',
                          Icons.account_circle_outlined),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _passwordController, 'Kata Sandi', Icons.lock_outline,
                          obscureText: true),
                      const SizedBox(height: 16),
                      _buildTextField(_konfirmasiPasswordController,
                          'Konfirmasi Kata Sandi', Icons.lock_outline,
                          obscureText: true),
                      const SizedBox(height: 16),
                      _buildTextField(
                          _noHpController, 'Nomor HP', Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField(_alamatController, 'Alamat',
                          Icons.location_on_outlined,
                          maxLines: 3),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: materialPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final response = await http.post(
                                  Uri.parse(
                                    'http://10.251.130.195:3000/API/auth/register',
                                  ),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'nama': _namaController.text.trim(),
                                    'email': _emailController.text.trim(),
                                    'username': _usernameController.text.trim(),
                                    'password': _passwordController.text.trim(),
                                    'no_hp': _noHpController.text.trim(),
                                    'alamat': _alamatController.text.trim(),
                                  }),
                                );
                                final data = jsonDecode(response.body);
                                setState(() {
                                  _isLoading = false;
                                });
                                if (response.statusCode == 201 &&
                                    data['status'] == true) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registrasi berhasil, silakan login',
                                        ),
                                      ),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Masuk(),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        data['message'] ?? 'Registrasi gagal',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Terjadi kesalahan: $e'),
                                  ),
                                );
                              }
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Masuk()),
                        );
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: materialPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      cursorColor: materialPink,
      obscureText: label == 'Kata Sandi'
          ? _obscurePassword
          : label == 'Konfirmasi Kata Sandi'
              ? _obscureKonfirmasiPassword
              : obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.13)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: materialPink, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: (label == 'Kata Sandi' || label == 'Konfirmasi Kata Sandi')
            ? IconButton(
                icon: Icon(
                  (label == 'Kata Sandi'
                          ? _obscurePassword
                          : _obscureKonfirmasiPassword)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    if (label == 'Kata Sandi') {
                      _obscurePassword = !_obscurePassword;
                    } else {
                      _obscureKonfirmasiPassword = !_obscureKonfirmasiPassword;
                    }
                  });
                },
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) {
        if (label == 'Nama Lengkap' && (value == null || value.isEmpty)) {
          return 'Nama lengkap harus diisi';
        }
        if (label == 'Email') {
          if (value == null || value.isEmpty) return 'Email harus diisi';
          if (!value.contains('@')) return 'Email tidak valid';
        }
        if (label == 'Username' && (value == null || value.isEmpty)) {
          return 'Username harus diisi';
        }
        if (label == 'Kata Sandi') {
          if (value == null || value.isEmpty) return 'Kata sandi harus diisi';
          if (value.length < 6) return 'Kata sandi minimal 6 karakter';
        }
        if (label == 'Konfirmasi Kata Sandi') {
          if (value == null || value.isEmpty)
            return 'Konfirmasi kata sandi harus diisi';
          if (value != _passwordController.text)
            return 'Kata sandi tidak cocok';
        }
        if (label == 'Nomor HP' && (value == null || value.isEmpty)) {
          return 'Nomor HP harus diisi';
        }
        if (label == 'Alamat' && (value == null || value.isEmpty)) {
          return 'Alamat harus diisi';
        }
        return null;
      },
    );
  }
}
