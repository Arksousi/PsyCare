class ChatSession {
  final String id;
  final String patientId;
  final String therapistId;
  final DateTime startedAt;
  bool isActive;

  ChatSession({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.startedAt,
    this.isActive = true,
  });
}

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}
