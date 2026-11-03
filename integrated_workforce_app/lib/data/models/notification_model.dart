import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;
  final String type; // 'attendance', 'approval', 'warning', 'info'

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isUnread = true,
    this.type = 'info',
  });

  NotificationModel copyWith({bool? isUnread}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      timeAgo: timeAgo,
      isUnread: isUnread ?? this.isUnread,
      type: type,
    );
  }

  @override
  List<Object?> get props => [id, title, description, timeAgo, isUnread, type];
}
