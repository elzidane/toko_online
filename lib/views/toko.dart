import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/models/response_data_list.dart';
import 'package:mobileapp2/models/toko_model.dart';
import 'package:mobileapp2/services/tokoService.dart';
import 'package:mobileapp2/views/insertToko.dart';
import 'package:mobileapp2/widget/alert.dart';// sesuaikan path

class Toko extends StatefulWidget {
  const Toko({super.key});

  @override
  State<Toko> createState() => _TokoState();
}

class _TokoState extends State<Toko> with TickerProviderStateMixin {
  // ── Services & Data ─────────────────────────────────────
  final TokoService _toko = TokoService();
  List<TokoModel>? _barang;
  List<TokoModel>? _filtered;
  bool _isLoading = true;
  String? _errorMessage;

  // ── Search & Filter ──────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _sortMode = 'default';

  // ── Animation ────────────────────────────────────────────
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // ── Colors ───────────────────────────────────────────────
  static const _bg      = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _amber   = Color(0xFFF59E0B);
  static const _red     = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _headerAnim, curve: Curves.easeOutCubic));
    _searchCtrl.addListener(_onSearch);
    getToko();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ─────────────────────────────────────────────────
  Future<void> getToko() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      ResponseDataList result = await _toko.getToko();
      if (mounted) {
        setState(() {
          if (result.status == true) {
            _barang = List<TokoModel>.from(result.data ?? []);
            _applyFilter();
          } else {
            _errorMessage = result.message;
          }
          _isLoading = false;
        });
        _headerAnim.forward();
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Terjadi kesalahan: $e'; _isLoading = false; });
    }
  }

  void _onSearch() => setState(() { _searchQuery = _searchCtrl.text.toLowerCase(); _applyFilter(); });

  void _applyFilter() {
    if (_barang == null) return;
    var list = _barang!.where((item) {
      if (_searchQuery.isEmpty) return true;
      return (item.nama_barang ?? '').toLowerCase().contains(_searchQuery) ||
          (item.kategori ?? '').toLowerCase().contains(_searchQuery);
    }).toList();
    switch (_sortMode) {
      case 'harga_asc':  list.sort((a, b) => (a.harga ?? 0).compareTo(b.harga ?? 0)); break;
      case 'harga_desc': list.sort((a, b) => (b.harga ?? 0).compareTo(a.harga ?? 0)); break;
      case 'stok':       list.sort((a, b) => (b.stok ?? 0).compareTo(a.stok ?? 0)); break;
    }
    _filtered = list;
  }

  String _fixImage(String? image) {
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$image';
  }

  String _formatRp(int? val) {
    if (val == null) return 'Rp 0';
    final s = val.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── Stats ─────────────────────────────────────────────────
  int get _totalStok   => (_barang ?? []).fold(0, (s, i) => s + (i.stok ?? 0));
  int get _maxHarga    => (_barang ?? []).isEmpty ? 0 : _barang!.map((e) => e.harga ?? 0).reduce((a, b) => a > b ? a : b);
  int get _totalNilai  => (_barang ?? []).fold(0, (s, i) => s + ((i.harga ?? 0) * (i.stok ?? 0)));

  // ── Navigate ──────────────────────────────────────────────
  Future<void> _goInsert({Map<String, dynamic> item = const {}}) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => Inserttoko(
            title: item.isEmpty ? 'Tambah Barang' : 'Edit Barang', item: item),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    if (result == true) getToko();
  }

  Future<void> _hapus(TokoModel item) async {
    var results = await AlertMassage().showAlertDialog(context);
    if (results != null && results.containsKey('status') && results['status'] == true) {
      final res = await _toko.deleteToko(context, item.id);
      if (!mounted) return;
      AlertMassage().showAlert(
        context,
        res.message ?? (res.status == true ? 'Berhasil dihapus' : 'Gagal menghapus'),
        res.status == true,
      );
      if (res.status == true) getToko();
    }
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: _buildFAB(),
      body: _isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() => const Center(
        child: CircularProgressIndicator(
            color: _primary, strokeWidth: 2.5));

  Widget _buildFAB() => FloatingActionButton.extended(
        onPressed: () => _goInsert(),
        backgroundColor: _primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600)),
      );

  Widget _buildBody() {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          if (_errorMessage != null)
            SliverFillRemaining(hasScrollBody: false, child: _buildError())
          else ...[
            if (_barang != null && _barang!.isNotEmpty) _buildStatsRow(),
            _buildSearchAndFilter(),
            _buildList(),
            if (_filtered != null && _filtered!.isNotEmpty) _buildFooter(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
        automaticallyImplyLeading: false,
        expandedHeight: 78,
        collapsedHeight: 78,
        floating: true,
        pinned: true,
        backgroundColor: _bg,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          title: FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_primary, _accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: _primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Katalog Produk',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Poppins', color: Colors.white, letterSpacing: -0.3)),
                        if (_barang != null)
                          Text('${_barang!.length} produk terdaftar',
                              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.45), fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); getToko(); },
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Icon(Icons.refresh_rounded, color: Colors.white.withOpacity(0.6), size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ── STATS ROW ─────────────────────────────────────────────
  Widget _buildStatsRow() => SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _headerFade,
          child: SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              children: [
                _statPill('Produk', '${_barang!.length}', Icons.shopping_bag_outlined, _primary),
                _statPill('Total Stok', '$_totalStok', Icons.inventory_2_outlined, _green),
                _statPill('Harga Maks', _formatRp(_maxHarga), Icons.trending_up_rounded, _amber),
                _statPill('Nilai Aset', _formatRp(_totalNilai), Icons.account_balance_wallet_outlined, _accent),
              ],
            ),
          ),
        ),
      );

  Widget _statPill(String label, String value, IconData icon, Color color) => Container(
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins')),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
              ],
            ),
          ],
        ),
      );

  // ── SEARCH & FILTER ───────────────────────────────────────
  Widget _buildSearchAndFilter() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
          child: Column(
            children: [
              // Search
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13),
                  cursorColor: _primary,
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk atau kategori...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontFamily: 'Poppins', fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.35), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4), size: 16),
                            onPressed: _searchCtrl.clear)
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Sort chips
              Row(
                children: [
                  _sortChip('Semua', 'default', Icons.apps_rounded),
                  _sortChip('Harga ↑', 'harga_asc', Icons.arrow_upward_rounded),
                  _sortChip('Harga ↓', 'harga_desc', Icons.arrow_downward_rounded),
                  _sortChip('Stok', 'stok', Icons.inventory_rounded),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _sortChip(String label, String mode, IconData icon) {
    final active = _sortMode == mode;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() { _sortMode = mode; _applyFilter(); }); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(colors: [_primary, _accent]) : null,
          color: active ? null : _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? Colors.transparent : Colors.white.withOpacity(0.08)),
          boxShadow: active ? [BoxShadow(color: _primary.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? Colors.white : Colors.white.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : Colors.white.withOpacity(0.5),
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  // ── LIST ─────────────────────────────────────────────────
  Widget _buildList() {
    if (_filtered == null || _filtered!.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _buildEmpty());
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: _filtered!.length,
        itemBuilder: (_, i) => _buildCard(_filtered![i], i),
      ),
    );
  }

  // ── PRODUCT CARD ──────────────────────────────────────────
  Widget _buildCard(TokoModel item, int index) {
    final imageUrl = _fixImage(item.image);
    final isLow = (item.stok ?? 0) <= 10;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 55),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onLongPress: () { HapticFeedback.mediumImpact(); _showActionSheet(item); },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              // Main row
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(imageUrl, index),
                    const SizedBox(width: 14),
                    Expanded(child: _buildInfo(item, isLow)),
                    _buildMenu(item),
                  ],
                ),
              ),
              // Bottom strip
              _buildStrip(item, isLow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url, int index) => Stack(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [_primary.withOpacity(0.15), _accent.withOpacity(0.08)]),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: url.isEmpty
                  ? const Icon(Icons.shopping_bag_outlined, color: _primary, size: 30)
                  : Image.network(url, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: _primary, size: 28),
                      loadingBuilder: (_, child, p) => p == null ? child : const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _primary)))),
            ),
          ),
          Positioned(
            top: 0, left: 0,
            child: Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_primary, _accent]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomRight: Radius.circular(8)),
              ),
              child: Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins'))),
            ),
          ),
        ],
      );

  Widget _buildInfo(TokoModel item, bool isLow) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.nama_barang ?? 'Tanpa Nama',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins'),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Wrap(
            spacing: 6,
            children: [
              _badge(item.kategori ?? 'Umum', _primary),
              _badge(isLow ? 'Terbatas' : 'Tersedia', isLow ? _amber : _green),
            ],
          ),
          const SizedBox(height: 7),
          Text(item.deskripsi ?? 'Tidak ada deskripsi',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.42), fontFamily: 'Poppins', height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(fontSize: 10, color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      );

  Widget _buildMenu(TokoModel item) => PopupMenuButton<String>(
        onSelected: (v) => v == 'edit'
            ? _goInsert(item: {'id': item.id, 'nama_barang': item.nama_barang, 'deskripsi': item.deskripsi, 'stok': item.stok, 'harga': item.harga, 'kategori': item.kategori, 'image': item.image})
            : _hapus(item),
        color: _surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.white.withOpacity(0.08))),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: _primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_outlined, size: 15, color: _primary)),
            const SizedBox(width: 10),
            const Text('Edit Barang', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 13)),
          ])),
          PopupMenuItem(value: 'delete', child: Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: _red.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline_rounded, size: 15, color: _red)),
            const SizedBox(width: 10),
            const Text('Hapus', style: TextStyle(color: _red, fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
          ])),
        ],
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(9)),
          child: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.4), size: 18),
        ),
      );

  Widget _buildStrip(TokoModel item, bool isLow) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.025),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined, size: 13, color: _green),
            const SizedBox(width: 5),
            Text(_formatRp(item.harga), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green, fontFamily: 'Poppins')),
            const Spacer(),
            Icon(Icons.layers_outlined, size: 13, color: Colors.white.withOpacity(0.35)),
            const SizedBox(width: 4),
            Text('${item.stok ?? 0} unit', style: TextStyle(fontSize: 12, color: isLow ? _amber : Colors.white54, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _goInsert(item: {'id': item.id, 'nama_barang': item.nama_barang, 'deskripsi': item.deskripsi, 'stok': item.stok, 'harga': item.harga, 'kategori': item.kategori, 'image': item.image}),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [_primary, _accent]), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit_rounded, size: 11, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                ]),
              ),
            ),
          ],
        ),
      );

  // ── ACTION SHEET ──────────────────────────────────────────
  void _showActionSheet(TokoModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 18),
                Text(item.nama_barang ?? 'Produk', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                const SizedBox(height: 18),
                _sheetBtn(Icons.edit_rounded, 'Edit Barang', _primary, () { Navigator.pop(context); _goInsert(item: {'id': item.id, 'nama_barang': item.nama_barang, 'deskripsi': item.deskripsi, 'stok': item.stok, 'harga': item.harga, 'kategori': item.kategori, 'image': item.image}); }),
                const SizedBox(height: 8),
                _sheetBtn(Icons.delete_outline_rounded, 'Hapus Barang', _red, () { Navigator.pop(context); _hapus(item); }),
                const SizedBox(height: 8),
                _sheetBtn(Icons.close_rounded, 'Batal', Colors.white38, () => Navigator.pop(context), ghost: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetBtn(IconData icon, String label, Color color, VoidCallback onTap, {bool ghost = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: ghost ? Colors.transparent : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ghost ? Colors.white.withOpacity(0.07) : color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 9),
              Text(label, style: TextStyle(color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      );

  // ── FOOTER ────────────────────────────────────────────────
  Widget _buildFooter() => SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_green.withOpacity(0.12), _green.withOpacity(0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _green.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: _green.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.account_balance_wallet_rounded, color: _green, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Nilai Inventori', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins')),
                  Text(_formatRp(_totalNilai), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _green, fontFamily: 'Poppins')),
                ],
              ),
              const Spacer(),
              Text('${_filtered?.length ?? 0} item', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3), fontFamily: 'Poppins')),
            ],
          ),
        ),
      );

  // ── EMPTY ─────────────────────────────────────────────────
  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _primary.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, color: _primary, size: 32),
            ),
            const SizedBox(height: 14),
            Text(_searchQuery.isEmpty ? 'Belum Ada Produk' : 'Tidak Ditemukan',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 5),
            Text(_searchQuery.isEmpty ? 'Tambah produk pertama kamu' : 'Coba kata kunci lain',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins')),
          ],
        ),
      );

  // ── ERROR ─────────────────────────────────────────────────
  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(color: _red.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.wifi_off_rounded, color: _red, size: 30),
              ),
              const SizedBox(height: 14),
              const Text('Gagal Memuat Data', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              Text(_errorMessage ?? '', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins'), textAlign: TextAlign.center),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: getToko,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi', style: TextStyle(fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
}