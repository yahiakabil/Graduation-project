import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/company_models.dart';
import '../../logic/company/company_cubit.dart';
import '../../logic/company/company_state.dart';
import '../../core/theme/app_colors_extension.dart';

class AdminRulesScreen extends StatefulWidget {
  const AdminRulesScreen({super.key});

  @override
  State<AdminRulesScreen> createState() => _AdminRulesScreenState();
}

class _AdminRulesScreenState extends State<AdminRulesScreen> {
  DeductionRulesModel? _editedRules;
  bool _hasUnsavedChanges = false;

  DeductionRulesModel _getCurrentRules(CompanyState state) {
    if (_editedRules != null) return _editedRules!;
    if (state is CompanyLoaded) {
      _editedRules = state.rules;
      return _editedRules!;
    }
    return const DeductionRulesModel();
  }

  void _updateRule(DeductionRulesModel updated) {
    setState(() {
      _editedRules = updated;
      _hasUnsavedChanges = true;
    });
  }

  void _revertChanges(DeductionRulesModel original) {
    setState(() {
      _editedRules = original;
      _hasUnsavedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reverted all changes to current active company rules.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Standard Defaults?'),
        content: const Text(
          'This will reset all lateness tiers, absence rules, 50m geofence, and 1.5x overtime rate to standard labor policy defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.absent),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _editedRules = const DeductionRulesModel();
                _hasUnsavedChanges = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset to standard labor policy defaults. Remember to Save & Apply.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset to Defaults', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Deduction Rules & Policies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to Defaults',
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state is CompanyLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.onTime,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final repoRules = (state is CompanyLoaded) ? state.rules : const DeductionRulesModel();
          final rules = _getCurrentRules(state);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
              // Unsaved changes banner
              if (_hasUnsavedChanges)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.late.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.late.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.late, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'You have unsaved rule modifications. Tap "Save & Apply" below to deploy.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.late,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _revertChanges(repoRules),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Revert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),

              // Section 1 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVE LATENESS LADDER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.colors.textMuted,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tap any tier to edit',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: context.colors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildEditableRow(
                      title: 'Grace Period (0–15 mins)',
                      value: rules.gracePeriod,
                      color: AppColors.onTime,
                      presets: const ['0 min deduction', 'Grace period only', '15 mins warning'],
                      onChanged: (val) => _updateRule(rules.copyWith(gracePeriod: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildEditableRow(
                      title: 'Tier 1 (16–60 mins late)',
                      value: rules.tier1,
                      color: AppColors.late,
                      presets: const ['0.5 Hour deduction', '1.0 Hour deduction', '1.5 Hours deduction', '2.0 Hours deduction'],
                      onChanged: (val) => _updateRule(rules.copyWith(tier1: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildEditableRow(
                      title: 'Tier 2 (61–120 mins late)',
                      value: rules.tier2,
                      color: AppColors.late,
                      presets: const ['1.5 Hours deduction', '2.0 Hours deduction', '2.5 Hours deduction', 'Half Day deduction'],
                      onChanged: (val) => _updateRule(rules.copyWith(tier2: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildEditableRow(
                      title: 'Tier 3 (121–240 mins late)',
                      value: rules.tier3,
                      color: AppColors.absent,
                      presets: const ['Half Day deduction', '3.0 Hours deduction', '4.0 Hours deduction', 'Full Day deduction'],
                      onChanged: (val) => _updateRule(rules.copyWith(tier3: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildEditableRow(
                      title: 'Tier 4 (> 240 mins late)',
                      value: rules.tier4,
                      color: AppColors.absent,
                      presets: const ['Full Day deduction', '1.5 Days deduction', '2.0 Days deduction'],
                      onChanged: (val) => _updateRule(rules.copyWith(tier4: val)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 2 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ABSENCE & SECURITY POLICIES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.colors.textMuted,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tap policy to customize',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: context.colors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildEditableRow(
                      title: 'Unexcused Absence',
                      value: rules.unexcusedAbsence,
                      color: AppColors.absent,
                      presets: const ['1.0 Day deduction', '2.0 Days deduction', '3.0 Days deduction', 'Official Warning + 2 Days'],
                      onChanged: (val) => _updateRule(rules.copyWith(unexcusedAbsence: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildEditableRow(
                      title: 'Missing Check-Out (24h)',
                      value: rules.missingCheckout,
                      color: AppColors.late,
                      presets: const ['Half Day deduction (if not fixed in 24h)', 'Full Day deduction', '1.0 Hour deduction', 'Notice Warning only'],
                      onChanged: (val) => _updateRule(rules.copyWith(missingCheckout: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildNumericRow(
                      title: 'Office Geofence Radius',
                      currentValue: rules.geofenceRadius,
                      unit: 'Meters (Strict)',
                      color: context.colors.primary,
                      presets: const [30.0, 50.0, 75.0, 100.0, 200.0],
                      helperText: 'Employees must be within this GPS distance from the branch coordinates to clock in.',
                      onChanged: (val) => _updateRule(rules.copyWith(geofenceRadius: val)),
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _buildNumericRow(
                      title: 'Overtime Multiplier Rate',
                      currentValue: rules.overtimeMultiplier,
                      unit: 'x Regular Hourly Rate',
                      color: AppColors.onTime,
                      presets: const [1.25, 1.5, 1.75, 2.0],
                      helperText: 'Applied to base hourly rate for approved manager & employee overtime hours.',
                      onChanged: (val) => _updateRule(rules.copyWith(overtimeMultiplier: val)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Button
              ElevatedButton.icon(
                onPressed: () {
                  // Save rules to repository and cubit
                  context.read<CompanyCubit>().saveRules(rules);
                  // Sync live app geofence radius config
                  AppConfig.branchRadiusMeters = rules.geofenceRadius;

                  setState(() {
                    _hasUnsavedChanges = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Company-wide deduction rules & geofence updated successfully!'),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.onTime,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  _hasUnsavedChanges ? 'Save & Apply Rule Changes' : 'Rules Active & Up to Date',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasUnsavedChanges ? context.colors.primary : AppColors.onTime,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: _hasUnsavedChanges ? 3 : 0,
                ),
              ),
            ],
          ),
        ),
      );
    },
      ),
    );
  }

  Widget _buildEditableRow({
    required String title,
    required String value,
    required Color color,
    required List<String> presets,
    required ValueChanged<String> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTextEditDialog(title, value, presets, onChanged),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to edit rule',
                      style: TextStyle(fontSize: 10, color: context.colors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_outlined, size: 13, color: color),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericRow({
    required String title,
    required double currentValue,
    required String unit,
    required Color color,
    required List<double> presets,
    required String helperText,
    required ValueChanged<double> onChanged,
  }) {
    final displayValue = (currentValue == currentValue.roundToDouble())
        ? '${currentValue.toInt()} $unit'
        : '$currentValue $unit';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showNumericEditDialog(title, currentValue, unit, presets, helperText, onChanged),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to edit value',
                      style: TextStyle(fontSize: 10, color: context.colors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayValue,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_outlined, size: 13, color: color),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextEditDialog(
    String title,
    String currentValue,
    List<String> presets,
    ValueChanged<String> onSave,
  ) {
    final controller = TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.colors.textMain),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Custom Penalty / Rule Description:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.colors.bgCanvas,
                      hintText: 'Enter penalty (e.g. 1.0 Hour deduction)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.colors.borderSubtle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick Preset Options:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((p) {
                      final isSelected = controller.text == p;
                      return ChoiceChip(
                        label: Text(p, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : context.colors.textMain)),
                        selected: isSelected,
                        selectedColor: context.colors.primary,
                        
                        onSelected: (val) {
                          setSheetState(() {
                            controller.text = p;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final text = controller.text.trim();
                            if (text.isNotEmpty) {
                              onSave(text);
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Apply Change'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNumericEditDialog(
    String title,
    double currentValue,
    String unit,
    List<double> presets,
    String helperText,
    ValueChanged<double> onSave,
  ) {
    final controller = TextEditingController(
      text: (currentValue == currentValue.roundToDouble())
          ? currentValue.toInt().toString()
          : currentValue.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.colors.textMain),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    helperText,
                    style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: context.colors.bgCanvas,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: context.colors.borderSubtle),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: context.colors.bgCanvas,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.colors.borderSubtle),
                        ),
                        child: Text(
                          unit,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: context.colors.textMain),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick Presets:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((p) {
                      final strVal = (p == p.roundToDouble()) ? p.toInt().toString() : p.toString();
                      final isSelected = controller.text == strVal;
                      return ChoiceChip(
                        label: Text(
                          '$strVal $unit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : context.colors.textMain,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: context.colors.primary,
                        
                        onSelected: (val) {
                          setSheetState(() {
                            controller.text = strVal;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final parsed = double.tryParse(controller.text.trim());
                            if (parsed != null && parsed > 0) {
                              onSave(parsed);
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Apply Change'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

