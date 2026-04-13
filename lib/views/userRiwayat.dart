import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/services/user.dart';

class UserRiwayatPage extends StatefulWidget {
  const UserRiwayatPage({super.key});

  @override
  State<UserRiwayatPage> createState() => _UserRiwayatPageState();
}

class _UserRiwayatPageState extends State<UserRiwayatPage>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _card = Color(0xFF1A2744);
  static const _primary = Color(0xFF6366F1);
  static const _accent = Color(0xFF8B5CF6);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  final UserService _service = UserService();
  List<dynamic> _riwayat = [];
  bool _isLoading = true;
  String? _errorMsg;

  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _loadRiwayat();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final result = await _service.getRiwayatTransaksi();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.status && result.data != null) {
          _riwayat = (result.data is List ? result.data : [])!;
        } else {
          _errorMsg = result.message;
        }
      });
      _headerAnim.forward();
    }
  }

  // ── Helper: hitung total dari detail (qty × harga_beli) ──
  int _hitungTotal(dynamic trx) {
    final detail = trx['detail'] as List? ?? [];
    return detail.fold(0, (sum, item) {
      final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      final harga = int.tryParse(item['harga_beli']?.toString() ?? '0') ?? 0;
      return sum + (qty * harga);
    });
  }

  // ── Total semua transaksi (API tidak punya status, hitung semua) ──
  int get _totalSpend =>
      _riwayat.fold(0, (s, r) => s + _hitungTotal(r));

  String _formatRp(dynamic val) {
    final v = int.tryParse(val?.toString() ?? '0') ?? 0;
    final s = v.toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── Status: API tidak kirim status, pakai default 'completed' ──
  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return _amber;
      case 'processed':
        return _blue;
      case 'shipped':
        return _accent;
      case 'completed':
        return _green;
      case 'cancelled':
        return _red;
      default:
        return _green;
    }
  }

  String _statusText(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'processed':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Selesai';
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'processed':
        return Icons.autorenew_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
      default:
        return Icons.check_circle_rounded;
    }
  }

  // ── Detail transaksi ─────────────────────────────────────
  void _showDetail(dynamic trx) {
    // Gunakan field API: id_transaksi, tgl_transaksi, detail
    final status = (trx['status'] ?? 'completed').toString();
    final sc = _statusColor(status);
    final items = trx['detail'] as List? ?? [];
    final totalCalc = _hitungTotal(trx);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.97),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: SingleChildScrollView(
                controller: ctrl,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: sc.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: sc.withOpacity(0.3)),
                            ),
                            child: Icon(
                              _statusIcon(status),
                              color: sc,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ Gunakan id_transaksi
                                Text(
                                  'TRX-${trx['id_transaksi']?.toString() ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // ✅ Gunakan tgl_transaksi
                                Text(
                                  trx['tgl_transaksi']?.toString() ?? '-',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.4),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // nama_user
                                Text(
                                  trx['nama_user']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.55),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sc.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: sc.withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_statusIcon(status),
                                          size: 12, color: sc),
                                      const SizedBox(width: 5),
                                      Text(
                                        _statusText(status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: sc,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stat cards
                      Row(
                        children: [
                          _detailStat(
                            'Total',
                            _formatRp(totalCalc),
                            Icons.payments_outlined,
                            _green,
                          ),
                          const SizedBox(width: 10),
                          _detailStat(
                            'Items',
                            '${items.length} produk',
                            Icons.shopping_cart_outlined,
                            _primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Items
                      Text(
                        'DETAIL PRODUK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.45),
                          fontFamily: 'Poppins',
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.07)),
                          ),
                          child: Center(
                            child: Text(
                              'Detail item tidak tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        )
                      else
                        ...items.map((item) {
                          // ✅ Gunakan field API: nama_barang, quantity, harga_beli
                          final nama =
                              item['nama_barang']?.toString() ?? '-';
                          final harga =
                              int.tryParse(item['harga_beli']?.toString() ?? '0') ?? 0;
                          final qty =
                              int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
                          final sub = harga * qty;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Row(
                              children: [
                                // Tidak ada image di API, pakai icon default
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _primary.withOpacity(0.15),
                                          _accent.withOpacity(0.07),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '📦',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${qty}x ${_formatRp(harga)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.4),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatRp(sub),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _green,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 4),
                      Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.07)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.7),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            _formatRp(totalCalc),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _green,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Close btn
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white60,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.45),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
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
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: _primary,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_errorMsg != null)
              SliverFillRemaining(hasScrollBody: false, child: _buildError())
            else ...[
              _buildSummaryRow(),
              _buildList(),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() => SliverAppBar(
        automaticallyImplyLeading: false,
        expandedHeight: 80,
        collapsedHeight: 80,
        floating: true,
        pinned: true,
        backgroundColor: _bg,
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${_riwayat.length} transaksi',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.45),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _loadRiwayat();
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildSummaryRow() => SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _headerFade,
          child: SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              children: [
                _statPill(
                  'Total Transaksi',
                  '${_riwayat.length}',
                  Icons.receipt_outlined,
                  _primary,
                ),
                _statPill(
                  'Total Item',
                  // Hitung total semua item dari semua transaksi
                  '${_riwayat.fold<int>(0, (s, r) => s + ((r['detail'] as List? ?? []).length))}',
                  Icons.shopping_bag_outlined,
                  _blue,
                ),
                _statPill(
                  'Total Spend',
                  _formatRp(_totalSpend),
                  Icons.account_balance_wallet_outlined,
                  _accent,
                ),
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
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildList() {
    if (_riwayat.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Transaksi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Transaksimu akan muncul di sini',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      sliver: SliverList.builder(
        itemCount: _riwayat.length,
        itemBuilder: (_, i) => _buildTrxCard(_riwayat[i], i),
      ),
    );
  }

  Widget _buildTrxCard(dynamic trx, int index) {
    // ✅ Semua field sesuai API
    final status = (trx['status'] ?? 'completed').toString();
    final sc = _statusColor(status);
    final items = trx['detail'] as List? ?? [];
    final totalCalc = _hitungTotal(trx);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + index * 55),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDetail(trx);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: sc.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: sc.withOpacity(0.25)),
                          ),
                          child: Icon(_statusIcon(status),
                              color: sc, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ id_transaksi
                              Text(
                                'TRX-${trx['id_transaksi']?.toString() ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 2),
                              // ✅ tgl_transaksi
                              Text(
                                trx['tgl_transaksi']?.toString() ?? '-',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.4),
                                  fontFamily: 'Poppins',
                                ),
                              ),
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
                            border:
                                Border.all(color: sc.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(status),
                                  size: 11, color: sc),
                              const SizedBox(width: 4),
                              Text(
                                _statusText(status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: sc,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // nama_user
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 12,
                            color: Colors.white.withOpacity(0.35)),
                        const SizedBox(width: 5),
                        Text(
                          trx['nama_user']?.toString() ?? '-',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.45),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Preview nama barang dari detail
                    if (items.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: items.take(3).map((item) {
                          // ✅ nama_barang langsung (bukan nested)
                          final nama =
                              item['nama_barang']?.toString() ?? '-';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              nama,
                              style: const TextStyle(
                                fontSize: 10,
                                color: _primary,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    if (items.isEmpty)
                      Text(
                        '0 item',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),

              // Strip bawah — total
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.025),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                        color: Colors.white.withOpacity(0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 13, color: _green),
                    const SizedBox(width: 5),
                    // ✅ Total dihitung dari detail
                    Text(
                      _formatRp(totalCalc),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _green,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showDetail(trx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
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
                            Text(
                              'Detail',
                              style: TextStyle(
                                fontSize: 11,
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
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.wifi_off_rounded, color: _red, size: 30),
              ),
              const SizedBox(height: 14),
              const Text(
                'Gagal Memuat Riwayat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMsg ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _loadRiwayat,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}