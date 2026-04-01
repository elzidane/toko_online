import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen>
    with TickerProviderStateMixin {
  // ── WARNA KONSISTEN ───────────────────────────────────────
  static const _bg      = Color(0xFF1E293B);
  static const _surface = Color(0xFF334155);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);

  late AnimationController _bgController;   // blob background
  late AnimationController _entryController; // stagger masuk
  late AnimationController _floatController; // floating icon
  late AnimationController _pulseController; // pulse ring

  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;
  late Animation<double>        _floatAnim;
  late Animation<double>        _pulseAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    // Blob background — lambat & loop
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    // Entry stagger
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fades = List.generate(7, (i) {
      final s = i * 0.07;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: Interval(s, (s + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });

    _slides = List.generate(7, (i) {
      final s = i * 0.07;
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryController,
        curve: Interval(s, (s + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    // Floating logo
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: false);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _a(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── BLOB BG ──
          _AnimatedBlobBg(controller: _bgController),

          // ── GRID OVERLAY (subtle texture) ──
          CustomPaint(
            size: size,
            painter: _GridPainter(),
          ),

          // ── KONTEN ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // ── BADGE ──
                      _a(0, _buildBadge()),
                      const SizedBox(height: 40),

                      // ── LOGO ANIMASI ──
                      _a(1, _buildFloatingLogo()),
                      const SizedBox(height: 36),

                      // ── JUDUL ──
                      _a(2, _buildTitle()),
                      const SizedBox(height: 16),

                      // ── DESKRIPSI ──
                      _a(3, _buildDesc()),
                      const SizedBox(height: 36),

                      // ── FITUR CHIPS ──
                      _a(4, _buildFeatureChips()),
                      const SizedBox(height: 44),

                      // ── TOMBOL LOGIN ──
                      _a(5, _buildLoginButton()),
                      const SizedBox(height: 14),

                      // ── TOMBOL REGISTER ──
                      _a(5, _buildRegisterButton()),
                      const SizedBox(height: 28),

                      // ── FOOTER ──
                      _a(6, _buildFooter()),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BADGE ─────────────────────────────────────────────────
  Widget _buildBadge() => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _primary.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Platform MarketPlace Terpercaya',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      );

  // ── FLOATING LOGO ─────────────────────────────────────────
  Widget _buildFloatingLogo() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring luar
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primary.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Ring tengah
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                  color: _primary.withOpacity(0.05),
                ),
              ),

              // Logo utama
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primary, _accent],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.45),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: _accent.withOpacity(0.2),
                      blurRadius: 60,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),

              // Badge "NEW" kecil
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: _green.withOpacity(0.4), blurRadius: 8)
                    ],
                  ),
                  child: const Text('NEW',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── JUDUL ─────────────────────────────────────────────────
  Widget _buildTitle() => Column(
        children: [
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: [_primary, _accent])
                    .createShader(b),
            child: const Text(
              'MiracleMates',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: -1,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  // ── DESKRIPSI ─────────────────────────────────────────────
  Widget _buildDesc() => Text(
        'Kelola toko kamu dengan lebih mudah,\ncepat, dan efisien dalam satu aplikasi.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.45),
          fontFamily: 'Poppins',
          height: 1.7,
        ),
        textAlign: TextAlign.center,
      );

  // ── FEATURE CHIPS ─────────────────────────────────────────
  Widget _buildFeatureChips() {
    final features = [
      (Icons.inventory_2_outlined, 'Manajemen Produk'),
      (Icons.bar_chart_rounded,    'Laporan Real-time'),
      (Icons.security_rounded,     'Keamanan Data'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withOpacity(0.07), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(f.$1, size: 15, color: _primary),
              const SizedBox(width: 7),
              Text(
                f.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.75),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── LOGIN BUTTON ──────────────────────────────────────────
  Widget _buildLoginButton() => SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _accent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/login'),
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Masuk ke Akun',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ── REGISTER BUTTON ───────────────────────────────────────
  Widget _buildRegisterButton() => SizedBox(
        width: double.infinity,
        height: 54,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/'),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white.withOpacity(0.7), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Buat Akun Baru',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ── FOOTER ────────────────────────────────────────────────
  Widget _buildFooter() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              size: 13, color: Colors.white.withOpacity(0.2)),
          const SizedBox(width: 6),
          Text(
            'Data kamu aman & terenkripsi',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.2),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );
}

// ── ANIMATED BLOB BACKGROUND ──────────────────────────────
class _AnimatedBlobBg extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBlobBg({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _BlobPainter(controller.value),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _blob(canvas,
        Offset(size.width * 0.85 + math.sin(t * math.pi * 2) * 30,
            size.height * 0.08 + math.cos(t * math.pi * 2) * 20),
        size.width * 0.55,
        const Color(0xFF6366F1).withOpacity(0.13));

    _blob(canvas,
        Offset(size.width * 0.08 + math.cos(t * math.pi * 2 + 1) * 24,
            size.height * 0.80 + math.sin(t * math.pi * 2 + 1) * 28),
        size.width * 0.55,
        const Color(0xFF8B5CF6).withOpacity(0.11));

    _blob(canvas,
        Offset(size.width * 0.5 + math.sin(t * math.pi * 2 + 2) * 18,
            size.height * 0.45 + math.cos(t * math.pi * 2 + 2) * 14),
        size.width * 0.3,
        const Color(0xFF10B981).withOpacity(0.05));
  }

  void _blob(Canvas canvas, Offset c, double r, Color color) =>
      canvas.drawCircle(c, r,
          Paint()
            ..color = color
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55));

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}

// ── SUBTLE GRID OVERLAY ───────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.8;

    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}