import '../api/api_client.dart';
import '../models/notification_model.dart';
import '../repositories/notifications_repository.dart';

class ApiNotificationsRepository implements INotificationsRepository {
  List<NotificationModel> _cached = [];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await ApiClient.get('/notifications');
      if (res is List) {
        final list = res.map((n) {
          final id = (n['id'] ?? 0).toString();
          final title = n['title']?.toString() ?? 'Notification';
          final body = n['body']?.toString() ?? '';
          final isRead = n['isRead'] as bool? ?? false;
          final type = n['type']?.toString().toLowerCase() ?? 'info';
          final createdAt = DateTime.tryParse(n['createdAt']?.toString() ?? '');
          String timeAgo = 'Just now';
          if (createdAt != null) {
            final diff = DateTime.now().difference(createdAt);
            if (diff.inMinutes < 60) {
              timeAgo = '${diff.inMinutes}m ago';
            } else if (diff.inHours < 24) {
              timeAgo = '${diff.inHours}h ago';
            } else {
              timeAgo = '${diff.inDays}d ago';
            }
          }
          return NotificationModel(
            id: id,
            title: title,
            description: body,
            timeAgo: timeAgo,
            isUnread: !isRead,
            type: type,
          );
        }).toList();
        _cached = list;
        return list;
      }
      return _cached;
    } catch (_) {
      return _cached;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      try {
        await ApiClient.put('/notifications/$intId/read');
      } catch (_) {}
    }
    final index = _cached.indexWhere((n) => n.id == id);
    if (index != -1) {
      _cached[index] = _cached[index].copyWith(isUnread: false);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await ApiClient.put('/notifications/read-all');
    } catch (_) {}
    _cached = _cached.map((n) => n.copyWith(isUnread: false)).toList();
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    _cached.insert(0, notification);
  }
}
