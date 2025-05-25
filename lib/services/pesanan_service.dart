import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PesananService {
  static const String baseUrl = 'http://localhost:3000/api/pesanan';

  // Get all pesanan (for admin) or user's pesanan
  static Future<List<Map<String, dynamic>>> getPesanan(String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          // Mapping field dari API ke field yang digunakan di UI
          return List<Map<String, dynamic>>.from(data['data'].map((order) => {
                'id': order['id_pemesanan'],
                'nama_user': order['nama_user'],
                'nama_unit': order['nama_unit'],
                'nama_operator': order['nama_operator'],
                'tanggal_mulai': order['tanggal_mulai'],
                'tanggal_selesai': order['tanggal_selesai'],
                'lokasi_pengiriman': order['lokasi_pengiriman'],
                'nama_perusahaan': order['nama_perusahaan'],
                'status': order['status'],
                'total_harga': order['total_harga'], // jika ada di API
              }));
        }
        throw Exception(data['message']);
      }
      throw Exception('Failed to load pesanan');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update pesanan status (admin only)
  static Future<Map<String, dynamic>> updateStatus(
    String token,
    String id,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          return data['data'];
        }
        throw Exception(data['message']);
      }
      throw Exception('Failed to update status');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete pesanan (admin only)
  static Future<bool> deletePesanan(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'];
      }
      throw Exception('Failed to delete pesanan');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> submitPesanan({
    required int idUser,
    required int idUnit,
    required int idOperator,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String lokasiPengiriman,
    required String namaPerusahaan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/pesanan/store'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'id_user': idUser,
        'id_unit': idUnit,
        'id_operator': idOperator,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'lokasi_pengiriman': lokasiPengiriman,
        'nama_perusahaan': namaPerusahaan,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['status'] == true;
    }
    return false;
  }
}
