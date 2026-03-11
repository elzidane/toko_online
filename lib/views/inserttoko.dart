import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapp2/services/tokoService.dart';
import 'package:mobileapp2/widget/alert.dart'; // sesuaikan path

class Inserttoko extends StatefulWidget {
  final String title;
  final Map<String, dynamic> item;

  const Inserttoko({Key? key, required this.title, required this.item})
      : super(key: key);

  @override
  State<Inserttoko> createState() => _InserttokoState();
}

class _InserttokoState extends State<Inserttoko>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TokoService _tokoService = TokoService();

  final _namaBarangController = TextEditingController();
  final _deskripsiController  = TextEditingController();
  final _stokController       = TextEditingController();
  final _hargaController      = TextEditingController();
  final _kategoriController   = TextEditingController();

  File? selectedImage;
  bool _isLoading      = false;
  bool _isImageLoading = false;
  bool get _isEdit     => widget.item.isNotEmpty;

  late AnimationController _animController;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  // ── PICK IMAGE FROM GALLERY ─────────────────────────────
  Future<void> getImage() async {
    setState(() => _isImageLoading = true);

    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    setState(() {
      if (img != null) selectedImage = File(img.path);
      _isImageLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.item.isNotEmpty) {
      _namaBarangController.text = widget.item['nama_barang']?.toString() ?? '';
      _deskripsiController.text  = widget.item['deskripsi']?.toString()   ?? '';
      _stokController.text       = widget.item['stok']?.toString()        ?? '';
      _hargaController.text      = widget.item['harga']?.toString()       ?? '';
      _kategoriController.text   = widget.item['kategori']?.toString()    ?? '';
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fades = List.generate(5, (i) {
      final start = i * 0.1;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start, (start + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOut),
      ));
    });

    _slides = List.generate(5, (i) {
      final start = i * 0.1;
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start, (start + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    _hargaController.dispose();
    _kategoriController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _a(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  // ── SIMPAN → LANGSUNG PANGGIL API ───────────────────────
  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = {
      'nama_barang': _namaBarangController.text.trim(),
      'deskripsi'  : _deskripsiController.text.trim(),
      'stok'       : int.tryParse(_stokController.text.trim())  ?? 0,
      'harga'      : int.tryParse(_hargaController.text.trim()) ?? 0,
      'kategori'   : _kategoriController.text.trim(),
    };

    final id = _isEdit ? widget.item['id'] : null;

    final res = await _tokoService.insertToko(request, selectedImage, id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.status == true) {
      AlertMassage().showAlert(
        context,
        res.message ?? (_isEdit ? 'Berhasil diperbarui' : 'Berhasil ditambahkan'),
        true,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context, true);
    } else {
      AlertMassage().showAlert(
        context,
        res.message ?? 'Terjadi kesalahan',
        false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              ),
              child: Icon(
                _isEdit ? Icons.edit_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins')),
          ],
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _a(0, _buildHeaderCard()),
                const SizedBox(height: 28),

                _a(1, _buildField(
                  label: 'Nama Barang',
                  hint: 'Contoh: Sepatu Olahraga',
                  icon: Icons.shopping_bag_outlined,
                  controller: _namaBarangController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Nama barang tidak boleh kosong';
                    if (v.trim().length < 3) return 'Minimal 3 karakter';
                    return null;
                  },
                )),
                const SizedBox(height: 16),

                _a(2, _buildField(
                  label: 'Deskripsi',
                  hint: 'Deskripsi singkat barang...',
                  icon: Icons.notes_rounded,
                  controller: _deskripsiController,
                  maxLines: 3,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Deskripsi tidak boleh kosong';
                    return null;
                  },
                )),
                const SizedBox(height: 16),

                _a(2, Row(children: [
                  Expanded(
                    child: _buildField(
                      label: 'Stok',
                      hint: '0',
                      icon: Icons.inventory_2_outlined,
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Stok wajib diisi';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      label: 'Harga (Rp)',
                      hint: '0',
                      icon: Icons.attach_money_rounded,
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Harga wajib diisi';
                        return null;
                      },
                    ),
                  ),
                ])),
                const SizedBox(height: 16),

                _a(3, _buildField(
                  label: 'Kategori',
                  hint: 'Contoh: Elektronik, Fashion...',
                  icon: Icons.category_outlined,
                  controller: _kategoriController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Kategori tidak boleh kosong';
                    return null;
                  },
                )),
                const SizedBox(height: 16),

                _a(3, _buildImagePicker()),
                const SizedBox(height: 32),

                _a(4, _buildSimpanButton()),
                const SizedBox(height: 12),
                _a(4, _buildBatalButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── IMAGE PICKER ─────────────────────────────────────────
  Widget _buildImagePicker() {
    final existingUrl = _isEdit
        ? (widget.item['image']?.toString() ?? '')
        : '';
    final hasExisting = existingUrl.isNotEmpty && selectedImage == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Gambar Barang',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Poppins')),
        ),
        GestureDetector(
          onTap: _isImageLoading ? null : getImage,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedImage != null
                    ? const Color(0xFF6366F1).withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: _isImageLoading
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                          color: Color(0xFF6366F1), strokeWidth: 2.5),
                    ),
                  )
                : selectedImage != null
                    ? _previewFile()
                    : hasExisting
                        ? _previewNetwork(existingUrl)
                        : _placeholder(),
          ),
        ),
        if (selectedImage != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  selectedImage!.path.split('/').last,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Poppins'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => selectedImage = null),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('Hapus',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.withOpacity(0.7),
                          fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _previewFile() => ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(fit: StackFit.expand, children: [
          Image.file(selectedImage!, fit: BoxFit.cover),
          _overlayHint(),
        ]),
      );

  Widget _previewNetwork(String url) {
    final fullUrl = url.startsWith('http')
        ? url
        : 'https://learn.smktelkom-mlg.sch.id/toko/$url';
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Stack(fit: StackFit.expand, children: [
        Image.network(fullUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder()),
        _overlayHint(),
      ]),
    );
  }

  Widget _overlayHint() => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 5),
              Text('Ketuk untuk ganti',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      );

  Widget _placeholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                color: Color(0xFF6366F1), size: 28),
          ),
          const SizedBox(height: 10),
          const Text('Pilih Gambar dari Galeri',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                  fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text('JPG, PNG · Ketuk untuk memilih',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35),
                  fontFamily: 'Poppins')),
        ],
      );

  // ── HEADER CARD ──────────────────────────────────────────
  Widget _buildHeaderCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.15),
              const Color(0xFF8B5CF6).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isEdit
                    ? Icons.shopping_bag_rounded
                    : Icons.add_shopping_cart_rounded,
                color: const Color(0xFF6366F1),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? 'Edit Barang' : 'Barang Baru',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _isEdit
                        ? 'Perbarui informasi barang'
                        : 'Isi detail barang yang ingin ditambahkan',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.55),
                        fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ── SIMPAN BUTTON ─────────────────────────────────────────
  Widget _buildSimpanButton() => SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _simpanData,
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.white.withOpacity(0.08),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              _isEdit
                                  ? Icons.save_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );

  // ── BATAL BUTTON ──────────────────────────────────────────
  Widget _buildBatalButton() => SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
          ),
          child: Text('Batal',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.45),
                  fontFamily: 'Poppins')),
        ),
      );

  // ── TEXT FIELD ────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'Poppins')),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
          cursorColor: const Color(0xFF6366F1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 14,
                fontFamily: 'Poppins'),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon,
                  color: Colors.white.withOpacity(0.35), size: 20),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
            filled: true,
            fillColor: const Color(0xFF334155),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.08), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.red.withOpacity(0.6), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorStyle: const TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}