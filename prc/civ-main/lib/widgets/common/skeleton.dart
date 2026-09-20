import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton loading primitives
//
// Usage:
//   SkeletonBox(width: 120, height: 14)          — generic shimmer box
//   SkeletonBox.circle(size: 40)                 — circular avatar placeholder
//   SkeletonBox.text(width: 200)                 — single-line text placeholder
//   SkeletonBox.multiline(lines: 3, width: ...)  — stacked text lines
//
// Compose them into a skeleton layout that mirrors the real screen:
//
//   RegisterSkeleton()   — pre-built skeleton for the register form
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.circle = false,
  });

  /// Circular placeholder (e.g. avatar, icon badge).
  const SkeletonBox.circle({super.key, required double size})
      : width  = size,
        height = size,
        radius = size / 2,
        circle = true;

  /// Single text-line placeholder.
  const SkeletonBox.text({super.key, double? width, double height = 13})
      : width  = width,
        height = height,
        radius = 6,
        circle = false;

  /// Stacked multi-line text block — returns a Column, not a SkeletonBox.
  static Widget multiline({
    int lines = 3,
    double? width,
    double lineHeight = 13,
    double spacing = 8,
    double lastLineWidthFactor = 0.6,
  }) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (i) {
          final isLast = i == lines - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: i < lines - 1 ? spacing : 0),
            child: _SkeletonShimmer(
              width: isLast && width != null
                  ? width * lastLineWidthFactor
                  : width,
              height: lineHeight,
              radius: 6,
            ),
          );
        }),
      );
    });
  }

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> {
  @override
  Widget build(BuildContext context) {
    return _SkeletonShimmer(
      width:  widget.width,
      height: widget.height,
      radius: widget.circle ? widget.height / 2 : widget.radius,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal animated shimmer
// ─────────────────────────────────────────────────────────────────────────────
class _SkeletonShimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonShimmer({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          width:  widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.lerp(
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF1F5F9),
                  _anim.value,
                )!,
                Color.lerp(
                  const Color(0xFFF1F5F9),
                  const Color(0xFFE2E8F0),
                  _anim.value,
                )!,
                Color.lerp(
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF1F5F9),
                  _anim.value,
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RegisterSkeleton
// Mirrors the register form card layout — shown while the screen is animating
// in or while a slow initial load is in progress.
// ─────────────────────────────────────────────────────────────────────────────
class RegisterSkeleton extends StatelessWidget {
  const RegisterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title placeholder
          const SkeletonBox(width: 200, height: 22),
          const SizedBox(height: 8),
          const SkeletonBox(width: 260, height: 14),
          const SizedBox(height: 28),

          // Form card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonField(labelWidth: 110),
                const SizedBox(height: 18),
                _skeletonField(labelWidth: 80),
                const SizedBox(height: 18),
                _skeletonField(labelWidth: 130),
                const SizedBox(height: 18),
                _skeletonField(labelWidth: 120),
                const SizedBox(height: 24),

                const Divider(color: AppColors.divider),
                const SizedBox(height: 20),

                // PIN row
                _skeletonField(labelWidth: 160),
                const SizedBox(height: 14),
                _skeletonPinRow(),
                const SizedBox(height: 20),

                // Confirm PIN row
                _skeletonField(labelWidth: 100),
                const SizedBox(height: 14),
                _skeletonPinRow(),
                const SizedBox(height: 4),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Terms checkbox placeholder
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          const SizedBox(height: 24),

          // Button placeholder
          const SkeletonBox(width: double.infinity, height: 54, radius: 16),
        ],
      ),
    );
  }

  Widget _skeletonField({double labelWidth = 100}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: labelWidth, height: 12),
        const SizedBox(height: 8),
        const SkeletonBox(width: double.infinity, height: 48, radius: 12),
      ],
    );
  }

  Widget _skeletonPinRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SkeletonBox(width: 46, height: 54, radius: 14),
      )),
    );
  }
}
