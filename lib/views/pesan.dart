import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Pesan extends StatefulWidget {
  const Pesan({super.key});

  @override
  State<Pesan> createState() => _PesanState();
}

class _PesanState extends State<Pesan> with TickerProviderStateMixin {
  // ── Colors (sama persis dgn Toko) ────────────────────────
  static const _bg      = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card    = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);
  static const _amber   = Color(0xFFF59E0B);
  static const _red     = Color(0xFFEF4444);
  static const _blue    = Color(0xFF3B82F6);

  // ── Animations ────────────────────────────────────────────
  late AnimationController _headerAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  // ── State ─────────────────────────────────────────────────
  int    _selectedFilter = 0;
  String _searchQuery    = '';
  String _sortMode       = 'terbaru';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filterLabels = [
    'Semua', 'Pending', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan',
  ];
  final List<String?> _filterStatus = [
    null, 'pending', 'processed', 'shipped', 'completed', 'cancelled',
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-2024-001', 'customer': 'Budi Santoso',
      'email': 'budi@gmail.com', 'phone': '081234567890',
      'date': '2024-01-15 14:30', 'status': 'pending', 'total': 28500000,
      'items': [
        {'name': 'MacBook Pro M3',  'qty': 1, 'price': 25000000},
        {'name': 'Mouse Wireless',  'qty': 1, 'price': 3500000},
      ],
      'payment': 'Bank Transfer', 'shipping': 'JNE Express',
      'address': 'Jl. Merdeka No. 123, Jakarta',
      'note': 'Tolong jangan banting-banting',
    },
    {
      'id': 'ORD-2024-002', 'customer': 'Siti Rahayu',
      'email': 'siti@gmail.com', 'phone': '081298765432',
      'date': '2024-01-14 10:15', 'status': 'processed', 'total': 18999000,
      'items': [{'name': 'iPhone 15 Pro', 'qty': 1, 'price': 18999000}],
      'payment': 'Credit Card', 'shipping': 'GoSend',
      'address': 'Jl. Sudirman No. 456, Bandung', 'note': '',
    },
    {
      'id': 'ORD-2024-003', 'customer': 'Agus Wijaya',
      'email': 'agus@gmail.com', 'phone': '081312345678',
      'date': '2024-01-13 16:45', 'status': 'shipped', 'total': 2399000,
      'items': [{'name': 'Nike Air Max', 'qty': 1, 'price': 2399000}],
      'payment': 'E-Wallet', 'shipping': 'J&T Express',
      'address': 'Jl. Asia Afrika No. 789, Surabaya', 'note': '',
    },
    {
      'id': 'ORD-2024-004', 'customer': 'Rina Melati',
      'email': 'rina@gmail.com', 'phone': '081323456789',
      'date': '2024-01-12 09:20', 'status': 'completed', 'total': 42500000,
      'items': [{'name': 'Sony Alpha 7 IV', 'qty': 1, 'price': 42500000}],
      'payment': 'Bank Transfer', 'shipping': 'SiCepat',
      'address': 'Jl. Gatot Subroto No. 101, Medan', 'note': '',
    },
    {
      'id': 'ORD-2024-005', 'customer': 'Dian Permata',
      'email': 'dian@gmail.com', 'phone': '081334567890',
      'date': '2024-01-11 13:10', 'status': 'cancelled', 'total': 4499000,
      'items': [{'name': 'AirPods Pro 2', 'qty': 1, 'price': 4499000}],
      'payment': 'Credit Card', 'shipping': 'JNE Express',
      'address': 'Jl. Diponegoro No. 202, Semarang', 'note': 'Dibatalkan oleh pelanggan',
    },
    {
      'id': 'ORD-2024-006', 'customer': 'Hendra Kurniawan',
      'email': 'hendra@gmail.com', 'phone': '081345678901',
      'date': '2024-01-10 11:30', 'status': 'processed', 'total': 35900000,
      'items': [{'name': 'Gucci Tote Bag', 'qty': 1, 'price': 35900000}],
      'payment': 'Bank Transfer', 'shipping': 'GoSend',
      'address': 'Jl. Thamrin No. 303, Makassar', 'note': '',
    },
    {
      'id': 'ORD-2024-007', 'customer': 'Maya Sari',
      'email': 'maya@gmail.com', 'phone': '081356789012',
      'date': '2024-01-09 15:45', 'status': 'pending', 'total': 32999000,
      'items': [{'name': 'Samsung QLED TV', 'qty': 1, 'price': 32999000}],
      'payment': 'E-Wallet', 'shipping': 'J&T Express',
      'address': 'Jl. Pahlawan No. 404, Bali', 'note': '',
    },
    {
      'id': 'ORD-2024-008', 'customer': 'Fajar Setiawan',
      'email': 'fajar@gmail.com', 'phone': '081367890123',
      'date': '2024-01-08 08:55', 'status': 'shipped', 'total': 5499000,
      'items': [{'name': 'Coffee Maker Premium', 'qty': 1, 'price': 5499000}],
      'payment': 'Credit Card', 'shipping': 'SiCepat',
      'address': 'Jl. Juanda No. 505, Yogyakarta', 'note': '',
    },
  ];

  // ── Getters ───────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    final statusFilter = _filterStatus[_selectedFilter];
    var list = _orders.where((o) {
      final matchStatus = statusFilter == null || o['status'] == statusFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          (o['id'] as String).toLowerCase().contains(q) ||
          (o['customer'] as String).toLowerCase().contains(q) ||
          (o['email'] as String).toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();

    switch (_sortMode) {
      case 'terbaru':
        list.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
        break;
      case 'terlama':
        list.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
        break;
      case 'tertinggi':
        list.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
        break;
      case 'terendah':
        list.sort((a, b) => (a['total'] as int).compareTo(b['total'] as int));
        break;
    }
    return list;
  }

  int _countStatus(String s) => _orders.where((o) => o['status'] == s).length;
  int get _totalRevenue => _orders
      .where((o) => o['status'] == 'completed')
      .fold(0, (s, o) => s + (o['total'] as int));

  // ── Helpers ───────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s) {
      case 'pending':   return _amber;
      case 'processed': return _blue;
      case 'shipped':   return _accent;
      case 'completed': return _green;
      case 'cancelled': return _red;
      default:          return Colors.grey;
    }
  }

  String _statusText(String s) {
    switch (s) {
      case 'pending':   return 'Menunggu';
      case 'processed': return 'Diproses';
      case 'shipped':   return 'Dikirim';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default:          return 'Unknown';
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':   return Icons.pending_actions_rounded;
      case 'processed': return Icons.autorenew_rounded;
      case 'shipped':   return Icons.local_shipping_rounded;
      case 'completed': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default:          return Icons.help_rounded;
    }
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Update status ─────────────────────────────────────────
  void _updateStatus(String orderId, String newStatus) {
    setState(() {
      final idx = _orders.indexWhere((o) => o['id'] == orderId);
      if (idx != -1) _orders[idx]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text('Status diperbarui ke ${_statusText(newStatus)}',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        ]),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildStatsRow(),
            _buildSearchSort(),
            _buildFilterChips(),
            _buildOrderList(),
            _buildFooterSummary(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
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
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: _primary.withOpacity(0.4),
                    blurRadius: 12, offset: const Offset(0, 4),
                  )],
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Manajemen Pesanan',
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins', color: Colors.white,
                          letterSpacing: -0.3,
                        )),
                    Text('${_filtered.length} pesanan ditampilkan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.45),
                          fontFamily: 'Poppins',
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showSortSheet();
                },
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Icon(Icons.sort_rounded,
                      color: Colors.white.withOpacity(0.6), size: 18),
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
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          children: [
            _statPill('Total Pesanan', '${_orders.length}',
                Icons.receipt_outlined, _primary),
            _statPill('Pending', '${_countStatus("pending")}',
                Icons.pending_actions_rounded, _amber),
            _statPill('Dikirim', '${_countStatus("shipped")}',
                Icons.local_shipping_rounded, _accent),
            _statPill('Selesai', '${_countStatus("completed")}',
                Icons.check_circle_rounded, _green),
            _statPill('Revenue', _formatRp(_totalRevenue),
                Icons.account_balance_wallet_outlined, _blue),
          ],
        ),
      ),
    ),
  );

  Widget _statPill(String label, String value, IconData icon, Color color) =>
      Container(
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(
                    fontSize: 10, color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Poppins')),
                Text(value, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Poppins')),
              ],
            ),
          ],
        ),
      );

  // ── SEARCH & SORT ─────────────────────────────────────────
  Widget _buildSearchSort() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(
              color: Colors.white, fontFamily: 'Poppins', fontSize: 13),
          cursorColor: _primary,
          decoration: InputDecoration(
            hintText: 'Cari ID pesanan atau nama pelanggan...',
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontFamily: 'Poppins', fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withOpacity(0.35), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.white.withOpacity(0.4), size: 16),
                    onPressed: _searchCtrl.clear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ),
  );

  // ── FILTER CHIPS ──────────────────────────────────────────
  Widget _buildFilterChips() => SliverToBoxAdapter(
    child: SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        itemCount: _filterLabels.length,
        itemBuilder: (_, i) {
          final active = _selectedFilter == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [_primary, _accent])
                    : null,
                color: active ? null : _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: active
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.08)),
                boxShadow: active
                    ? [BoxShadow(
                        color: _primary.withOpacity(0.35),
                        blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Text(
                _filterLabels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : Colors.white.withOpacity(0.5),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  // ── ORDER LIST ────────────────────────────────────────────
  Widget _buildOrderList() {
    final list = _filtered;
    if (list.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.inbox_rounded, color: _primary, size: 32),
              ),
              const SizedBox(height: 14),
              const Text('Tidak Ada Pesanan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
              const SizedBox(height: 5),
              Text('Tidak ada pesanan dengan filter ini',
                  style: TextStyle(fontSize: 12,
                      color: Colors.white.withOpacity(0.4), fontFamily: 'Poppins')),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      sliver: SliverList.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => _buildOrderCard(list[i], i),
      ),
    );
  }

  // ── ORDER CARD ────────────────────────────────────────────
  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final sc = _statusColor(order['status'] as String);
    final isPending = order['status'] == 'pending';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + index * 55),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDetail(order);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showActionSheet(order);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 16, offset: const Offset(0, 6),
            )],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header row ──
                    Row(
                      children: [
                        // Avatar inisial
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_primary, _accent]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: _primary.withOpacity(0.3),
                              blurRadius: 8, offset: const Offset(0, 3),
                            )],
                          ),
                          child: Center(child: Text(
                            _initials(order['customer'] as String),
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800,
                              color: Colors.white, fontFamily: 'Poppins',
                            ),
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order['customer'] as String,
                                  style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: Colors.white, fontFamily: 'Poppins',
                                  )),
                              const SizedBox(height: 2),
                              Text(order['id'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.4),
                                    fontFamily: 'Poppins',
                                  )),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: sc.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sc.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(order['status'] as String),
                                  size: 12, color: sc),
                              const SizedBox(width: 5),
                              Text(_statusText(order['status'] as String),
                                  style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700,
                                    color: sc, fontFamily: 'Poppins',
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Info box ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          _infoRow(Icons.calendar_today_rounded,
                              'Tanggal', order['date'] as String),
                          const SizedBox(height: 8),
                          _infoRow(Icons.local_shipping_rounded,
                              'Pengiriman', order['shipping'] as String),
                          const SizedBox(height: 8),
                          _infoRow(Icons.shopping_cart_outlined,
                              'Items', '${(order['items'] as List).length} produk'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Produk preview ──
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: (order['items'] as List).take(3).map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            item['name'] as String,
                            style: const TextStyle(
                              fontSize: 10, color: _primary,
                              fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Urgent indicator for pending
                    if (isPending) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _amber.withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 13, color: _amber),
                          const SizedBox(width: 6),
                          Text('Perlu konfirmasi segera',
                              style: TextStyle(
                                fontSize: 11, color: _amber,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              )),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Strip bawah ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.025),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.06))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 13, color: _green),
                    const SizedBox(width: 5),
                    Text(_formatRp(order['total'] as int),
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: _green, fontFamily: 'Poppins',
                        )),
                    const Spacer(),
                    // Quick action: update status
                    GestureDetector(
                      onTap: () => _showUpdateStatus(order['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.edit_rounded, size: 11,
                              color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text('Status',
                              style: TextStyle(
                                fontSize: 11, fontFamily: 'Poppins',
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                              )),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showDetail(order),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_primary, _accent]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye_rounded,
                                size: 11, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Detail',
                                style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: Colors.white, fontFamily: 'Poppins',
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 13, color: Colors.white.withOpacity(0.35)),
      const SizedBox(width: 7),
      Text('$label:', style: TextStyle(
          fontSize: 11, color: Colors.white.withOpacity(0.4),
          fontFamily: 'Poppins')),
      const Spacer(),
      Text(value, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: Colors.white, fontFamily: 'Poppins')),
    ],
  );

  // ── FOOTER ────────────────────────────────────────────────
  Widget _buildFooterSummary() {
    final list = _filtered;
    if (list.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    final total = list.fold<int>(0, (s, o) => s + (o['total'] as int));
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_green.withOpacity(0.12), _green.withOpacity(0.04)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _green.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: _green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.summarize_rounded,
                  color: _green, size: 18),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Nilai Pesanan',
                  style: TextStyle(fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Poppins')),
              Text(_formatRp(total),
                  style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w800, color: _green,
                      fontFamily: 'Poppins')),
            ]),
            const Spacer(),
            Text('${list.length} pesanan',
                style: TextStyle(fontSize: 11,
                    color: Colors.white.withOpacity(0.3),
                    fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  // ── DETAIL MODAL ──────────────────────────────────────────
  void _showDetail(Map<String, dynamic> order) {
    final sc = _statusColor(order['status'] as String);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.97,
        builder: (_, scrollCtrl) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.97),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: SingleChildScrollView(
                controller: scrollCtrl,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ── Header ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_primary, _accent]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: _primary.withOpacity(0.35),
                                blurRadius: 12, offset: const Offset(0, 4),
                              )],
                            ),
                            child: Center(child: Text(
                              _initials(order['customer'] as String),
                              style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800,
                                color: Colors.white, fontFamily: 'Poppins',
                              ),
                            )),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order['customer'] as String,
                                    style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w800,
                                      color: Colors.white, fontFamily: 'Poppins',
                                      letterSpacing: -0.3,
                                    )),
                                const SizedBox(height: 2),
                                Text(order['id'] as String,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.4),
                                        fontFamily: 'Poppins')),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: sc.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: sc.withOpacity(0.35)),
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_statusIcon(order['status'] as String),
                                            size: 12, color: sc),
                                        const SizedBox(width: 5),
                                        Text(_statusText(order['status'] as String),
                                            style: TextStyle(
                                              fontSize: 11, color: sc,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Poppins',
                                            )),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Stat cards ──
                      Row(children: [
                        Expanded(child: _detailStat(
                            'Total', _formatRp(order['total'] as int),
                            Icons.payments_outlined, _green)),
                        const SizedBox(width: 10),
                        Expanded(child: _detailStat(
                            'Items',
                            '${(order['items'] as List).length} produk',
                            Icons.shopping_cart_outlined, _primary)),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _detailStat(
                            'Pembayaran', order['payment'] as String,
                            Icons.credit_card_rounded, _blue)),
                        const SizedBox(width: 10),
                        Expanded(child: _detailStat(
                            'Pengiriman', order['shipping'] as String,
                            Icons.local_shipping_rounded, _accent)),
                      ]),
                      const SizedBox(height: 20),

                      // ── Pelanggan ──
                      _sectionTitle('Informasi Pelanggan'),
                      const SizedBox(height: 10),
                      _detailBox([
                        _detailRow(Icons.person_outline_rounded,
                            'Nama', order['customer'] as String),
                        _detailRow(Icons.email_outlined,
                            'Email', order['email'] as String),
                        _detailRow(Icons.phone_outlined,
                            'Telepon', order['phone'] as String),
                        _detailRow(Icons.location_on_outlined,
                            'Alamat', order['address'] as String),
                        _detailRow(Icons.calendar_today_rounded,
                            'Tanggal', order['date'] as String),
                        if ((order['note'] as String).isNotEmpty)
                          _detailRow(Icons.notes_rounded,
                              'Catatan', order['note'] as String),
                      ]),
                      const SizedBox(height: 20),

                      // ── Items ──
                      _sectionTitle('Detail Produk'),
                      const SizedBox(height: 10),
                      ...(order['items'] as List).map((item) =>
                          _itemRow(item as Map<String, dynamic>)),
                      const SizedBox(height: 4),
                      Container(
                        height: 1, color: Colors.white.withOpacity(0.07),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.7),
                                fontFamily: 'Poppins',
                              )),
                          Text(_formatRp(order['total'] as int),
                              style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: _green, fontFamily: 'Poppins',
                              )),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Action buttons ──
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _showUpdateStatus(order['id'] as String);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [_primary, _accent]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_rounded,
                                        size: 15, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text('Update Status',
                                        style: TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w700,
                                          color: Colors.white, fontFamily: 'Poppins',
                                        )),
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.print_outlined,
                                        size: 15, color: Colors.white54),
                                    SizedBox(width: 6),
                                    Text('Invoice',
                                        style: TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w600,
                                          color: Colors.white54, fontFamily: 'Poppins',
                                        )),
                                  ]),
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
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.45),
        fontFamily: 'Poppins', letterSpacing: 0.8,
      ));

  Widget _detailBox(List<Widget> children) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: Column(children: children),
  );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.35)),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text('$label',
              style: TextStyle(fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: 'Poppins')),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.white, fontFamily: 'Poppins')),
        ),
      ],
    ),
  );

  Widget _itemRow(Map<String, dynamic> item) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary.withOpacity(0.18), _accent.withOpacity(0.08)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('📦', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['name'] as String,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Text('${item['qty']}x ${_formatRp(item['price'] as int)}',
                style: TextStyle(fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                    fontFamily: 'Poppins')),
          ]),
        ),
        Text(_formatRp((item['price'] as int) * (item['qty'] as int)),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: _green, fontFamily: 'Poppins')),
      ],
    ),
  );

  Widget _detailStat(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                      fontSize: 10, color: Colors.white.withOpacity(0.45),
                      fontFamily: 'Poppins')),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: color, fontFamily: 'Poppins'),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      );

  // ── UPDATE STATUS SHEET ───────────────────────────────────
  void _showUpdateStatus(String orderId) {
    final current = _orders.firstWhere((o) => o['id'] == orderId)['status'] as String;
    showModalBottomSheet(
      context: context,
      
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(

        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 12),
          child: SingleChildScrollView(
            child: Container(
              height: 480,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.97),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Update Status Pesanan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                          color: Colors.white, fontFamily: 'Poppins')),
                  const SizedBox(height: 4),
                  Text(orderId,
                      style: TextStyle(fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                          fontFamily: 'Poppins')),
                  const SizedBox(height: 18),
                  ...['pending', 'processed', 'shipped', 'completed', 'cancelled']
                      .map((status) {
                    final sc2   = _statusColor(status);
                    final isNow = status == current;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (status != current) _updateStatus(orderId, status);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: isNow
                              ? sc2.withOpacity(0.12)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isNow
                                ? sc2.withOpacity(0.4)
                                : Colors.white.withOpacity(0.07),
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: sc2.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_statusIcon(status), color: sc2, size: 15),
                          ),
                          const SizedBox(width: 12),
                          Text(_statusText(status),
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: isNow ? sc2 : Colors.white,
                                fontFamily: 'Poppins',
                              )),
                          const Spacer(),
                          if (isNow)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: sc2.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Saat ini',
                                  style: TextStyle(
                                    fontSize: 10, color: sc2,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                        ]),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── ACTION SHEET (long press) ─────────────────────────────
  void _showActionSheet(Map<String, dynamic> order) {
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
              color: _surface.withOpacity(0.97),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(order['customer'] as String,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Poppins')),
              Text(order['id'] as String,
                  style: TextStyle(fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                      fontFamily: 'Poppins')),
              const SizedBox(height: 18),
              _sheetBtn(Icons.remove_red_eye_rounded, 'Lihat Detail', _accent, () {
                Navigator.pop(context);
                _showDetail(order);
              }),
              const SizedBox(height: 8),
              _sheetBtn(Icons.edit_rounded, 'Update Status', _primary, () {
                Navigator.pop(context);
                _showUpdateStatus(order['id'] as String);
              }),
              const SizedBox(height: 8),
              _sheetBtn(Icons.print_outlined, 'Cetak Invoice', _blue, () {
                Navigator.pop(context);
              }),
              const SizedBox(height: 8),
              _sheetBtn(Icons.close_rounded, 'Batal', Colors.white38,
                  () => Navigator.pop(context), ghost: true),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sheetBtn(IconData icon, String label, Color color, VoidCallback onTap,
      {bool ghost = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: ghost ? Colors.transparent : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ghost
                  ? Colors.white.withOpacity(0.07)
                  : color.withOpacity(0.25),
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 9),
            Text(label,
                style: TextStyle(color: color, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      );

  // ── SORT SHEET ────────────────────────────────────────────
  void _showSortSheet() {
    final options = [
      ('terbaru',  'Terbaru',        Icons.arrow_downward_rounded),
      ('terlama',  'Terlama',        Icons.arrow_upward_rounded),
      ('tertinggi','Harga Tertinggi', Icons.trending_up_rounded),
      ('terendah', 'Harga Terendah', Icons.trending_down_rounded),
    ];
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
              color: _surface.withOpacity(0.97),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Urutkan Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                        color: Colors.white, fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isActive = _sortMode == opt.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _sortMode = opt.$1);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(colors: [_primary, _accent])
                          : null,
                      color: isActive ? null : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.07),
                      ),
                    ),
                    child: Row(children: [
                      Icon(opt.$3,
                          color: isActive ? Colors.white : Colors.white54,
                          size: 18),
                      const SizedBox(width: 12),
                      Text(opt.$2,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : Colors.white70,
                            fontFamily: 'Poppins',
                          )),
                    ]),
                  ),
                );
              }),
            ]),
          ),
        ),
      ),
    );
  }
}