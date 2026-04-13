import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:mobileapp2/views/dashboard_user.dart';
import 'package:mobileapp2/models/user_login.dart';
import 'package:mobileapp2/views/dashboard.dart';
import 'package:mobileapp2/views/pesan.dart';
import 'package:mobileapp2/views/toko.dart';
import 'package:mobileapp2/views/userRiwayat.dart';

class Bottomnav extends StatefulWidget {
  int activePage = 0;
  Bottomnav(this.activePage);

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> with TickerProviderStateMixin {
  // ── Design Tokens ────────────────────────────────────────
  static const _bg      = Color(0xFF080D1A);
  static const _surface = Color(0xFF111827);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);

  UserLogin userLogin = UserLogin();
  String? role;

  int currentIndex = 0;
  List<Widget> navbar = [];

  // Nav item data
  List<_NavItem> _navItems = [];

  // Animation controllers per item
  late List<AnimationController> _scaleCtrl;
  late List<Animation<double>> _scaleAnim;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.activePage;
    // init dummy scale controllers (will be rebuilt on role load)
    _scaleCtrl = [];
    _scaleAnim = [];
    getDataLogin();
  }

  @override
  void dispose() {
    for (final c in _scaleCtrl) c.dispose();
    super.dispose();
  }

  void _initAnimations(int count) {
    for (final c in _scaleCtrl) c.dispose();
    _scaleCtrl = List.generate(
      count,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _scaleAnim = _scaleCtrl
        .map((c) => Tween<double>(begin: 1.0, end: 0.78).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
  }

  getDataLogin() async {
    var user = await userLogin.getUserLogin();
    if (user!.status != false) {
      setState(() {
        role = user.role;
        _buildNavItems();
      });
    } else {
      Navigator.popAndPushNamed(context, '/login');
    }
  }

  void _buildNavItems() {
    if (role == 'admin') {
      navbar = [Dashboard(), Toko()];
      _navItems = [
        _NavItem(
          label: 'Dashboard',
          iconOff: Ri.home_2_line,
          iconOn:  Ri.home_2_fill,
        ),
        _NavItem(
          label: 'Toko',
          iconOff: Ri.shopping_bag_2_line,
          iconOn:  Ri.shopping_bag_2_fill,
        ),
      ];
    } else if (role == 'user') {
      navbar = [DashboardUser(), Pesan(), UserRiwayatPage()];
      _navItems = [
        _NavItem(
          label: 'Beranda',
          iconOff: Ri.home_2_line,
          iconOn:  Ri.home_2_fill,
        ),
        _NavItem(
          label: 'Belanja',
          iconOff: Ri.shopping_bag_2_line,
          iconOn:  Ri.shopping_bag_2_fill,
        ),
        _NavItem(
          label: 'Riwayat',
          iconOff: Ri.time_line,
          iconOn:  Ri.time_fill,
        ),
      ];
    }

    if (currentIndex >= navbar.length) currentIndex = 0;
    _initAnimations(navbar.length);
  }

  void onTap(int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();

    // Bounce animation: press → release
    _scaleCtrl[index].forward().then((_) => _scaleCtrl[index].reverse());

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (navbar.isEmpty) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(
            color: _primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: navbar[currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              return Expanded(child: _buildNavTab(i));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(int index) {
    final item      = _navItems[index];
    final isActive  = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedBuilder(
        animation: _scaleAnim.isNotEmpty ? _scaleAnim[index] : kAlwaysCompleteAnimation,
        builder: (_, __) {
          final scale = _scaleAnim.isNotEmpty ? _scaleAnim[index].value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon container ─────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Iconify(
                    isActive ? item.iconOn : item.iconOff,
                    size: 22,
                    color: isActive
                        ? _primary
                        : Colors.white.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 3),
                // ── Label ──────────────────────────────────
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? _primary
                        : Colors.white.withOpacity(0.32),
                    letterSpacing: 0.1,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────
class _NavItem {
  final String label;
  final String iconOff;
  final String iconOn;
  const _NavItem({
    required this.label,
    required this.iconOff,
    required this.iconOn,
  });
}
