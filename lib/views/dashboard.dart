import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/models/toko_model.dart';
import 'package:mobileapp2/models/user_login.dart';
import 'package:mobileapp2/providers/user_provider.dart';
import 'package:mobileapp2/services/tokoService.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin {
  // ── Colors (identik dgn Toko & Pesan) ────────────────────
  static const _bg      = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _amber   = Color(0xFFF59E0B);
  static const _red     = Color(0xFFEF4444);
  static const _blue    = Color(0xFF3B82F6);

  // ── Services ──────────────────────────────────────────────
  final UserLogin    _userLogin    = UserLogin();
  final TokoService  _tokoService  = TokoService();

  // ── State ─────────────────────────────────────────────────
  String?           nama;
  String?           role;
  bool              isLoading = true;
  bool              _refreshing = false;
  List<TokoModel>   products = [];
  int               _chartPeriod = 6; // 3 or 6
  int               _activeStatTab = 0; // 0=produk,1=stok,2=nilai
  String?           _errorMsg;

  // ── Animations ────────────────────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _pulseAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _pulse;

  // ── Chart data (static – replace with API) ────────────────
  final Map<int, List<Map<String, dynamic>>> _chartData = {
    3: [
      {'month': 'Apr', 'sales': 280, 'orders': 34},
      {'month': 'Mei', 'sales': 350, 'orders': 41},
      {'month': 'Jun', 'sales': 420, 'orders': 52},
    ],
    6: [
      {'month': 'Jan', 'sales': 120, 'orders': 14},
      {'month': 'Feb', 'sales': 180, 'orders': 22},
      {'month': 'Mar', 'sales': 220, 'orders': 28},
      {'month': 'Apr', 'sales': 280, 'orders': 34},
      {'month': 'Mei', 'sales': 350, 'orders': 41},
      {'month': 'Jun', 'sales': 420, 'orders': 52},
    ],
  };

  // ── Computed stats ────────────────────────────────────────
  int get totalStok   => products.fold(0, (s, p) => s + (p.stok ?? 0));
  int get totalNilai  => products.fold(0, (s, p) => s + ((p.harga ?? 0) * (p.stok ?? 0)));
  int get hargaMaks   => products.isEmpty ? 0
      : products.map((p) => p.harga ?? 0).reduce((a, b) => a > b ? a : b);
  int get stokTerbatas => products.where((p) => (p.stok ?? 0) <= 10).length;
  int get stokHabis   => products.where((p) => (p.stok ?? 0) == 0).length;
  List<TokoModel> get topProduk => [...products]
    ..sort((a, b) => ((b.harga ?? 0) * (b.stok ?? 0))
        .compareTo((a.harga ?? 0) * (a.stok ?? 0)));

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseAnim  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(
        begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerAnim, curve: Curves.easeOutCubic));
    _pulse = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));
    _loadAll();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  Future<void> _loadAll({bool refresh = false}) async {
    if (refresh) setState(() => _refreshing = true);
    await Future.wait([_getUserLogin(), _getProducts()]);
    if (mounted) {
      setState(() => _refreshing = false);
      _headerAnim.forward(from: 0);
    }
  }

  Future<void> _getUserLogin() async {
    final user = await _userLogin.getUserLogin();
    if (mounted) {
      if (user.status != false && user.name != null) {
        setState(() {
          nama      = user.name;
          role      = user.role;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _getProducts() async {
    try {
      final result = await _tokoService.getToko();
      if (mounted && result.status == true) {
        setState(() {
          products  = List<TokoModel>.from(result.data ?? []);
          _errorMsg = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  String fixImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$image';
  }

  String formatRp(int val) {
    if (val >= 1000000000) return 'Rp ${(val / 1000000000).toStringAsFixed(1)}M';
    if (val >= 1000000)    return 'Rp ${(val / 1000000).toStringAsFixed(1)}Jt';
    if (val >= 1000)       return 'Rp ${(val / 1000).toStringAsFixed(0)}rb';
    return 'Rp $val';
  }

  String formatRpFull(int val) {
    final s = val.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── Logout dialog ─────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.97),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded,
                        size: 32, color: _red),
                  ),
                  const SizedBox(height: 20),
                  const Text('Konfirmasi Logout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins', color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('Apakah kamu yakin ingin keluar?',
                      style: TextStyle(fontSize: 13,
                          color: Colors.white.withOpacity(0.55),
                          fontFamily: 'Poppins'),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(child: Text('Batal',
                              style: TextStyle(color: Colors.white60,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await _userLogin.clearUserLogin();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [_red, _red.withOpacity(0.7)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('Logout',
                              style: TextStyle(color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700))),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (isLoading) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadAll(refresh: true),
          color: _primary,
          backgroundColor: _surface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(userProvider),
              if (_refreshing)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    color: _primary,
                    backgroundColor: _surface,
                    minHeight: 2,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _headerFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildWelcomeCard(userProvider),
                          const SizedBox(height: 20),
                          _buildQuickStatsScroll(),
                          const SizedBox(height: 20),
                          _buildAlertBanner(),
                          _buildStatGrid(),
                          const SizedBox(height: 20),
                          _buildChart(),
                          const SizedBox(height: 20),
                          _buildCategoryBreakdown(),
                          const SizedBox(height: 20),
                          _buildTopProducts(),
                          const SizedBox(height: 20),
                          _buildRecentProducts(),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────
  Widget _buildAppBar(UserProvider userProvider) => SliverAppBar(
    automaticallyImplyLeading: false,
    expandedHeight: 80,
    collapsedHeight: 80,
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
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_primary, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: _primary.withOpacity(0.4),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.dashboard_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Dashboard',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins', color: Colors.white,
                          letterSpacing: -0.3)),
                  Text('Overview & Analytics',
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.45),
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
            // Refresh button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _loadAll(refresh: true);
              },
              child: Container(
                width: 38, height: 38,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Icon(Icons.refresh_rounded,
                    color: Colors.white.withOpacity(0.6), size: 18),
              ),
            ),
            // Logout button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showLogoutDialog();
              },
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _red.withOpacity(0.2)),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: _red, size: 18),
              ),
            ),
          ]),
        ),
      ),
    ),
  );

  // ── WELCOME CARD ──────────────────────────────────────────
  Widget _buildWelcomeCard(UserProvider userProvider) {
    final now    = DateTime.now();
    final hour   = now.hour;
    final greeting = hour < 12 ? 'Selamat Pagi'
        : hour < 15 ? 'Selamat Siang'
        : hour < 18 ? 'Selamat Sore' : 'Selamat Malam';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
            color: _primary.withOpacity(0.35),
            blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: TextStyle(fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Text(userProvider.userName ?? nama ?? 'Admin',
                  style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w800, color: Colors.white,
                      fontFamily: 'Poppins', letterSpacing: -0.5),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Wrap(spacing: 8, 
              runSpacing: 8,
              children: [
                _welBadge(Icons.verified_rounded,
                    role?.toUpperCase() ?? 'ADMIN'),
                _welBadge(Icons.shopping_bag_outlined,
                    '${products.length} Produk'),
                if (stokTerbatas > 0)
                  _welBadge(Icons.warning_amber_rounded,
                      '$stokTerbatas Perlu Restock',
                      color: _amber),
              ]),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Avatar lingkaran
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          ),
          child: ClipOval(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.person_rounded, color: Colors.white, size: 36),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _welBadge(IconData icon, String label, {Color color = Colors.white}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color == Colors.white
              ? Colors.white.withOpacity(0.18)
              : color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w700, color: color,
              fontFamily: 'Poppins')),
        ]),
      );

  // ── QUICK STATS (horizontal scroll) ──────────────────────
  Widget _buildQuickStatsScroll() => SizedBox(
    height: 96,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _statPill('Total Produk', '${products.length}',
            Icons.shopping_bag_outlined, _primary),
        _statPill('Total Stok', '$totalStok',
            Icons.inventory_2_outlined, _green),
        _statPill('Nilai Aset', formatRp(totalNilai),
            Icons.account_balance_wallet_outlined, _accent),
        _statPill('Harga Maks', formatRp(hargaMaks),
            Icons.trending_up_rounded, _amber),
        _statPill('Stok Habis', '$stokHabis',
            Icons.remove_shopping_cart_outlined, _red),
      ],
    ),
  );

  Widget _statPill(String label, String value, IconData icon, Color color) =>
      Container(
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color.withOpacity(0.18), color.withOpacity(0.06)
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Poppins')),
                Text(value, style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: Colors.white,
                    fontFamily: 'Poppins')),
              ]),
        ]),
      );

  // ── ALERT BANNER (stok rendah / habis) ───────────────────
  Widget _buildAlertBanner() {
    if (stokHabis == 0 && stokTerbatas == 0) return const SizedBox();
    return Column(children: [
      if (stokHabis > 0)
        _alertRow(Icons.remove_shopping_cart_outlined,
            '$stokHabis produk stok HABIS — segera restock!', _red),
      if (stokTerbatas > 0)
        _alertRow(Icons.warning_amber_rounded,
            '$stokTerbatas produk stok terbatas (≤10 unit)', _amber),
      const SizedBox(height: 20),
    ]);
  }

  Widget _alertRow(IconData icon, String msg, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(children: [
      ScaleTransition(
        scale: _pulse,
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: TextStyle(fontSize: 12,
          color: color, fontFamily: 'Poppins',
          fontWeight: FontWeight.w600))),
    ]),
  );

  // ── STAT GRID (2x2) ───────────────────────────────────────
  Widget _buildStatGrid() => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 14,
    mainAxisSpacing: 14,
    childAspectRatio: 1.05,
    children: [
      _statCard(Icons.shopping_bag_outlined, 'Total Produk',
          '${products.length}', 'item terdaftar', _primary),
      _statCard(Icons.inventory_2_outlined, 'Total Stok',
          '$totalStok', 'unit tersedia', _green),
      _statCard(Icons.trending_up_rounded, 'Harga Tertinggi',
          formatRp(hargaMaks), 'per produk', _amber),
      _statCard(Icons.account_balance_wallet_outlined, 'Nilai Inventori',
          formatRp(totalNilai), 'total aset', _accent),
    ],
  );

  Widget _statCard(IconData icon, String title, String value,
      String sub, Color color) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) => Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, 14 * (1 - v)), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(value, style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: Colors.white, fontFamily: 'Poppins',
                  letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(title, style: TextStyle(
                  fontSize: 12, color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              const SizedBox(height: 1),
              Text(sub, style: TextStyle(
                  fontSize: 10, color: color.withOpacity(0.8),
                  fontFamily: 'Poppins')),
            ],
          ),
        ),
      );

  // ── CHART ─────────────────────────────────────────────────
  Widget _buildChart() {
    final data = _chartData[_chartPeriod]!;
    final maxY = (data.map((d) => d['sales'] as int).reduce((a, b) => a > b ? a : b) + 80).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.bar_chart_rounded,
                color: _primary, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Sales Overview',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins', color: Colors.white)),
          ),
          // Period toggle
          Container(
            decoration: BoxDecoration(
                color: _surface, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [3, 6].map((p) {
              final active = _chartPeriod == p;
              return GestureDetector(
                onTap: () => setState(() => _chartPeriod = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: active ? const LinearGradient(
                        colors: [_primary, _accent]) : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$p Bln', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: active ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontFamily: 'Poppins')),
                ),
              );
            }).toList()),
          ),
        ]),
        const SizedBox(height: 8),
        // Summary row
        Row(children: [
          _chartSummary('Total Sales',
              '${data.fold(0, (s, d) => s + (d['sales'] as int))}',
              _primary),
          const SizedBox(width: 16),
          _chartSummary('Total Orders',
              '${data.fold(0, (s, d) => s + (d['orders'] as int))}',
              _green),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.05),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= data.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(data[idx]['month'] as String,
                          style: TextStyle(fontSize: 10,
                              color: Colors.white.withOpacity(0.45),
                              fontFamily: 'Poppins')),
                    );
                  },
                  reservedSize: 28,
                ),
              ),
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              // Sales line
              LineChartBarData(
                spots: data.asMap().entries.map((e) =>
                    FlSpot(e.key.toDouble(),
                        (e.value['sales'] as int).toDouble())).toList(),
                isCurved: true,
                gradient: const LinearGradient(colors: [_primary, _accent]),
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_primary.withOpacity(0.25),
                      _primary.withOpacity(0.0)],
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: _accent,
                        strokeWidth: 2,
                        strokeColor: _bg,
                      ),
                ),
              ),
              // Orders line (secondary)
              LineChartBarData(
                spots: data.asMap().entries.map((e) =>
                    FlSpot(e.key.toDouble(),
                        (e.value['orders'] as int).toDouble() * 8)).toList(),
                isCurved: true,
                color: _green.withOpacity(0.6),
                barWidth: 2,
                isStrokeCapRound: true,
                dashArray: [5, 4],
                belowBarData: BarAreaData(show: false),
                dotData: const FlDotData(show: false),
              ),
            ],
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
          )),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(children: [
          _legend(_primary, 'Sales'),
          const SizedBox(width: 16),
          _legend(_green, 'Orders (scaled)'),
        ]),
      ]),
    );
  }

  Widget _chartSummary(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 10,
          color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins')),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
          color: color, fontFamily: 'Poppins')),
    ],
  );

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 16, height: 3,
        decoration: BoxDecoration(color: color,
            borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 10,
        color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins')),
  ]);

  // ── CATEGORY BREAKDOWN ────────────────────────────────────
  Widget _buildCategoryBreakdown() {
    if (products.isEmpty) return const SizedBox();
    // Group by kategori
    final Map<String, int> cats = {};
    for (final p in products) {
      final k = p.kategori ?? 'Lainnya';
      cats[k] = (cats[k] ?? 0) + 1;
    }
    final sorted = cats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [_primary, _accent, _green, _amber, _blue, _red];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
            blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.pie_chart_rounded,
                color: _accent, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Sebaran Kategori',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins', color: Colors.white)),
        ]),
        const SizedBox(height: 16),
        ...sorted.take(5).toList().asMap().entries.map((entry) {
          final i     = entry.key;
          final cat   = entry.value;
          final pct   = (cat.value / products.length * 100).round();
          final color = colors[i % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(cat.key,
                    style: const TextStyle(fontSize: 12,
                        color: Colors.white, fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600))),
                Text('${cat.value} produk · $pct%',
                    style: TextStyle(fontSize: 11,
                        color: Colors.white.withOpacity(0.45),
                        fontFamily: 'Poppins')),
              ]),
              const SizedBox(height: 6),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct / 100),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  // ── TOP PRODUCTS (by nilai) ───────────────────────────────
  Widget _buildTopProducts() {
    if (products.isEmpty) return const SizedBox();
    final top = topProduk.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
            blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.emoji_events_rounded,
                color: _amber, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Top Produk (Nilai Tertinggi)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins', color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 16),
        ...top.asMap().entries.map((entry) {
          final i    = entry.key;
          final item = entry.value;
          final nilai = (item.harga ?? 0) * (item.stok ?? 0);
          final medals = ['🥇', '🥈', '🥉'];
          final imgUrl = fixImageUrl(item.image);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(children: [
              Text(medals[i],
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_primary.withOpacity(0.18),
                        _accent.withOpacity(0.08)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imgUrl.isEmpty
                      ? const Icon(Icons.shopping_bag_outlined,
                      color: _primary, size: 22)
                      : Image.network(imgUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined,
                          color: _primary, size: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama_barang ?? '-',
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700, color: Colors.white,
                          fontFamily: 'Poppins'),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${item.stok ?? 0} unit · ${item.kategori ?? '-'}',
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                          fontFamily: 'Poppins')),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatRp(item.harga ?? 0),
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: _green,
                        fontFamily: 'Poppins')),
                Text(formatRp(nilai),
                    style: TextStyle(fontSize: 10,
                        color: Colors.white.withOpacity(0.35),
                        fontFamily: 'Poppins')),
              ]),
            ]),
          );
        }),
      ]),
    );
  }

  // ── RECENT PRODUCTS ───────────────────────────────────────
  Widget _buildRecentProducts() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.history_rounded,
                  color: _green, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Produk Terbaru',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins', color: Colors.white)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${products.length} produk',
                style: const TextStyle(fontSize: 11,
                    color: _primary, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (products.isEmpty)
        _buildEmptyState()
      else
        ...products.take(5).toList().asMap().entries.map(
              (e) => _buildProductCard(e.value, e.key)),
    ]);
  }

  Widget _buildProductCard(TokoModel item, int index) {
    final imgUrl  = fixImageUrl(item.image);
    final isLow   = (item.stok ?? 0) <= 10;
    final isEmpty = (item.stok ?? 0) == 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEmpty
                ? _red.withOpacity(0.25)
                : Colors.white.withOpacity(0.07),
          ),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          // Image
          Stack(children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_primary.withOpacity(0.15),
                      _accent.withOpacity(0.07)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imgUrl.isEmpty
                    ? const Icon(Icons.shopping_bag_outlined,
                    color: _primary, size: 26)
                    : Image.network(imgUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined,
                        color: _primary, size: 24),
                    loadingBuilder: (_, child, p) => p == null ? child
                        : const Center(child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _primary)))),
              ),
            ),
            if (isEmpty)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text('HABIS',
                          style: TextStyle(fontSize: 9,
                              fontWeight: FontWeight.w800, color: _red,
                              fontFamily: 'Poppins'))),
                ),
              ),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nama_barang ?? '-',
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: Colors.white,
                        fontFamily: 'Poppins'),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(item.kategori ?? 'Umum',
                        style: const TextStyle(fontSize: 9,
                            color: _primary, fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 7),
                Row(children: [
                  Text(formatRpFull(item.harga ?? 0),
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w800, color: _green,
                          fontFamily: 'Poppins')),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? _red.withOpacity(0.12)
                          : isLow
                          ? _amber.withOpacity(0.12)
                          : _green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isEmpty
                            ? _red.withOpacity(0.3)
                            : isLow
                            ? _amber.withOpacity(0.3)
                            : _green.withOpacity(0.25),
                      ),
                    ),
                    child: Text('${item.stok ?? 0} unit',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: isEmpty ? _red
                                : isLow ? _amber : _green,
                            fontFamily: 'Poppins')),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────
  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
            color: _primary.withOpacity(0.08), shape: BoxShape.circle),
        child: const Icon(Icons.inbox_rounded, color: _primary, size: 30),
      ),
      const SizedBox(height: 12),
      const Text('Belum ada produk', style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
          fontFamily: 'Poppins')),
      const SizedBox(height: 5),
      Text('Data produk akan tampil di sini',
          style: TextStyle(fontSize: 12,
              color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins')),
    ]),
  );
}