import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Key untuk menyimpan token di SharedPreferences
  static const String _tokenKey = 'token';

  /// Fungsi untuk mendapatkan token yang tersimpan
  /// @return String token jika ada, null jika tidak ada
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Fungsi untuk menyimpan token
  /// @param token Token yang akan disimpan
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Fungsi untuk menghapus token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Fungsi untuk mengecek apakah user sudah login
  /// @return boolean true jika sudah login, false jika belum
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
