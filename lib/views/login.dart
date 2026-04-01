import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/providers/user_provider.dart';
import 'package:mobileapp2/services/user.dart';
import 'package:mobileapp2/widget/alert.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading  = false;
  bool _showPass   = false;
  bool _emailFocus = false;
  bool _passFocus  = false;

  late AnimationController _bgController;
  late AnimationController _entryController;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;

  // ── WARNA SAMA DENGAN DASHBOARD ──────────────────────────
  static const _bg      = Color(0xFF1E293B);
  static const _surface = Color(0xFF334155);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fades = List.generate(6, (i) {
      final s = i * 0.08;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: Interval(s, (s + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });

    _slides = List.generate(6, (i) {
      final s = i * 0.08;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryController,
        curve: Interval(s, (s + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      _entryController.forward();
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _a(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  // ── LOGIN HANDLER ─────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final data = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    };

    final userLogin = await _userService.loginUser(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (userLogin != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(userLogin);
      AlertMassage().showAlert(context, 'Login berhasil!', true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pushReplacementNamed(context, '/bottomnav');
    } else {
      AlertMassage().showAlert(context, 'Email atau password salah', false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── ANIMATED BLOB BACKGROUND ──
          _AnimatedMeshBg(controller: _bgController),

          // ── KONTEN ──
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),

                      // HEADER
                      _a(0, _buildHeader()),
                      const SizedBox(height: 40),

                      // FORM
                      _a(1, _buildFormCard()),
                      const SizedBox(height: 24),

                      // DIVIDER
                      _a(3, _buildDivider()),
                      const SizedBox(height: 20),

                      // REGISTER
                      _a(4, _buildRegisterLink()),
                      const SizedBox(height: 40),
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

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader() => Column(
        children: [
          // Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _accent],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 34),
          ),
          const SizedBox(height: 18),

          // App label
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [_primary, _accent],
            ).createShader(b),
            child: const Text(
              'MircaleMates',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Masuk ke Akunmu',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Kelola toko dengan mudah',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  // ── FORM CARD ─────────────────────────────────────────────
  Widget _buildFormCard() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface.withOpacity(0.65),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Email'),
              const SizedBox(height: 8),
              _field(
                controller: _emailController,
                hint: 'contoh@email.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                isFocused: _emailFocus,
                onFocusChange: (v) => setState(() => _emailFocus = v),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email harus diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Password'),
                  Text(
                    'Lupa password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primary.withOpacity(0.8),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _field(
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: !_showPass,
                isFocused: _passFocus,
                onFocusChange: (v) => setState(() => _passFocus = v),
                suffix: GestureDetector(
                  onTap: () => setState(() => _showPass = !_showPass),
                  child: Icon(
                    _showPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password harus diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // LOGIN BUTTON
              _a(2, _buildLoginButton()),
            ],
          ),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.7),
          fontFamily: 'Poppins',
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    bool isFocused = false,
    required Function(bool) onFocusChange,
    Widget? suffix,
    String? Function(String?)? validator,
  }) =>
      Focus(
        onFocusChange: onFocusChange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.18),
                      blurRadius: 16,
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
            cursorColor: _primary,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 14,
                  fontFamily: 'Poppins'),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon,
                    size: 20,
                    color: isFocused
                        ? _primary
                        : Colors.white.withOpacity(0.3)),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 48, minHeight: 48),
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 14), child: suffix)
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 48, minHeight: 48),
              filled: true,
              fillColor: _bg.withOpacity(0.55),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.07), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.red.withOpacity(0.6), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              errorStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.redAccent),
            ),
          ),
        ),
      );

  // ── LOGIN BUTTON ──────────────────────────────────────────
  Widget _buildLoginButton() => SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _accent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.38),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleLogin,
              borderRadius: BorderRadius.circular(14),
              splashColor: Colors.white.withOpacity(0.08),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.login_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Masuk Sekarang',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );

  // ── DIVIDER ───────────────────────────────────────────────
  Widget _buildDivider() => Row(
        children: [
          Expanded(
              child: Divider(
                  color: Colors.white.withOpacity(0.07), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'keamanan terjamin',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.2),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
              child: Divider(
                  color: Colors.white.withOpacity(0.07), thickness: 1)),
        ],
      );

  // ── REGISTER LINK ─────────────────────────────────────────
  Widget _buildRegisterLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun? ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.35),
              fontFamily: 'Poppins',
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
            child: ShaderMask(
              shaderCallback: (b) =>
                  const LinearGradient(colors: [_primary, _accent])
                      .createShader(b),
              child: const Text(
                'Daftar Sekarang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      );
}

// ── ANIMATED BLOB BACKGROUND ──────────────────────────────
class _AnimatedMeshBg extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedMeshBg({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _MeshPainter(controller.value),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double t;
  _MeshPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _blob(
      canvas,
      Offset(
        size.width * 0.85 + math.sin(t * math.pi * 2) * 28,
        size.height * 0.08 + math.cos(t * math.pi * 2) * 18,
      ),
      size.width * 0.52,
      const Color(0xFF6366F1).withOpacity(0.12),
    );

    _blob(
      canvas,
      Offset(
        size.width * 0.08 + math.cos(t * math.pi * 2 + 1) * 22,
        size.height * 0.78 + math.sin(t * math.pi * 2 + 1) * 28,
      ),
      size.width * 0.55,
      const Color(0xFF8B5CF6).withOpacity(0.10),
    );

    _blob(
      canvas,
      Offset(
        size.width * 0.5 + math.sin(t * math.pi * 2 + 2) * 18,
        size.height * 0.42 + math.cos(t * math.pi * 2 + 2) * 14,
      ),
      size.width * 0.28,
      const Color(0xFF10B981).withOpacity(0.05),
    );
  }

  void _blob(Canvas canvas, Offset center, double r, Color color) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}