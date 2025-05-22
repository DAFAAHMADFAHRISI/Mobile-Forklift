import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../services/forklift_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AdminGate extends StatefulWidget {
  const AdminGate({super.key});
  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  bool _isLoggedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _loading = false;
    });
  }

  void _onLoginSuccess() async {
    await _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (!_isLoggedIn) {
      return AdminLoginForm(onLoginSuccess: _onLoginSuccess);
    }
    return KelolaForklift();
  }
}

class AdminLoginForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AdminLoginForm({required this.onLoginSuccess, super.key});
  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final loginResult = await ForkliftService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _loading = false;
    });

    if (loginResult['success']) {
      if (loginResult['isAdmin']) {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _error = 'Akses ditolak! Anda bukan admin.';
        });
      }
    } else {
      setState(() {
        _error = loginResult['message'] ?? 'Login gagal!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Login Admin',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KelolaForklift extends StatefulWidget {
  const KelolaForklift({super.key});

  @override
  State<KelolaForklift> createState() => _KelolaForkliftState();
}

class _KelolaForkliftState extends State<KelolaForklift> {
  List<Map<String, dynamic>> _forklifts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadForklifts();
  }

  Future<void> _loadForklifts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final forklifts = await ForkliftService.getAllForklifts();
      setState(() {
        _forklifts = forklifts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteForklift(int id) async {
    try {
      final success = await ForkliftService.deleteForklift(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit berhasil dihapus')),
        );
        _loadForklifts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus unit: ${e.toString()}')),
      );
    }
  }

  void _showForkliftForm({Map<String, dynamic>? forklift}) {
    showDialog(
      context: context,
      builder: (context) => ForkliftForm(
        forklift: forklift,
        onSuccess: _loadForklifts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800);
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Unit Forklift')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _forklifts.length,
                  itemBuilder: (context, index) {
                    final forklift = _forklifts[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.grey[200],
                                width: 110,
                                height: 90,
                                child: forklift['gambar'] != null
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            'http://10.251.130.109:3000/images/${forklift['gambar']}',
                                        fit: BoxFit.cover,
                                        width: 110,
                                        height: 90,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child: Icon(Icons.forklift,
                                                    size: 50)),
                                      )
                                    : const Center(
                                        child: Icon(Icons.forklift, size: 50)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          forklift['nama_unit'] ?? '-',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            color: orange,
                                            onPressed: () {
                                              _showForkliftForm(
                                                  forklift: forklift);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20),
                                            color: Colors.red,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Konfirmasi Hapus'),
                                                  content: const Text(
                                                      'Apakah Anda yakin ingin menghapus unit ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteForklift(
                                                            forklift[
                                                                'id_unit']);
                                                      },
                                                      child:
                                                          const Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    forklift['status'] == 'tersedia'
                                        ? 'Tersedia'
                                        : 'Disewa',
                                    style: TextStyle(
                                      color: forklift['status'] == 'tersedia'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kapasitas: ${forklift['kapasitas']} ton',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Harga Mulai dari',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Rp ${forklift['harga_per_jam'] ?? '-'} / Jam',
                                    style: const TextStyle(
                                      color: orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (forklift['deskripsi'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      forklift['deskripsi'],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black87),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () {
          _showForkliftForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ForkliftForm extends StatefulWidget {
  final Map<String, dynamic>? forklift;
  final Function onSuccess;
  const ForkliftForm({this.forklift, required this.onSuccess, super.key});

  @override
  State<ForkliftForm> createState() => _ForkliftFormState();
}

class _ForkliftFormState extends State<ForkliftForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kapasitasController = TextEditingController();
  final _hargaController = TextEditingController();
  dynamic _imageFile;
  String? _currentImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.forklift != null) {
      _namaController.text = widget.forklift!['nama_unit'] ?? '';
      _kapasitasController.text = widget.forklift!['kapasitas'] ?? '';
      _hargaController.text =
          widget.forklift!['harga_per_jam']?.toString() ?? '';
      _currentImageUrl = widget.forklift!['gambar'];
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        if (kIsWeb) {
          // For web platform
          setState(() {
            _imageFile = picked;
            _currentImageUrl = null;
          });
        } else {
          // For mobile platform
          final file = File(picked.path);
          final extension = picked.path.split('.').last.toLowerCase();

          if (!['jpg', 'jpeg', 'png'].contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Hanya file JPEG, JPG, dan PNG yang diperbolehkan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          // Check file size (5MB limit)
          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ukuran file terlalu besar. Maksimal 5MB'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          setState(() {
            _imageFile = file;
            _currentImageUrl = null;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'nama_unit': _namaController.text,
      'kapasitas': _kapasitasController.text,
      'harga_per_jam': _hargaController.text,
    };

    try {
      bool success;
      if (widget.forklift == null) {
        success = await ForkliftService.addForklift(data, _imageFile);
      } else {
        success = await ForkliftService.editForklift(
            widget.forklift!['id_unit'], data, _imageFile);
      }

      if (success) {
        if (mounted) {
          widget.onSuccess();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan data!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.forklift == null ? 'Tambah Forklift' : 'Edit Forklift'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_currentImageUrl != null && _imageFile == null)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(
                          'http://10.251.130.109:3000/images/$_currentImageUrl'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (_imageFile != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: kIsWeb
                          ? NetworkImage(_imageFile.path)
                          : FileImage(_imageFile as File) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Unit'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _kapasitasController,
                decoration:
                    const InputDecoration(labelText: 'Kapasitas (contoh: 3)'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga per Jam'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pilih Gambar'),
                  ),
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(p.basename(_imageFile.path)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
