import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import 'app_avatar.dart';
import 'status_chip.dart';
import '../../core/theme/app_colors_extension.dart';

class EmployeeAttendanceHistoryDialog extends StatefulWidget {
  final String employeeName;
  final String employeeCode;
  final String? photoUrl;
  final String role;
  final String department;
  final String branchName;
  final double branchRadius;

  const EmployeeAttendanceHistoryDialog({
    super.key,
    required this.employeeName,
    required this.employeeCode,
    this.photoUrl,
    required this.role,
    required this.department,
    required this.branchName,
    this.branchRadius = 50.0,
  });

  static void show(
    BuildContext context, {
    required String employeeName,
    required String employeeCode,
    String? photoUrl,
    required String role,
    required String department,
    required String branchName,
    double branchRadius = 50.0,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => EmployeeAttendanceHistoryDialog(
        employeeName: employeeName,
        employeeCode: employeeCode,
        photoUrl: photoUrl,
        role: role,
        department: department,
        branchName: branchName,
        branchRadius: branchRadius,
      ),
    );
  }

  @override
  State<EmployeeAttendanceHistoryDialog> createState() => _EmployeeAttendanceHistoryDialogState();
}

class _EmployeeAttendanceHistoryDialogState extends State<EmployeeAttendanceHistoryDialog> {
  DateTime _currentMonth = DateTime(2026, 10);
  DateTime? _selectedDate;
  String _activeFilter = 'all'; // 'all', 'late', 'absent', 'offline'
  late List<AttendanceRecordModel> _monthRecords;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2026, 10, 20); // Default to a recent day with rich telemetry
    _generateMonthRecords();
  }

  void _generateMonthRecords() {
    // Generate realistic historical records for the selected month
    final int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final List<AttendanceRecordModel> records = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final weekday = date.weekday; // 5 = Friday, 6 = Saturday (Egypt weekend)
      final isWeekend = weekday == DateTime.friday || weekday == DateTime.saturday;

      if (isWeekend) {
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.weekend,
        ));
      } else if (day == 6) {
        // Armed Forces Day (Egyptian Public Holiday)
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.weekend,
          notes: 'Armed Forces Day (Official Public Holiday)',
        ));
      } else if (day == 14) {
        // Approved sick leave
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.onLeave,
          notes: 'Pre-approved Sick Leave with medical excuse note',
        ));
      } else if (day == 8) {
        // Late arrival
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.late,
          checkInTime: '09:28 AM',
          checkOutTime: '05:02 PM',
          minutesLate: 28,
          deductionHours: 1.0,
          deductionLabel: '1.0 Hour (Tier 1)',
          latitude: 30.0732,
          longitude: 31.0184,
          biometricVerified: true,
          notes: 'Checked in 28m late • Hardware BSSID verified',
        ));
      } else if (day == 18) {
        // Another late arrival
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.late,
          checkInTime: '09:35 AM',
          checkOutTime: '05:15 PM',
          minutesLate: 35,
          deductionHours: 2.0,
          deductionLabel: '2.0 Hours (Tier 2)',
          latitude: 30.0732,
          longitude: 31.0184,
          biometricVerified: true,
          notes: 'Exceeded 30m grace limit • -2h ladder applied',
        ));
      } else if (day == 19) {
        // Unexcused absence
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.absent,
          deductionHours: 16.0,
          deductionLabel: '2.0 Days (Unexcused Absence)',
          notes: 'No check-in recorded • No leave requested',
        ));
      } else if (day == 20) {
        // Day with Signal Lost gap & reconnect auditing
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.onTime,
          checkInTime: '08:52 AM',
          checkOutTime: '05:00 PM',
          latitude: 30.0732,
          longitude: 31.0184,
          biometricVerified: true,
          notes: 'Signal Lost gap recorded: 11:42 AM - 12:15 PM (33 mins offline) • Check-in preserved after reconnect',
        ));
      } else if (day == 21) {
        // Day with manual HR checkin override
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.onTime,
          checkInTime: '09:05 AM',
          checkOutTime: '05:05 PM',
          latitude: 30.0732,
          longitude: 31.0184,
          biometricVerified: false,
          notes: 'Manual Check-In Override by HR (Yahia Hussien): Phone battery died at reception',
        ));
      } else {
        // Normal on-time day
        records.add(AttendanceRecordModel(
          id: 'rec-$day',
          date: date,
          status: AttendanceStatus.onTime,
          checkInTime: '08:50 AM',
          checkOutTime: '05:05 PM',
          latitude: 30.0732,
          longitude: 31.0184,
          biometricVerified: true,
          overtimeMinutes: (day % 3 == 0) ? 90 : 0,
          notes: 'Inside 50m geofence perimeter • Router BSSID verified',
        ));
      }
    }

    _monthRecords = records;
  }

  void _onMonthChanged(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _selectedDate = null;
      _generateMonthRecords();
    });
  }

  Future<void> _pickSpecificDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? _currentMonth,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2027, 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
              onPrimary: Colors.white,
              onSurface: context.colors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month);
        _selectedDate = picked;
        _generateMonthRecords();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.bgCard,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Header: Employee Info & Close Button ─────────────────
                  _buildHeader(context),

                  // ─── Body: Month Navigator & Search ───────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Month Selector & Date Search Bar
                          _buildMonthAndSearchBar(),
                          const SizedBox(height: 16),

                          // Month Metrics Summary Bar
                          _buildMonthMetricsSummary(),
                          const SizedBox(height: 16),

                          // Interactive Calendar Grid
                          _buildCalendarGrid(),
                          const SizedBox(height: 18),

                          // Selected Day Inspector Card
                          if (_selectedDate != null) ...[
                            _buildSelectedDayCard(),
                            const SizedBox(height: 18),
                          ],

                          // Filter Tabs for Full Month Log
                          _buildFilterTabs(),
                          const SizedBox(height: 12),

                          // Scrollable Full Records List
                          _buildRecordsList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        border: Border(bottom: BorderSide(color: context.colors.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppAvatar(
                name: widget.employeeName,
                photoUrl: widget.photoUrl,
                radius: 24,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.employeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.employeeCode,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.role} • ${widget.department} • ${widget.branchName}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthAndSearchBar() {
    final monthStr = DateFormat('MMMM yyyy').format(_currentMonth);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.bgCanvas,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month Switcher
          Row(
            children: [
              IconButton(
                onPressed: () => _onMonthChanged(-1),
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: context.colors.bgCard,
                  padding: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                monthStr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textMain,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => _onMonthChanged(1),
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: context.colors.bgCard,
                  padding: const EdgeInsets.all(6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          // Search Specific Day Button
          ElevatedButton.icon(
            onPressed: _pickSpecificDate,
            icon: const Icon(Icons.search_rounded, size: 16),
            label: const Text('Search Date'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthMetricsSummary() {
    int onTimeCount = 0;
    int lateCount = 0;
    int absentCount = 0;
    int leaveCount = 0;

    for (var r in _monthRecords) {
      if (r.status == AttendanceStatus.onTime) onTimeCount++;
      if (r.status == AttendanceStatus.late) lateCount++;
      if (r.status == AttendanceStatus.absent) absentCount++;
      if (r.status == AttendanceStatus.onLeave) leaveCount++;
    }

    return Row(
      children: [
        Expanded(child: _buildMetricPill('On-Time', '$onTimeCount days', AppColors.onTime, AppColors.onTimeLight)),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricPill('Late', '$lateCount days', AppColors.late, AppColors.lateLight)),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricPill('Absent', '$absentCount days', AppColors.absent, AppColors.absentLight)),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricPill('Leaves', '$leaveCount days', AppColors.onLeave, AppColors.onLeaveLight)),
      ],
    );
  }

  Widget _buildMetricPill(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    // In Dart DateTime: Monday is 1, Sunday is 7.
    // For our Sun-first header: Sun = 0, Mon = 1, ... Sat = 6.
    final firstDayOfWeek = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final int leadingEmptySlots = firstDayOfWeek % 7;
    final int totalSlots = leadingEmptySlots + _monthRecords.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        children: [
          // Day names header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek
                .map((d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 7-Column Responsive Month Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptySlots) {
                return const SizedBox();
              }

              final recordIndex = index - leadingEmptySlots;
              final r = _monthRecords[recordIndex];
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == r.date.year &&
                  _selectedDate!.month == r.date.month &&
                  _selectedDate!.day == r.date.day;

              Color dotColor;
              switch (r.status) {
                case AttendanceStatus.onTime:
                  dotColor = AppColors.onTime;
                  break;
                case AttendanceStatus.late:
                  dotColor = AppColors.late;
                  break;
                case AttendanceStatus.absent:
                  dotColor = AppColors.absent;
                  break;
                case AttendanceStatus.onLeave:
                  dotColor = AppColors.onLeave;
                  break;
                case AttendanceStatus.weekend:
                  dotColor = context.colors.borderSubtle;
                  break;
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = r.date;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.primary : context.colors.bgCanvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? context.colors.primary : context.colors.borderSubtle,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${r.date.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : context.colors.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayCard() {
    final record = _monthRecords.firstWhere(
      (r) =>
          r.date.year == _selectedDate!.year &&
          r.date.month == _selectedDate!.month &&
          r.date.day == _selectedDate!.day,
      orElse: () => AttendanceRecordModel(
        id: 'temp',
        date: _selectedDate!,
        status: AttendanceStatus.weekend,
      ),
    );

    final dateTitle = DateFormat('EEEE, MMMM d, yyyy').format(record.date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgCanvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.primary.withAlpha(80), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECTED DATE TELEMETRY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: context.colors.textMain,
                    ),
                  ),
                ],
              ),
              StatusChip(status: record.status),
            ],
          ),
          const SizedBox(height: 14),

          // Timestamps row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.login, size: 13, color: AppColors.onTime),
                          SizedBox(width: 4),
                          Text('Recorded Check-In', style: TextStyle(fontSize: 10, color: context.colors.textMuted, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.checkInTime ?? '--:--',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: context.colors.textMain),
                      ),
                      if (record.minutesLate > 0)
                        Text(
                          '${record.minutesLate}m late (${record.deductionLabel})',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.late),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.logout, size: 13, color: AppColors.absent),
                          SizedBox(width: 4),
                          Text('Recorded Check-Out', style: TextStyle(fontSize: 10, color: context.colors.textMuted, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.checkOutTime ?? '--:--',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: context.colors.textMain),
                      ),
                      Text(
                        record.checkOutTime != null ? 'Shift Completed' : 'No checkout logged',
                        style: TextStyle(fontSize: 10, color: context.colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMain),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('all', 'All Days (${_monthRecords.length})'),
          const SizedBox(width: 6),
          _buildFilterChip('late', 'Late Arrivals Only'),
          const SizedBox(width: 6),
          _buildFilterChip('absent', 'Absences Only'),
          const SizedBox(width: 6),
          _buildFilterChip('offline', 'Signal Lost / Offline Logs'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.textMain : context.colors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? context.colors.textMain : context.colors.borderSubtle),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : context.colors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    final filtered = _monthRecords.where((r) {
      if (_activeFilter == 'late') return r.status == AttendanceStatus.late;
      if (_activeFilter == 'absent') return r.status == AttendanceStatus.absent;
      if (_activeFilter == 'offline') return r.notes?.contains('Signal Lost') ?? false;
      return true;
    }).toList();

    return Column(
      children: filtered.map((r) {
        final dateStr = DateFormat('EEE, MMM d').format(r.date);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.bgCanvas,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${r.date.day}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: context.colors.textMain),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      Text(
                        r.checkInTime != null
                            ? '${r.checkInTime} → ${r.checkOutTime ?? "Pending"}'
                            : (r.status == AttendanceStatus.weekend ? 'Weekend' : 'No Clock In'),
                        style: TextStyle(fontSize: 10.5, color: context.colors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              StatusChip(status: r.status),
            ],
          ),
        );
      }).toList(),
    );
  }
}


