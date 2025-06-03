import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ForkliftService {
  static const String baseUrl = 'http://10.251.130.195:3000/api/unit';
  static const String authUrl = 'http://10.251.130.195:3000/api/auth/login';

  // Fungsi login untuk semua user (admin dan user biasa)
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
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
      final responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        final data = responseData['data'];
        final token = data['token'];
        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return responseData;
      }
      throw Exception(responseData['message']);
    }

    return {
      'status': false,
      'message': 'Login gagal! Username/password salah.'
    };
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

  // Add new forklift
  static Future<bool> addForklift(
      Map<String, String> data, dynamic imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
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

    // Handle image upload for both web and mobile
    if (imageFile != null) {
      if (kIsWeb) {
        // Web platform
        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.name;
        final mimeType = _getMimeType(fileName);

        request.files.add(
          http.MultipartFile.fromBytes(
            'gambar',
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else {
        // Mobile platform
        if (imageFile is File) {
          request.files.add(
            await http.MultipartFile.fromPath('gambar', imageFile.path),
          );
        }
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('ADD RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);
        return respData['status'] == true;
      }
      throw Exception('Failed to add forklift: ${response.body}');
    } catch (e) {
      print('Error in addForklift: $e');
      throw Exception('Failed to add forklift: $e');
    }
  }

  // Update forklift
  static Future<bool> editForklift(
      int id, Map<String, String> data, dynamic imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('TOKEN: $token');

    var uri = Uri.parse('$baseUrl/edit/$id');
    var request = http.MultipartRequest('PUT', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }

    final allowedFields = [
      'kapasitas',
      'nama_unit',
      'harga_per_jam',
      'deskripsi'
    ];
    data.forEach((key, value) {
      if (allowedFields.contains(key)) {
        request.fields[key] = value;
      }
    });

    // Handle image upload for both web and mobile
    if (imageFile != null) {
      if (kIsWeb) {
        // Web platform
        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.name;
        final mimeType = _getMimeType(fileName);

        request.files.add(
          http.MultipartFile.fromBytes(
            'gambar',
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      } else {
        // Mobile platform
        if (imageFile is File) {
          final extension = imageFile.path.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png'].contains(extension)) {
            throw Exception('Hanya file JPEG, JPG, dan PNG yang diperbolehkan');
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              'gambar',
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          );
        }
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('EDIT RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);
        return respData['status'] == true;
      }
      throw Exception('Failed to edit forklift: ${response.body}');
    } catch (e) {
      print('Error in editForklift: $e');
      throw Exception('Failed to edit forklift: $e');
    }
  }

  // Helper function to get MIME type
  static String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Delete forklift
  static Future<bool> deleteForklift(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
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
