import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/team_member_model.dart';
import '../../logic/team/team_cubit.dart';
import '../../logic/team/team_state.dart';
import '../widgets/app_avatar.dart';
import '../widgets/employee_attendance_history_dialog.dart';
import '../widgets/status_chip.dart';
import '../../core/theme/app_colors_extension.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  void _showMemberTimelineSheet(BuildContext context, TeamMemberModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: member.name,
                        photoUrl: member.photoUrl,
                        radius: 20,
                        status: member.status,
                        showStatusDot: true,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: context.colors.textMain,
                            ),
                          ),
                          Text(
                            '${member.role} • ${member.code}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  StatusChip(status: member.status),
                ],
              ),
              const SizedBox(height: 16),

              // Issue Summary Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: member.issuesCount > 0 ? AppColors.absentLight : AppColors.onTimeLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: member.issuesCount > 0
                        ? AppColors.absent.withAlpha(50)
                        : AppColors.onTime.withAlpha(50),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      member.issuesCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: member.issuesCount > 0 ? AppColors.absent : AppColors.onTime,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Flagged Issues Today: ${member.issueLabel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: member.issuesCount > 0 ? AppColors.absent : AppColors.onTime,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Button to open Full History & Date Search
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  EmployeeAttendanceHistoryDialog.show(
                    context,
                    employeeName: member.name,
                    employeeCode: member.code,
                    photoUrl: member.photoUrl,
                    role: member.role,
                    department: 'Technology & Engineering',
                    branchName: 'Main HQ Branch (50m Geofence)',
                  );
                },
                icon: const Icon(Icons.history_rounded, size: 16),
                label: const Text('View Full Attendance History & Search Dates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'CHRONOLOGICAL 15-MINUTE PRESENCE LOG',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: 10),

              // Chronological list of 15-minute intervals
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: member.intervals.length,
                  itemBuilder: (ctx, idx) {
                    final iv = member.intervals[idx];

                    Color bg;
                    Color text;
                    IconData icon;
                    if (iv.status == 'inside') {
                      bg = AppColors.onTimeLight;
                      text = AppColors.onTime;
                      icon = Icons.location_on;
                    } else if (iv.status == 'outside') {
                      bg = AppColors.absentLight;
                      text = AppColors.absent;
                      icon = Icons.location_off;
                    } else if (iv.status == 'signal_lost') {
                      bg = AppColors.lateLight;
                      text = AppColors.late;
                      icon = Icons.phonelink_erase_rounded;
                    } else {
                      bg = context.colors.bgCanvas;
                      text = context.colors.textDim;
                      icon = Icons.schedule;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: text.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: text, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  iv.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: text,
                                  ),
                                ),
                                Text(
                                  iv.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.textMain,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.colors.bgCard,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              iv.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Bonus & Discretionary Deductions Summary
              if (member.bonus > 0 || member.discretionaryDeductions > 0 || member.isSuspended) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.bgCanvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.colors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      if (member.isSuspended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.absent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ACCOUNT SUSPENDED',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        )
                      else ...[
                        if (member.bonus > 0)
                          Text(
                            'Bonus: +${member.bonus.toInt()} EGP  ',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onTime),
                          ),
                        if (member.discretionaryDeductions > 0)
                          Text(
                            'Deductions: -${member.discretionaryDeductions.toInt()} EGP',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.absent),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Manager Actions Column
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  _showManualCheckInDialog(context, member);
                },
                icon: const Icon(Icons.fingerprint, size: 18, color: AppColors.onTime),
                label: Text('Log Manual Check-In (Override)', style: TextStyle(color: AppColors.onTime, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.onTime),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  _showAwardBonusOrDeductionDialog(context, member);
                },
                icon: const Icon(Icons.card_giftcard, size: 18),
                label: const Text('Award Bonus / Disciplinary Deduction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        _showWriteWarningDialog(context, member);
                      },
                      icon: const Icon(Icons.edit_note, size: 18, color: AppColors.late),
                      label: Text('Issue Warning', style: TextStyle(color: AppColors.late, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.late),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        if (member.isSuspended) {
                          _showReactivateMemberDialog(context, member);
                        } else {
                          _showDeactivateMemberDialog(context, member);
                        }
                      },
                      icon: Icon(
                        member.isSuspended ? Icons.lock_open_rounded : Icons.block,
                        size: 18,
                        color: member.isSuspended ? AppColors.onTime : AppColors.absent,
                      ),
                      label: Text(
                        member.isSuspended ? 'Reopen Account' : 'Close Account',
                        style: TextStyle(
                          color: member.isSuspended ? AppColors.onTime : AppColors.absent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: member.isSuspended ? AppColors.onTime : AppColors.absent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  _showRemoveMemberDialog(context, member);
                },
                icon: const Icon(Icons.delete_forever, size: 18, color: AppColors.absent),
                label: Text('Remove Account Permanently', style: TextStyle(color: AppColors.absent, fontSize: 12, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.absent.withAlpha(80)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAwardBonusOrDeductionDialog(BuildContext context, TeamMemberModel member) {
    bool isBonus = true;
    final amountCtrl = TextEditingController(text: '150');
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: context.colors.bgCard,
          title: Text(
            'Adjust for ${member.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Award Bonus (+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                      selected: isBonus,
                      selectedColor: AppColors.onTime,
                      labelStyle: TextStyle(color: isBonus ? Colors.white : context.colors.textMain),
                      onSelected: (val) => setDialogState(() => isBonus = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Deduction (-)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                      selected: !isBonus,
                      selectedColor: AppColors.absent,
                      labelStyle: TextStyle(color: !isBonus ? Colors.white : context.colors.textMain),
                      onSelected: (val) => setDialogState(() => isBonus = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Amount (EGP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'EGP '),
              ),
              const SizedBox(height: 12),
              const Text('Official Reason / Message for Employee', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: isBonus
                      ? 'e.g. Exceptional weekend overtime delivery...'
                      : 'e.g. Disciplinary breach of branch conduct...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                final reason = reasonCtrl.text.trim();
                if (amount > 0 && reason.isNotEmpty) {
                  context.read<TeamCubit>().awardBonusOrDeduction(
                        employeeId: member.id,
                        amount: amount,
                        isBonus: isBonus,
                        reason: reason,
                      );
                  Navigator.pop(dialogCtx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBonus ? AppColors.onTime : AppColors.absent,
                foregroundColor: Colors.white,
              ),
              child: Text(isBonus ? 'Award Bonus' : 'Apply Deduction'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateMemberDialog(BuildContext context, TeamMemberModel member) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.absent, size: 28),
            SizedBox(width: 8),
            Text('Close Account?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Are you sure you want to deactivate ${member.name}\'s account? The employee will be suspended from clocking in or accessing workplace resources.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeamCubit>().deactivateMember(member.id);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate Account'),
          ),
        ],
      ),
    );
  }

  void _showReactivateMemberDialog(BuildContext context, TeamMemberModel member) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: AppColors.onTime, size: 28),
            SizedBox(width: 8),
            Text('Reopen Account?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Do you want to reopen and restore full access for ${member.name}? The employee will be active again.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeamCubit>().reactivateMember(member.id);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onTime,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reopen & Activate'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, TeamMemberModel member) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.absent, size: 28),
            SizedBox(width: 8),
            Text('Remove Account?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently remove ${member.name} (${member.code})? This will delete the account from your department team.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeamCubit>().removeMember(member.id);
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permanently Remove'),
          ),
        ],
      ),
    );
  }

  void _showManualCheckInDialog(BuildContext context, TeamMemberModel member) {
    final reasonCtrl = TextEditingController(text: 'Device battery died / hardware issue reported');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Row(
          children: [
            Icon(Icons.edit_calendar_rounded, color: context.colors.primary, size: 26),
            SizedBox(width: 8),
            Text('Manual Check-In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manually clock in ${member.name}. This is logged under manager credentials for full audit accountability.',
              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason for Override',
                hintText: 'e.g. Phone battery died / damaged screen...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<TeamCubit>().manualCheckIn(
                    employeeId: member.id,
                    managerName: 'Manager Mohamed Adel',
                    reason: reasonCtrl.text.trim().isNotEmpty
                        ? reasonCtrl.text.trim()
                        : 'Phone battery died',
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Manual Check-In'),
          ),
        ],
      ),
    );
  }

  void _showAddTeamMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Junior Developer');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: const Text('Add Employee to My Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: context.colors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Onboarding note: Only Admin can assign the salary in EGP. This request routes to Admin for approval.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Full Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Mahmoud Hassan')),
              const SizedBox(height: 12),
              const Text('Job Role / Title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: roleCtrl, decoration: const InputDecoration(hintText: 'e.g. Flutter Engineer')),
              const SizedBox(height: 12),
              const Text('Workplace Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: 'e.g. mahmoud@company.com')),
              const SizedBox(height: 12),
              const Text('Phone Number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(hintText: 'e.g. 01011223344')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                final newMember = TeamMemberModel(
                  id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  role: roleCtrl.text.trim(),
                  code: 'EMP-${(1000 + DateTime.now().millisecond)}',
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  status: AttendanceStatus.onTime,
                  statusText: 'Pending Admin Approval',
                  issuesCount: 0,
                  issueLabel: 'All Good',
                  intervals: const [],
                  isPendingAdminApproval: true,
                );
                context.read<TeamCubit>().addMember(newMember);
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('Submit to Admin'),
          ),
        ],
      ),
    );
  }

  void _showWriteWarningDialog(BuildContext context, TeamMemberModel member) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Text(
          'Issue Warning to ${member.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specify official disciplinary reason for repeated lateness or absence without pre-approval:',
              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reason for this official warning...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.trim().isNotEmpty) {
                context.read<TeamCubit>().issueWarning(
                      employeeId: member.id,
                      reason: reasonCtrl.text.trim(),
                      level: 1,
                    );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Warning issued to ${member.name}'),
                    backgroundColor: AppColors.late,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.late,
              foregroundColor: Colors.white,
            ),
            child: const Text('Issue Warning'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Team Presence Radar'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded, color: context.colors.primary),
            tooltip: 'Add Employee to Team',
            onPressed: () => _showAddTeamMemberDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TeamCubit>().loadTeam(),
          ),
        ],
      ),
      body: BlocConsumer<TeamCubit, TeamState>(
        listener: (context, state) {
          if (state is TeamLoaded && state.message != null) {
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
          if (state is TeamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<TeamMemberModel> members = (state is TeamLoaded) ? state.members : [];
          final loaded = state is TeamLoaded ? state : null;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Top Counters
                  Row(
                children: [
                  _buildCounterCard(
                    title: 'On Time',
                    count: loaded?.presentCount ?? 5,
                    color: AppColors.onTime,
                    bg: AppColors.onTimeLight,
                  ),
                  const SizedBox(width: 8),
                  _buildCounterCard(
                    title: 'Late',
                    count: loaded?.lateCount ?? 2,
                    color: AppColors.late,
                    bg: AppColors.lateLight,
                  ),
                  const SizedBox(width: 8),
                  _buildCounterCard(
                    title: 'Absent',
                    count: loaded?.absentCount ?? 1,
                    color: AppColors.absent,
                    bg: AppColors.absentLight,
                  ),
                  const SizedBox(width: 8),
                  _buildCounterCard(
                    title: 'Leave',
                    count: loaded?.onLeaveCount ?? 0,
                    color: AppColors.onLeave,
                    bg: AppColors.onLeaveLight,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TEAM MEMBERS (TAP TO INSPECT 15-MIN LOG)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: context.colors.textMuted,
                    ),
                  ),
                  Text(
                    '${members.length} Staff',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile cards stacked under each other
              ...members.map((member) {
                return GestureDetector(
                  onTap: () => _showMemberTimelineSheet(context, member),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: member.issuesCount > 0
                            ? AppColors.late.withAlpha(120)
                            : context.colors.borderSubtle,
                        width: member.issuesCount > 0 ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(member.issuesCount > 0 ? 12 : 5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar with Attention / Issue Counter Badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AppAvatar(
                              name: member.name,
                              photoUrl: member.photoUrl,
                              radius: 24,
                              status: member.status,
                              showStatusDot: true,
                            ),
                            if (member.issuesCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.absent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: context.colors.bgCard, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.absent.withAlpha(80),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${member.issuesCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.textMain,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${member.role} • ${member.statusText}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: member.status == AttendanceStatus.late
                                      ? AppColors.late
                                      : member.status == AttendanceStatus.absent
                                          ? AppColors.absent
                                          : context.colors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Issue Label or Status Chip
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (member.issuesCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.lateLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${member.issuesCount} Issues',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.late,
                                  ),
                                ),
                              )
                            else
                              StatusChip(status: member.status),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  icon: Icon(Icons.calendar_month_rounded, color: context.colors.primary, size: 18),
                                  tooltip: 'Full Attendance History & Search Dates',
                                  onPressed: () {
                                    EmployeeAttendanceHistoryDialog.show(
                                      context,
                                      employeeName: member.name,
                                      employeeCode: member.code,
                                      photoUrl: member.photoUrl,
                                      role: member.role,
                                      department: 'Mobile Engineering Team',
                                      branchName: 'Main HQ Branch',
                                      branchRadius: 50.0,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Timeline',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.primary,
                                  ),
                                ),
                                Icon(Icons.chevron_right, size: 14, color: context.colors.primary),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget _buildCounterCard({
    required String title,
    required int count,
    required Color color,
    required Color bg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



