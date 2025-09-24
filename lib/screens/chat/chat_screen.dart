import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  final MatchModel match;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.match,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.startListeningToMessages(widget.match.matchId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.stopListeningToMessages();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: AppConstants.shortAnimationDuration,
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (userProvider.currentUser == null) return;

    _messageController.clear();

    final success = await chatProvider.sendMessage(
      widget.match.matchId,
      userProvider.currentUser!.uid,
      text,
    );

    if (success) {
      _scrollToBottom();
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        chatProvider.error ?? 'Failed to send message',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Helpers.getRandomColor(widget.otherUser.uid),
              child: widget.otherUser.photoUrls.isNotEmpty
                  ? ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(18), // Image size
                  child: PrivateNetworkImage(
                    imageUrl: widget.otherUser.photoUrls.first,
                    fit: BoxFit.cover,
                    seedForFallbackColor: widget.otherUser.uid,
                  ),
                ),
              )
                  : Text(
                widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${widget.otherUser.age} years old',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Consumer2<ChatProvider, UserProvider>(
              builder: (context, chatProvider, userProvider, child) {
                final messages = chatProvider.messages;
                final currentUserId = userProvider.currentUser?.uid;

                if (currentUserId == null) {
                  return const Center(child: Text('Error: User not found'));
                }

                if (messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Helpers.getRandomColor(widget.otherUser.uid),
              child: widget.otherUser.photoUrls.isNotEmpty
                  ? ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(40), // Image size
                  child: PrivateNetworkImage(
                    imageUrl: widget.otherUser.photoUrls.first,
                    fit: BoxFit.cover,
                    seedForFallbackColor: widget.otherUser.uid,
                  ),
                ),
              )
                  : Text(
                widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You matched with ${widget.otherUser.name}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation with a friendly message',
              style: TextStyle(
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Helpers.getRandomColor(widget.otherUser.uid),
              child: widget.otherUser.photoUrls.isNotEmpty
                  ? ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(16), // Image size
                  child: PrivateNetworkImage(
                    imageUrl: widget.otherUser.photoUrls.first,
                    fit: BoxFit.cover,
                    seedForFallbackColor: widget.otherUser.uid,
                  ),
                ),
              )
                  : Text(
                widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? AppConstants.primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : null,
                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppConstants.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : AppConstants.textSecondary,
                      fontSize: 12,
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return FloatingActionButton(
                  onPressed: chatProvider.isLoading ? null : _sendMessage,
                  mini: true,
                  backgroundColor: AppConstants.primaryColor,
                  child: chatProvider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

