import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  final UserLogin _userLogin = UserLogin();
  final TokoService _tokoService = TokoService();

  String? nama;
  String? role;
  bool isLoading = true;
  List<TokoModel> products = [];

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Chart data statis (bisa diganti dari API jika tersedia)
  final List<Map<String, dynamic>> salesData = [
    {'month': 'Jan', 'sales': 120},
    {'month': 'Feb', 'sales': 180},
    {'month': 'Mar', 'sales': 220},
    {'month': 'Apr', 'sales': 280},
    {'month': 'May', 'sales': 350},
    {'month': 'Jun', 'sales': 420},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _loadAll();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_getUserLogin(), _getProducts()]);
    if (mounted) _animController.forward();
  }

  Future<void> _getUserLogin() async {
    var user = await _userLogin.getUserLogin();
    if (mounted) {
      if (user.status != false && user.name != null) {
        setState(() {
          nama = user.name;
          role = user.role;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _getProducts() async {
    var result = await _tokoService.getToko();
    if (mounted && result.status == true) {
      setState(() {
        products = List<TokoModel>.from(result.data ?? []);
      });
    }
  }

  // ── HELPER ────────────────────────────────────────────────
  String fixImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'https://learn.smktelkom-mlg.sch.id/toko/$image';
  }

  String formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp $amount';
  }

  int get totalStok =>
      products.fold(0, (sum, p) => sum + (p.stok ?? 0));

  int get totalNilai =>
      products.fold(0, (sum, p) => sum + ((p.harga ?? 0) * (p.stok ?? 0)));

  int get hargaTertinggi => products.isEmpty
      ? 0
      : products.map((p) => p.harga ?? 0).reduce((a, b) => a > b ? a : b);

  // ── LOGOUT DIALOG ─────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 32, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text('Konfirmasi Logout',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                'Apakah kamu yakin ingin keluar?',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.15)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Batal',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _userLogin.clearUserLogin();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF6366F1), strokeWidth: 2))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // ── APP BAR ──
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 60,
                    collapsedHeight: 60,
                    floating: true,
                    pinned: true,
                    backgroundColor: const Color(0xFF1E293B),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding:
                          const EdgeInsets.only(left: 20, bottom: 12),
                      title: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              gradient: const LinearGradient(colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6)
                              ]),
                            ),
                            child: const Icon(Icons.dashboard_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Dashboard',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      color: Colors.white)),
                              Text('Overview & Analytics',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontFamily: 'Poppins')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: _showLogoutDialog,
                        icon: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.red, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── WELCOME CARD ──
                        _buildWelcomeCard(userProvider),
                        const SizedBox(height: 24),

                        // ── STAT GRID ──
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.0,
                          children: [
                            _buildStatCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Total Produk',
                              value: products.length.toString(),
                              color: const Color(0xFF6366F1),
                              sub: 'item terdaftar',
                            ),
                            _buildStatCard(
                              icon: Icons.inventory_2_outlined,
                              title: 'Total Stok',
                              value: totalStok.toString(),
                              color: const Color(0xFF10B981),
                              sub: 'unit tersedia',
                            ),
                            _buildStatCard(
                              icon: Icons.trending_up_rounded,
                              title: 'Harga Tertinggi',
                              value: formatCurrency(hargaTertinggi),
                              color: const Color(0xFFF59E0B),
                              sub: 'per produk',
                            ),
                            _buildStatCard(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Nilai Inventori',
                              value: formatCurrency(totalNilai),
                              color: const Color(0xFF8B5CF6),
                              sub: 'total aset',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── CHART ──
                        _buildChart(),
                        const SizedBox(height: 24),

                        // ── PRODUK TERBARU ──
                        _buildSectionHeader('Produk Terbaru', products.length),
                        const SizedBox(height: 14),

                        if (products.isEmpty)
                          _buildEmptyState()
                        else
                          ...products
                              .take(5)
                              .map((p) => _buildProductCard(p))
                              .toList(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── WELCOME CARD ──────────────────────────────────────────
  Widget _buildWelcomeCard(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang,',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 4),
                Text(
                  userProvider.userName ?? nama ?? 'Admin',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.3),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        role?.toUpperCase() ?? 'ADMIN',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  // ── STAT CARD ─────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 3),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500)),
          if (sub != null) ...[
            const SizedBox(height: 1),
            Text(sub,
                style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                    fontFamily: 'Poppins')),
          ],
        ],
      ),
    );
  }

  // ── CHART ─────────────────────────────────────────────────
  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sales Overview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('6 Bulan',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6366F1),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: salesData.asMap().entries.map((e) {
                      return FlSpot(
                          e.key.toDouble(),
                          (e.value['sales'] as int).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF6366F1),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.3),
                          const Color(0xFF6366F1).withOpacity(0.0),
                        ],
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
                minX: 0,
                maxX: (salesData.length - 1).toDouble(),
                minY: 0,
                maxY: 500,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: salesData
                .map((d) => Text(d['month'],
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                        fontFamily: 'Poppins')))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Colors.white)),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$count produk',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6366F1),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── PRODUCT CARD ──────────────────────────────────────────
  Widget _buildProductCard(TokoModel item) {
    final imageUrl = fixImageUrl(item.image);
    final isLowStock = (item.stok ?? 0) <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          // Gambar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF6366F1).withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.shopping_bag_outlined,
                      color: Color(0xFF6366F1), size: 28)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF6366F1),
                          size: 28),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6366F1)))),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama_barang ?? '-',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.kategori ?? 'Tanpa Kategori',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.45),
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rp ${item.harga ?? 0}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                          fontFamily: 'Poppins'),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.stok ?? 0} stok',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isLowStock
                                ? Colors.orange
                                : Colors.green,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              color: Color(0xFF6366F1), size: 40),
          const SizedBox(height: 12),
          const Text('Belum ada produk',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text('Data produk akan tampil di sini',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}