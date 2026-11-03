import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import '../../logic/attendance/attendance_cubit.dart';
import '../../logic/attendance/attendance_state.dart';
import '../widgets/status_chip.dart';
import '../../core/theme/app_colors_extension.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedMonth = DateTime(2026, DateTime.now().month);
  DateTime? _selectedDay;

  void _prevMonth() => setState(() {
    _selectedDay = null;
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
  });
  void _nextMonth() => setState(() {
    _selectedDay = null;
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
  });

  void _showDayDetailsSheet(BuildContext context, AttendanceRecordModel record) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (sheetCtx) {
        final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(record.date);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY ATTENDANCE BREAKDOWN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: context.colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: context.colors.textMain,
                        ),
                      ),
                    ],
                  ),
                  StatusChip(status: record.status),
                ],
              ),
              const SizedBox(height: 20),

              // Recorded Times Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.bgCanvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recorded Check-In',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.checkInTime ?? 'No Record',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: record.checkInTime != null
                                  ? context.colors.textMain
                                  : AppColors.absent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recorded Check-Out',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.checkOutTime ?? 'No Record',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: record.checkOutTime != null
                                  ? context.colors.textMain
                                  : context.colors.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Deduction Ladder Breakdown
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: record.deductionHours > 0
                      ? AppColors.lateLight
                      : AppColors.onTimeLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: record.deductionHours > 0
                        ? AppColors.late.withAlpha(50)
                        : AppColors.onTime.withAlpha(50),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      record.deductionHours > 0
                          ? Icons.access_time_filled
                          : Icons.check_circle,
                      color: record.deductionHours > 0
                          ? AppColors.late
                          : AppColors.onTime,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lateness Ladder Assessment',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: record.deductionHours > 0
                                  ? AppColors.late
                                  : AppColors.onTime,
                            ),
                          ),
                          Text(
                            record.deductionLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: record.deductionHours > 0
                                  ? AppColors.late
                                  : AppColors.onTime,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => Navigator.of(sheetCtx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Close Breakdown'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Attendance Ledger'),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: context.colors.primary),
            onPressed: _prevMonth,
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDay ?? _selectedMonth,
                firstDate: DateTime(2024),
                lastDate: DateTime(2027, 12),
                initialEntryMode: DatePickerEntryMode.calendarOnly,
              );
              if (picked != null) {
                setState(() {
                  _selectedDay = picked;
                  _selectedMonth = DateTime(picked.year, picked.month);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedDay != null ? context.colors.primary : context.colors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: _selectedDay != null ? Colors.white : context.colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedDay != null
                        ? DateFormat('dd MMM yyyy').format(_selectedDay!)
                        : DateFormat('MMM yyyy').format(_selectedMonth),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _selectedDay != null ? Colors.white : context.colors.primary,
                    ),
                  ),
                  if (_selectedDay != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedDay = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: context.colors.primary),
            onPressed: _nextMonth,
          ),
        ],
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<AttendanceRecordModel> allRecords =
              (state is AttendanceLoaded) ? state.historyList : [];
          // Filter records by selected single day or selected month
          final records = allRecords.where((r) {
            if (_selectedDay != null) {
              return r.date.year == _selectedDay!.year &&
                     r.date.month == _selectedDay!.month &&
                     r.date.day == _selectedDay!.day;
            }
            return r.date.year == _selectedMonth.year && r.date.month == _selectedMonth.month;
          }).toList();
          final MonthSummaryModel? summary =
              (state is AttendanceLoaded && records.isNotEmpty) ? state.monthSummary : null;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<AttendanceCubit>().loadAttendanceData();
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                // Active single-day filter notice banner
                if (_selectedDay != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.colors.primary.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, size: 16, color: context.colors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Showing Single Day: ${DateFormat('dd MMM yyyy').format(_selectedDay!)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.colors.primary),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => setState(() => _selectedDay = null),
                          icon: Icon(Icons.close, size: 14, color: context.colors.primary),
                          label: Text('Full Month', style: TextStyle(fontSize: 11, color: context.colors.primary, fontWeight: FontWeight.w700)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        ),
                      ],
                    ),
                  ),
                ],
                // Month Summary Card (Time Only - No Currency)
                if (summary != null) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.colors.bgCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.colors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'MONTH SUMMARY (TIME ONLY)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: context.colors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4 Stat Counters
                        Row(
                          children: [
                            _buildStatBox(
                              label: 'Present',
                              value: '${summary.presentDays}',
                              color: AppColors.onTime,
                            ),
                            const SizedBox(width: 8),
                            _buildStatBox(
                              label: 'Late Days',
                              value: '${summary.lateDays}',
                              color: AppColors.late,
                            ),
                            const SizedBox(width: 8),
                            _buildStatBox(
                              label: 'Absent',
                              value: '${summary.absentDays}',
                              color: AppColors.absent,
                            ),
                            const SizedBox(width: 8),
                            _buildStatBox(
                              label: 'Overtime',
                              value: '${summary.totalOvertimeHours}h',
                              color: AppColors.onLeave,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 5-Penalty Days Warning Risk Meter
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.bgCardSubtle,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Warning Risk Progress:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.colors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${summary.penaltyDaysCount} of ${summary.maxPenaltyThreshold} penalty days',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.late,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: summary.penaltyDaysCount /
                                      summary.maxPenaltyThreshold,
                                  minHeight: 6,
                                  backgroundColor: context.colors.borderSubtle,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.late,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Daily Ledger Header
                Text(
                  'DAILY ATTENDANCE LOG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // List of Days
                if (records.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No attendance records found for this period.',
                        style: TextStyle(color: context.colors.textMuted),
                      ),
                    ),
                  )
                else
                  ...records.map((rec) {
                    final dayNum = DateFormat('dd').format(rec.date);
                    final dayWeek = DateFormat('EEE').format(rec.date);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: context.colors.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.colors.borderSubtle),
                      ),
                      child: ListTile(
                        onTap: () => _showDayDetailsSheet(context, rec),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: rec.status == AttendanceStatus.onTime
                                ? AppColors.onTimeLight
                                : rec.status == AttendanceStatus.late
                                    ? AppColors.lateLight
                                    : AppColors.absentLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNum,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: rec.status == AttendanceStatus.onTime
                                      ? AppColors.onTime
                                      : rec.status == AttendanceStatus.late
                                          ? AppColors.late
                                          : AppColors.absent,
                                ),
                              ),
                              Text(
                                dayWeek.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: rec.status == AttendanceStatus.onTime
                                      ? AppColors.onTime
                                      : rec.status == AttendanceStatus.late
                                          ? AppColors.late
                                          : AppColors.absent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          rec.checkInTime != null
                              ? '${rec.checkInTime} – ${rec.checkOutTime ?? 'Active'}'
                              : 'No Clock-In Recorded',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textMain,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.deductionLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: rec.deductionHours > 0
                                    ? AppColors.late
                                    : (rec.deductionLabel.contains('Approved') ? AppColors.onTime : context.colors.textMuted),
                              ),
                            ),
                            if (rec.notes != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.verified, size: 12, color: AppColors.onTime),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      rec.notes!,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onTime),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: StatusChip(status: rec.status),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      );
    },
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.bgCardSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.borderSubtle),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

