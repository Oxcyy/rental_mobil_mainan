import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../app_store.dart';
import '../models/car.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_app_bar.dart';
import '../main.dart'; 

class CarFormScreen extends StatefulWidget {
  final Car? car;
  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _noteCtrl;
  
  bool _isSaving = false;
  File? _selectedImage;

  bool get isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.car?.name ?? '');
    _colorCtrl = TextEditingController(text: widget.car?.color ?? '');
    _noteCtrl = TextEditingController(text: widget.car?.note ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    final store = context.read<AppStore>();
    final navigator = Navigator.of(context);
    
    try {
      String? uploadedImageUrl = widget.car?.imageUrl;

      if (_selectedImage != null) {
        uploadedImageUrl = await SupabaseService.uploadCarImage(_selectedImage!);
      }

      if (isEditing) {
        final updated = widget.car!.copyWith(
          name: _nameCtrl.text.trim(),
          color: _colorCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
          imageUrl: uploadedImageUrl,
        );
        await store.updateCar(updated);
        navigator.pop();
        showSnackBarWithOK('Mobil berhasil diperbarui!');
      } else {
        final car = Car(
          id: '',
          name: _nameCtrl.text.trim(),
          color: _colorCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
          imageUrl: uploadedImageUrl,
        );
        await store.addCar(car);
        navigator.pop();
        showSnackBarWithOK('Mobil berhasil ditambahkan!');
      }
    } catch (e) {
      debugPrint(e.toString()); 
      showSnackBarWithOK('Gagal: $e', backgroundColor: const Color(0xFFFF8A80)); 
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _neoInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 3)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(title: isEditing ? 'EDIT MOBIL' : 'TAMBAH MOBIL'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage, 
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80DEEA), 
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 3),
                          boxShadow: [BoxShadow(color: borderColor, offset: const Offset(6, 6), blurRadius: 0)],
                          image: _selectedImage != null
                              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                              : (widget.car?.imageUrl != null && widget.car!.imageUrl!.isNotEmpty)
                                  ? DecorationImage(image: NetworkImage(widget.car!.imageUrl!), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (_selectedImage == null && (widget.car?.imageUrl == null || widget.car!.imageUrl!.isEmpty))
                            ? const Icon(Icons.add_a_photo, color: Colors.black, size: 50)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA80FC), 
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2)
                        ),
                        child: const Icon(Icons.edit, color: Colors.black, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _label('NAMA MOBIL *', isDark),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                decoration: _neoInputDecoration('Contoh: Ferrari SF90', Icons.label),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              
              _label('WARNA *', isDark),
              TextFormField(
                controller: _colorCtrl,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                decoration: _neoInputDecoration('Contoh: Merah', Icons.palette),
                validator: (v) => v == null || v.trim().isEmpty ? 'Warna tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              
              _label('KETERANGAN TAMBAHAN', isDark),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                decoration: _neoInputDecoration('Contoh: Kondisi baru, edisi terbatas', Icons.notes),
              ),
              const SizedBox(height: 16),
              
              _label('HARGA SEWA', isDark),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF59D), 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.black),
                    SizedBox(width: 12),
                    Text(
                      'Rp 20.000 / 15 MENIT',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              InkWell(
                onTap: _isSaving ? null : _save,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isSaving ? Colors.grey : const Color(0xFFB9F6CA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: _isSaving ? null : [BoxShadow(color: borderColor, offset: const Offset(4, 4), blurRadius: 0)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSaving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                      else Icon(isEditing ? Icons.save : Icons.add_circle, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH MOBIL',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
      );
}