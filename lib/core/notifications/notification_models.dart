enum AppNotificationType {
  bookingRequest,
  bookingConfirmed,
  bookingRejected,
  bookingCancelled,
}

class AppNotification {
  final String id;
  final String userId; // receiver
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}
