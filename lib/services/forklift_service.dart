import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ForkliftService {
  static const String baseUrl = 'http://localhost:3000/api/unit';
  static const String authUrl = 'http://localhost:3000/api/auth/login';

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
      Map<String, String> data, File? imageFile) async {
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

    // Tambahkan file jika ada
    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('gambar', imageFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('ADD RESPONSE: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      final respData = json.decode(response.body);
      return respData['status'] == true;
    }
    return false;
  }

  // Update forklift
  static Future<bool> editForklift(
      int id, Map<String, String> data, File? imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('TOKEN: $token');

    var uri = Uri.parse('$baseUrl/edit/$id');
    var request = http.MultipartRequest('PUT', uri);

    // Tambahkan header Authorization dengan format yang benar
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
    }

    // Hanya field yang didukung backend
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

    // Tambahkan file jika ada
    if (imageFile != null) {
      final extension = imageFile.path.split('.').last.toLowerCase();
      print('File extension: $extension');
      print('File path: ${imageFile.path}');
      print('File exists: ${await imageFile.exists()}');
      print('File size: ${await imageFile.length()} bytes');

      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw Exception('Hanya file JPEG, JPG, dan PNG yang diperbolehkan');
      }
      final fileName = imageFile.path.split('/').last;
      print('Uploading file: $fileName');
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          imageFile.path,
          filename: fileName,
        ),
      );
    }

    try {
      print('Sending request to: \\${uri.toString()}');
      print('Request headers: \\${request.headers}');
      print('Request fields: \\${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('EDIT RESPONSE: \\${response.statusCode} \\${response.body}');

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);
        return respData['status'] == true;
      } else {
        print(
            'EDIT ERROR: Status code: \\${response.statusCode}, Body: \\${response.body}');
      }
      return false;
    } on SocketException catch (e) {
      print('SocketException in editForklift: $e');
      return false;
    } catch (e) {
      print('Error in editForklift: $e');
      return false;
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
