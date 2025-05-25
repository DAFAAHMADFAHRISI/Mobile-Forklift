import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';

class DaftarOperator extends StatefulWidget {
  const DaftarOperator({Key? key}) : super(key: key);

  @override
  State<DaftarOperator> createState() => _DaftarOperatorState();
}

class _DaftarOperatorState extends State<DaftarOperator> {
  List<dynamic> _operators = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchOperators();
  }

  Future<void> fetchOperators() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Token tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/operator'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        setState(() {
          _operators = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Gagal mengambil data operator';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Daftar Operator'),
          backgroundColor: Color(0xFFFFA500)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _operators.length,
                  itemBuilder: (context, index) {
                    final operator = _operators[index];
                    return Card(
                      child: ListTile(
                        title: Text(operator['nama_operator'] ?? '-'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No HP: ${operator['no_hp'] ?? '-'}'),
                            Text('Status: ${operator['status'] ?? '-'}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context, operator);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
