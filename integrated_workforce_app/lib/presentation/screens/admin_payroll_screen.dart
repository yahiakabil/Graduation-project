import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../data/models/company_models.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/payroll/payroll_cubit.dart';
import '../../logic/payroll/payroll_state.dart';

class AdminPayrollScreen extends StatelessWidget {
  const AdminPayrollScreen({super.key});

  void _showLockMonthConfirmation(BuildContext context, PayrollLoaded state) {
    final colors = context.colors;
    final month = state.activeMonth;
    final days = state.daysAccrued;
    final amount = state.estimatedAccruedNet > 0 ? state.estimatedAccruedNet : (month.totalNet / 30 * days);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors.bgCard,
        title: Row(
          children: [
            Icon(Icons.payments_rounded, color: colors.statusSuccess, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Disburse & Pay Salaries',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colors.textMain,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm salary disbursement for ' + month.label + ':',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              '• Accrued period: ' + days.toString() + ' day(s)\n' +
              '• Estimated net payout: \$' + amount.toStringAsFixed(2) + '\n' +
              '• Deductions, overtime, and bonuses calculated automatically.\n' +
              '• Once disbursed today, next disbursement will unlock tomorrow for +1 day.\n' +
              '• Push notification broadcast to company roster.',
              style: TextStyle(fontSize: 12, height: 1.5, color: colors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textDim)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<PayrollCubit>().disburseSalaries();
              context.read<NotificationsCubit>().addNotification(
                    title: 'Daily Salary Disbursed (' + days.toString() + ' Day(s))',
                    description: 'Salary disbursement processed for ' + days.toString() + ' accrued day(s).',
                    type: 'approval',
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.statusSuccess,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Disbursement'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown(BuildContext context, AppColorsExtension colors, PayrollLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedMonthId,
          dropdownColor: colors.bgCard,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary, size: 20),
          items: state.months.map((m) {
            return DropdownMenuItem<String>(
              value: m.id,
              child: Text(
                m.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.textMain,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<PayrollCubit>().selectMonth(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthStatusChip(PayrollMonthModel activeMonth, AppColorsExtension colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: activeMonth.isLocked
            ? colors.bgCardSubtle
            : colors.statusSuccess.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: activeMonth.isLocked
              ? colors.borderSubtle
              : colors.statusSuccess.withAlpha(60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activeMonth.isLocked
                ? Icons.lock_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 15,
            color: activeMonth.isLocked ? colors.textMuted : colors.statusSuccess,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Status: ${activeMonth.status}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: activeMonth.isLocked ? colors.textMuted : colors.statusSuccess,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisburseButton(
      BuildContext context, PayrollLoaded state, AppColorsExtension colors) {
    if (state.isDisbursedToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.statusSuccess.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.statusSuccess.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: colors.statusSuccess),
            const SizedBox(width: 6),
            Text(
              'Disbursed Today (0 days pending)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: colors.statusSuccess,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: state.isDisbursing ? null : () => _showLockMonthConfirmation(context, state),
      icon: state.isDisbursing
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.payments_rounded, size: 15),
      label: Text(
        state.isDisbursing
            ? 'Processing...'
            : 'Disburse Salaries (' + state.daysAccrued.toString() + ' Day' + (state.daysAccrued > 1 ? 's' : '') + ')',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required AppColorsExtension colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgCardSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      appBar: AppBar(
        backgroundColor: colors.bgCard,
        elevation: 0,
        title: Text(
          'Payroll Department',
          style: TextStyle(
            color: colors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textMain),
      ),
      body: BlocConsumer<PayrollCubit, PayrollState>(
        listener: (context, state) {
          if (state is PayrollLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: colors.statusSuccess,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PayrollLoading) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (state is! PayrollLoaded) {
            return Center(
              child: Text(
                'Loading payroll archives...',
                style: TextStyle(color: colors.textMuted),
              ),
            );
          }

          final activeMonth = state.activeMonth;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Header & Month Selector (Responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 460;
                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAYROLL ARCHIVES & HISTORY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    activeMonth.label,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildMonthDropdown(context, colors, state),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAYROLL ARCHIVES & HISTORY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: colors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeMonth.label,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: colors.textMain,
                                ),
                              ),
                            ],
                          ),
                          _buildMonthDropdown(context, colors, state),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // 2. Month Status Banner (Responsive Stack on Mobile)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 460;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.bgCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        child: isNarrow
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMonthStatusChip(activeMonth, colors),
                                  if (!activeMonth.isLocked) ...[
                                    const SizedBox(height: 10),
                                    _buildDisburseButton(context, state, colors),
                                  ],
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMonthStatusChip(activeMonth, colors),
                                  if (!activeMonth.isLocked)
                                    _buildDisburseButton(context, state, colors),
                                ],
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Total Company Net Payout Card (Executive Cyber Styling)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'PAYROLL TELEMETRY',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                          color: colors.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AUDITED MONTH',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: colors.textDim,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '\$${activeMonth.totalNet.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: colors.textMain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Sub-cards Grid (Responsive: 2-column or stacked)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 360;
                            final deductionsCard = _buildSubStatCard(
                              icon: Icons.trending_down_rounded,
                              iconColor: colors.statusDanger,
                              title: 'Total Deductions',
                              value: '-\$${activeMonth.totalDeductions.toStringAsFixed(2)}',
                              valueColor: colors.statusDanger,
                              colors: colors,
                            );
                            final overtimeCard = _buildSubStatCard(
                              icon: Icons.trending_up_rounded,
                              iconColor: colors.statusSuccess,
                              title: 'Overtime (${activeMonth.overtimeHours}h)',
                              value: '+\$${activeMonth.overtimeAmount.toStringAsFixed(2)}',
                              valueColor: colors.statusSuccess,
                              colors: colors,
                            );

                            if (isMobile) {
                              return Column(
                                children: [
                                  deductionsCard,
                                  const SizedBox(height: 8),
                                  overtimeCard,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: deductionsCard),
                                const SizedBox(width: 10),
                                Expanded(child: overtimeCard),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 4. Department & Team Containers Section
                  Text(
                    'DEPARTMENT & TEAM CONTAINERS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...activeMonth.teams.map((t) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.primary.withAlpha(50)),
                            ),
                            child: Icon(Icons.corporate_fare_rounded, color: colors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.teamName,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: colors.statusDanger.withAlpha(20),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        '-\$${t.deductions.toInt()}',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: colors.statusDanger,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: colors.statusSuccess.withAlpha(20),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        '+\$${t.overtimeAmount.toInt()} OT',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: colors.statusSuccess,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '\$${t.totalNet.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textMain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NET PAYOUT',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textDim,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
