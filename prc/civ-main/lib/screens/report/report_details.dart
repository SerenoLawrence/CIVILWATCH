import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../widgets/navigation/app_bar.dart';
import '_report_stepper.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;
  const ReportDetailsScreen({super.key, required this.reportData});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String? _selectedBarangay;
  bool _useCurrentLocation = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushNamed(context, AppRoutes.reportReview, arguments: {
      ...widget.reportData,
      'barangay': _selectedBarangay ?? 'Aplaya',
      'description': _descController.text.trim(),
      'severity': 'Moderate', // set by admin when assigning office
      'useCurrentLocation': _useCurrentLocation,
    });
  }

  @override
  Widget build(BuildContext context) {
    final category =
        widget.reportData['category'] as String? ?? 'Infrastructure';
    final catColor = AppHelpers.getCategoryColor(category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CivilWatchAppBar(
        title: 'Report Concern',
        subtitle: 'Step 4 of 5',
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ReportStepper(currentStep: 3),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Location ─────────────────────────────────────────
                    _SectionLabel(
                      icon: Icons.location_on_rounded,
                      label: 'Incident Location',
                    ),
                    const SizedBox(height: 12),

                    _LocationOption(
                      icon: Icons.my_location_rounded,
                      label: 'Use Current Location',
                      isSelected: _useCurrentLocation,
                      onTap: () =>
                          setState(() => _useCurrentLocation = true),
                    ),
                    const SizedBox(height: 8),
                    _LocationOption(
                      icon: Icons.location_on_rounded,
                      label: 'Select on Map',
                      isSelected: !_useCurrentLocation,
                      onTap: () =>
                          setState(() => _useCurrentLocation = false),
                    ),

                    if (!_useCurrentLocation) ...[
                      const SizedBox(height: 14),
                      _BarangayDropdown(
                        value: _selectedBarangay,
                        onChanged: (v) =>
                            setState(() => _selectedBarangay = v),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Description ───────────────────────────────────────
                    _SectionLabel(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Description',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Provide details about the incident.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descController,
                      validator: AppValidators.description,
                      maxLines: 4,
                      maxLength: 300,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: catColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _ReportDetailsFooter(
              onNext: _next,
              catColor: catColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}

class _BarangayDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;

  const _BarangayDropdown({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text('Select barangay',
          style:
              GoogleFonts.inter(fontSize: 14, color: AppColors.textHint)),
      onChanged: onChanged,
      items: AppStrings.barangays
          .map((b) => DropdownMenuItem(
                value: b,
                child: Text(b,
                    style: GoogleFonts.inter(fontSize: 14)),
              ))
          .toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        prefixIcon: const Icon(Icons.location_city_rounded,
            color: AppColors.textHint, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      style: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textPrimary),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary),
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class _ReportDetailsFooter extends StatelessWidget {
  final VoidCallback onNext;
  final Color catColor;
  const _ReportDetailsFooter(
      {required this.onNext, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: catColor,
                foregroundColor: AppColors.white,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                textStyle: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
