import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final INotificationsRepository notificationsRepository;

  NotificationsCubit({required this.notificationsRepository})
      : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final list = await notificationsRepository.getNotifications();
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await notificationsRepository.markAsRead(id);
      final list = await notificationsRepository.getNotifications();
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await notificationsRepository.markAllAsRead();
      final list = await notificationsRepository.getNotifications();
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> addNotification({
    required String title,
    required String description,
    required String type,
  }) async {
    try {
      final notif = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        timeAgo: 'Just now',
        isUnread: true,
        type: type,
      );
      await notificationsRepository.addNotification(notif);
      final list = await notificationsRepository.getNotifications();
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }
}
