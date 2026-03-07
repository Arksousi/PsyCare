import 'package:flutter/material.dart';

import '../../../core/chat/chat_models.dart';
import '../../../core/chat/store.dart';
import '../../../core/theme/app_colors.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;

  const ChatListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatStore _store = ChatStore.instance;

  void _openChat(BuildContext context, String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          currentUserId: widget.currentUserId,
          otherUserName: widget.otherUserName,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _newChat(BuildContext context) {
    final bool currentIsTherapist =
        widget.currentUserId == _store.demoTherapistId;

    final session = _store.getOrCreateSession(
      patientId: currentIsTherapist ? widget.otherUserId : widget.currentUserId,
      therapistId:
      currentIsTherapist ? widget.currentUserId : widget.otherUserId,
    );

    _openChat(context, session.id);
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _store.sessionsForUser(widget.currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),

      // ✅ Force teal FAB (no random defaults)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        onPressed: () => _newChat(context),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('New chat'),
      ),

      body: sessions.isEmpty
          ? const _EmptyChats()
          : ListView.separated(
        itemCount: sessions.length,
        separatorBuilder: (_, __) =>
        const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, i) {
          final ChatSession s = sessions[i];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryTeal.withOpacity(0.12),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryTeal,
              ),
            ),
            title: Text(
              widget.otherUserName,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              _store.lastMessagePreview(s.id),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () => _openChat(context, s.id),
          );
        },
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 44, color: AppColors.primaryTeal),
            SizedBox(height: 10),
            Text(
              "No chats yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap "New chat" to start.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
