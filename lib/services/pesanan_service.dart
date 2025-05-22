import 'dart:convert';
import 'package:http/http.dart' as http;

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
          return List<Map<String, dynamic>>.from(data['data']);
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
}
