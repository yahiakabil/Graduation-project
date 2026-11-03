import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../logic/notifications/notifications_state.dart';
import '../../core/theme/app_colors_extension.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Mark all read',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: context.colors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<NotificationModel> list = (state is NotificationsLoaded)
              ? state.notifications
              : [];

          if (list.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: context.colors.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];

              IconData icon;
              Color iconColor;
              switch (item.type) {
                case 'attendance':
                  icon = Icons.access_time_filled;
                  iconColor = AppColors.late;
                  break;
                case 'approval':
                  icon = Icons.check_circle;
                  iconColor = AppColors.onTime;
                  break;
                case 'warning':
                  icon = Icons.warning_rounded;
                  iconColor = AppColors.absent;
                  break;
                default:
                  icon = Icons.notifications;
                  iconColor = context.colors.primary;
              }

              return GestureDetector(
                onTap: () {
                  context.read<NotificationsCubit>().markAsRead(item.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item.isUnread ? context.colors.primaryLight : context.colors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.isUnread
                          ? context.colors.primary.withAlpha(60)
                          : context.colors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.colors.bgCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.borderSubtle),
                        ),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: item.isUnread
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      color: context.colors.textMain,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.timeAgo,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.colors.textDim,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: item.isUnread
                                    ? context.colors.textMain
                                    : context.colors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

