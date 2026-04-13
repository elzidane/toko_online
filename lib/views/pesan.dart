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

class _PesanState extends State<Pesan> with TickerProviderStateMixin {
  // ── Palette ──────────────────────────────────────────────
  static const _bg = Color(0xFF080E1A);
  static const _surface = Color(0xFF0F172A);
  static const _card = Color(0xFF141F35);
  static const _border = Color(0xFF1E2D47);
  static const _primary = Color(0xFF6366F1);
  static const _accent = Color(0xFF818CF8);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF94A3B8);
  static const _textMuted = Color(0xFF475569);

  // ── State ────────────────────────────────────────────────
  final UserService _service = UserService();
  List<dynamic> _products = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String? _errorMsg;
  String _searchQuery = '';
  String _selectedKat = 'Semua';
  String _sortMode = 'default';
  List<String> _kategoriList = ['Semua'];
  bool _showSearchBar = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // ── Animations ───────────────────────────────────────────
  late AnimationController _fadeAnim;
  late AnimationController _searchAnim;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;
  late Animation<double> _searchExpand;

  @override
  void initState() {
    super.initState();
    _fadeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeIn = CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOutCubic));
    _searchExpand = CurvedAnimation(
      parent: _searchAnim,
      curve: Curves.easeOutCubic,
    );

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
    _fadeAnim.dispose();
    _searchAnim.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final result = await _service.getBarang();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.status && result.data != null) {
          _products = (result.data is List ? result.data : [])!;
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
      _fadeAnim.forward();
    }
  }

  void _applyFilter() {
    var list = _products.where((p) {
      final matchKat =
          _selectedKat == 'Semua' || (p['kategori'] ?? '') == _selectedKat;
      final matchQ =
          _searchQuery.isEmpty ||
          (p['nama_barang'] ?? '').toString().toLowerCase().contains(
            _searchQuery,
          ) ||
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

  void _toggleSearch() {
    HapticFeedback.lightImpact();
    setState(() => _showSearchBar = !_showSearchBar);
    if (_showSearchBar) {
      _searchAnim.forward();
      Future.delayed(
        const Duration(milliseconds: 180),
        () => _searchFocus.requestFocus(),
      );
    } else {
      _searchAnim.reverse();
      _searchCtrl.clear();
      setState(() {
        _searchQuery = '';
        _applyFilter();
      });
      _searchFocus.unfocus();
    }
  }

  String _fixImage(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$img';
  }

  String _formatRp(dynamic val) {
    final v = (val ?? 0) is int
        ? val as int
        : int.tryParse(val.toString()) ?? 0;
    final s = v.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              for (final pesan in pesanList) {
                final barangId = pesan['barang_id'];
                final qty = (pesan['qty'] is int)
                    ? pesan['qty'] as int
                    : int.tryParse(pesan['qty'].toString()) ?? 1;
                final idx = _products.indexWhere(
                  (p) => p['id'].toString() == barangId.toString(),
                );
                if (idx != -1) {
                  final stokLama =
                      int.tryParse(_products[idx]['stok'].toString()) ?? 0;
                  _products[idx] = Map<String, dynamic>.from(
                    _products[idx] as Map,
                  )..['stok'] = (stokLama - qty).clamp(0, 999999);
                }
              }
              _applyFilter();
            });
          });
        },
      ),
    );
  }

  void _showDetail(dynamic p) {
    final imgUrl = _fixImage(p['image']?.toString());
    final isLow = (p['stok'] ?? 0) <= 10;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final cart = context.read<CartProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: cart,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, ctrl) => _ProductDetailSheet(
            p: p,
            imgUrl: imgUrl,
            isLow: isLow,
            isEmpty: isEmpty,
            cart: cart,
            formatRp: _formatRp,
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
              SliverFillRemaining(hasScrollBody: false, child: _buildError())
            else if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: _primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            else ...[
              if (_showSearchBar) _buildSearchBar(),
              _buildKategoriChips(),
              _buildSortRow(),
              _buildGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
    automaticallyImplyLeading: false,
    expandedHeight: 72,
    collapsedHeight: 72,
    floating: true,
    pinned: true,
    backgroundColor: _bg,
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideIn,
          child: Row(
            children: [
              // Brand mark
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primary.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: _primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Toko Online',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: _textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${_filtered.length} produk',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              // Search toggle
              _iconBtn(
                icon: _showSearchBar
                    ? Icons.close_rounded
                    : Icons.search_rounded,
                active: _showSearchBar,
                onTap: _toggleSearch,
              ),
              const SizedBox(width: 8),

              // Cart
              Consumer<CartProvider>(
                builder: (_, cart, __) => GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showCart();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cart.totalItems > 0
                              ? _primary.withOpacity(0.15)
                              : _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cart.totalItems > 0
                                ? _primary.withOpacity(0.4)
                                : _border,
                          ),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: cart.totalItems > 0 ? _accent : _textMuted,
                          size: 18,
                        ),
                      ),
                      if (cart.totalItems > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: const BoxDecoration(
                              color: _red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${cart.totalItems}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: _border.withOpacity(0.5)),
    ),
  );

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: active ? _primary.withOpacity(0.15) : _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? _primary.withOpacity(0.4) : _border),
      ),
      child: Icon(icon, color: active ? _accent : _textMuted, size: 18),
    ),
  );

  // ── Search bar ───────────────────────────────────────────
  Widget _buildSearchBar() => SliverToBoxAdapter(
    child: SizeTransition(
      sizeFactor: _searchExpand,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            style: const TextStyle(
              color: _textPrimary,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
            cursorColor: _primary,
            decoration: InputDecoration(
              hintText: 'Cari produk atau kategori...',
              hintStyle: const TextStyle(
                color: _textMuted,
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _textMuted,
                size: 18,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchQuery = '';
                          _applyFilter();
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: _textMuted,
                        size: 16,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    ),
  );

  // ── Kategori chips ───────────────────────────────────────
  Widget _buildKategoriChips() => SliverToBoxAdapter(
    child: SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        itemCount: _kategoriList.length,
        itemBuilder: (_, i) {
          final kat = _kategoriList[i];
          final active = _selectedKat == kat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedKat = kat;
                _applyFilter();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? _primary : _surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active ? _primary : _border),
              ),
              child: Text(
                kat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : _textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  // ── Sort row ─────────────────────────────────────────────
  Widget _buildSortRow() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          Text(
            '${_filtered.length} produk',
            style: const TextStyle(
              fontSize: 12,
              color: _textMuted,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ('default', 'Default', Icons.grid_view_rounded),
                  ('harga_asc', 'Termurah', Icons.arrow_upward_rounded),
                  ('harga_desc', 'Termahal', Icons.arrow_downward_rounded),
                  ('stok', 'Stok', Icons.inventory_2_outlined),
                ].map((s) {
                  final active = _sortMode == s.$1;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _sortMode = s.$1;
                        _applyFilter();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? _primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: active ? _primary.withOpacity(0.5) : _border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.$3,
                              size: 11,
                              color: active ? _accent : _textMuted),
                          const SizedBox(width: 4),
                          Text(
                            s.$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: active ? _accent : _textMuted,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Product grid ─────────────────────────────────────────
  Widget _buildGrid() {
    if (_filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: _textMuted,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak Ditemukan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Coba kata kunci lain',
                style: TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.59,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _buildProductCard(_filtered[i], i),
          childCount: _filtered.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic p, int index) {
    final imgUrl = _fixImage(p['image']?.toString());
    final isLow = (p['stok'] ?? 0) <= 10 && (p['stok'] ?? 0) > 0;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final id = int.tryParse(p['id'].toString()) ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => _showDetail(p),
        child: Consumer<CartProvider>(
          builder: (_, cart, __) {
            final inCart = cart.isInCart(id);
            final qty = cart.qtyOf(id);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: inCart ? _primary.withOpacity(0.35) : _border,
                  width: inCart ? 1.5 : 1,
                ),
                boxShadow: inCart
                    ? [
                        BoxShadow(
                          color: _primary.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image ──
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 128,
                          color: _surface,
                          child: imgUrl.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: _textMuted,
                                    size: 32,
                                  ),
                                )
                              : Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: _textMuted,
                                      size: 28,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Overlay jika stok habis
                      if (isEmpty)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                              child: const Center(
                                child: Text(
                                  'Habis',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Stok terbatas badge
                      if (isLow && !isEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _amber.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Sisa ${p['stok']}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      // Cart qty badge
                      if (inCart)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Info ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori label
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (p['kategori'] ?? 'Umum').toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: _accent,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p['nama_barang'] ?? '-',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              fontFamily: 'Poppins',
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            _formatRp(p['harga']),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _green,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Cart control ──
                          isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _border),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Habis',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _textMuted,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              : inCart
                              ? _QtyChip(
                                  qty: qty,
                                  onDec: () {
                                    HapticFeedback.selectionClick();
                                    cart.decreaseQty(id);
                                  },
                                  onInc: () {
                                    HapticFeedback.selectionClick();
                                    cart.increaseQty(id);
                                  },
                                )
                              : GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    cart.addItem(
                                      CartItem(
                                        id: id,
                                        nama: p['nama_barang'] ?? '-',
                                        harga:
                                            int.tryParse(
                                              p['harga'].toString(),
                                            ) ??
                                            0,
                                        image: p['image']?.toString(),
                                        kategori: p['kategori']?.toString(),
                                        stokMax:
                                            int.tryParse(
                                              p['stok'].toString(),
                                            ) ??
                                            0,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _primary.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          size: 13,
                                          color: _accent,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Tambah',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _accent,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
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

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: _red.withOpacity(0.2)),
            ),
            child: const Icon(Icons.wifi_off_rounded, color: _red, size: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMsg ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: _textMuted,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadProducts,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withOpacity(0.3)),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 13,
                  color: _accent,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Qty chip widget ──────────────────────────────────────
class _QtyChip extends StatelessWidget {
  final int qty;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _QtyChip({required this.qty, required this.onDec, required this.onInc});

  static const _primary = Color(0xFF6366F1);
  static const _accent = Color(0xFF818CF8);
  static const _red = Color(0xFFEF4444);
  static const _surface = Color(0xFF0F172A);
  static const _border = Color(0xFF1E2D47);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onDec,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.remove_rounded, color: _red, size: 14),
            ),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          GestureDetector(
            onTap: onInc,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.add_rounded, color: _accent, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// PRODUCT DETAIL SHEET
// ══════════════════════════════════════════════════════════
class _ProductDetailSheet extends StatelessWidget {
  final dynamic p;
  final String imgUrl;
  final bool isLow;
  final bool isEmpty;
  final CartProvider cart;
  final String Function(dynamic) formatRp;

  const _ProductDetailSheet({
    required this.p,
    required this.imgUrl,
    required this.isLow,
    required this.isEmpty,
    required this.cart,
    required this.formatRp,
  });

  static const _surface = Color(0xFF0F172A);
  static const _card = Color(0xFF141F35);
  static const _border = Color(0xFF1E2D47);
  static const _primary = Color(0xFF6366F1);
  static const _accent = Color(0xFF818CF8);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF94A3B8);
  static const _textMuted = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _border)),
          ),
          child: ChangeNotifierProvider.value(
            value: cart,
            child: Consumer<CartProvider>(
              builder: (_, cart, __) {
                final id = int.tryParse(p['id'].toString()) ?? 0;
                final qty = cart.qtyOf(id);
                final inCart = qty > 0;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 4),
                          width: 36,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Hero image
                      Container(
                        width: double.infinity,
                        height: 240,
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: imgUrl.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: _textMuted,
                                    size: 56,
                                  ),
                                )
                              : Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: _textMuted,
                                      size: 44,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status chips
                            Row(
                              children: [
                                _chip(
                                  (p['kategori'] ?? 'Umum').toString(),
                                  _primary.withOpacity(0.12),
                                  _accent,
                                ),
                                const SizedBox(width: 8),
                                _chip(
                                  isEmpty
                                      ? 'Stok Habis'
                                      : isLow
                                      ? 'Terbatas'
                                      : 'Tersedia',
                                  (isEmpty
                                          ? _red
                                          : isLow
                                          ? _amber
                                          : _green)
                                      .withOpacity(0.1),
                                  isEmpty
                                      ? _red
                                      : isLow
                                      ? _amber
                                      : _green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Nama
                            Text(
                              p['nama_barang'] ?? '-',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Deskripsi
                            if ((p['deskripsi'] ?? '').toString().isNotEmpty)
                              Text(
                                p['deskripsi'].toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textSecondary,
                                  fontFamily: 'Poppins',
                                  height: 1.65,
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Stats row
                            Row(
                              children: [
                                _statBox(
                                  'Harga',
                                  formatRp(p['harga']),
                                  Icons.payments_outlined,
                                  _green,
                                ),
                                const SizedBox(width: 10),
                                _statBox(
                                  'Stok',
                                  '${p['stok'] ?? 0} unit',
                                  Icons.inventory_2_outlined,
                                  isEmpty
                                      ? _red
                                      : isLow
                                      ? _amber
                                      : _primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // CTA
                            isEmpty
                                ? _disabledButton()
                                : inCart
                                ? _qtyControl(
                                    qty,
                                    onDec: () {
                                      HapticFeedback.selectionClick();
                                      cart.decreaseQty(id);
                                    },
                                    onInc: () {
                                      HapticFeedback.selectionClick();
                                      cart.increaseQty(id);
                                    },
                                  )
                                : _addButton(() {
                                    HapticFeedback.lightImpact();
                                    cart.addItem(
                                      CartItem(
                                        id: id,
                                        nama: p['nama_barang'] ?? '-',
                                        harga:
                                            int.tryParse(
                                              p['harga'].toString(),
                                            ) ??
                                            0,
                                        image: p['image']?.toString(),
                                        kategori: p['kategori']?.toString(),
                                        stokMax:
                                            int.tryParse(
                                              p['stok'].toString(),
                                            ) ??
                                            0,
                                      ),
                                    );
                                  }),

                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Tutup',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textMuted,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: fg,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _statBox(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _addButton(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'Tambah ke Keranjang',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    ),
  );

  Widget _disabledButton() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: const Center(
      child: Text(
        'Stok Habis',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textMuted,
          fontFamily: 'Poppins',
        ),
      ),
    ),
  );

  Widget _qtyControl(
    int qty, {
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onDec,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _red.withOpacity(0.2)),
              ),
              child: const Center(
                child: Icon(Icons.remove_rounded, color: _red, size: 18),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$qty',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onInc,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _primary.withOpacity(0.3)),
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: _accent, size: 18),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════
// CART SHEET
// ══════════════════════════════════════════════════════════
class _CartSheet extends StatelessWidget {
  final VoidCallback onCheckout;
  const _CartSheet({required this.onCheckout});

  static const _surface = Color(0xFF0F172A);
  static const _card = Color(0xFF141F35);
  static const _border = Color(0xFF1E2D47);
  static const _primary = Color(0xFF6366F1);
  static const _accent = Color(0xFF818CF8);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF94A3B8);
  static const _textMuted = Color(0xFF475569);

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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Consumer<CartProvider>(
            builder: (_, cart, __) => Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Keranjang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${cart.totalItems} item',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _accent,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (cart.items.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            cart.clear();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Hapus Semua',
                            style: TextStyle(
                              fontSize: 12,
                              color: _red,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Divider(height: 1, color: _border),

                // Items
                Expanded(
                  child: cart.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _card,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _border),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: _textMuted,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Keranjang Kosong',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Pilih produk untuk ditambahkan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: _border),
                          itemBuilder: (_, i) {
                            final item = cart.items[i];
                            final imgUrl =
                                item.image != null && item.image!.isNotEmpty
                                ? item.image!.startsWith('http')
                                      ? item.image!
                                      : 'https://learn.smktelkom-mlg.sch.id/toko/${item.image}'
                                : '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                children: [
                                  // Thumb
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      color: _card,
                                      child: imgUrl.isEmpty
                                          ? const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: _textMuted,
                                              size: 22,
                                            )
                                          : Image.network(
                                              imgUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.broken_image_outlined,
                                                    color: _textMuted,
                                                    size: 20,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nama,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _textPrimary,
                                            fontFamily: 'Poppins',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _formatRp(item.harga),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _green,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Qty
                                  Row(
                                    children: [
                                      _CartQtyBtn(
                                        icon: Icons.remove_rounded,
                                        color: _red,
                                        onTap: () => cart.decreaseQty(item.id),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          '${item.qty}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _textPrimary,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                      _CartQtyBtn(
                                        icon: Icons.add_rounded,
                                        color: _primary,
                                        onTap: () => cart.increaseQty(item.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Footer
                if (cart.items.isNotEmpty) ...[
                  Divider(height: 1, color: _border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total · ${cart.totalItems} item',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textSecondary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              _formatRp(cart.totalHarga),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _green,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: onCheckout,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _primary.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.payment_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Checkout',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _CartQtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CartQtyBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// CHECKOUT SHEET
// ══════════════════════════════════════════════════════════
class _CheckoutSheet extends StatefulWidget {
  final UserService service;
  final void Function(List<Map<String, dynamic>>)? onSuccess;
  const _CheckoutSheet({required this.service, this.onSuccess});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet>
    with SingleTickerProviderStateMixin {
  static const _surface = Color(0xFF0F172A);
  static const _card = Color(0xFF141F35);
  static const _border = Color(0xFF1E2D47);
  static const _primary = Color(0xFF6366F1);
  static const _accent = Color(0xFF818CF8);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF94A3B8);
  static const _textMuted = Color(0xFF475569);

  bool _isLoading = false;
  bool _success = false;
  String? _errMsg;

  late AnimationController _successAnim;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = CurvedAnimation(
      parent: _successAnim,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _successAnim.dispose();
    super.dispose();
  }

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
    setState(() {
      _isLoading = true;
      _errMsg = null;
    });
    final pesanList = List<Map<String, dynamic>>.from(cart.toPesanList());
    final result = await widget.service.buatTransaksi(pesanList);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.status) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSuccess?.call(pesanList);
      });
      cart.clear();
      setState(() => _success = true);
      _successAnim.forward();
    } else {
      setState(() => _errMsg = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _border)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                if (_success) ...[
                  // ── Success ──────────────────────────────
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: _successScale,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: _green.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: _green,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pesanan Berhasil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pesanan kamu sedang diproses',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 36),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Kembali Belanja',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // ── Checkout form ─────────────────────────
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Konfirmasi Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${cart.items.length} item dalam pesanan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textMuted,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: _border),
                  const SizedBox(height: 12),

                  // Item list
                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _border),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: _textMuted,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nama,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.qty}× ${_formatRp(item.harga)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _textMuted,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatRp(item.subtotal),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _green,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(height: 1, color: _border),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        _formatRp(cart.totalHarga),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _green,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Error
                  if (_errMsg != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: _red,
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errMsg!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _red,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit button
                  GestureDetector(
                    onTap: _isLoading ? null : () => _submit(cart),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? _primary.withOpacity(0.5)
                            : _primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: _primary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Konfirmasi & Bayar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
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
