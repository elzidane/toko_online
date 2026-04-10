import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/providers/cartProvider.dart';
import 'package:mobileapp2/services/user.dart';
import 'package:provider/provider.dart';
import 'package:mobileapp2/models/user_login.dart';

import 'package:mobileapp2/providers/user_provider.dart';
class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser>
    with TickerProviderStateMixin {
  // ── Colors (identik dgn seluruh app) ─────────────────────
  static const _bg      = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _amber   = Color(0xFFF59E0B);
  static const _red     = Color(0xFFEF4444);
  static const _blue    = Color(0xFF3B82F6);
  static const _pink    = Color(0xFFEC4899);

  // ── Services ──────────────────────────────────────────────
  final UserService  _service   = UserService();
  final UserLogin    _userLogin = UserLogin();

  // ── State ─────────────────────────────────────────────────
  String?        _nama;
  List<dynamic>  _products     = [];
  bool           _isLoading    = true;
  String?        _errorMsg;
  String         _selectedKat  = 'Semua';
  List<String>   _kategoriList = ['Semua'];

  // ── Carousel ──────────────────────────────────────────────
  int  _bannerIndex = 0;
  late PageController _pageCtrl;

  // ── Animations ────────────────────────────────────────────
  late AnimationController _fadeAnim;
  late Animation<double>   _fade;

  // ── Banner data ───────────────────────────────────────────
  final List<_BannerData> _banners = [
    _BannerData(
      title: 'Flash Sale Hari Ini!',
      subtitle: 'Diskon hingga 50% untuk produk pilihan',
      emoji: '🔥',
      grad: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    _BannerData(
      title: 'Produk Terbaru',
      subtitle: 'Temukan koleksi terbaru yang baru saja tiba',
      emoji: '✨',
      grad: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _BannerData(
      title: 'Gratis Ongkir',
      subtitle: 'Minimum belanja Rp 100.000 bebas ongkos kirim',
      emoji: '🚚',
      grad: [Color(0xFF10B981), Color(0xFF0EA5E9)],
    ),
    _BannerData(
      title: 'Bayar Nanti',
      subtitle: 'Cicilan 0% tersedia untuk semua produk',
      emoji: '💳',
      grad: [Color(0xFFF59E0B), Color(0xFFEC4899)],
    ),
  ];

  // ── Category icons ────────────────────────────────────────
  final Map<String, IconData> _katIcons = {
    'Semua':      Icons.apps_rounded,
    'Elektronik': Icons.devices_rounded,
    'Pakaian':    Icons.checkroom_rounded,
    'Makanan':    Icons.restaurant_rounded,
    'Olahraga':   Icons.fitness_center_rounded,
    'Kendaraan':  Icons.directions_car_rounded,
    'Aksesoris':  Icons.watch_rounded,
    'Kesehatan':  Icons.health_and_safety_rounded,
    'Rumah':      Icons.home_rounded,
  };

  // ── Computed ──────────────────────────────────────────────
  List<dynamic> get _filteredProducts {
    if (_selectedKat == 'Semua') return _products;
    return _products
        .where((p) => (p['kategori'] ?? '') == _selectedKat)
        .toList();
  }

  List<dynamic> get _featuredProducts =>
      _products.where((p) => (p['stok'] ?? 0) > 0).take(6).toList();

  List<dynamic> get _newArrivals => _products.reversed.take(8).toList();

  List<dynamic> get _hotProducts {
    final list = List<dynamic>.from(_products);
    list.sort((a, b) => (b['stok'] ?? 0).compareTo(a['stok'] ?? 0));
    return list.take(6).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.92);
    _fadeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOut));
    _loadAll();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeAnim.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      final next = (_bannerIndex + 1) % _banners.length;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic);
      }
      return mounted;
    });
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    await Future.wait([_loadUser(), _loadProducts()]);
    if (mounted) _fadeAnim.forward();
  }

  Future<void> _loadUser() async {
    final user = await _userLogin.getUserLogin();
    if (mounted) setState(() => _nama = user.name);
  }

  Future<void> _loadProducts() async {
    final result = await _service.getBarang();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.status && result.data != null) {
          _products = result.data is List ? result.data as List : [];
          final cats = <String>{'Semua'};
          for (final p in _products) {
            if (p['kategori'] != null) cats.add(p['kategori'].toString());
          }
          _kategoriList = cats.toList();
        } else {
          _errorMsg = result.message;
        }
      });
    }
  }

  String _fixImage(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$img';
  }

  String _formatRp(dynamic val) {
    final v = int.tryParse(val?.toString() ?? '0') ?? 0;
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}Jt';
    if (v >= 1000)    return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp $v';
  }

  String _formatRpFull(dynamic val) {
    final v = int.tryParse(val?.toString() ?? '0') ?? 0;
    final s = v.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(
                color: _primary, strokeWidth: 2.5))
            : _errorMsg != null
                ? _buildError()
                : FadeTransition(
                    opacity: _fade,
                    child: RefreshIndicator(
                      onRefresh: _loadAll,
                      color: _primary,
                      backgroundColor: _surface,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildAppBar(),
                          SliverToBoxAdapter(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 20),
                              _buildBannerCarousel(),
                              const SizedBox(height: 24),
                              _buildQuickActions(),
                              const SizedBox(height: 24),
                              _buildCategoryRow(),
                              const SizedBox(height: 24),
                              if (_featuredProducts.isNotEmpty) ...[
                                _buildSectionHeader(
                                    '⭐ Produk Unggulan', 'Lihat Semua', _primary),
                                const SizedBox(height: 14),
                                _buildHorizontalProducts(_featuredProducts),
                                const SizedBox(height: 24),
                              ],
                              _buildPromoBanner(),
                              const SizedBox(height: 24),
                              if (_hotProducts.isNotEmpty) ...[
                                _buildSectionHeader(
                                    '🔥 Terlaris', 'Lihat Semua', _red),
                                const SizedBox(height: 14),
                                _buildHorizontalProducts(_hotProducts),
                                const SizedBox(height: 24),
                              ],
                              _buildSectionHeader(
                                  '🆕 Semua Produk', '', _green),
                              const SizedBox(height: 14),
                              _buildProductGrid(),
                              const SizedBox(height: 100),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
    automaticallyImplyLeading: false,
    floating: true,
    snap: true,
    backgroundColor: _bg,
    elevation: 0,
    toolbarHeight: 70,
    title: Row(children: [
      // Avatar
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_primary, _accent]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: _primary.withOpacity(0.35),
              blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Center(child: Text(
          _nama != null && _nama!.isNotEmpty
              ? _nama![0].toUpperCase() : 'U',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
              color: Colors.white, fontFamily: 'Poppins'),
        )),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting(),
              style: TextStyle(fontSize: 11,
                  color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins')),
          Text(_nama ?? 'Pengguna',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins',
                  letterSpacing: -0.3),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      )),
      // Notif
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(Icons.notifications_outlined,
            color: Colors.white.withOpacity(0.6), size: 18),
      ),
      const SizedBox(width: 8),
      // Cart
      Consumer<CartProvider>(builder: (_, cart, __) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: cart.totalItems > 0
                  ? const LinearGradient(colors: [_primary, _accent])
                  : null,
              color: cart.totalItems == 0
                  ? Colors.white.withOpacity(0.07) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cart.totalItems > 0
                  ? Colors.transparent : Colors.white.withOpacity(0.08)),
            ),
            child: Icon(Icons.shopping_cart_rounded,
                color: cart.totalItems > 0
                    ? Colors.white : Colors.white.withOpacity(0.6),
                size: 18),
          ),
          if (cart.totalItems > 0)
            Positioned(top: -4, right: -4, child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                  color: _red, shape: BoxShape.circle),
              child: Center(child: Text('${cart.totalItems}',
                  style: const TextStyle(fontSize: 8,
                      color: Colors.white, fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins'))),
            )),
        ],
      )),
    ]),
  );

  // ── SEARCH BAR ────────────────────────────────────────────
  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate ke shop page langsung (kalau ada routing)
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
              blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded,
              color: Colors.white.withOpacity(0.3), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('Cari produk yang kamu mau...',
              style: TextStyle(fontSize: 13,
                  color: Colors.white.withOpacity(0.3),
                  fontFamily: 'Poppins'))),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primary, _accent]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded,
                color: Colors.white, size: 14),
          ),
        ]),
      ),
    ),
  );

  // ── BANNER CAROUSEL ───────────────────────────────────────
  Widget _buildBannerCarousel() => Column(children: [
    SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _bannerIndex = i),
        itemCount: _banners.length,
        itemBuilder: (_, i) {
          final b = _banners[i];
          return AnimatedScale(
            scale: _bannerIndex == i ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: b.grad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(
                    color: b.grad[0].withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Stack(children: [
                // Decorative circles
                Positioned(right: -20, top: -20, child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle),
                )),
                Positioned(right: 30, bottom: -30, child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle),
                )),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('PROMO',
                              style: const TextStyle(fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white, fontFamily: 'Poppins',
                                  letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 10),
                        Text(b.title,
                            style: const TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white, fontFamily: 'Poppins',
                                letterSpacing: -0.5)),
                        const SizedBox(height: 6),
                        Text(b.subtitle,
                            style: TextStyle(fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                                fontFamily: 'Poppins', height: 1.4),
                            maxLines: 2),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Belanja Sekarang',
                              style: TextStyle(fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: b.grad[0], fontFamily: 'Poppins')),
                        ),
                      ],
                    )),
                    Text(b.emoji,
                        style: const TextStyle(fontSize: 64)),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    ),
    const SizedBox(height: 12),
    // Dot indicator
    Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_banners.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _bannerIndex == i ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            gradient: _bannerIndex == i
                ? const LinearGradient(colors: [_primary, _accent])
                : null,
            color: _bannerIndex == i
                ? null : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ))),
  ]);

  // ── QUICK ACTIONS ─────────────────────────────────────────
  Widget _buildQuickActions() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      _quickAction('Flash Sale', Icons.flash_on_rounded, _amber),
      _quickAction('Terbaru',    Icons.new_releases_rounded, _blue),
      _quickAction('Promo',      Icons.local_offer_rounded,  _pink),
      _quickAction('Wishlist',   Icons.favorite_rounded,     _red),
    ]),
  );

  Widget _quickAction(String label, IconData icon, Color color) =>
      Expanded(child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Column(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withOpacity(0.18), color.withOpacity(0.06)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 7),
          Text(label, style: TextStyle(fontSize: 10,
              color: Colors.white.withOpacity(0.7), fontFamily: 'Poppins',
              fontWeight: FontWeight.w600)),
        ]),
      ));

  // ── CATEGORY ROW ──────────────────────────────────────────
  Widget _buildCategoryRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: _buildSectionHeader('Kategori', '', _accent),
      ),
      SizedBox(height: 80, child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kategoriList.length,
        itemBuilder: (_, i) {
          final kat    = _kategoriList[i];
          final active = _selectedKat == kat;
          final icon   = _katIcons[kat] ?? Icons.category_rounded;
          final colors = [_primary, _accent, _green, _amber, _blue, _pink, _red];
          final color  = colors[i % colors.length];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedKat = kat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              child: Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: active
                        ? LinearGradient(colors: [color, color.withOpacity(0.6)])
                        : null,
                    color: active ? null : _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? Colors.transparent : Colors.white.withOpacity(0.08),
                      width: active ? 0 : 1,
                    ),
                    boxShadow: active ? [BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 10, offset: const Offset(0, 4))] : [],
                  ),
                  child: Icon(icon,
                      color: active ? Colors.white : color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(kat.length > 8 ? '${kat.substring(0, 7)}..' : kat,
                    style: TextStyle(fontSize: 10,
                        color: active ? Colors.white : Colors.white.withOpacity(0.5),
                        fontFamily: 'Poppins',
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
              ]),
            ),
          );
        },
      )),
    ],
  );

  // ── SECTION HEADER ────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Text(title, style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.w800, color: Colors.white,
              fontFamily: 'Poppins', letterSpacing: -0.3)),
          const Spacer(),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(action, style: TextStyle(fontSize: 12,
                    color: color, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
              ]),
            ),
        ]),
      );

  // ── HORIZONTAL PRODUCT SCROLL ─────────────────────────────
  Widget _buildHorizontalProducts(List<dynamic> list) => SizedBox(
    height: 220,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final p       = list[i];
        final imgUrl  = _fixImage(p['image']?.toString());
        final isLow   = (p['stok'] ?? 0) <= 10 && (p['stok'] ?? 0) > 0;
        final isEmpty = (p['stok'] ?? 0) == 0;
        final id      = int.tryParse(p['id'].toString()) ?? 0;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 250 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
              opacity: v.clamp(0.0, 1.0), child: child),
          child: Consumer<CartProvider>(
            builder: (_, cart, __) {
              final inCart = cart.isInCart(id);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!isEmpty) {
                    cart.addItem(CartItem(
                      id: id,
                      nama: p['nama_barang'] ?? '-',
                      harga: int.tryParse(p['harga'].toString()) ?? 0,
                      image: p['image']?.toString(),
                      kategori: p['kategori']?.toString(),
                      stokMax: int.tryParse(p['stok'].toString()) ?? 0,
                    ));
                  }
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: inCart
                            ? _primary.withOpacity(0.5)
                            : Colors.white.withOpacity(0.07)),
                    boxShadow: [BoxShadow(
                        color: inCart
                            ? _primary.withOpacity(0.15)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: inCart ? 16 : 10,
                        offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Stack(children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18)),
                          child: Container(
                            height: 120, width: double.infinity,
                            decoration: BoxDecoration(gradient: LinearGradient(
                              colors: [_primary.withOpacity(0.15),
                                _accent.withOpacity(0.07)])),
                            child: imgUrl.isEmpty
                                ? const Center(child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: _primary, size: 36))
                                : Image.network(imgUrl, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Center(child: Icon(
                                            Icons.broken_image_outlined,
                                            color: _primary, size: 30))),
                          ),
                        ),
                        if (inCart)
                          Positioned(top: 8, right: 8, child: Container(
                            width: 26, height: 26,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [_primary, _accent]),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14),
                          )),
                        if (isEmpty)
                          Positioned.fill(child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    topRight: Radius.circular(18))),
                            child: const Center(child: Text('HABIS',
                                style: TextStyle(fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _red, fontFamily: 'Poppins'))),
                          )),
                        if (isLow)
                          Positioned(top: 8, left: 8, child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: _amber.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('${p['stok']} sisa',
                                style: const TextStyle(fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white, fontFamily: 'Poppins')),
                          )),
                      ]),
                      // Info
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['nama_barang'] ?? '-',
                                style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white, fontFamily: 'Poppins'),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatRp(p['harga']),
                                    style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _green, fontFamily: 'Poppins')),
                                if (!isEmpty)
                                  Container(
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      gradient: inCart
                                          ? const LinearGradient(
                                              colors: [_green, _green])
                                          : const LinearGradient(
                                              colors: [_primary, _accent]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                        inCart
                                            ? Icons.check_rounded
                                            : Icons.add_rounded,
                                        color: Colors.white, size: 14),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );

  // ── PROMO BANNER ──────────────────────────────────────────
  Widget _buildPromoBanner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Expanded(child: _promoBannerCard(
          '🎁', 'Voucher\nGratis', 'Claim sekarang',
          [_pink, Color(0xFFEC4899).withOpacity(0.6)])),
      const SizedBox(width: 12),
      Expanded(child: _promoBannerCard(
          '💎', 'Member\nVIP', 'Daftar gratis',
          [_amber, Color(0xFFF59E0B).withOpacity(0.6)])),
    ]),
  );

  Widget _promoBannerCard(String emoji, String title, String sub,
      List<Color> grad) =>
      GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: grad,
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
                color: grad[0].withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w800, color: Colors.white,
                    fontFamily: 'Poppins', height: 1.2)),
                const SizedBox(height: 4),
                Text(sub, style: TextStyle(fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Poppins')),
              ],
            )),
          ]),
        ),
      );

  // ── MAIN PRODUCT GRID ─────────────────────────────────────
  Widget _buildProductGrid() {
    final list = _filteredProducts;
    if (list.isEmpty) return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Column(children: [
        Container(width: 72, height: 72,
            decoration: BoxDecoration(color: _primary.withOpacity(0.08),
                shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded, color: _primary, size: 32)),
        const SizedBox(height: 14),
        const Text('Tidak ada produk',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins')),
      ])),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.70,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildGridCard(list[i], i),
      ),
    );
  }

  Widget _buildGridCard(dynamic p, int index) {
    final imgUrl  = _fixImage(p['image']?.toString());
    final isLow   = (p['stok'] ?? 0) <= 10 && (p['stok'] ?? 0) > 0;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final id      = int.tryParse(p['id'].toString()) ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: Consumer<CartProvider>(
        builder: (_, cart, __) {
          final inCart = cart.isInCart(id);
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (!isEmpty && !inCart) {
                cart.addItem(CartItem(
                  id: id,
                  nama: p['nama_barang'] ?? '-',
                  harga: int.tryParse(p['harga'].toString()) ?? 0,
                  image: p['image']?.toString(),
                  kategori: p['kategori']?.toString(),
                  stokMax: int.tryParse(p['stok'].toString()) ?? 0,
                ));
              } else if (inCart) {
                cart.removeItem(id);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: inCart
                        ? _primary.withOpacity(0.45)
                        : Colors.white.withOpacity(0.07)),
                boxShadow: [BoxShadow(
                    color: inCart
                        ? _primary.withOpacity(0.15)
                        : Colors.black.withOpacity(0.22),
                    blurRadius: inCart ? 18 : 12,
                    offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image area
                  Stack(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Container(
                        height: 130, width: double.infinity,
                        decoration: BoxDecoration(gradient: LinearGradient(
                          colors: [_primary.withOpacity(0.15),
                            _accent.withOpacity(0.07)])),
                        child: imgUrl.isEmpty
                            ? const Center(child: Icon(
                                Icons.shopping_bag_outlined,
                                color: _primary, size: 40))
                            : Image.network(imgUrl, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(
                                        Icons.broken_image_outlined,
                                        color: _primary, size: 34))),
                      ),
                    ),
                    // In-cart checkmark
                    if (inCart)
                      Positioned(top: 8, right: 8, child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [_primary, _accent]),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 15),
                      )),
                    // Habis overlay
                    if (isEmpty)
                      Positioned.fill(child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        child: const Center(child: Text('HABIS',
                            style: TextStyle(fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _red, fontFamily: 'Poppins',
                                letterSpacing: 1))),
                      )),
                    // Stok terbatas badge
                    if (isLow)
                      Positioned(top: 8, left: 8, child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: _amber.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(7)),
                        child: Text('${p['stok']} sisa',
                            style: const TextStyle(fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white, fontFamily: 'Poppins')),
                      )),
                  ]),

                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: _primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(p['kategori'] ?? 'Umum',
                                style: const TextStyle(fontSize: 9,
                                    color: _primary, fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 6),
                          Text(p['nama_barang'] ?? '-',
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins',
                                  height: 1.2),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Text(_formatRpFull(p['harga']),
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _green, fontFamily: 'Poppins')),
                          const SizedBox(height: 8),
                          // CTA button
                          isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                          color: _red.withOpacity(0.2))),
                                  child: const Center(child: Text('Habis',
                                      style: TextStyle(fontSize: 10,
                                          color: _red, fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700))),
                                )
                              : AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    gradient: inCart
                                        ? LinearGradient(
                                            colors: [_green, _green.withOpacity(0.7)])
                                        : const LinearGradient(
                                            colors: [_primary, _accent]),
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: [BoxShadow(
                                        color: (inCart ? _green : _primary)
                                            .withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2))],
                                  ),
                                  child: Center(child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                          inCart ? Icons.check_rounded
                                              : Icons.add_shopping_cart_rounded,
                                          size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(inCart ? 'Di Keranjang' : 'Tambah',
                                          style: const TextStyle(fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              fontFamily: 'Poppins')),
                                    ],
                                  )),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ERROR ─────────────────────────────────────────────────
  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 68, height: 68,
          decoration: BoxDecoration(color: _red.withOpacity(0.08),
              shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, color: _red, size: 30)),
      const SizedBox(height: 14),
      const Text('Gagal Memuat',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              color: Colors.white, fontFamily: 'Poppins')),
      const SizedBox(height: 6),
      Text(_errorMsg ?? '',
          style: TextStyle(fontSize: 12,
              color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins'),
          textAlign: TextAlign.center),
      const SizedBox(height: 22),
      ElevatedButton.icon(
        onPressed: _loadAll,
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

// ── Banner data model ─────────────────────────────────────
class _BannerData {
  final String       title;
  final String       subtitle;
  final String       emoji;
  final List<Color>  grad;
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.grad,
  });
}