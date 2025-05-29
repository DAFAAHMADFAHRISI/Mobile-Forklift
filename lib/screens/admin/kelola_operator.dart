import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/forklift_service.dart';

class KelolaOperator extends StatefulWidget {
  const KelolaOperator({super.key});

  @override
  State<KelolaOperator> createState() => _KelolaOperatorState();
}

class _KelolaOperatorState extends State<KelolaOperator> {
  List<Map<String, dynamic>> _operators = [];
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
      final token = await ForkliftService.getToken();
      final response = await http.get(
        Uri.parse('http://192.168.1.12:3000/api/operator'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          List<dynamic> operators = data['data'];
          setState(() {
            _operators = operators
                .map<Map<String, dynamic>>((op) => {
                      'id': op['id_operator'],
                      'nama_operator': op['nama_operator'],
                      'status': op['status'],
                      'no_hp': op['no_hp'],
                    })
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Gagal mengambil data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Gagal mengambil data: ${response.statusCode}';
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

  void _showAddOperatorDialog() {
    final _formKey = GlobalKey<FormState>();
    String namaOperator = '';
    String noHp = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Operator'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nama Operator'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => namaOperator = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'No HP'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => noHp = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context);
                  await _addOperator(namaOperator, noHp);
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addOperator(String namaOperator, String noHp) async {
    setState(() => _isLoading = true);
    try {
      final token = await ForkliftService.getToken();
      final response = await http.post(
        Uri.parse('http://192.168.1.12:3000/api/operator/store'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nama_operator': namaOperator,
          'no_hp': noHp,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['status'] == true) {
        await fetchOperators();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operator berhasil ditambahkan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal menambah operator')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editOperator(Map<String, dynamic> operator) async {
    final _formKey = GlobalKey<FormState>();
    String namaOperator = operator['nama_operator'];
    String noHp = operator['no_hp'];
    String status = operator['status'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Operator'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: namaOperator,
                  decoration: InputDecoration(labelText: 'Nama Operator'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => namaOperator = value!,
                ),
                TextFormField(
                  initialValue: noHp,
                  decoration: InputDecoration(labelText: 'No HP'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => noHp = value!,
                ),
                TextFormField(
                  initialValue: status,
                  decoration: InputDecoration(labelText: 'Status'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => status = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context);
                  await _updateOperator(
                      operator['id'], namaOperator, noHp, status);
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateOperator(
      int id, String namaOperator, String noHp, String status) async {
    setState(() => _isLoading = true);
    try {
      final token = await ForkliftService.getToken();
      final response = await http.put(
        Uri.parse('http://192.168.1.12:3000/api/operator/edit/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nama_operator': namaOperator,
          'no_hp': noHp,
          'status': status,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        await fetchOperators();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operator berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal edit operator')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteOperator(int id) async {
    setState(() => _isLoading = true);
    try {
      final token = await ForkliftService.getToken();
      final response = await http.delete(
        Uri.parse('http://192.168.1.12:3000/api/operator/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == true) {
        await fetchOperators();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operator berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal hapus operator')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Operator')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _operators.length,
                  itemBuilder: (context, index) {
                    final operator = _operators[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(operator['nama_operator']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${operator['status']}'),
                            Text('No. HP: ${operator['no_hp']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editOperator(operator);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Hapus Operator'),
                                    content: Text(
                                        'Yakin ingin menghapus operator ini?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text('Batal')),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text('Hapus')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteOperator(operator['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOperatorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
