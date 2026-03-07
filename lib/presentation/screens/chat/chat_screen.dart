import 'package:flutter/material.dart';

import '../../../core/chat/chat_models.dart';
import '../../../core/chat/store.dart';
import '../../../core/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatStore _store = ChatStore.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    // Auto-scroll to bottom when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(jump: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scroll.hasClients) return;
    final offset = _scroll.position.maxScrollExtent;

    if (jump) {
      _scroll.jumpTo(offset);
    } else {
      _scroll.animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    _store.sendMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      content: text,
    );

    setState(() {});
    Future.delayed(const Duration(milliseconds: 40), () => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final messages = _store.messagesForChat(widget.chatId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final ChatMessage m = messages[i];
                final bool isMe = m.senderId == widget.currentUserId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryTeal : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isMe ? Colors.transparent : AppColors.border,
                      ),
                      boxShadow: isMe
                          ? []
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      m.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,

                      // ✅ Let theme control borders/focus (teal)
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        suffixIcon: IconButton(
                          onPressed: _send,
                          icon: const Icon(Icons.send_rounded),
                          color: AppColors.primaryTeal,
                        ),
                      ),

                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
