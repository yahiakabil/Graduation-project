import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/user_model.dart';
import '../../logic/attendance/attendance_cubit.dart';
import '../../logic/attendance/attendance_state.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/notifications/notifications_state.dart';
import '../widgets/app_avatar.dart';
import '../widgets/biometric_gps_dialog.dart';
import '../widgets/status_chip.dart';
import 'alerts_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  void _openCheckInDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BiometricGpsDialog(
        branchRadius: user.branchRadiusMeters,
        userPhotoUrl: user.photoUrl,
        userName: user.name,
        userCode: user.code,
        onConfirmCheckIn: ({
          required double latitude,
          required double longitude,
          required bool biometricVerified,
          required bool isMockLocation,
        }) {
          context.read<AttendanceCubit>().checkIn(
                latitude: latitude,
                longitude: longitude,
                biometricVerified: biometricVerified,
                isMockLocation: isMockLocation,
              );
        },
      ),
    );
  }

  void _showCheckOutConfirmation(BuildContext context) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors.bgCard,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.absentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: AppColors.absent, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'End Workday?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: colors.textMain,
              ),
            ),
          ],
        ),
        content: Text(
          'Confirm clocking out for today? Attendance logs will be sealed for payroll audit.',
          style: TextStyle(fontSize: 13, color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textDim)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AttendanceCubit>().checkOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clock Out'),
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
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.onTime,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.absent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final AttendanceRecordModel record = (state is AttendanceLoaded)
              ? state.todayRecord
              : AttendanceRecordModel(
                  id: 'default',
                  date: DateTime.now(),
                  status: AttendanceStatus.onTime,
                );

          final bool isCheckedIn = record.checkInTime != null;
          final bool isCheckedOut = record.checkOutTime != null;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<AttendanceCubit>().loadAttendanceData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar (Profile Greeting + Alert Bell)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppAvatar(
                              name: user.name,
                              photoUrl: user.photoUrl,
                              radius: 22,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user.name}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${user.jobTitle} • ${user.code}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        BlocBuilder<NotificationsCubit, NotificationsState>(
                          builder: (context, notifState) {
                            final unreadCount = notifState is NotificationsLoaded
                                ? notifState.unreadCount
                                : 0;
                            return GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AlertsScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.bgCard,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.borderSubtle),
                                ),
                                child: Badge.count(
                                  count: unreadCount,
                                  isLabelVisible: unreadCount > 0,
                                  backgroundColor: colors.statusDanger,
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    size: 22,
                                    color: colors.textMain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Shift & Branch Geofence Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, const Color(0xFF1E1B4B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withAlpha(50),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
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
                                  const Text(
                                    'TODAY\'S ASSIGNED SHIFT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.shiftName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    user.shiftHours,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              StatusChip(status: record.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.onTime,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${user.branchName} (Geofence: ${user.branchRadiusMeters.toInt()}m)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Inside GPS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.onTime,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Active Shift Location Guard Enforcement
                    if (isCheckedIn && !isCheckedOut) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.onTime.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.security, color: AppColors.onTime, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ACTIVE SHIFT: LOCATION GUARD ENFORCED',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: AppColors.onTime,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Device GPS must remain ON. Disabling location services sends an immediate unauthorized absence alert to manager.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Big Biometric Action Button Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: colors.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            isCheckedOut
                                ? 'Shift Completed for Today'
                                : isCheckedIn
                                    ? 'You are currently Clocked In'
                                    : 'Touch to Clock-In (GPS & Biometrics)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Large Round Button
                          GestureDetector(
                            onTap: isCheckedOut
                                ? null
                                : () {
                                    if (!isCheckedIn) {
                                      _openCheckInDialog(context);
                                    } else {
                                      _showCheckOutConfirmation(context);
                                    }
                                  },
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isCheckedOut
                                      ? [AppColors.weekend, AppColors.weekend]
                                      : isCheckedIn
                                          ? [AppColors.absent, const Color(0xFFBE123C)]
                                          : [AppColors.onTime, const Color(0xFF047857)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isCheckedOut
                                        ? Colors.black12
                                        : isCheckedIn
                                            ? AppColors.absent.withAlpha(90)
                                            : AppColors.onTime.withAlpha(90),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isCheckedIn ? Icons.logout : Icons.fingerprint,
                                      size: 42,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isCheckedOut
                                          ? 'COMPLETED'
                                          : isCheckedIn
                                              ? 'CHECK OUT'
                                              : 'CHECK IN',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      isCheckedIn ? 'Tap to confirm' : '50m GPS Verified',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Hardware Verification Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMiniIndicator(
                                context: context,
                                icon: Icons.phone_android,
                                label: 'Registered Phone',
                                isOk: true,
                              ),
                              const SizedBox(width: 16),
                              _buildMiniIndicator(
                                context: context,
                                icon: Icons.gps_fixed,
                                label: 'No Fake GPS',
                                isOk: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Container with Check-in and Check-out Times
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'TODAY\'S ATTENDANCE TIMESTAMPS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: colors.textDim,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Check-In Column
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.bgCardSubtle,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colors.borderSubtle.withAlpha(60)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.login,
                                            size: 14,
                                            color: AppColors.onTime,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Recorded Check-In',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: colors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        record.checkInTime ?? '--:--',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: isCheckedIn
                                              ? colors.textMain
                                              : colors.textDim,
                                        ),
                                      ),
                                      if (record.minutesLate > 0)
                                        Text(
                                          '${record.minutesLate}m late (-1h ladder)',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.late,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Check-Out Column
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.bgCardSubtle,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colors.borderSubtle.withAlpha(60)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.logout,
                                            size: 14,
                                            color: AppColors.absent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Recorded Check-Out',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: colors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        record.checkOutTime ?? '--:--',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: isCheckedOut
                                              ? colors.textMain
                                              : colors.textDim,
                                        ),
                                      ),
                                      Text(
                                        isCheckedOut
                                            ? 'Shift Ended'
                                            : 'Shift ends at 05:00 PM',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colors.textDim,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Active Deduction Ladder Note
                          if (record.deductionHours > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lateLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.late.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.late,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Lateness Ladder: ${record.deductionLabel}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.late,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniIndicator({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isOk,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOk ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: isOk ? AppColors.onTime : AppColors.absent,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
