import 'dart:math';
import 'notification_models.dart';

class NotificationStore {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  final List<AppNotification> _items = [];

  List<AppNotification> forUser(String userId) {
    final list = _items.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int unreadCount(String userId) {
    return _items.where((n) => n.userId == userId && !n.isRead).length;
  }

  void markAllRead(String userId) {
    for (final n in _items.where((x) => x.userId == userId)) {
      n.isRead = true;
    }
  }

  void push({
    required String userId,
    required AppNotificationType type,
    required String title,
    required String message,
  }) {
    _items.insert(
      0,
      AppNotification(
        id: _id("ntf"),
        userId: userId,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
  }

  String _id(String prefix) =>
      "${prefix}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}";
}
