import '../models/notification_model.dart';
import '../repositories/notifications_repository.dart';

class FakeNotificationsRepository implements INotificationsRepository {
  final List<NotificationModel> _notifications = [
    const NotificationModel(
      id: 'notif-1',
      title: 'Clock-In Recorded (Lateness Alert)',
      description: 'Clocked in at 09:28 AM (28 min late). Deducted: 1.0 hr via Lateness Ladder.',
      timeAgo: '15m ago',
      isUnread: true,
      type: 'attendance',
    ),
    const NotificationModel(
      id: 'notif-2',
      title: 'Leave Request Approved',
      description: 'Manager Eng. Tarek approved your Annual Leave request for Oct 10–12.',
      timeAgo: '1d ago',
      isUnread: true,
      type: 'approval',
    ),
    const NotificationModel(
      id: 'notif-3',
      title: 'Official Attendance Warning Issued',
      description: 'You have received a Level 1 attendance warning for exceeding 4 late days in October.',
      timeAgo: '2d ago',
      isUnread: false,
      type: 'warning',
    ),
    const NotificationModel(
      id: 'notif-4',
      title: 'Shift Schedule Reminder',
      description: 'Morning Core Shift starts at 09:00 AM at Main HQ Branch (50m Geofence).',
      timeAgo: '3d ago',
      isUnread: false,
      type: 'info',
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isUnread: false);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isUnread: false);
    }
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
  }
}
