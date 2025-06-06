import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'order_history.dart';
import 'forklift_list.dart';
import '../../services/pesanan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daftar_operator.dart';
import 'pembayaran.dart';

class NewOrder extends StatefulWidget {
  final Map<String, dynamic>? selectedForklift;
  const NewOrder({this.selectedForklift, super.key});

  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _perusahaanController = TextEditingController();
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  Map<String, dynamic>? _selectedForklift;
  Map<String, dynamic>? _selectedOperator;

  bool _isUploading = false;

  // Define custom colors
  static const Color darkNavy = Color(0xFF1A1D29);
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color materialPink = Color(0xFFE91E63);
  static const Color materialPurple = Color(0xFF9C27B0);
  static const Color lightGray = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    if (widget.selectedForklift != null) {
      _selectedForklift = widget.selectedForklift;
    }
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _perusahaanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
          // Reset tanggal selesai jika tanggal mulai diubah
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = null;
          }
        } else {
          if (_tanggalMulai != null && picked.isBefore(_tanggalMulai!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Tanggal selesai tidak boleh sebelum tanggal mulai'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _tanggalSelesai = picked;
          }
        }
      });
    }
  }

  int _getHargaPerJam() {
    if (_selectedForklift == null) return 0;
    final hargaRaw = _selectedForklift!['harga_per_jam'];
    if (hargaRaw == null) return 0;
    if (hargaRaw is int) return hargaRaw;
    if (hargaRaw is String) return int.tryParse(hargaRaw) ?? 0;
    return int.tryParse(hargaRaw.toString()) ?? 0;
  }

  String _getKapasitas() {
    if (_selectedForklift == null) return 'Tidak tersedia';
    final raw = _selectedForklift!['kapasitas'];
    if (raw == null) return 'Tidak tersedia';
    if (raw is int) return raw.toString();
    if (raw is String && raw.isNotEmpty) return raw;
    return raw.toString();
  }

  int _calculateTotal() {
    if (_selectedForklift == null ||
        _tanggalMulai == null ||
        _tanggalSelesai == null) {
      return 0;
    }
    final hargaInt = _getHargaPerJam();
    final duration = _tanggalSelesai!.difference(_tanggalMulai!).inHours;
    if (duration <= 0) return 0; // Durasi tidak boleh <= 0
    return hargaInt * duration;
  }

  int _getIdForklift() {
    if (_selectedForklift == null) return 0;
    final raw = _selectedForklift!['id'] ?? _selectedForklift!['id_unit'];
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return int.tryParse(raw.toString()) ?? 0;
  }

  int _getIdOperator() {
    if (_selectedOperator == null) return 0;
    final raw = _selectedOperator!['id_operator'] ?? _selectedOperator!['id'];
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return int.tryParse(raw.toString()) ?? 0;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi tanggal
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mulai dan selesai harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi urutan tanggal
    if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi durasi dan total
    if (_calculateTotal() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Durasi pemesanan tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi operator
    if (_selectedOperator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih operator terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('DEBUG _selectedForklift: \\n');
    print(_selectedForklift);
    print('DEBUG _selectedOperator: \\n');
    print(_selectedOperator);
    setState(() => _isUploading = true);
    try {
      final response = await PesananService.submitPesanan(
        idUnit: _getIdForklift(),
        idOperator: _getIdOperator(),
        tanggalMulai: _tanggalMulai!.toIso8601String().split('T').first,
        tanggalSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
        lokasiPengiriman: _lokasiController.text,
        namaPerusahaan: _perusahaanController.text,
      );

      if (response != null && response['status'] == true) {
        final idPemesanan = response['id_pemesanan'] ??
            (response['data'] != null
                ? response['data']['id_pemesanan']
                : null);
        if (idPemesanan != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Pembayaran(
                  jumlah: _calculateTotal(),
                  metode: 'Transfer Bank',
                  tanggalPembayaran: DateTime.now(),
                  idPemesanan: idPemesanan,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Gagal membuat pemesanan: id_pemesanan tidak ditemukan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Gagal membuat pemesanan: ${response != null && response['message'] != null ? response['message'] : ''}'),
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
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ForkliftList()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: lightGray,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
            color: darkNavy,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForkliftList()),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Pemesanan Baru',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pilih forklift dan operator untuk kebutuhan Anda',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                darkNavy,
                deepPurple,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedForklift != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unit yang Dipilih',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nama Unit: ${_selectedForklift!['nama_unit']}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Kapasitas: ${_getKapasitas()}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Harga: Rp ${_getHargaPerJam() > 0 ? _getHargaPerJam() : 'Tidak tersedia'} / jam',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Operator',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _selectedOperator == null
                                    ? Text(
                                        'Belum ada operator dipilih',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: _selectedOperator!['foto'] !=
                                                        null &&
                                                    _selectedOperator!['foto']
                                                        .toString()
                                                        .isNotEmpty
                                                ? Image.network(
                                                    'http://192.168.1.10:3000/uploads/operator/${_selectedOperator!['foto']}',
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(Icons.person,
                                                            size: 48,
                                                            color:
                                                                Colors.white54),
                                                  )
                                                : Container(
                                                    width: 48,
                                                    height: 48,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                        Icons.person,
                                                        size: 32,
                                                        color: Colors.white54),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Nama: ${_selectedOperator!['nama_operator']}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                Text(
                                                  'No HP: ${_selectedOperator!['no_hp']}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                Text(
                                                  'Status: ${_selectedOperator!['status']}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: materialPink,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(80, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DaftarOperator(),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _selectedOperator =
                                          Map<String, dynamic>.from(result);
                                    });
                                  }
                                },
                                child: const Text('Pilih'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Tanggal Mulai',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              _tanggalMulai == null
                                  ? 'Pilih tanggal'
                                  : '${_tanggalMulai!.day}/${_tanggalMulai!.month}/${_tanggalMulai!.year}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.calendar_today,
                              color: materialPink,
                            ),
                            onTap: () => _selectDate(context, true),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Tanggal Selesai',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              _tanggalSelesai == null
                                  ? 'Pilih tanggal'
                                  : '${_tanggalSelesai!.day}/${_tanggalSelesai!.month}/${_tanggalSelesai!.year}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.calendar_today,
                              color: materialPink,
                            ),
                            onTap: () => _selectDate(context, false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lokasi Pengiriman',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lokasiController,
                            style: const TextStyle(color: Colors.black87),
                            cursorColor: Colors.black87,
                            decoration: InputDecoration(
                              hintText: 'Masukkan lokasi pengiriman',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: materialPink,
                                ),
                              ),
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lokasi pengiriman harus diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama Perusahaan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _perusahaanController,
                            style: const TextStyle(color: Colors.black87),
                            cursorColor: Colors.black87,
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama perusahaan',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: materialPink,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama perusahaan harus diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Pemesanan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedForklift != null) ...[
                            Text(
                              'Unit: ${_selectedForklift!['nama_unit']}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Kapasitas: ${_getKapasitas()}',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Harga: Rp ${_getHargaPerJam() > 0 ? _getHargaPerJam() : 'Tidak tersedia'} / jam',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                          if (_selectedOperator != null)
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _selectedOperator!['foto'] != null &&
                                          _selectedOperator!['foto']
                                              .toString()
                                              .isNotEmpty
                                      ? Image.network(
                                          'http://192.168.1.10:3000/uploads/operator/${_selectedOperator!['foto']}',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.person,
                                                      size: 32,
                                                      color: Colors.white54),
                                        )
                                      : Container(
                                          width: 32,
                                          height: 32,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.person,
                                              size: 20, color: Colors.white54),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Operator: ${_selectedOperator!['nama_operator']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          if (_tanggalMulai != null &&
                              _tanggalSelesai != null) ...[
                            Text(
                              'Durasi: ${_tanggalSelesai!.difference(_tanggalMulai!).inHours} jam',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Total: Rp ${_calculateTotal()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: materialPink,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: materialPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Buat Pemesanan'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_calculateTotal() == 0 &&
                      _tanggalMulai != null &&
                      _tanggalSelesai != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Durasi pemesanan tidak valid',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
