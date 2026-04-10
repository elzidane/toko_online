import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/providers/cartProvider.dart';
import 'package:mobileapp2/services/user.dart';
import 'package:provider/provider.dart';


class Pesan extends StatefulWidget {
  const Pesan({super.key});

  @override
  State<Pesan> createState() => _PesanState();
}

class _PesanState extends State<Pesan>
    with TickerProviderStateMixin {
  // ── Colors ───────────────────────────────────────────────
  static const _bg      = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _amber   = Color(0xFFF59E0B);
  static const _red     = Color(0xFFEF4444);

  // ── State ────────────────────────────────────────────────
  final UserService _service = UserService();
  List<dynamic> _products    = [];
  List<dynamic> _filtered    = [];
  bool          _isLoading   = true;
  String?       _errorMsg;
  String        _searchQuery = '';
  String        _selectedKat = 'Semua';
  String        _sortMode    = 'default';
  List<String>  _kategoriList = ['Semua'];

  final TextEditingController _searchCtrl = TextEditingController();

  // ── Animations ───────────────────────────────────────────
  late AnimationController _headerAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(
        begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerAnim, curve: Curves.easeOutCubic));
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
        _applyFilter();
      });
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await _service.getBarang();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.status && result.data != null) {
          _products = (result.data is List ? result.data : [])!;
          // Collect kategori
          final cats = <String>{'Semua'};
          for (final p in _products) {
            if (p['kategori'] != null) cats.add(p['kategori'].toString());
          }
          _kategoriList = cats.toList();
          _applyFilter();
        } else {
          _errorMsg = result.message;
        }
      });
      _headerAnim.forward();
    }
  }

  void _applyFilter() {
    var list = _products.where((p) {
      final matchKat  = _selectedKat == 'Semua' ||
          (p['kategori'] ?? '') == _selectedKat;
      final matchQ    = _searchQuery.isEmpty ||
          (p['nama_barang'] ?? '').toString().toLowerCase().contains(_searchQuery) ||
          (p['kategori'] ?? '').toString().toLowerCase().contains(_searchQuery);
      return matchKat && matchQ;
    }).toList();

    switch (_sortMode) {
      case 'harga_asc':
        list.sort((a, b) => (a['harga'] ?? 0).compareTo(b['harga'] ?? 0));
        break;
      case 'harga_desc':
        list.sort((a, b) => (b['harga'] ?? 0).compareTo(a['harga'] ?? 0));
        break;
      case 'stok':
        list.sort((a, b) => (b['stok'] ?? 0).compareTo(a['stok'] ?? 0));
        break;
    }
    _filtered = list;
  }

  String _fixImage(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$img';
  }

  String _formatRp(dynamic val) {
    final v = (val ?? 0) is int ? val as int : int.tryParse(val.toString()) ?? 0;
    final s = v.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── Cart modal ───────────────────────────────────────────
  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        onCheckout: () {
          Navigator.pop(context);
          _showCheckout();
        },
      ),
    );
  }

  void _showCheckout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        service: _service,
        onSuccess: (List<Map<String, dynamic>> pesanList) {
          // Kurangi stok lokal secara optimistik
          // pakai addPostFrameCallback agar aman saat sheet masih render
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              for (final pesan in pesanList) {
                final barangId = pesan['barang_id'];
                final qty = (pesan['qty'] is int)
                    ? pesan['qty'] as int
                    : int.tryParse(pesan['qty'].toString()) ?? 1;

                final idx = _products.indexWhere(
                    (p) => p['id'].toString() == barangId.toString());

                if (idx != -1) {
                  final stokLama =
                      int.tryParse(_products[idx]['stok'].toString()) ?? 0;
                  final stokBaru = (stokLama - qty).clamp(0, 999999);
                  // Buat copy map baru agar Flutter detect perubahan
                  _products[idx] =
                      Map<String, dynamic>.from(_products[idx] as Map)
                        ..['stok'] = stokBaru;
                }
              }
              _applyFilter();
            });

            // Refresh dari API setelah 1 detik untuk sinkronisasi
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) _loadProducts();
            });
          });
        },
      ),
    );
  }

  // ── Detail produk ────────────────────────────────────────
  void _showDetail(dynamic p) {
    final imgUrl  = _fixImage(p['image']?.toString());
    final isLow   = (p['stok'] ?? 0) <= 10;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final cart    = context.read<CartProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: cart,
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, ctrl) => ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: _surface.withOpacity(0.97),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.1))),
                ),
                child: SingleChildScrollView(
                  controller: ctrl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 4),
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      // Hero image
                      Container(
                        width: double.infinity,
                        height: 260,
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            _primary.withOpacity(0.2),
                            _accent.withOpacity(0.1)
                          ]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: imgUrl.isEmpty
                              ? const Center(child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: _primary, size: 80))
                              : Image.network(imgUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Center(child: Icon(
                                          Icons.broken_image_outlined,
                                          color: _primary, size: 60))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges
                            Row(children: [
                              _badge(p['kategori'] ?? 'Umum', _primary),
                              const SizedBox(width: 8),
                              _badge(
                                  isEmpty ? 'Stok Habis'
                                      : isLow ? 'Terbatas' : 'Tersedia',
                                  isEmpty ? _red : isLow ? _amber : _green),
                            ]),
                            const SizedBox(height: 12),
                            Text(p['nama_barang'] ?? '-',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800,
                                    color: Colors.white, fontFamily: 'Poppins',
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 8),
                            Text(p['deskripsi'] ?? 'Tidak ada deskripsi.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.55),
                                    fontFamily: 'Poppins', height: 1.6)),
                            const SizedBox(height: 20),
                            // Stat row
                            Row(children: [
                              _detailStat('Harga',
                                  _formatRp(p['harga']),
                                  Icons.payments_outlined, _green),
                              const SizedBox(width: 10),
                              _detailStat('Stok',
                                  '${p['stok'] ?? 0} unit',
                                  Icons.inventory_2_outlined,
                                  isLow ? _amber : _primary),
                            ]),
                            const SizedBox(height: 24),
                            // Add to cart button
                            Consumer<CartProvider>(
                              builder: (_, cart, __) {
                                final qty = cart.qtyOf(
                                    int.tryParse(p['id'].toString()) ?? 0);
                                final inCart = qty > 0;
                                if (isEmpty) {
                                  return _disabledBtn('Stok Habis');
                                }
                                return inCart
                                    ? _qtyControl(
                                        qty,
                                        onDec: () => cart.decreaseQty(
                                            int.tryParse(p['id'].toString()) ?? 0),
                                        onInc: () => cart.increaseQty(
                                            int.tryParse(p['id'].toString()) ?? 0),
                                      )
                                    : _addBtn(
                                        'Tambah ke Keranjang',
                                        Icons.add_shopping_cart_rounded,
                                        () {
                                          cart.addItem(CartItem(
                                            id: int.tryParse(p['id'].toString()) ?? 0,
                                            nama: p['nama_barang'] ?? '-',
                                            harga: int.tryParse(
                                                    p['harga'].toString()) ?? 0,
                                            image: p['image']?.toString(),
                                            kategori: p['kategori']?.toString(),
                                            stokMax: int.tryParse(
                                                    p['stok'].toString()) ?? 0,
                                          ));
                                          HapticFeedback.lightImpact();
                                        },
                                      );
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            if (_errorMsg != null)
              SliverFillRemaining(
                  hasScrollBody: false, child: _buildError())
            else if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(
                    color: _primary, strokeWidth: 2.5)),
              )
            else ...[
              _buildSearchBar(),
              _buildKategoriChips(),
              _buildSortRow(),
              _buildGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
    automaticallyImplyLeading: false,
    expandedHeight: 80,
    collapsedHeight: 80,
    floating: true, pinned: true,
    backgroundColor: _bg, elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      titlePadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      title: FadeTransition(
        opacity: _headerFade,
        child: SlideTransition(
          position: _headerSlide,
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_primary, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _primary.withOpacity(0.4),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Toko Online',
                      style: TextStyle(fontSize: 17,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins', color: Colors.white,
                          letterSpacing: -0.3)),
                  Text('${_filtered.length} produk tersedia',
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.45),
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
            // Cart button
            Consumer<CartProvider>(
              builder: (_, cart, __) => GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showCart();
                },
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: cart.totalItems > 0
                          ? const LinearGradient(
                              colors: [_primary, _accent])
                          : null,
                      color: cart.totalItems == 0
                          ? Colors.white.withOpacity(0.07) : null,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: cart.totalItems > 0
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.08)),
                      boxShadow: cart.totalItems > 0
                          ? [BoxShadow(
                              color: _primary.withOpacity(0.4),
                              blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Icon(Icons.shopping_cart_rounded,
                        color: cart.totalItems > 0
                            ? Colors.white
                            : Colors.white.withOpacity(0.55),
                        size: 20),
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      top: -4, right: -4,
                      child: Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(
                            color: _red, shape: BoxShape.circle),
                        child: Center(child: Text(
                            '${cart.totalItems}',
                            style: const TextStyle(fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins'))),
                      ),
                    ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ),
  );

  // ── Search ───────────────────────────────────────────────
  Widget _buildSearchBar() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: Colors.white,
              fontFamily: 'Poppins', fontSize: 13),
          cursorColor: _primary,
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3),
                fontFamily: 'Poppins', fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withOpacity(0.35), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.white.withOpacity(0.4), size: 16),
                    onPressed: _searchCtrl.clear)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ),
  );

  // ── Kategori chips ───────────────────────────────────────
  Widget _buildKategoriChips() => SliverToBoxAdapter(
    child: SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        itemCount: _kategoriList.length,
        itemBuilder: (_, i) {
          final kat    = _kategoriList[i];
          final active = _selectedKat == kat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() { _selectedKat = kat; _applyFilter(); });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: active ? const LinearGradient(
                    colors: [_primary, _accent]) : null,
                color: active ? null : _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active
                    ? Colors.transparent : Colors.white.withOpacity(0.08)),
                boxShadow: active ? [BoxShadow(
                    color: _primary.withOpacity(0.35),
                    blurRadius: 8, offset: const Offset(0, 3))] : [],
              ),
              child: Text(kat,
                  style: TextStyle(fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      fontFamily: 'Poppins')),
            ),
          );
        },
      ),
    ),
  );

  // ── Sort row ─────────────────────────────────────────────
  Widget _buildSortRow() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(children: [
        Text('${_filtered.length} produk',
            style: TextStyle(fontSize: 12,
                color: Colors.white.withOpacity(0.4),
                fontFamily: 'Poppins')),
        const Spacer(),
        ...[
          ('default', 'Default', Icons.apps_rounded),
          ('harga_asc', 'Murah', Icons.arrow_upward_rounded),
          ('harga_desc', 'Mahal', Icons.arrow_downward_rounded),
        ].map((s) {
          final active = _sortMode == s.$1;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() { _sortMode = s.$1; _applyFilter(); });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: active ? const LinearGradient(
                    colors: [_primary, _accent]) : null,
                color: active ? null : _surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active
                    ? Colors.transparent : Colors.white.withOpacity(0.08)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(s.$3, size: 11,
                    color: active ? Colors.white
                        : Colors.white.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(s.$2, style: TextStyle(fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontFamily: 'Poppins')),
              ]),
            ),
          );
        }),
      ]),
    ),
  );

  // ── Product grid ─────────────────────────────────────────
  Widget _buildGrid() {
    if (_filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 72, height: 72,
                decoration: BoxDecoration(color: _primary.withOpacity(0.08),
                    shape: BoxShape.circle),
                child: const Icon(Icons.search_off_rounded,
                    color: _primary, size: 32)),
            const SizedBox(height: 14),
            const Text('Produk Tidak Ditemukan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
          ],
        )),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _buildProductCard(_filtered[i], i),
          childCount: _filtered.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic p, int index) {
    final imgUrl  = _fixImage(p['image']?.toString());
    final isLow   = (p['stok'] ?? 0) <= 10;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final id      = int.tryParse(p['id'].toString()) ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () => _showDetail(p),
        child: Consumer<CartProvider>(
          builder: (_, cart, __) {
            final inCart = cart.isInCart(id);
            return Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: inCart
                      ? _primary.withOpacity(0.4)
                      : Colors.white.withOpacity(0.07),
                ),
                boxShadow: [BoxShadow(
                  color: inCart
                      ? _primary.withOpacity(0.15)
                      : Colors.black.withOpacity(0.22),
                  blurRadius: inCart ? 20 : 14,
                  offset: const Offset(0, 6),
                )],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Container(
                        width: double.infinity, height: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            _primary.withOpacity(0.18),
                            _accent.withOpacity(0.08)
                          ]),
                        ),
                        child: imgUrl.isEmpty
                            ? const Center(child: Icon(
                                Icons.shopping_bag_outlined,
                                color: _primary, size: 40))
                            : Image.network(imgUrl, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(
                                        Icons.broken_image_outlined,
                                        color: _primary, size: 36))),
                      ),
                    ),
                    // Stok badge
                    Positioned(top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isEmpty
                              ? _red.withOpacity(0.9)
                              : isLow ? _amber.withOpacity(0.9)
                              : _green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                            isEmpty ? 'Habis'
                                : isLow ? '${p['stok']} tersisa'
                                : 'Tersedia',
                            style: const TextStyle(fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white, fontFamily: 'Poppins')),
                      ),
                    ),
                    // In-cart indicator
                    if (inCart)
                      Positioned(top: 8, left: 8,
                        child: Container(
                          width: 28, height: 28,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [_primary, _accent]),
                              shape: BoxShape.circle),
                          child: Center(child: Text(
                              '${cart.qtyOf(id)}',
                              style: const TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFamily: 'Poppins'))),
                        ),
                      ),
                  ]),

                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['nama_barang'] ?? '-',
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins',
                                  height: 1.2),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Text(_formatRp(p['harga']),
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _green, fontFamily: 'Poppins')),
                          const SizedBox(height: 8),
                          // Add / qty control
                          isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: _red.withOpacity(0.2)),
                                  ),
                                  child: const Center(child: Text('Habis',
                                      style: TextStyle(fontSize: 10,
                                          color: _red, fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700))),
                                )
                              : inCart
                              ? _qtyControlSmall(
                                  cart.qtyOf(id),
                                  onDec: () => cart.decreaseQty(id),
                                  onInc: () => cart.increaseQty(id),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    cart.addItem(CartItem(
                                      id: id,
                                      nama: p['nama_barang'] ?? '-',
                                      harga: int.tryParse(
                                              p['harga'].toString()) ?? 0,
                                      image: p['image']?.toString(),
                                      kategori: p['kategori']?.toString(),
                                      stokMax: int.tryParse(
                                              p['stok'].toString()) ?? 0,
                                    ));
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [_primary, _accent]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_rounded,
                                            size: 13,
                                            color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Keranjang',
                                            style: TextStyle(fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontFamily: 'Poppins')),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(7)),
    child: Text(text, style: TextStyle(fontSize: 11, color: color,
        fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
  );

  Widget _detailStat(String label, String value, IconData icon, Color color) =>
      Expanded(child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color.withOpacity(0.12), color.withOpacity(0.04)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: color.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 14)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10,
                  color: Colors.white.withOpacity(0.45),
                  fontFamily: 'Poppins')),
              Text(value, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color, fontFamily: 'Poppins'),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
        ]),
      ));

  Widget _qtyControl(int qty,
      {required VoidCallback onDec, required VoidCallback onInc}) =>
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: onDec,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                color: _red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _red.withOpacity(0.3))),
            child: const Center(child: Icon(
                Icons.remove_rounded, color: _red, size: 18)),
          ),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('$qty', style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: Colors.white, fontFamily: 'Poppins')),
        ),
        Expanded(child: GestureDetector(
          onTap: onInc,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_primary, _accent]),
                borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Icon(
                Icons.add_rounded, color: Colors.white, size: 18)),
          ),
        )),
      ]);

  Widget _qtyControlSmall(int qty,
      {required VoidCallback onDec, required VoidCallback onInc}) =>
      Container(
        decoration: BoxDecoration(
            color: _surface, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: onDec, child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Icon(Icons.remove_rounded,
                      color: _red, size: 14))),
              Text('$qty', style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins')),
              GestureDetector(onTap: onInc, child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.add_rounded,
                      color: _primary, size: 14))),
            ]),
      );

  Widget _addBtn(String label, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primary, _accent]),
              borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins')),
          ]),
        ),
      );

  Widget _disabledBtn(String label) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1))),
    child: Center(child: Text(label, style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.35), fontFamily: 'Poppins'))),
  );

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 68, height: 68,
          decoration: BoxDecoration(color: _red.withOpacity(0.08),
              shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, color: _red, size: 30)),
      const SizedBox(height: 14),
      const Text('Gagal Memuat Produk',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: Colors.white, fontFamily: 'Poppins')),
      const SizedBox(height: 6),
      Text(_errorMsg ?? '',
          style: TextStyle(fontSize: 12,
              color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins'),
          textAlign: TextAlign.center),
      const SizedBox(height: 22),
      ElevatedButton.icon(
        onPressed: _loadProducts,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Coba Lagi',
            style: TextStyle(fontFamily: 'Poppins')),
        style: ElevatedButton.styleFrom(
            backgroundColor: _primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
      ),
    ]),
  ));
}

// ══════════════════════════════════════════════════════════
// CART SHEET
// ══════════════════════════════════════════════════════════
class _CartSheet extends StatelessWidget {
  final VoidCallback onCheckout;
  const _CartSheet({required this.onCheckout});

  static const _bg      = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _red     = Color(0xFFEF4444);

  String _formatRp(int val) {
    final s = val.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.97),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Consumer<CartProvider>(
            builder: (_, cart, __) => Column(children: [
              // Handle
              Center(child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2)),
              )),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_primary, _accent]),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.shopping_cart_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Keranjang Belanja',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white, fontFamily: 'Poppins')),
                      Text('${cart.totalItems} item',
                          style: TextStyle(fontSize: 11,
                              color: Colors.white.withOpacity(0.45),
                              fontFamily: 'Poppins')),
                    ],
                  )),
                  if (cart.items.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        cart.clear();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _red.withOpacity(0.25)),
                        ),
                        child: const Text('Hapus Semua',
                            style: TextStyle(fontSize: 11,
                                color: _red, fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 14),
              // Cart items
              Expanded(
                child: cart.items.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 72, height: 72,
                              decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.08),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.shopping_cart_outlined,
                                  color: _primary, size: 32)),
                          const SizedBox(height: 14),
                          const Text('Keranjang Kosong',
                              style: TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins')),
                          const SizedBox(height: 5),
                          Text('Tambahkan produk ke keranjang',
                              style: TextStyle(fontSize: 12,
                                  color: Colors.white.withOpacity(0.4),
                                  fontFamily: 'Poppins')),
                        ],
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cart.items.length,
                        itemBuilder: (_, i) {
                          final item = cart.items[i];
                          final imgUrl = item.image != null &&
                                  item.image!.isNotEmpty
                              ? item.image!.startsWith('http')
                                  ? item.image!
                                  : 'https://learn.smktelkom-mlg.sch.id/toko/${item.image}'
                              : '';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.07)),
                            ),
                            child: Row(children: [
                              // Thumb
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      _primary.withOpacity(0.15),
                                      _accent.withOpacity(0.07)]),
                                  ),
                                  child: imgUrl.isEmpty
                                      ? const Icon(Icons.shopping_bag_outlined,
                                          color: _primary, size: 24)
                                      : Image.network(imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                  Icons.broken_image_outlined,
                                                  color: _primary, size: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nama,
                                      style: const TextStyle(fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Poppins'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Text(_formatRp(item.harga),
                                      style: const TextStyle(fontSize: 12,
                                          color: _green,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins')),
                                ],
                              )),
                              // Qty control
                              Row(children: [
                                GestureDetector(
                                  onTap: () => cart.decreaseQty(item.id),
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                        color: _red.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: _red.withOpacity(0.25))),
                                    child: const Icon(Icons.remove_rounded,
                                        color: _red, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text('${item.qty}',
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontFamily: 'Poppins')),
                                ),
                                GestureDetector(
                                  onTap: () => cart.increaseQty(item.id),
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [_primary, _accent]),
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: const Icon(Icons.add_rounded,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ]),
                            ]),
                          );
                        },
                      ),
              ),
              // Footer
              if (cart.items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  decoration: BoxDecoration(
                    color: _card.withOpacity(0.8),
                    border: Border(
                        top: BorderSide(
                            color: Colors.white.withOpacity(0.07))),
                  ),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total (${cart.totalItems} item)',
                            style: TextStyle(fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                                fontFamily: 'Poppins')),
                        Text(_formatRp(cart.totalHarga),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: _green, fontFamily: 'Poppins')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: onCheckout,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_primary, _accent]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                                color: _primary.withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 5))]),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Checkout Sekarang',
                                style: TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// CHECKOUT SHEET
// ══════════════════════════════════════════════════════════
class _CheckoutSheet extends StatefulWidget {
  final UserService                          service;
  final void Function(List<Map<String, dynamic>> pesanList)? onSuccess;
  const _CheckoutSheet({required this.service, this.onSuccess});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _red     = Color(0xFFEF4444);

  bool _isLoading = false;
  bool _success   = false;
  String? _errMsg;

  String _formatRp(int val) {
    final s = val.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Future<void> _submit(CartProvider cart) async {
    setState(() { _isLoading = true; _errMsg = null; });

    // Simpan pesanList SEBELUM apapun — cart belum di-clear
    final pesanList = List<Map<String, dynamic>>.from(cart.toPesanList());

    final result = await widget.service.buatTransaksi(pesanList);

    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (result.status) {
      // Panggil onSuccess DULU dengan data pesanList yang sudah tersimpan
      // pakai addPostFrameCallback agar parent setState aman meski sheet masih terbuka
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSuccess?.call(pesanList);
      });

      // Baru clear cart dan tampilkan sukses
      cart.clear();
      setState(() => _success = true);
    } else {
      setState(() => _errMsg = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.97),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2)),
                )),

                if (_success) ...[
                  // ── Success state ──
                  const SizedBox(height: 20),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                        color: _green.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _green.withOpacity(0.3), width: 2)),
                    child: const Icon(Icons.check_circle_rounded,
                        color: _green, size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text('Transaksi Berhasil!',
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w800, color: Colors.white,
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  Text('Pesanan kamu sedang diproses',
                      style: TextStyle(fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_primary, _accent]),
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('Kembali Belanja',
                          style: TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins'))),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // ── Checkout form ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Konfirmasi Pesanan',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w800, color: Colors.white,
                            fontFamily: 'Poppins')),
                  ),
                  const SizedBox(height: 16),

                  // Item list
                  ...cart.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.06))),
                    child: Row(children: [
                      const Text('📦',
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.nama,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('${item.qty}x ${_formatRp(item.harga)}',
                              style: TextStyle(fontSize: 11,
                                  color: Colors.white.withOpacity(0.4),
                                  fontFamily: 'Poppins')),
                        ],
                      )),
                      Text(_formatRp(item.subtotal),
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700, color: _green,
                              fontFamily: 'Poppins')),
                    ]),
                  )),

                  const SizedBox(height: 4),
                  Container(height: 1,
                      color: Colors.white.withOpacity(0.07)),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembayaran',
                          style: TextStyle(fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                              fontFamily: 'Poppins')),
                      Text(_formatRp(cart.totalHarga),
                          style: const TextStyle(fontSize: 20,
                              fontWeight: FontWeight.w800, color: _green,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_errMsg != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _red.withOpacity(0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded,
                            color: _red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errMsg!,
                            style: const TextStyle(fontSize: 12,
                                color: _red, fontFamily: 'Poppins'))),
                      ]),
                    ),

                  GestureDetector(
                    onTap: _isLoading ? null : () => _submit(cart),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _isLoading ? null : const LinearGradient(
                            colors: [_primary, _accent]),
                        color: _isLoading ? Colors.white12 : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isLoading ? [] : [BoxShadow(
                            color: _primary.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5))],
                      ),
                      child: _isLoading
                          ? const Center(child: SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5)))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Konfirmasi & Bayar',
                                    style: TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        fontFamily: 'Poppins')),
                              ],
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}