import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:cross_file/cross_file.dart'; // Untuk XFile

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

  // Add new forklift (web & mobile: multipart/form-data)
  static Future<bool> addForklift(
      Map<String, String> data, dynamic imageFile) async {
    final token = kIsWeb
        ? html.window.localStorage['token']
        : (await SharedPreferences.getInstance()).getString('token');
    print('TOKEN: $token');

    var uri = Uri.parse('$baseUrl/store');
    var request = http.MultipartRequest('POST', uri);

    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    // Hanya field yang didukung backend
    final allowedFields = ['kapasitas', 'nama_unit', 'harga_per_jam'];
    data.forEach((key, value) {
      if (allowedFields.contains(key)) {
        request.fields[key] = value;
      }
    });

    // Tambahkan file jika ada
    if (imageFile != null) {
      if (kIsWeb) {
        // Pastikan imageFile adalah XFile dari image_picker_web
        if (imageFile.runtimeType.toString() == 'XFile') {
          var fileName = 'image.jpg';
          try {
            fileName = (imageFile as dynamic).name ?? 'image.jpg';
          } catch (_) {}
          final bytes = await imageFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'gambar',
            bytes,
            filename: fileName,
          ));
        } else {
          // Jika bukan XFile, skip file
          print('Web: imageFile harus XFile dari image_picker_web');
        }
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('gambar', imageFile.path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('ADD RESPONSE: \\${response.statusCode} \\${response.body}');

    if (response.statusCode == 200) {
      final respData = json.decode(response.body);
      return respData['status'] == true;
    }
    return false;
  }

  // Update forklift (web: multipart ke /edit/:id)
  // Pastikan hanya field yang didukung backend: kapasitas, nama_unit, harga_per_jam
  static Future<bool> editForklift(
      int id, Map<String, String> data, dynamic imageFile) async {
    final token = kIsWeb
        ? html.window.localStorage['token']
        : (await SharedPreferences.getInstance()).getString('token');
    print('TOKEN: $token');

    var uri = Uri.parse('$baseUrl/edit/$id');
    var request = http.MultipartRequest('PUT', uri);

    // Set header Authorization
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    // Hanya field yang didukung backend
    final allowedFields = ['kapasitas', 'nama_unit', 'harga_per_jam'];
    data.forEach((key, value) {
      if (allowedFields.contains(key)) {
        request.fields[key] = value;
      }
    });

    // Tambahkan file jika ada
    if (imageFile != null) {
      if (kIsWeb) {
        if (imageFile is XFile) {
          var fileName = imageFile.name;
          final bytes = await imageFile.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'gambar',
            bytes,
            filename: fileName,
          ));
        } else {
          print('Web: imageFile harus XFile dari image_picker_web');
        }
      } else {
        request.files
            .add(await http.MultipartFile.fromPath('gambar', imageFile.path));
      }
    }

    // Kirim request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('EDIT RESPONSE: \\${response.statusCode} \\${response.body}');

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
