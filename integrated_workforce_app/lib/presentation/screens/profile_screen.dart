import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../logic/attendance/attendance_cubit.dart';
import '../../logic/attendance/attendance_state.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/theme/theme_cubit.dart';
import '../widgets/app_avatar.dart';
import 'complaints_screen.dart';
import '../../data/models/request_model.dart';
import '../../logic/requests/requests_cubit.dart';
import '../../core/theme/app_colors_extension.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasPendingProfileChange = false;
  bool _warningAcknowledged = false;

  void _openEditProfileModal() {
    final phoneCtrl = TextEditingController(text: widget.user.phone);
    final addressCtrl = TextEditingController(text: widget.user.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (modalCtx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile (Protected)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: context.colors.textMain,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(modalCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Safeguard Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: context.colors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Core work info is locked by HR. Changes to phone and address require Manager approval before applying.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Read-only fields
              _buildReadOnlyField('Full Name', widget.user.name),
              const SizedBox(height: 10),
              _buildReadOnlyField('Work Account Email', widget.user.email),
              const SizedBox(height: 10),
              _buildReadOnlyField('Department & Shift', '${widget.user.department} • ${widget.user.shiftName}'),
              const SizedBox(height: 10),

              // Editable Phone
              Text(
                'Phone Number (11 Digits)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_android, size: 18),
                ),
              ),
              const SizedBox(height: 14),

              // Editable Address
              Text(
                'Home Address',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.home_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  final newPhone = phoneCtrl.text.trim();
                  final newAddress = addressCtrl.text.trim();
                  if (newPhone.isEmpty && newAddress.isEmpty) {
                    Navigator.of(modalCtx).pop();
                    return;
                  }

                  final newReq = RequestModel(
                    id: 'req-${DateTime.now().millisecondsSinceEpoch}',
                    employeeId: widget.user.id,
                    employeeName: widget.user.name,
                    employeeRole: widget.user.jobTitle,
                    type: RequestType.profileUpdate,
                    status: RequestStatus.pending,
                    submissionDate: DateTime.now(),
                    targetDate: DateTime.now().toIso8601String().split('T').first,
                    reason: 'Phone: $newPhone, Address: $newAddress',
                    updatedPhone: newPhone,
                    updatedAddress: newAddress,
                    reviewerRole: 'Direct Manager / HR',
                    department: widget.user.department,
                  );

                  context.read<RequestsCubit>().submitRequest(newReq);
                  Navigator.of(modalCtx).pop();
                  setState(() {
                    _hasPendingProfileChange = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile update request sent to Leader and HR for approval!'),
                      backgroundColor: context.colors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Submit for Leader & HR Approval'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openChangePasswordModal() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.colors.textMain,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (errorMsg != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.absentLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(errorMsg!, style: const TextStyle(color: AppColors.absent, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  const Text('Current Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: currentCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Enter current password'),
                  ),
                  const SizedBox(height: 12),
                  const Text('New Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Min 8 characters'),
                  ),
                  const SizedBox(height: 12),
                  const Text('Confirm New Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Re-enter new password'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final current = currentCtrl.text.trim();
                      final newPw = newCtrl.text.trim();
                      final confirm = confirmCtrl.text.trim();

                      if (current.isEmpty) {
                        setModalState(() => errorMsg = 'Please enter your current password.');
                        return;
                      }
                      if (newPw.length < 8) {
                        setModalState(() => errorMsg = 'New password must be at least 8 characters.');
                        return;
                      }
                      if (newPw != confirm) {
                        setModalState(() => errorMsg = 'New password and confirmation do not match.');
                        return;
                      }
                      if (newPw == current) {
                        setModalState(() => errorMsg = 'New password must be different from current.');
                        return;
                      }

                      try {
                        await context.read<AuthCubit>().changePassword(
                          currentPassword: current,
                          newPassword: newPw,
                        );
                        if (modalCtx.mounted) Navigator.of(modalCtx).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                              backgroundColor: AppColors.onTime,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        setModalState(() => errorMsg = e.toString().replaceAll('Exception: ', ''));
                      }
                    },
                    child: const Text('Update Password'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openDeviceStatusModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (modalCtx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My Registered Phone Device',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.onTimeLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.onTime.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: AppColors.onTime, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active & Hardware Bound',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onTime,
                            ),
                          ),
                          Text(
                            'Device UUID: ${widget.user.registeredPhoneId ?? 'UUID-8FA1-90E2'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Attendance clock-in can only be recorded from this registered physical device to prevent proxy attendance.',
                style: TextStyle(fontSize: 12, color: context.colors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(modalCtx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWarningsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'My Official Warnings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lateLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.late.withAlpha(60)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.late,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'LEVEL 1 WARNING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              'Oct 16, 2026',
                              style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Issued by: ${widget.user.managerName}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reason: Repeated lateness without pre-approved excuse exceeding 4 days in October.',
                          style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _warningAcknowledged
                              ? null
                              : () {
                                  setSheetState(() => _warningAcknowledged = true);
                                  setState(() => _warningAcknowledged = true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Warning officially acknowledged.'),
                                      backgroundColor: AppColors.onTime,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.late,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_warningAcknowledged ? 'Acknowledged' : 'Acknowledge Warning'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    // Enforcement: Cannot logout while checked in
    final attendanceState = context.read<AttendanceCubit>().state;
    final isCurrentlyCheckedIn = (attendanceState is AttendanceLoaded) &&
        attendanceState.todayRecord.checkInTime != null &&
        attendanceState.todayRecord.checkOutTime == null;

    if (isCurrentlyCheckedIn) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: context.colors.bgCard,
          title: const Row(
            children: [
              Icon(Icons.block_rounded, color: AppColors.absent, size: 28),
              SizedBox(width: 8),
              Text(
                'Active Shift in Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Text(
            'You cannot sign out while your shift is currently active. Please check out first before logging out.',
            style: TextStyle(fontSize: 13, color: context.colors.textMuted),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Text(
          'Log Out Confirmation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Are you sure you want to log out? Your session token will be cleared and you will be returned to the Login screen.',
          style: TextStyle(fontSize: 13, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isDark ? AppColors.darkCardBorder : context.colors.borderSubtle;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  AppAvatar(
                    name: widget.user.name,
                    photoUrl: widget.user.photoUrl,
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkTextPrimary : context.colors.textMain,
                          ),
                        ),
                        Text(
                          '${widget.user.jobTitle} • ${widget.user.role.name.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : context.colors.bgCanvas,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Code: ${widget.user.code}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Pending Profile Change Alert Banner
            if (_hasPendingProfileChange)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lateLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.late.withAlpha(60)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_top, color: AppColors.late, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Profile update pending: Waiting for your manager to approve changes.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.late,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Feature Rows Menu (Like the Demo)
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // 1. Edit Profile & Contact
                  _buildMenuRow(
                    icon: Icons.person_outline,
                    iconColor: context.colors.primary,
                    iconBg: context.colors.primaryLight,
                    title: 'Edit Profile & Contact',
                    subtitle: 'Phone & address (manager approval required)',
                    onTap: _openEditProfileModal,
                  ),
                  Divider(height: 1, color: context.colors.borderSubtle),

                  // 2. Change Password
                  _buildMenuRow(
                    icon: Icons.lock_outline,
                    iconColor: Colors.purple,
                    iconBg: const Color(0xFFF3E8FF),
                    title: 'Change Password',
                    subtitle: 'Update workplace account password',
                    onTap: _openChangePasswordModal,
                  ),
                  Divider(height: 1, color: context.colors.borderSubtle),

                  // 3. My Phone / Registered Device
                  _buildMenuRow(
                    icon: Icons.phone_android,
                    iconColor: AppColors.onTime,
                    iconBg: AppColors.onTimeLight,
                    title: 'My Registered Phone',
                    subtitle: 'Active & Bound to hardware',
                    onTap: _openDeviceStatusModal,
                  ),
                  Divider(height: 1, color: context.colors.borderSubtle),

                  // 4. My Warnings
                  _buildMenuRow(
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.late,
                    iconBg: AppColors.lateLight,
                    title: 'My Warnings & Disciplinary',
                    subtitle: _warningAcknowledged ? 'All warnings acknowledged' : '1 Active Warning',
                    onTap: _openWarningsModal,
                  ),
                  Divider(height: 1, color: context.colors.borderSubtle),

                  // 5. Direct HR Complaints & About Workplace
                  _buildMenuRow(
                    icon: Icons.shield_outlined,
                    iconColor: context.colors.primary,
                    iconBg: context.colors.primaryLight,
                    title: 'Direct HR Complaints & About Us',
                    subtitle: 'Confidential whistleblower & enterprise standards',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSubtle),

                  // 6. Theme Toggle (Dark / Light Mode)
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      final isDark = themeMode == ThemeMode.dark;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: context.colors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: context.colors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Dark Appearance',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textMain,
                          ),
                        ),
                        subtitle: Text(
                          isDark ? 'Cyber Neon theme enabled' : 'Nordic Light theme enabled',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textMuted,
                          ),
                        ),
                        trailing: Switch(
                          value: isDark,
                          activeColor: context.colors.accent,
                          activeTrackColor: context.colors.primaryLight,
                          onChanged: (val) {
                            context.read<ThemeCubit>().toggleTheme(val);
                          },
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: context.colors.borderSubtle),

                  // 7. Log Out
                  _buildMenuRow(
                    icon: Icons.logout,
                    iconColor: AppColors.absent,
                    iconBg: AppColors.absentLight,
                    title: 'Log Out of Workplace',
                    subtitle: 'Clear session token and exit',
                    onTap: _showLogoutDialog,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (Read-Only)',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.colors.textDim),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.bgCanvas,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: isDestructive ? AppColors.absent : context.colors.textMain,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: context.colors.textMuted,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 18, color: context.colors.textDim),
    );
  }
}


