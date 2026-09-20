import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/navigation/app_bar.dart';
import '../../services/report_service.dart';
import '../../widgets/common/app_dialog.dart';
import '_report_stepper.dart';

class ReportReviewScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;
  const ReportReviewScreen({super.key, required this.reportData});

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  bool _confirmed = false;

  void _submit() async {
    if (!_confirmed) {
      AppDialog.error(
        context,
        title: 'Confirmation Required',
        message: 'Please tick the box to confirm the information is accurate before submitting.',
        actionLabel: 'OK, Got It',
      );
      return;
    }

    AppDialog.loading(context, message: 'Submitting your report…');

    final result = await ReportService.instance.submitReport(widget.reportData);

    if (!mounted) return;
    AppDialog.hide(context);

    if (result.report != null) {
      // Success — navigate to submitted screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.reportSubmitted,
        (r) => r.settings.name == AppRoutes.home,
        arguments: {
          ...widget.reportData,
          'referenceNumber': result.report!.referenceNumber,
          'submittedAt': result.report!.submittedAt.toIso8601String(),
        },
      );
    } else {
      AppDialog.error(
        context,
        title: 'Submission Failed',
        message: result.error ?? 'Could not submit your report. Please check your connection and try again.',
        actionLabel: 'Try Again',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.reportData;
    final category = data['category'] as String? ?? 'Infrastructure';
    final concern = data['concern'] as String? ??
        data['issue'] as String? ?? '';
    final address = data['address'] as String? ?? '';
    final purok = data['purok'] as String? ?? '';
    final barangay = data['barangay'] as String? ?? '';
    final city = data['city'] as String? ?? 'Digos City';
    final province = data['province'] as String? ?? 'Davao del Sur';
    final landmark = data['landmark'] as String? ?? '';
    final additionalDetails = data['additionalDetails'] as String? ??
        data['description'] as String? ?? '';
    final hasPhoto = data['hasPhoto'] == true;
    final photoFile = data['photoFile'] as XFile?;

    final catColor = AppHelpers.getCategoryColor(category);
    final catBg = AppHelpers.getCategoryBgColor(category);
    final catIcon = AppHelpers.getCategoryIcon(category);
    final concernIcon = AppHelpers.getConcernIcon(concern);

    // Build full address string
    final addressParts = <String>[];
    if (address.isNotEmpty) addressParts.add(address);
    if (purok.isNotEmpty) addressParts.add(purok);
    if (barangay.isNotEmpty) addressParts.add('Brgy. $barangay');
    if (city.isNotEmpty) addressParts.add(city);
    if (province.isNotEmpty) addressParts.add(province);
    final fullAddress = addressParts.isEmpty
        ? 'No location selected'
        : addressParts.join(', ');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CivilWatchAppBar(
        title: 'Review Concern',
        subtitle: 'Step 5 of 5',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: ReportStepper(currentStep: 4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please review your concern\nbefore submitting.',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Once submitted, your concern will be forwarded\nto the appropriate city office.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Summary card ──────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Category row
                        _ReviewRow(
                          icon: catIcon,
                          label: 'Category',
                          child: _Chip(
                              label: category,
                              color: catColor,
                              bg: catBg),
                        ),
                        _RowDivider(),

                        // Concern row
                        _ReviewRow(
                          icon: concernIcon,
                          label: 'Concern',
                          child: Text(
                            concern.isEmpty ? '—' : concern,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _RowDivider(),

                        // Photo row
                        _ReviewRow(
                          icon: Icons.camera_alt_rounded,
                          label: 'Photo',
                          child: hasPhoto && photoFile != null
                              ? GestureDetector(
                                  onTap: () => showDialog(
                                    context: context,
                                    barrierColor:
                                        Colors.black.withOpacity(0.92),
                                    builder: (_) => GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).pop(),
                                      child: Scaffold(
                                        backgroundColor: Colors.transparent,
                                        body: Center(
                                          child: InteractiveViewer(
                                            child: Image.file(
                                                File(photoFile.path)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(photoFile.path),
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Color(0xFFF59E0B), size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'No photo attached',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        _RowDivider(),

                        // Location row
                        _ReviewRow(
                          icon: Icons.location_on_rounded,
                          label: 'Location',
                          child: Text(
                            fullAddress,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),

                        // Landmark row (only if provided)
                        if (landmark.isNotEmpty) ...[
                          _RowDivider(),
                          _ReviewRow(
                            icon: Icons.place_rounded,
                            label: 'Landmark',
                            child: Text(
                              landmark,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],

                        // Additional details row
                        _RowDivider(),
                        _ReviewRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Details',
                          child: Text(
                            additionalDetails.isEmpty
                                ? 'No additional details'
                                : additionalDetails,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: additionalDetails.isEmpty
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                              height: 1.4,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _RowDivider(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Confirmation checkbox ─────────────────────────────
                  GestureDetector(
                    onTap: () =>
                        setState(() => _confirmed = !_confirmed),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _confirmed
                            ? AppColors.primarySurface
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _confirmed
                              ? AppColors.primary
                              : AppColors.divider,
                          width: _confirmed ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _confirmed
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: _confirmed
                                    ? AppColors.primary
                                    : AppColors.inputBorder,
                                width: 2,
                              ),
                            ),
                            child: _confirmed
                                ? const Icon(Icons.check_rounded,
                                    color: AppColors.white, size: 15)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I confirm that the information provided\nis accurate and true.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom bar ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.divider),
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: Text(
                            'Submit Concern',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.divider);
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Chip({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
