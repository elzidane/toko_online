import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  AlertMassage  —  dark-themed, konsisten dengan dashboard
// ─────────────────────────────────────────────────────────────
class AlertMassage {
  static const _bg      = Color(0xFF1E293B);
  static const _surface = Color(0xFF334155);
  static const _primary = Color(0xFF6366F1);
  static const _accent  = Color(0xFF8B5CF6);

  // ── 1. OVERLAY TOAST (top-slide) ─────────────────────────
  void showAlert(
    BuildContext context,
    String message,
    bool status, {
    Duration? duration,
    VoidCallback? onClose,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    bool closed = false;

    void close() {
      if (!closed) {
        closed = true;
        if (entry.mounted) entry.remove();
        onClose?.call();
      }
    }

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _SlideToast(
            message: message,
            status: status,
            onClose: close,
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration ?? const Duration(seconds: 4), close);
  }

  // ── 2. SNACKBAR ───────────────────────────────────────────
  void showSnackBarAlert(
    BuildContext context,
    String message,
    bool status, {
    Duration? duration,
  }) {
    final isSuccess = status;
    final color     = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon      = isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration ?? const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSuccess ? 'Berhasil' : 'Gagal',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withOpacity(0.35), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. DIALOG ALERT ───────────────────────────────────────
  void showDialogAlert(
    BuildContext context,
    String message,
    bool status, {
    String? title,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => _DarkDialog(
        message: message,
        status: status,
        title: title,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  // ── 4. CONFIRM DIALOG (hapus / lanjut) ───────────────────
  Future<Map<String, dynamic>?> showAlertDialog(BuildContext context) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => const _ConfirmDialog(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SLIDE TOAST
// ─────────────────────────────────────────────────────────────
class _SlideToast extends StatefulWidget {
  final String message;
  final bool status;
  final VoidCallback onClose;

  const _SlideToast({
    required this.message,
    required this.status,
    required this.onClose,
  });

  @override
  State<_SlideToast> createState() => _SlideToastState();
}

class _SlideToastState extends State<_SlideToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color => widget.status
      ? const Color(0xFF10B981)
      : const Color(0xFFEF4444);

  IconData get _icon => widget.status
      ? Icons.check_circle_rounded
      : Icons.error_rounded;

  String get _title => widget.status ? 'Berhasil!' : 'Gagal!';

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _color.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _color.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: _color.withOpacity(0.25), width: 1.5),
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),

              const SizedBox(width: 14),

              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        color: _color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Close button
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white.withOpacity(0.4), size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DARK DIALOG  (success / error)
// ─────────────────────────────────────────────────────────────
class _DarkDialog extends StatefulWidget {
  final String message;
  final bool status;
  final String? title;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const _DarkDialog({
    required this.message,
    required this.status,
    this.title,
    this.confirmText,
    this.onConfirm,
  });

  @override
  State<_DarkDialog> createState() => _DarkDialogState();
}

class _DarkDialogState extends State<_DarkDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color =>
      widget.status ? const Color(0xFF10B981) : const Color(0xFFEF4444);

  IconData get _icon =>
      widget.status ? Icons.check_circle_rounded : Icons.error_rounded;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: _color.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon dengan glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _color.withOpacity(0.06),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _color.withOpacity(0.12),
                        border: Border.all(
                            color: _color.withOpacity(0.25), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _color.withOpacity(0.25),
                              blurRadius: 20),
                        ],
                      ),
                      child: Icon(_icon, color: _color, size: 32),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  widget.title ??
                      (widget.status ? 'Berhasil!' : 'Terjadi Kesalahan'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _color,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.55),
                    fontFamily: 'Poppins',
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: _outlineBtn(
                        'Tutup',
                        () => Navigator.of(context).pop(),
                      ),
                    ),
                    if (widget.onConfirm != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _fillBtn(
                          widget.confirmText ?? 'OK',
                          _color,
                          () {
                            Navigator.of(context).pop();
                            widget.onConfirm!();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CONFIRM DIALOG  (hapus / batal)
// ─────────────────────────────────────────────────────────────
class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog();

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scale = Tween<double>(begin: 0.85, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  //mengkonfirmasi data akan dihapus atau tidak
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withOpacity(0.08), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon konfirmasi
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF59E0B).withOpacity(0.06),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFF59E0B),
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'Hapus Data?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  'Data yang dihapus tidak dapat dikembalikan.\nApakah kamu yakin ingin melanjutkan?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.45),
                    fontFamily: 'Poppins',
                    height: 1.65,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Tombol
                Row(
                  children: [
                    Expanded(
                      child: _outlineBtn(
                        'Batal',
                        () => Navigator.of(context)
                            .pop({'status': false}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _fillBtn(
                        'Hapus',
                        const Color(0xFFEF4444),
                        () => Navigator.of(context)
                            .pop({'status': true}),
                        icon: Icons.delete_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED BUTTON HELPERS
// ─────────────────────────────────────────────────────────────
Widget _outlineBtn(String label, VoidCallback onTap) => SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white.withOpacity(0.04),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );

Widget _fillBtn(String label, Color color, VoidCallback onTap,
    {IconData? icon}) =>
    SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

// ─────────────────────────────────────────────────────────────
//  TOAST NOTIFICATION (static, dari bawah)
// ─────────────────────────────────────────────────────────────
class ToastNotification {
  static void show(BuildContext context, String message, bool isSuccess) {
    final color = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon  = isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 24,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _BottomToast(
              message: message, color: color, icon: icon),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _BottomToast extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _BottomToast(
      {required this.message, required this.color, required this.icon});

  @override
  State<_BottomToast> createState() => _BottomToastState();
}

class _BottomToastState extends State<_BottomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withOpacity(0.15), blurRadius: 20),
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}