import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/request_model.dart';
import '../../data/models/user_model.dart';
import '../../logic/requests/requests_cubit.dart';
import '../../logic/requests/requests_state.dart';
import '../widgets/app_avatar.dart';
import 'alerts_screen.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/notifications/notifications_state.dart';
import '../../core/theme/app_colors_extension.dart';

class ApprovalsScreen extends StatelessWidget {
  final UserModel? user;

  const ApprovalsScreen({super.key, this.user});

  void _showDecisionDialog(BuildContext context, RequestModel req, bool isApprove) {
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle : Icons.cancel,
              color: isApprove ? AppColors.onTime : AppColors.absent,
            ),
            const SizedBox(width: 8),
            Text(
              isApprove ? 'Approve Request' : 'Reject Request',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm ${isApprove ? 'approving' : 'rejecting'} ${req.typeLabel} for ${req.employeeName}:',
              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Optional manager comment (e.g. Approved)...'
                    : 'Reason for rejection (e.g. Needs prior notice)...',
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
              Navigator.of(dialogCtx).pop();
              if (isApprove) {
                context.read<RequestsCubit>().approveRequest(
                      req.id,
                      comment: commentCtrl.text.trim().isNotEmpty
                          ? commentCtrl.text.trim()
                          : 'Approved by Manager.',
                    );
              } else {
                context.read<RequestsCubit>().rejectRequest(
                      req.id,
                      comment: commentCtrl.text.trim().isNotEmpty
                          ? commentCtrl.text.trim()
                          : 'Rejected by Manager.',
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.onTime : AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Approvals Queue'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, notifState) {
              final count = notifState is NotificationsLoaded ? notifState.unreadCount : 0;
              return IconButton(
                icon: Badge.count(
                  count: count,
                  isLabelVisible: count > 0,
                  backgroundColor: AppColors.absent,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                tooltip: 'Notifications & Alerts',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertsScreen()),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<RequestsCubit, RequestsState>(
        builder: (context, state) {
          if (state is RequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<RequestModel> allPending =
              (state is RequestsLoaded) ? state.pendingApprovals : [];
          final List<RequestModel> pending = user?.role == UserRole.manager
              ? allPending.where((r) => r.department == user!.department || r.reviewerRole.contains(user!.name)).toList()
              : allPending;

          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 48, color: AppColors.onTime),
                  SizedBox(height: 12),
                  Text(
                    'No pending requests to review.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: pending.length,
                itemBuilder: (context, index) {
              final req = pending[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.colors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Member & Request Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppAvatar(
                              name: req.employeeName,
                              radius: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.employeeName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: context.colors.textMain,
                                  ),
                                ),
                                Text(
                                  req.employeeRole,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lateLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            req.typeLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.late,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Verification Data Box (Compares Requested vs Actual Server Check-in)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.bgCanvas,
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
                                'Requested Details:',
                                style: TextStyle(fontSize: 11, color: context.colors.textMuted, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${req.targetDate} ${req.minutes != null ? '(${req.minutes} mins)' : ''}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                              ),
                            ],
                          ),
                          if (req.actualCheckInTime != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Actual Server Clock-In:',
                                  style: TextStyle(fontSize: 11, color: context.colors.textMuted, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  req.actualCheckInTime!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.late),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Reason: "${req.reason}"',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Decision Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showDecisionDialog(context, req, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.absent,
                              side: BorderSide(color: AppColors.absentLight),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showDecisionDialog(context, req, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.onTime,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
      ),
    );
  }
}


