import '../models/notification_model.dart';

abstract class INotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> addNotification(NotificationModel notification);
}
