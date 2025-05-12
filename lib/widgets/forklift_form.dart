import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:cross_file/cross_file.dart';
import '../services/forklift_service.dart';

class ForkliftForm extends StatefulWidget {
  final bool isEdit;
  final int? forkliftId;
  final Map<String, String>? initialData;

  const ForkliftForm(
      {Key? key, this.isEdit = false, this.forkliftId, this.initialData})
      : super(key: key);

  @override
  State<ForkliftForm> createState() => _ForkliftFormState();
}

class _ForkliftFormState extends State<ForkliftForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaUnitController = TextEditingController();
  final TextEditingController _kapasitasController = TextEditingController();
  final TextEditingController _hargaPerJamController = TextEditingController();

  XFile? _pickedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialData != null) {
      _namaUnitController.text = widget.initialData!['nama_unit'] ?? '';
      _kapasitasController.text = widget.initialData!['kapasitas'] ?? '';
      _hargaPerJamController.text = widget.initialData!['harga_per_jam'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final file = await ImagePickerWeb.getImageAsFile();
    if (file != null && file.runtimeType.toString() == 'XFile') {
      setState(() {
        _pickedImage = file as XFile;
      });
    } else if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Gagal memilih gambar: browser atau package tidak mendukung XFile.')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'nama_unit': _namaUnitController.text,
      'kapasitas': _kapasitasController.text,
      'harga_per_jam': _hargaPerJamController.text,
    };

    bool success = false;
    if (widget.isEdit && widget.forkliftId != null) {
      success = await ForkliftService.editForklift(
          widget.forkliftId!, data, _pickedImage);
    } else {
      success = await ForkliftService.addForklift(data, _pickedImage);
    }

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.isEdit
                ? 'Berhasil edit forklift!'
                : 'Berhasil tambah forklift!')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Gagal ${widget.isEdit ? 'edit' : 'tambah'} forklift!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Forklift' : 'Tambah Forklift'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaUnitController,
                decoration: InputDecoration(labelText: 'Nama Unit'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _kapasitasController,
                decoration: InputDecoration(labelText: 'Kapasitas (contoh: 3)'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _hargaPerJamController,
                decoration: InputDecoration(labelText: 'Harga per Jam'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pilih Gambar'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pickedImage != null
                          ? _pickedImage!.name
                          : 'Belum ada gambar',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: Text(widget.isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}
