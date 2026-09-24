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

// ─────────────────────────────────────────────────────────────────────────────
// HomeTabSkeleton
// Mirrors: AppBar greeting | stat tiles row | CTA banner |
//          section header | mini map card | section header | announcement cards
// ─────────────────────────────────────────────────────────────────────────────
class HomeTabSkeleton extends StatelessWidget {
  const HomeTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting area ────────────────────────────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 160, height: 14),
                const SizedBox(height: 6),
                const SkeletonBox(width: 220, height: 22),
              ],
            ),
          ),
          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── CTA banner ────────────────────────────────────────────
                const SkeletonBox(
                    width: double.infinity, height: 80, radius: 16),
                const SizedBox(height: 28),

                // ── "My Reports" section title ────────────────────────────
                _sectionHeader(),
                const SizedBox(height: 14),

                // ── 4 stat tiles ──────────────────────────────────────────
                Row(
                  children: List.generate(4, (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                      child: _statTile(),
                    ),
                  )),
                ),
                const SizedBox(height: 28),

                // ── "Community Map" section title ─────────────────────────
                _sectionHeader(),
                const SizedBox(height: 14),

                // ── Mini map card ─────────────────────────────────────────
                const SkeletonBox(
                    width: double.infinity, height: 170, radius: 16),
                const SizedBox(height: 28),

                // ── "Announcements" section title ─────────────────────────
                _sectionHeader(),
                const SizedBox(height: 14),

                // ── 2 announcement cards ──────────────────────────────────
                _announcementCard(),
                const SizedBox(height: 12),
                _announcementCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          SkeletonBox(width: 110, height: 14),
          SkeletonBox(width: 60, height: 12),
        ],
      );

  Widget _statTile() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: const [
            SkeletonBox.circle(size: 36),
            SizedBox(height: 8),
            SkeletonBox(width: 28, height: 18),
            SizedBox(height: 4),
            SkeletonBox(width: 40, height: 10),
          ],
        ),
      );

  Widget _announcementCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox.circle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: double.infinity, height: 13),
                  SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 11),
                  SizedBox(height: 4),
                  SkeletonBox(width: 160, height: 11),
                  SizedBox(height: 8),
                  SkeletonBox(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// MyReportsSkeleton
// Mirrors: search bar | filter chips | list of ReportCards (left strip + info)
// ─────────────────────────────────────────────────────────────────────────────
class MyReportsSkeleton extends StatelessWidget {
  const MyReportsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          const SkeletonBox(width: double.infinity, height: 44, radius: 12),
          const SizedBox(height: 12),

          // Filter chips row
          Row(
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SkeletonBox(width: 72 + (i * 8.0), height: 32, radius: 20),
            )),
          ),
          const SizedBox(height: 16),

          // Report card list
          ...List.generate(5, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _reportCard(),
          )),
        ],
      ),
    );
  }

  Widget _reportCard() => Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Category colour strip
            const SkeletonBox(width: 6, height: double.infinity, radius: 0),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        SkeletonBox(width: 140, height: 14),
                        SkeletonBox(width: 72, height: 22, radius: 12),
                      ],
                    ),
                    const SkeletonBox(width: 180, height: 11),
                    Row(
                      children: const [
                        SkeletonBox(width: 100, height: 10),
                        SizedBox(width: 16),
                        SkeletonBox(width: 80, height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsSkeleton
// Mirrors: group label | list of notification rows (icon + title + desc + time)
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Today" group label
          const SkeletonBox(width: 60, height: 12),
          const SizedBox(height: 10),
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _notifRow(),
          )),
          const SizedBox(height: 12),

          // "Yesterday" group label
          const SkeletonBox(width: 90, height: 12),
          const SizedBox(height: 10),
          ...List.generate(2, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _notifRow(),
          )),
        ],
      ),
    );
  }

  Widget _notifRow() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox.circle(size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: double.infinity, height: 13),
                  SizedBox(height: 5),
                  SkeletonBox(width: double.infinity, height: 11),
                  SizedBox(height: 4),
                  SkeletonBox(width: 160, height: 11),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileSkeleton
// Mirrors: avatar circle + name + location + chip |
//          activity stats card (3 tiles) |
//          menu items list
// ─────────────────────────────────────────────────────────────────────────────
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SkeletonBox(width: 80, height: 14),
                    SkeletonBox(width: 60, height: 30, radius: 20),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar
                const SkeletonBox.circle(size: 80),
                const SizedBox(height: 12),

                // Name + location + chip
                const SkeletonBox(width: 160, height: 18),
                const SizedBox(height: 6),
                const SkeletonBox(width: 200, height: 12),
                const SizedBox(height: 8),
                const SkeletonBox(width: 70, height: 24, radius: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Activity stats card ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 90, height: 14),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(3, (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      child: Column(
                        children: const [
                          SkeletonBox.circle(size: 36),
                          SizedBox(height: 6),
                          SkeletonBox(width: 30, height: 16),
                          SizedBox(height: 4),
                          SkeletonBox(width: 48, height: 10),
                        ],
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
                _infoRow(),
                const SizedBox(height: 10),
                _infoRow(),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Menu card ────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: List.generate(4, (i) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: const [
                        SkeletonBox.circle(size: 36),
                        SizedBox(width: 14),
                        SkeletonBox(width: 120, height: 13),
                        Spacer(),
                        SkeletonBox(width: 16, height: 16, radius: 4),
                      ],
                    ),
                  ),
                  if (i < 3)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              )),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoRow() => Row(
        children: const [
          SkeletonBox.circle(size: 18),
          SizedBox(width: 10),
          SkeletonBox(width: 80, height: 11),
          SizedBox(width: 8),
          SkeletonBox(width: 120, height: 11),
        ],
      );
}
