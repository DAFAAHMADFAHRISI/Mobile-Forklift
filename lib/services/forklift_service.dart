import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class ForkliftService {
  static const String baseUrl = 'http://localhost:3000/api/unit';
  static const String authUrl = 'http://localhost:3000/api/auth/login';

  // Fungsi login admin
  static Future<bool> loginAdmin(String username, String password) async {
    final response = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'username': username, 'password': password}),
    );
    print('LOGIN RESPONSE: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['data'] != null ? data['data']['token'] : null;
      if (data['status'] == true && token != null) {
        if (kIsWeb) {
          html.window.localStorage['token'] = token;
          print('TOKEN DISIMPAN: $token');
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        return true;
      }
    }
    return false;
  }

  static String? getTokenSync() {
    if (kIsWeb) {
      return html.window.localStorage['token'];
    }
    return null;
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['token'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }
  }

  // Get all forklifts
  static Future<List<Map<String, dynamic>>> getAllForklifts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        throw Exception(data['message']);
      }
      throw Exception('Failed to load forklifts');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get available forklifts
  static Future<List<Map<String, dynamic>>> getAvailableForklifts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/available'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        throw Exception(data['message']);
      }
      throw Exception('Failed to load available forklifts');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Add new forklift (web: JSON, mobile: multipart)
  static Future<bool> addForklift(
      Map<String, String> data, File? imageFile) async {
    final token = kIsWeb
        ? html.window.localStorage['token']
        : (await SharedPreferences.getInstance()).getString('token');
    print('TOKEN: $token');
    if (kIsWeb) {
      // WEB: Kirim data sebagai JSON ke endpoint /store (tanpa gambar)
      final response = await http.post(
        Uri.parse('$baseUrl/store'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final respData = json.decode(response.body);
        return respData['status'] == true;
      }
      return false;
    } else {
      // MOBILE: Kirim data dan gambar pakai MultipartRequest ke /store
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/store'));
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      data.forEach((key, value) => request.fields[key] = value);
      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('gambar', imageFile.path));
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final respData = json.decode(respStr);
        return respData['status'] == true;
      }
      return false;
    }
  }

  // Update forklift (web: JSON ke /edit/:id, mobile: multipart ke /edit/:id)
  static Future<bool> editForklift(
      int id, Map<String, String> data, File? imageFile) async {
    final token = kIsWeb
        ? html.window.localStorage['token']
        : (await SharedPreferences.getInstance()).getString('token');
    print('TOKEN: $token');
    final response = await http.put(
      Uri.parse('$baseUrl/edit/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final respData = json.decode(response.body);
      return respData['status'] == true;
    }
    return false;
  }

  // Delete forklift
  static Future<bool> deleteForklift(int id) async {
    final token = kIsWeb
        ? html.window.localStorage['token']
        : (await SharedPreferences.getInstance()).getString('token');
    print('TOKEN: $token');
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == true;
    }
    return false;
  }
}
