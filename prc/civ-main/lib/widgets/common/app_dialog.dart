import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppDialog  — user-friendly modal for ages 36–50
//
// Design goals:
//   • Large centred card — always visible, never hidden behind keyboard
//   • Big icon badge (88px), large readable text (16–20px)
//   • Tall tap-friendly button (56px, full-width)
//   • Coloured top accent strip per variant for instant recognition
//   • Smooth scale+fade entrance animation
//
// Static helpers:
//   AppDialog.loading(context, message: '...')
//   AppDialog.success(context, title: '...', message: '...', ...)
//   AppDialog.error(context, title: '...', message: '...', ...)
//   AppDialog.hide(context)
// ─────────────────────────────────────────────────────────────────────────────

enum _DialogVariant { loading, success, error }

class AppDialog extends StatelessWidget {
  final _DialogVariant _variant;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const AppDialog._({
    required _DialogVariant variant,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  }) : _variant = variant;

  // ── Loading ───────────────────────────────────────────────────────────────
  static Future<void> loading(
    BuildContext context, {
    String message = 'Please wait…',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: true,
      builder: (_) => AppDialog._(
        variant: _DialogVariant.loading,
        message: message,
      ),
    );
  }

  // ── Success ───────────────────────────────────────────────────────────────
  static Future<void> success(
    BuildContext context, {
    String title = 'Success!',
    required String message,
    String actionLabel = 'Continue',
    VoidCallback? onAction,
  }) {
    HapticFeedback.lightImpact();
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: true,
      builder: (_) => AppDialog._(
        variant: _DialogVariant.success,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  static Future<void> error(
    BuildContext context, {
    String title = 'Something went wrong',
    required String message,
    String actionLabel = 'OK, Got It',
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    HapticFeedback.mediumImpact();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      useRootNavigator: true,
      builder: (_) => AppDialog._(
        variant: _DialogVariant.error,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: onDismiss,
      ),
    );
  }

  // ── Dismiss helper ────────────────────────────────────────────────────────
  static void hide(BuildContext context) {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _variant != _DialogVariant.loading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Tight horizontal padding so card is wide on small phones
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        // Align slightly above center — stays visible even with soft keyboard
        alignment: const Alignment(0, -0.15),
        child: _DialogCard(
          variant: _variant,
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal animated card
// ─────────────────────────────────────────────────────────────────────────────
class _DialogCard extends StatefulWidget {
  final _DialogVariant variant;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const _DialogCard({
    required this.variant,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  @override
  State<_DialogCard> createState() => _DialogCardState();
}

class _DialogCardState extends State<_DialogCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Per-variant colours ───────────────────────────────────────────────────
  Color get _accent {
    return switch (widget.variant) {
      _DialogVariant.loading => AppColors.primary,
      _DialogVariant.success => const Color(0xFF16A34A),
      _DialogVariant.error   => const Color(0xFFDC2626),
    };
  }

  Color get _accentLight {
    return switch (widget.variant) {
      _DialogVariant.loading => AppColors.primarySurface,
      _DialogVariant.success => const Color(0xFFF0FDF4),
      _DialogVariant.error   => const Color(0xFFFEF2F2),
    };
  }

  // ── Icon area ─────────────────────────────────────────────────────────────
  Widget get _icon {
    if (widget.variant == _DialogVariant.loading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 3.5,
        ),
      );
    }
    final iconData = widget.variant == _DialogVariant.success
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    return Icon(iconData, color: _accent, size: 44);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.18),
                blurRadius: 48,
                spreadRadius: 0,
                offset: const Offset(0, 16),
              ),
              const BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          // Clip so the top accent strip respects the rounded corners
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Coloured accent strip at top ────────────────────────────
              Container(
                height: 6,
                color: _accent,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon badge ────────────────────────────────────────
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: _icon),
                    ),

                    const SizedBox(height: 24),

                    // ── Title ─────────────────────────────────────────────
                    if (widget.title != null) ...[
                      Text(
                        widget.title!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // ── Message (success / error only — loading has its own below) ─
                    if (widget.message != null &&
                        widget.variant != _DialogVariant.loading)
                      Text(
                        widget.message!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                    // ── Action button ─────────────────────────────────────
                    if (widget.variant != _DialogVariant.loading) ...[
                      const SizedBox(height: 28),

                      // Full-width tall button — easy to tap
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            if (widget.onAction != null) {
                              widget.onAction!();
                            } else if (widget.onDismiss != null) {
                              widget.onDismiss!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            widget.actionLabel ?? 'OK',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),

                      // ── Tap-outside hint for error dialogs ────────────
                      if (widget.variant == _DialogVariant.error) ...[
                        const SizedBox(height: 12),
                        Text(
                          'or tap outside to dismiss',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],

                    // ── Loading sub-label ─────────────────────────────────
                    if (widget.variant == _DialogVariant.loading &&
                        widget.message != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        widget.message!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
