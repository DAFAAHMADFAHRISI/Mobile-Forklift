import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/midtrans_notification.dart';
import 'dart:async';

class PesananService {
  static const String baseUrl = 'http://192.168.1.10:3000/api/pesanan';

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

  static Future<Map<String, dynamic>?> submitPesanan({
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
      Uri.parse('http://192.168.1.10:3000/api/pesanan/store'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
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
      return data;
    }
    return null;
  }

  Future<void> handleMidtransNotification(
      MidtransNotification notification) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://35bd-2001-448a-5020-bad7-e196-d230-a536-7b75.ngrok-free.app/api/payment/notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(notification.toJson()),
      );

      if (response.statusCode == 200) {
        print('Notifikasi berhasil diproses');
      } else {
        print('Gagal memproses notifikasi: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Polling status pembayaran
  Timer? _timer;

  void startPolling(
      String orderId, Function(MidtransNotification) onSuccess) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('http://192.168.1.10:3000/api/payment/status/$orderId'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Cek status pembayaran dari response backend
          String status = '';
          if (data['data'] != null && data['data']['status'] != null) {
            status = data['data']['status'];
          } else if (data['transaction_status'] != null) {
            status = data['transaction_status'];
          }
          if (status == 'success' || status == 'settlement') {
            final notification = MidtransNotification.fromJson({
              'transaction_status': status,
              'order_id': data['data']?['order_id'] ?? data['order_id'] ?? '',
              'fraud_status':
                  data['data']?['fraud_status'] ?? data['fraud_status'] ?? '',
              'status_code':
                  data['data']?['status_code'] ?? data['status_code'] ?? '',
              'gross_amount': data['data']?['jumlah']?.toString() ??
                  data['gross_amount'] ??
                  '',
              'payment_type':
                  data['data']?['metode'] ?? data['payment_type'] ?? '',
              'transaction_id': data['data']?['id_pembayaran']?.toString() ??
                  data['transaction_id'] ??
                  '',
              'signature_key': '',
              'simulate': '',
            });
            onSuccess(notification);
            stopPolling();
          }
        }
      } catch (e) {
        print('Error polling payment status: $e');
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }
}
