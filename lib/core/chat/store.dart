import 'dart:math';
import 'chat_models.dart';

class ChatStore {
  ChatStore._();
  static final ChatStore instance = ChatStore._();

  final Map<String, ChatSession> _sessionsById = {};
  final Map<String, List<ChatMessage>> _messagesByChatId = {};

  // Demo therapist/patient pairing for MVP use
  // You can replace these later with real auth users.
  final String demoTherapistId = 'therapist_1';
  final String demoTherapistName = 'Therapist';
  final String demoPatientId = 'patient_1';
  final String demoPatientName = 'Patient';

  String _id(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
  }

  ChatSession getOrCreateSession({
    required String patientId,
    required String therapistId,
  }) {
    // Try find existing active session
    for (final s in _sessionsById.values) {
      if (s.patientId == patientId && s.therapistId == therapistId && s.isActive) {
        return s;
      }
    }

    final session = ChatSession(
      id: _id('chat'),
      patientId: patientId,
      therapistId: therapistId,
      startedAt: DateTime.now(),
    );
    _sessionsById[session.id] = session;
    _messagesByChatId.putIfAbsent(session.id, () => []);

    // Seed a welcome message
    _messagesByChatId[session.id]!.add(
      ChatMessage(
        id: _id('msg'),
        chatId: session.id,
        senderId: therapistId,
        content: 'Hello. I am here to support you. What would you like to talk about?',
        timestamp: DateTime.now(),
      ),
    );

    return session;
  }

  List<ChatSession> sessionsForUser(String userId) {
    return _sessionsById.values
        .where((s) => s.patientId == userId || s.therapistId == userId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  List<ChatMessage> messagesForChat(String chatId) {
    return List.unmodifiable(_messagesByChatId[chatId] ?? const []);
  }

  void sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) {
    if (content.trim().isEmpty) return;

    final msg = ChatMessage(
      id: _id('msg'),
      chatId: chatId,
      senderId: senderId,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    _messagesByChatId.putIfAbsent(chatId, () => []);
    _messagesByChatId[chatId]!.add(msg);
  }

  String lastMessagePreview(String chatId) {
    final list = _messagesByChatId[chatId];
    if (list == null || list.isEmpty) return '';
    return list.last.content;
  }

}
