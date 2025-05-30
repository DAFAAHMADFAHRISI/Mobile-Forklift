import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import 'admin_theme.dart';

class LogTransaksi extends StatefulWidget {
  const LogTransaksi({super.key});

  @override
  State<LogTransaksi> createState() => _LogTransaksiState();
}

class _LogTransaksiState extends State<LogTransaksi> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.25:3000/api/log-transaksi/'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        setState(() {
          _logs = data.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id_log'],
              'tanggal': item['waktu'],
              'tipe': item['status_transaksi'],
              'deskripsi': item['keterangan'],
              'detail': {
                'ID Pemesanan': item['id_pemesanan'],
                'ID User': item['id_user'],
              },
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal mengambil data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> deleteLog(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }
      final response = await http.delete(
        Uri.parse('http://192.168.1.25:3000/api/log-transaksi/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == true) {
        setState(() {
          _logs.removeWhere((log) => log['id'] == id);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log berhasil dihapus')),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? 'Gagal menghapus log')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Color getBadgeColor(String tipe) {
    switch (tipe) {
      case 'status_dikirim':
        return Colors.blue;
      case 'status_dibayar':
        return Colors.green;
      case 'status_dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Log Transaksi', style: AdminTheme.appBarTitle),
          backgroundColor: AdminTheme.primaryDark,
          elevation: 0),
      body: Container(
        decoration: AdminTheme.backgroundGradient,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(_error!, style: TextStyle(color: Colors.white)))
                : _logs.isEmpty
                    ? const Center(
                        child: Text('Belum ada log transaksi.',
                            style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Container(
                            decoration: AdminTheme.cardBox,
                            margin: const EdgeInsets.only(bottom: 18),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: getBadgeColor(log['tipe']),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            log['tipe']
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.redAccent),
                                          tooltip: 'Hapus log',
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Konfirmasi'),
                                                content: const Text(
                                                    'Yakin ingin menghapus log ini?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx)
                                                            .pop(false),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(ctx)
                                                            .pop(true),
                                                    child: const Text('Hapus',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await deleteLog(log['id']);
                                            }
                                          },
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              formatDate(log['tanggal']),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      log['deskripsi'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Detail:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...log['detail']
                                        .entries
                                        .map<Widget>((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, bottom: 2),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${entry.key}: ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              '${entry.value}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
