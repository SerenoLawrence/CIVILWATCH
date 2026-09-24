import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/helpers.dart';
import '../../models/notification_model.dart';
import '../../widgets/cards/notification_card.dart';
import '../../widgets/common/skeleton.dart';

class NotificationScreen extends StatelessWidget {
  final bool embedded;
  const NotificationScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final state = AppState();
        final allNotifs = state.notifications;
        final unread = state.unreadCount;

        final today = allNotifs
            .where((n) =>
                DateTime.now().difference(n.timestamp).inHours < 24)
            .toList();
        final yesterday = allNotifs.where((n) {
          final diff = DateTime.now().difference(n.timestamp);
          return diff.inHours >= 24 && diff.inHours < 48;
        }).toList();
        final earlier = allNotifs
            .where((n) =>
                DateTime.now().difference(n.timestamp).inHours >= 48)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      if (!embedded) ...[
                        IconButton(
                          icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Notifications',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (unread > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$unread new',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (unread > 0)
                        TextButton(
                          onPressed: () => state.markAllRead(),
                          child: Text(
                            'Mark all read',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),

                // ── List ─────────────────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const NotificationsSkeleton()
                      : allNotifs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "You'll be notified when\nyour report status changes.",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (today.isNotEmpty) ...[
                              _GroupLabel('Today'),
                              ...today.map((n) => NotificationCard(
                                    notification: n,
                                    onTap: () => state.markRead(n.id),
                                  )),
                            ],
                            if (yesterday.isNotEmpty) ...[
                              _GroupLabel('Yesterday'),
                              ...yesterday.map((n) => NotificationCard(
                                    notification: n,
                                    onTap: () => state.markRead(n.id),
                                  )),
                            ],
                            if (earlier.isNotEmpty) ...[
                              _GroupLabel('Earlier'),
                              ...earlier.map((n) => NotificationCard(
                                    notification: n,
                                    onTap: () => state.markRead(n.id),
                                  )),
                            ],
                            const SizedBox(height: 12),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
