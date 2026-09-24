import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/helpers.dart';
import '../../models/report.dart';
import '../../widgets/cards/report_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/inputs/search_field.dart';

class MyReportsScreen extends StatefulWidget {
  final bool embedded;
  const MyReportsScreen({super.key, this.embedded = false});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'All';
  String _searchQuery = '';

  static const _filters = ['All', 'Pending', 'In Progress', 'Resolved'];

  List<IncidentReport> _getFiltered(List<IncidentReport> source) {
    var list = source;
    if (_activeFilter != 'All') {
      list = list.where((r) {
        if (_activeFilter == 'Pending') {
          return r.status == 'Pending Validation' || r.status == 'Submitted';
        }
        if (_activeFilter == 'In Progress') return r.status == 'In Progress';
        if (_activeFilter == 'Resolved') return r.status == 'Resolved';
        return true;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((r) =>
              r.issue.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.barangay.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AppState so list rebuilds whenever a report is added/updated
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, _) {
        final filtered = _getFiltered(AppState().reports);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.embedded) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Reports',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Track the status of your reported incidents.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.filter_list_rounded,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('Filter',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search + filter chips ──────────────────────────────
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Column(
                    children: [
                      SearchField(
                        hint: 'Search reports...',
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        onClear: () => setState(() => _searchQuery = ''),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((f) {
                            final isActive = _activeFilter == f;
                            Color dotColor = AppColors.textSecondary;
                            if (f == 'Pending')
                              dotColor = AppColors.statusPending;
                            if (f == 'In Progress')
                              dotColor = AppColors.statusInProgress;
                            if (f == 'Resolved')
                              dotColor = AppColors.statusResolved;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _activeFilter = f),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.navy
                                        : AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.navy
                                          : AppColors.divider,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (f != 'All') ...[
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.white
                                                : dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ] else ...[
                                        Icon(Icons.list_rounded,
                                            size: 14,
                                            color: isActive
                                                ? AppColors.white
                                                : AppColors.textSecondary),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        f,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isActive
                                              ? AppColors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),

                // ── Report List ────────────────────────────────────────
                Expanded(
                  child: AppState().isLoading
                      ? const MyReportsSkeleton()
                      : filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.article_outlined,
                          title: 'No reports found',
                          subtitle: _searchQuery.isNotEmpty
                              ? 'Try a different search term.'
                              : 'You have no $_activeFilter reports yet.',
                          actionLabel: 'Report a Concern',
                          onAction: () => Navigator.pushNamed(
                              context, AppRoutes.reportCategory),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final report = filtered[i];
                            return ReportCard(
                              report: report,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.trackReport,
                                arguments: {'reportId': report.id},
                              ),
                            );
                          },
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
