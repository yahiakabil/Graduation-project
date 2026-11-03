import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import '../../core/theme/app_colors_extension.dart';

class StatusChip extends StatelessWidget {
  final AttendanceStatus status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case AttendanceStatus.onTime:
        bg = AppColors.onTimeLight;
        text = AppColors.onTime;
        label = 'On Time';
        icon = Icons.check_circle_outline;
        break;
      case AttendanceStatus.late:
        bg = AppColors.lateLight;
        text = AppColors.late;
        label = 'Late';
        icon = Icons.access_time;
        break;
      case AttendanceStatus.absent:
        bg = AppColors.absentLight;
        text = AppColors.absent;
        label = 'Absent';
        icon = Icons.highlight_off;
        break;
      case AttendanceStatus.onLeave:
        bg = AppColors.onLeaveLight;
        text = AppColors.onLeave;
        label = 'On Leave';
        icon = Icons.flight_takeoff;
        break;
      case AttendanceStatus.weekend:
        bg = AppColors.weekendLight;
        text = AppColors.weekend;
        label = 'Off / Weekend';
        icon = Icons.calendar_today;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            customLabel ?? label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

