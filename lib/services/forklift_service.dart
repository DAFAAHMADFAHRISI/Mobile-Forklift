import 'dart:convert';
import 'package:http/http.dart' as http;

class ForkliftService {
  static const String baseUrl = 'http://localhost:3000/api/unit';

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
  static Future<Map<String, dynamic>> addForklift(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/store'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return responseData['data'];
        }
        throw Exception(responseData['message']);
      }
      throw Exception('Failed to add forklift');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update forklift
  static Future<Map<String, dynamic>> updateForklift(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return responseData['data'];
        }
        throw Exception(responseData['message']);
      }
      throw Exception('Failed to update forklift');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete forklift
  static Future<bool> deleteForklift(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == true;
      }
      throw Exception('Failed to delete forklift');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
