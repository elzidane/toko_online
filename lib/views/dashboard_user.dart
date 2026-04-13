import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/providers/cartProvider.dart';
import 'package:mobileapp2/services/user.dart';
import 'package:provider/provider.dart';
import 'package:mobileapp2/models/user_login.dart';
// import 'package:mobileapp2/providers/cart_provider.dart';
// import 'package:mobileapp2/services/userService.dart';

class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser>
    with TickerProviderStateMixin {
  // ── Design Tokens ─────────────────────────────────────────
  static const _bg      = Color(0xFF080D1A);
  static const _surface = Color(0xFF111827);
  static const _card    = Color(0xFF141E2E);
  static const _cardAlt = Color(0xFF0F1929);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _amber   = Color(0xFFF59E0B);
  static const _red     = Color(0xFFEF4444);
  static const _blue    = Color(0xFF3B82F6);
  static const _divider = Color(0xFF1E2D40);

  // ── Services ──────────────────────────────────────────────
  final UserService _service   = UserService();
  final UserLogin   _userLogin = UserLogin();

  // ── State ─────────────────────────────────────────────────
  String?       _nama;
  List<dynamic> _products     = [];
  bool          _isLoading    = true;
  String?       _errorMsg;
  String        _selectedKat  = 'Semua';
  List<String>  _kategoriList = ['Semua'];
  String        _searchQuery  = '';

  // ── Icon press states ──────────────────────────────────
  bool _isNotifPressed  = false;
  bool _isCartPressed   = false;
  bool _isLogoutPressed = false;
  bool _isStorePressred = false;

  // ── Carousel ──────────────────────────────────────────────
  int              _bannerIdx = 0;
  late PageController _pageCtrl;

  // ── Stagger animations ────────────────────────────────────
  late List<AnimationController> _staggerCtrls;
  late List<Animation<double>>   _staggerFades;
  late List<Animation<Offset>>   _staggerSlides;

  // ── Banner config ─────────────────────────────────────────
  final List<_Banner> _banners = const [
    _Banner(
      tag: 'EKSKLUSIF',
      title: 'Penawaran\nTerbaik Hari Ini',
      subtitle: 'Temukan produk pilihan dengan harga spesial',
      icon: Icons.local_fire_department_rounded,
      grad: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    ),
    _Banner(
      tag: 'BARU TIBA',
      title: 'Koleksi\nTerbaru 2024',
      subtitle: 'Produk segar yang baru saja hadir untukmu',
      icon: Icons.auto_awesome_rounded,
      grad: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _Banner(
      tag: 'GRATIS ONGKIR',
      title: 'Belanja Lebih\nHemat Sekarang',
      subtitle: 'Bebas ongkos kirim ke seluruh Indonesia',
      icon: Icons.local_shipping_rounded,
      grad: [Color(0xFF059669), Color(0xFF0EA5E9)],
    ),
    _Banner(
      tag: 'PROMO',
      title: 'Cicilan 0%\nTanpa Syarat',
      subtitle: 'Bayar nanti dengan tenor hingga 12 bulan',
      icon: Icons.credit_score_rounded,
      grad: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
  ];

  // ── Category icons ────────────────────────────────────────
  final Map<String, IconData> _katIcons = {
    'Semua'     : Icons.grid_view_rounded,
    'Elektronik': Icons.devices_rounded,
    'Pakaian'   : Icons.checkroom_rounded,
    'Makanan'   : Icons.restaurant_rounded,
    'Olahraga'  : Icons.fitness_center_rounded,
    'Kendaraan' : Icons.two_wheeler_rounded,
    'Aksesoris' : Icons.watch_rounded,
    'Kesehatan' : Icons.health_and_safety_rounded,
    'Rumah'     : Icons.home_rounded,
    'Buku'      : Icons.menu_book_rounded,
  };

  // ── Getters ───────────────────────────────────────────────
  List<dynamic> get _filtered {
    var result = _products;
    if (_selectedKat != 'Semua') {
      result = result.where((p) => p['kategori'] == _selectedKat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) {
        final nama = p['nama_barang']?.toString().toLowerCase() ?? '';
        return nama.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return result;
  }

  List<dynamic> get _featured =>
      _products.where((p) => (p['stok'] ?? 0) > 0).take(8).toList();

  List<dynamic> get _terlaris {
    final l = List<dynamic>.from(_products);
    l.sort((a, b) => (b['harga'] ?? 0).compareTo(a['harga'] ?? 0));
    return l.take(6).toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
    _staggerCtrls = List.generate(6, (_) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500)));
    _staggerFades = _staggerCtrls.map((c) =>
        Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();
    _staggerSlides = _staggerCtrls.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOutCubic))).toList();
    _loadAll();
    _startCarousel();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _staggerCtrls) c.dispose();
    super.dispose();
  }

  void _startCarousel() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_bannerIdx + 1) % _banners.length;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(next,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuart);
      }
      return mounted;
    });
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    await Future.wait([_loadUser(), _loadProducts()]);
    if (mounted) _runStagger();
  }

  void _runStagger() {
    for (int i = 0; i < _staggerCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) _staggerCtrls[i].forward();
      });
    }
  }

  Future<void> _loadUser() async {
    final user = await _userLogin.getUserLogin();
    if (mounted) setState(() => _nama = user.name);
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30, offset: const Offset(0, 10))
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _red.withOpacity(0.25)),
              ),
              child: const Icon(Icons.logout_rounded, color: _red, size: 24),
            ),
            const SizedBox(height: 16),
            const Text('Keluar Akun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Text('Apakah kamu yakin ingin logout?',
                style: TextStyle(fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Poppins', height: 1.4),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Center(child: Text('Batal',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: Colors.white, fontFamily: 'Poppins'))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: _red.withOpacity(0.3),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Center(child: Text('Logout',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: Colors.white, fontFamily: 'Poppins'))),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirm == true && mounted) {
      await _userLogin.clearUserLogin();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', (route) => false);
      }
    }
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

  // ── Helpers ───────────────────────────────────────────────
  String _fixImage(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$img';
  }

  String _formatRpShort(dynamic val) {
    final v = int.tryParse(val?.toString() ?? '0') ?? 0;
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)} Jt';
    if (v >= 1000)    return 'Rp ${(v / 1000).toStringAsFixed(0)} rb';
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
    if (h < 12) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _stagger(int idx, Widget child) => FadeTransition(
    opacity: _staggerFades[idx.clamp(0, 5)],
    child: SlideTransition(
        position: _staggerSlides[idx.clamp(0, 5)], child: child),
  );

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(
            color: _primary, strokeWidth: 2)),
      );
    }
    if (_errorMsg != null) {
      return Scaffold(backgroundColor: _bg, body: _buildError());
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAll,
          color: _primary,
          backgroundColor: _surface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false,
                backgroundColor: _bg.withOpacity(0.95),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 64,
                title: _buildAppBarTitle(),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stagger(0, _buildSearchBar()),
                    const SizedBox(height: 24),
                    _stagger(1, _buildCarousel()),
                    const SizedBox(height: 28),
                    _stagger(2, _buildQuickAccess()),
                    const SizedBox(height: 28),
                    _stagger(2, _buildCategorySection()),
                    const SizedBox(height: 28),
                    if (_featured.isNotEmpty) ...[
                      _stagger(3, _buildSectionLabel(
                          'Produk Unggulan', Icons.star_rounded, _amber)),
                      const SizedBox(height: 16),
                      _stagger(3, _buildHorizontalList(_featured)),
                      const SizedBox(height: 28),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(height: 1, color: _divider),
                    ),
                    const SizedBox(height: 28),
                    if (_terlaris.isNotEmpty) ...[
                      _stagger(4, _buildSectionLabel(
                          'Pilihan Terbaik', Icons.trending_up_rounded, _primary)),
                      const SizedBox(height: 16),
                      _stagger(4, _buildHorizontalList(_terlaris)),
                      const SizedBox(height: 28),
                    ],
                    _stagger(4, _buildPromoStrip()),
                    const SizedBox(height: 28),
                    _stagger(5, _buildSectionLabel(
                        'Semua Produk', Icons.apps_rounded, _accent)),
                    const SizedBox(height: 16),
                    _stagger(5, _buildProductGrid()),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR TITLE ─────────────────────────────────────────
  // Helper: icon button dengan animasi scale saat ditekan
  Widget _iconBtn({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required bool isPressed,
    required String pressKey,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() {
          if (pressKey == 'notif')  _isNotifPressed  = true;
          if (pressKey == 'cart')   _isCartPressed   = true;
          if (pressKey == 'logout') _isLogoutPressed = true;
          if (pressKey == 'store')  _isStorePressred = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          if (pressKey == 'notif')  _isNotifPressed  = false;
          if (pressKey == 'cart')   _isCartPressed   = false;
          if (pressKey == 'logout') _isLogoutPressed = false;
          if (pressKey == 'store')  _isStorePressred = false;
        });
        onTap();
      },
      onTapCancel: () {
        setState(() {
          if (pressKey == 'notif')  _isNotifPressed  = false;
          if (pressKey == 'cart')   _isCartPressed   = false;
          if (pressKey == 'logout') _isLogoutPressed = false;
          if (pressKey == 'store')  _isStorePressred = false;
        });
      },
      child: AnimatedScale(
        scale: isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isPressed ? bgColor.withOpacity(0.3) : bgColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: borderColor),
              boxShadow: isPressed ? [BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 10, offset: const Offset(0, 2))] : [],
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          if (badge != null) badge,
        ]),
      ),
    );
  }

  Widget _buildAppBarTitle() => Row(children: [
    // Store icon
    GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isStorePressred = true);
      },
      onTapUp: (_) => setState(() => _isStorePressred = false),
      onTapCancel: () => setState(() => _isStorePressred = false),
      child: AnimatedScale(
        scale: _isStorePressred ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: _isStorePressred
                    ? [_accent, _primary]
                    : [_primary, _accent],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
                color: _primary.withOpacity(_isStorePressred ? 0.6 : 0.3),
                blurRadius: _isStorePressred ? 14 : 8,
                offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_greeting(),
            style: TextStyle(fontSize: 10,
                color: Colors.white.withOpacity(0.4),
                fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
        Text(_nama ?? 'Pengguna',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: Colors.white, fontFamily: 'Poppins',
                letterSpacing: -0.3),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    )),
    // Notification
    _iconBtn(
      icon: Icons.notifications_outlined,
      iconColor: Colors.white.withOpacity(0.55),
      bgColor: Colors.white.withOpacity(0.05),
      borderColor: Colors.white.withOpacity(0.07),
      isPressed: _isNotifPressed,
      pressKey: 'notif',
      onTap: () {},
    ),
    const SizedBox(width: 8),
    // Cart
    Consumer<CartProvider>(builder: (_, cart, __) => _iconBtn(
      icon: Icons.shopping_bag_outlined,
      iconColor: cart.totalItems > 0 ? _primary : Colors.white.withOpacity(0.45),
      bgColor: cart.totalItems > 0
          ? _primary.withOpacity(0.15)
          : Colors.white.withOpacity(0.05),
      borderColor: cart.totalItems > 0
          ? _primary.withOpacity(0.35)
          : Colors.white.withOpacity(0.07),
      isPressed: _isCartPressed,
      pressKey: 'cart',
      onTap: () {},
      badge: cart.totalItems > 0
          ? Positioned(top: -4, right: -4, child: Container(
              width: 17, height: 17,
              decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
              child: Center(child: Text('${cart.totalItems}',
                  style: const TextStyle(fontSize: 8, color: Colors.white,
                      fontWeight: FontWeight.w800, fontFamily: 'Poppins'))),
            ))
          : null,
    )),
    const SizedBox(width: 8),
    // Logout
    _iconBtn(
      icon: Icons.logout_rounded,
      iconColor: _red.withOpacity(0.8),
      bgColor: _red.withOpacity(0.08),
      borderColor: _red.withOpacity(0.18),
      isPressed: _isLogoutPressed,
      pressKey: 'logout',
      onTap: _logout,
    ),
  ]);

  // ── SEARCH BAR ────────────────────────────────────────────
  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    child: Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.search_rounded,
            color: Colors.white.withOpacity(0.22), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            style: const TextStyle(
                fontSize: 13, color: Colors.white, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Cari produk yang kamu inginkan...',
              hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.22),
                  fontFamily: 'Poppins'),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            width: 34, height: 34,
            decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withOpacity(0.2))),
            child: const Icon(Icons.tune_rounded, color: _primary, size: 15),
          ),
        ),
      ]),
    ),
  );

  // ── BANNER CAROUSEL ───────────────────────────────────────
  Widget _buildCarousel() => Column(children: [
    SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _bannerIdx = i),
        itemCount: _banners.length,
        itemBuilder: (_, i) {
          final b      = _banners[i];
          final active = _bannerIdx == i;
          return AnimatedScale(
            scale: active ? 1.0 : 0.94,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: b.grad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                boxShadow: active ? [BoxShadow(
                    color: b.grad[0].withOpacity(0.4),
                    blurRadius: 24, offset: const Offset(0, 10))] : [],
              ),
              child: Stack(children: [
                Positioned(right: -18, top: -18, child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      shape: BoxShape.circle),
                )),
                Positioned(right: 50, bottom: -40, child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      shape: BoxShape.circle),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 18, 20),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(b.tag,
                              style: const TextStyle(fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white, fontFamily: 'Poppins',
                                  letterSpacing: 1.2)),
                        ),
                        const SizedBox(height: 10),
                        Text(b.title,
                            style: const TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w800, color: Colors.white,
                                fontFamily: 'Poppins', height: 1.15,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 6),
                        Text(b.subtitle,
                            style: TextStyle(fontSize: 11,
                                color: Colors.white.withOpacity(0.8),
                                fontFamily: 'Poppins', height: 1.4),
                            maxLines: 2),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8, offset: const Offset(0, 3))]),
                          child: GestureDetector(
                            onTap: () => HapticFeedback.lightImpact(),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('Lihat Sekarang',
                                  style: TextStyle(fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: b.grad[0], fontFamily: 'Poppins')),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 11, color: b.grad[0]),
                            ]),
                          ),
                        ),
                      ],
                    )),
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25), width: 1.5)),
                      child: Icon(b.icon, color: Colors.white, size: 30),
                    ),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    ),
    const SizedBox(height: 14),
    Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_banners.length, (i) {
          final active = _bannerIdx == i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              gradient: active ? const LinearGradient(
                  colors: [_primary, _accent]) : null,
              color: active ? null : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        })),
  ]);

  // ── QUICK ACCESS ──────────────────────────────────────────
  Widget _buildQuickAccess() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _quickItem('Flash Sale', Icons.flash_on_rounded, _amber),
          _vDivider(),
          _quickItem('Terbaru',   Icons.new_releases_rounded, _blue),
          _vDivider(),
          _quickItem('Promo',     Icons.local_offer_rounded, _primary),
          _vDivider(),
          _quickItem('Wishlist',  Icons.favorite_border_rounded, _red),
        ],
      ),
    ),
  );

  Widget _vDivider() => Container(
      width: 1, height: 34, color: Colors.white.withOpacity(0.06));

  Widget _quickItem(String label, IconData icon, Color color) =>
      _PressableIcon(
        label: label,
        icon: icon,
        color: color,
      );

  // ── CATEGORY SECTION ──────────────────────────────────────
  Widget _buildCategorySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionLabel('Kategori', Icons.category_rounded, _accent),
      const SizedBox(height: 14),
      SizedBox(
        height: 84,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _kategoriList.length,
          itemBuilder: (_, i) {
            final kat    = _kategoriList[i];
            final active = _selectedKat == kat;
            final icon   = _katIcons[kat] ?? Icons.category_rounded;
            final colors = [_primary, _accent, _green, _amber,
              _blue, _red, const Color(0xFFEC4899), const Color(0xFF14B8A6)];
            final color  = colors[i % colors.length];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedKat = kat);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: active
                          ? color.withOpacity(0.18)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? color.withOpacity(0.45)
                            : Colors.white.withOpacity(0.07),
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: active ? [BoxShadow(
                          color: color.withOpacity(0.22),
                          blurRadius: 10, offset: const Offset(0, 4))] : [],
                    ),
                    child: Icon(icon,
                        color: active ? color : Colors.white.withOpacity(0.3),
                        size: 22),
                  ),
                  const SizedBox(height: 7),
                  Text(kat.length > 8 ? '${kat.substring(0, 7)}..' : kat,
                      style: TextStyle(fontSize: 10, fontFamily: 'Poppins',
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? Colors.white : Colors.white.withOpacity(0.35))),
                ]),
              ),
            );
          },
        ),
      ),
    ],
  );

  // ── SECTION LABEL ─────────────────────────────────────────
  Widget _buildSectionLabel(String title, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(children: [
          Container(
            width: 3, height: 18,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.25)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w800, color: Colors.white,
              fontFamily: 'Poppins', letterSpacing: -0.3)),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Lihat semua',
                  style: TextStyle(fontSize: 11, color: color,
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 14, color: color),
            ]),
          ),
        ]),
      );

  // ── HORIZONTAL LIST ───────────────────────────────────────
  Widget _buildHorizontalList(List<dynamic> products) => SizedBox(
    height: 228,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: products.length,
      itemBuilder: (_, i) => _buildHCard(products[i], i),
    ),
  );

  Widget _buildHCard(dynamic p, int i) {
    final imgUrl  = _fixImage(p['image']?.toString());
    final isLow   = (p['stok'] ?? 0) > 0 && (p['stok'] ?? 0) <= 10;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final id      = int.tryParse(p['id'].toString()) ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + i * 55),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) =>
          Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      child: Consumer<CartProvider>(builder: (_, cart, __) {
        final inCart = cart.isInCart(id);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (!isEmpty) {
              if (inCart) {
                cart.removeItem(id);
              } else {
                cart.addItem(CartItem(
                  id: id,
                  nama: p['nama_barang'] ?? '-',
                  harga: int.tryParse(p['harga'].toString()) ?? 0,
                  image: p['image']?.toString(),
                  kategori: p['kategori']?.toString(),
                  stokMax: int.tryParse(p['stok'].toString()) ?? 0,
                ));
              }
            }
          },
          child: Container(
            width: 152,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: inCart
                      ? _primary.withOpacity(0.35)
                      : Colors.white.withOpacity(0.06),
                  width: inCart ? 1.5 : 1),
              boxShadow: [BoxShadow(
                  color: inCart
                      ? _primary.withOpacity(0.12)
                      : Colors.black.withOpacity(0.28),
                  blurRadius: 12, offset: const Offset(0, 5))],
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
                      height: 118, width: double.infinity,
                      color: _cardAlt,
                      child: imgUrl.isEmpty
                          ? Center(child: Icon(Icons.shopping_bag_outlined,
                              color: _primary.withOpacity(0.3), size: 34))
                          : Image.network(imgUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white.withOpacity(0.12),
                                  size: 26))),
                    ),
                  ),
                  if (isEmpty)
                    Positioned.fill(child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18)),
                      child: Container(
                        color: Colors.black.withOpacity(0.62),
                        child: Center(child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: _red, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Habis', style: TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w800, color: Colors.white,
                              fontFamily: 'Poppins')),
                        )),
                      ),
                    )),
                  if (isLow)
                    Positioned(bottom: 0, left: 0, right: 0, child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: _amber,
                      child: Center(child: Text('Sisa ${p['stok']}',
                          style: const TextStyle(fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white, fontFamily: 'Poppins'))),
                    )),
                  if (inCart)
                    Positioned(top: 8, right: 8, child: Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [_primary, _accent]),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12),
                    )),
                ]),
                // Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['nama_barang'] ?? '-',
                          style: const TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w700, color: Colors.white,
                              fontFamily: 'Poppins', height: 1.25),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatRpShort(p['harga']),
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w800, color: _green,
                                  fontFamily: 'Poppins')),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: isEmpty
                                  ? Colors.white.withOpacity(0.04)
                                  : inCart
                                  ? _green.withOpacity(0.15)
                                  : _primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  color: isEmpty
                                      ? Colors.white.withOpacity(0.07)
                                      : inCart
                                      ? _green.withOpacity(0.3)
                                      : _primary.withOpacity(0.25)),
                            ),
                            child: Icon(
                                isEmpty ? Icons.remove_rounded
                                    : inCart ? Icons.check_rounded
                                    : Icons.add_rounded,
                                color: isEmpty
                                    ? Colors.white.withOpacity(0.15)
                                    : inCart ? _green : _primary,
                                size: 14),
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
      }),
    );
  }

  // ── PROMO STRIP ───────────────────────────────────────────
  Widget _buildPromoStrip() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(children: [
      Expanded(child: _promoCard(
          'Gratis Ongkir', 'Min. belanja Rp 100rb',
          Icons.local_shipping_rounded, _green,
          [const Color(0xFF052E16), const Color(0xFF064E3B)])),
      const SizedBox(width: 12),
      Expanded(child: _promoCard(
          'Cicilan 0%', 'Tenor hingga 12 bulan',
          Icons.credit_score_rounded, _blue,
          [const Color(0xFF1E3A5F), const Color(0xFF1E40AF)])),
    ]),
  );

  Widget _promoCard(String title, String sub, IconData icon, Color color,
      List<Color> bgGrad) =>
      GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: bgGrad,
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w800, color: Colors.white,
                    fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 10,
                    color: Colors.white.withOpacity(0.5), fontFamily: 'Poppins')),
              ],
            )),
          ]),
        ),
      );

  // ── PRODUCT GRID ──────────────────────────────────────────
  Widget _buildProductGrid() {
    final list = _filtered;
    if (list.isEmpty) return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Column(children: [
        Container(width: 60, height: 60,
            decoration: BoxDecoration(
                color: _primary.withOpacity(0.06), shape: BoxShape.circle),
            child: Icon(Icons.inbox_rounded,
                color: _primary.withOpacity(0.4), size: 26)),
        const SizedBox(height: 12),
        Text('Tidak ada produk',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.35), fontFamily: 'Poppins')),
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
          childAspectRatio: 0.60,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildGridCard(list[i], i),
      ),
    );
  }

  Widget _buildGridCard(dynamic p, int index) {
    final imgUrl  = _fixImage(p['image']?.toString());
    final isLow   = (p['stok'] ?? 0) > 0 && (p['stok'] ?? 0) <= 10;
    final isEmpty = (p['stok'] ?? 0) == 0;
    final id      = int.tryParse(p['id'].toString()) ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
      ),
      child: Consumer<CartProvider>(builder: (_, cart, __) {
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
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: inCart
                      ? _primary.withOpacity(0.32)
                      : Colors.white.withOpacity(0.06),
                  width: inCart ? 1.5 : 1),
              boxShadow: [BoxShadow(
                  color: inCart
                      ? _primary.withOpacity(0.1)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: 12, offset: const Offset(0, 5))],
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
                      height: 130, width: double.infinity,
                      color: _cardAlt,
                      child: imgUrl.isEmpty
                          ? Center(child: Icon(Icons.shopping_bag_outlined,
                              color: _primary.withOpacity(0.3), size: 36))
                          : Image.network(imgUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white.withOpacity(0.1),
                                  size: 28))),
                    ),
                  ),
                  if (isEmpty)
                    Positioned.fill(child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18)),
                      child: Container(
                        color: Colors.black.withOpacity(0.65),
                        child: Center(child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: _red,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Text('Stok Habis',
                              style: TextStyle(fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white, fontFamily: 'Poppins')),
                        )),
                      ),
                    )),
                  if (isLow)
                    Positioned(bottom: 0, left: 0, right: 0, child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: _amber,
                      child: Center(child: Text('Sisa ${p['stok']} unit',
                          style: const TextStyle(fontSize: 9,
                              fontWeight: FontWeight.w700, color: Colors.white,
                              fontFamily: 'Poppins'))),
                    )),
                  if (inCart)
                    Positioned(top: 8, right: 8, child: Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [_primary, _accent]),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13),
                    )),
                ]),
                // Info
                Expanded(child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['kategori'] ?? 'Umum',
                          style: TextStyle(fontSize: 9,
                              color: _primary.withOpacity(0.75),
                              fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 5),
                      Text(p['nama_barang'] ?? '-',
                          style: const TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w700, color: Colors.white,
                              fontFamily: 'Poppins', height: 1.2),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(_formatRpFull(p['harga']),
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w800, color: _green,
                              fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.07))),
                              child: Center(child: Text('Tidak tersedia',
                                  style: TextStyle(fontSize: 10,
                                      color: Colors.white.withOpacity(0.25),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600))),
                            )
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: inCart
                                    ? const LinearGradient(colors: [
                                        Color(0xFF059669), Color(0xFF10B981)])
                                    : const LinearGradient(
                                        colors: [_primary, _accent]),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(
                                    color: (inCart ? _green : _primary)
                                        .withOpacity(0.25),
                                    blurRadius: 8, offset: const Offset(0, 3))],
                              ),
                              child: Center(child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(inCart
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(inCart ? 'Di Keranjang' : 'Tambah',
                                      style: const TextStyle(fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Poppins')),
                                ],
                              )),
                            ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── ERROR ─────────────────────────────────────────────────
  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 64, height: 64,
          decoration: BoxDecoration(color: _red.withOpacity(0.07),
              shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, color: _red, size: 26)),
      const SizedBox(height: 16),
      const Text('Koneksi Bermasalah',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
              color: Colors.white, fontFamily: 'Poppins')),
      const SizedBox(height: 6),
      Text(_errorMsg ?? '',
          style: TextStyle(fontSize: 12,
              color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins'),
          textAlign: TextAlign.center),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: _loadAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_primary, _accent]),
              borderRadius: BorderRadius.circular(12)),
          child: const Text('Coba Lagi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, fontFamily: 'Poppins')),
        ),
      ),
    ]),
  ));
}

// ── Banner model ──────────────────────────────────────────
class _Banner {
  final String      tag;
  final String      title;
  final String      subtitle;
  final IconData    icon;
  final List<Color> grad;
  const _Banner({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.grad,
  });
}

// ── Pressable Icon widget (quick access) ──────────────────
class _PressableIcon extends StatefulWidget {
  final String   label;
  final IconData icon;
  final Color    color;

  const _PressableIcon({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  State<_PressableIcon> createState() => _PressableIconState();
}

class _PressableIconState extends State<_PressableIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _pressed
                  ? widget.color.withOpacity(0.22)
                  : widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _pressed
                    ? widget.color.withOpacity(0.5)
                    : widget.color.withOpacity(0.18),
              ),
              boxShadow: _pressed
                  ? [BoxShadow(
                      color: widget.color.withOpacity(0.35),
                      blurRadius: 12, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          const SizedBox(height: 7),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: _pressed ? FontWeight.w700 : FontWeight.w600,
              color: _pressed
                  ? Colors.white
                  : Colors.white.withOpacity(0.55),
            ),
            child: Text(widget.label),
          ),
        ]),
      ),
    );
  }
}