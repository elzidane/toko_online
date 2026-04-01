import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapp2/services/user.dart';
import 'package:mobileapp2/widget/alert.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading     = false;
  bool _showPass      = false;
  bool _nameFocus     = false;
  bool _emailFocus    = false;
  bool _passFocus     = false;
  String? _role;

  final List<String> _roleChoice = ['admin', 'user'];

  // ── PASSWORD STRENGTH ─────────────────────────────────────
  int _passStrength = 0; // 0-3
  void _checkStrength(String v) {
    int s = 0;
    if (v.length >= 6) s++;
    if (v.contains(RegExp(r'[A-Z]'))) s++;
    if (v.contains(RegExp(r'[0-9!@#\$%^&*]'))) s++;
    setState(() => _passStrength = s);
  }

  // ── WARNA ─────────────────────────────────────────────────
  static const _bg      = Color(0xFF1E293B);
  static const _surface = Color(0xFF334155);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);
  static const _green   = Color(0xFF10B981);

  late AnimationController _bgController;
  late AnimationController _entryController;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fades = List.generate(8, (i) {
      final s = i * 0.07;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve:
            Interval(s, (s + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });

    _slides = List.generate(8, (i) {
      final s = i * 0.07;
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryController,
        curve: Interval(s, (s + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    Future.delayed(const Duration(milliseconds: 150),
        () => _entryController.forward());
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _a(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  // ── REGISTER HANDLER ──────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final data = {
      'name'    : _nameController.text.trim(),
      'email'   : _emailController.text.trim(),
      'role'    : _role,
      'password': _passwordController.text,
    };

    final result = await _userService.registerUser(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.status) {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() => _role = null);
      AlertMassage().showAlert(context, result.message, true,
          duration: const Duration(seconds: 2),
          onClose: () =>
              Navigator.pushReplacementNamed(context, '/login'));
    } else {
      AlertMassage().showAlert(context, result.message, false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _AnimatedBlobBg(controller: _bgController),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // ── BACK + STEP ──
                    _a(0, _buildTopBar()),
                    const SizedBox(height: 32),

                    // ── HEADER ──
                    _a(1, _buildHeader()),
                    const SizedBox(height: 32),

                    // ── FORM CARD ──
                    _a(2, _buildFormCard()),
                    const SizedBox(height: 24),

                    // ── DIVIDER ──
                    _a(6, _buildDivider()),
                    const SizedBox(height: 18),

                    // ── LOGIN LINK ──
                    _a(7, _buildLoginLink()),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────
  Widget _buildTopBar() => Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.08), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: _primary.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                _stepDot(1, true),
                _stepLine(),
                _stepDot(2, false),
              ],
            ),
          ),
        ],
      );

  Widget _stepDot(int n, bool active) => Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: active ? _primary : _surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: active ? _primary : Colors.white.withOpacity(0.15),
                  width: 1.5),
            ),
            child: Center(
              child: Text('$n',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : Colors.white38,
                      fontFamily: 'Poppins')),
            ),
          ),
          if (n == 1) ...[
            const SizedBox(width: 6),
            Text('Daftar',
                style: TextStyle(
                    fontSize: 11,
                    color: active ? _primary : Colors.white38,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ],
        ],
      );

  Widget _stepLine() => Container(
        width: 24,
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white.withOpacity(0.1),
      );

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader() => Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _accent],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.38),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person_add_alt_1_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 18),
          const Text(
            'Buat Akun Baru',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          Text(
            'Daftar sekarang dan mulai kelola\ntokomu dengan mudah!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
              fontFamily: 'Poppins',
              height: 1.6,
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
          border: Border.all(
              color: Colors.white.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
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
              // Nama
              _a(3, _label('Nama Lengkap')),
              const SizedBox(height: 8),
              _a(3, _field(
                controller: _nameController,
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
                isFocused: _nameFocus,
                onFocusChange: (v) => setState(() => _nameFocus = v),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Nama harus diisi';
                  if (v.trim().length < 3) return 'Minimal 3 karakter';
                  return null;
                },
              )),

              const SizedBox(height: 18),

              // Email
              _a(3, _label('Email')),
              const SizedBox(height: 8),
              _a(3, _field(
                controller: _emailController,
                hint: 'contoh@email.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                isFocused: _emailFocus,
                onFocusChange: (v) => setState(() => _emailFocus = v),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Email harus diisi';
                  if (!v.contains('@'))
                    return 'Format email tidak valid';
                  return null;
                },
              )),

              const SizedBox(height: 18),

              // Role dropdown
              _a(4, _label('Peran Akun')),
              const SizedBox(height: 8),
              _a(4, _buildRoleSelector()),

              const SizedBox(height: 18),

              // Password
              _a(5, _label('Password')),
              const SizedBox(height: 8),
              _a(5, _field(
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: !_showPass,
                isFocused: _passFocus,
                onFocusChange: (v) => setState(() => _passFocus = v),
                onChanged: _checkStrength,
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
              )),

              // Password strength bar
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                _a(5, _buildStrengthBar()),
              ],

              const SizedBox(height: 28),

              // Submit button
              _a(6, _buildRegisterButton()),
            ],
          ),
        ),
      );

  // ── ROLE SELECTOR ─────────────────────────────────────────
  Widget _buildRoleSelector() => Row(
        children: _roleChoice.map((r) {
          final selected = _role == r;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _role = r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                    right: r == _roleChoice.first ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? _primary.withOpacity(0.15)
                      : _bg.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? _primary
                        : Colors.white.withOpacity(0.07),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: _primary.withOpacity(0.2),
                              blurRadius: 12)
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      r == 'admin'
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline_rounded,
                      color: selected ? _primary : Colors.white38,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? _primary : Colors.white38,
                        fontFamily: 'Poppins',
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      r == 'admin' ? 'Kelola semua' : 'Akses standar',
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? _primary.withOpacity(0.7)
                            : Colors.white24,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );

  // ── PASSWORD STRENGTH BAR ─────────────────────────────────
  Widget _buildStrengthBar() {
    final labels = ['Lemah', 'Sedang', 'Kuat'];
    final colors = [Colors.red, Colors.orange, _green];
    final idx    = (_passStrength - 1).clamp(0, 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < _passStrength
                      ? colors[idx]
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        if (_passStrength > 0)
          Text(
            'Kekuatan password: ${labels[idx]}',
            style: TextStyle(
              fontSize: 11,
              color: colors[idx],
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  // ── REGISTER BUTTON ───────────────────────────────────────
  Widget _buildRegisterButton() => SizedBox(
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
              onTap: _isLoading ? null : _handleRegister,
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
                          Icon(Icons.person_add_alt_1_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Buat Akun',
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
              'sudah punya akun?',
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

  // ── LOGIN LINK ────────────────────────────────────────────
  Widget _buildLoginLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sudah punya akun? ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.35),
              fontFamily: 'Poppins',
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/login'),
            child: ShaderMask(
              shaderCallback: (b) =>
                  const LinearGradient(colors: [_primary, _accent])
                      .createShader(b),
              child: const Text(
                'Masuk Sekarang',
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

  // ── LABEL ─────────────────────────────────────────────────
  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.7),
          fontFamily: 'Poppins',
        ),
      );

  // ── TEXT FIELD ────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    bool isFocused = false,
    required Function(bool) onFocusChange,
    Widget? suffix,
    void Function(String)? onChanged,
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
                        color: _primary.withOpacity(0.18), blurRadius: 16)
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            onChanged: onChanged,
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
                      padding: const EdgeInsets.only(right: 14),
                      child: suffix)
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
                borderSide:
                    const BorderSide(color: _primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.red.withOpacity(0.6), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Colors.red, width: 1.5),
              ),
              errorStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.redAccent),
            ),
          ),
        ),
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
    _b(canvas,
        Offset(size.width * 0.85 + math.sin(t * math.pi * 2) * 28,
            size.height * 0.06 + math.cos(t * math.pi * 2) * 18),
        size.width * 0.52,
        const Color(0xFF6366F1).withOpacity(0.12));

    _b(canvas,
        Offset(size.width * 0.08 + math.cos(t * math.pi * 2 + 1) * 22,
            size.height * 0.82 + math.sin(t * math.pi * 2 + 1) * 26),
        size.width * 0.55,
        const Color(0xFF8B5CF6).withOpacity(0.10));

    _b(canvas,
        Offset(size.width * 0.5 + math.sin(t * math.pi * 2 + 2) * 16,
            size.height * 0.45 + math.cos(t * math.pi * 2 + 2) * 12),
        size.width * 0.28,
        const Color(0xFF10B981).withOpacity(0.05));
  }

  void _b(Canvas canvas, Offset c, double r, Color color) =>
      canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = color
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55));

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}