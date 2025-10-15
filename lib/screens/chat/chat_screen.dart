import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _isScrolled = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.startListeningToMessages(widget.match.matchId);

    _scrollController.addListener(_onScroll);

    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Listen to focus changes to handle keyboard
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.offset <= _scrollController.position.minScrollExtent + 10;
      if (isAtBottom != _isScrolled) {
        setState(() {
          _isScrolled = !isAtBottom;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.stopListeningToMessages();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
    if (_showEmojiPicker) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _messageController
      ..text += emoji.emoji
      ..selection = TextSelection.collapsed(offset: _messageController.text.length);
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

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.more_vert, color: AppConstants.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      'Chat Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Options
              _buildChatOption(
                Icons.person_outline,
                'View Profile',
                    () {
                  Navigator.pop(context);
                  _showUserProfile();
                },
              ),
              _buildChatOption(
                Icons.block,
                'Block User',
                    () {
                  Navigator.pop(context);
                  _showBlockConfirmation();
                },
                isDestructive: true,
              ),
              _buildChatOption(
                Icons.report,
                'Report User',
                    () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
                isDestructive: true,
              ),
              _buildChatOption(
                Icons.delete_outline,
                'Clear Chat',
                    () {
                  Navigator.pop(context);
                  _showClearChatConfirmation();
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatOption(IconData icon, String text, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppConstants.primaryColor,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppConstants.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: UserDetailBottomSheet(
          user: widget.otherUser,
          showActionButtons: false, // Read-only in chat
        ),
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${widget.otherUser.name}? You will no longer be able to message each other.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block user functionality
              Helpers.showSnackBar(context, '${widget.otherUser.name} has been blocked');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text('Please select a reason for reporting this user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement report functionality
              Helpers.showSnackBar(context, 'Thank you for your report. We will review it shortly.');
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showClearChatConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages in this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear chat functionality
              Helpers.showSnackBar(context, 'Chat cleared successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close keyboard and emoji picker when tapping outside
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
        if (_showEmojiPicker) {
          setState(() {
            _showEmojiPicker = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Match info banner for empty state
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty) {
                  return _buildMatchBanner();
                }
                return const SizedBox();
              },
            ),

            // Messages
            Expanded(
              child: Consumer2<ChatProvider, UserProvider>(
                builder: (context, chatProvider, userProvider, child) {
                  final messages = chatProvider.messages;
                  final currentUserId = userProvider.currentUser?.uid;

                  if (currentUserId == null) {
                    return _buildErrorState();
                  }

                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Stack(
                    children: [
                      // Messages list
                      ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == currentUserId;
                          final showAvatar = _shouldShowAvatar(messages, index, currentUserId);

                          return _buildMessageBubble(message, isMe, showAvatar);
                        },
                      ),

                      // Scroll to bottom button
                      if (_isScrolled) _buildScrollToBottomButton(),
                    ],
                  );
                },
              ),
            ),

            // Emoji Picker
            if (_showEmojiPicker) _buildEmojiPicker(),

            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // User avatar with status
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: widget.otherUser.photoUrls.isNotEmpty
                      ? PrivateNetworkImage(
                    imageUrl: widget.otherUser.photoUrls.first,
                    fit: BoxFit.cover,
                    seedForFallbackColor: widget.otherUser.uid,
                  )
                      : Container(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Text(
                        widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Online indicator
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: AppConstants.textPrimary),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  Widget _buildMatchBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.9),
            AppConstants.secondaryColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "It's a Match!",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You and ${widget.otherUser.name} are connected',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppConstants.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load chat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppConstants.primaryColor,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: widget.otherUser.photoUrls.isNotEmpty
                              ? PrivateNetworkImage(
                            imageUrl: widget.otherUser.photoUrls.first,
                            fit: BoxFit.cover,
                            seedForFallbackColor: widget.otherUser.uid,
                          )
                              : Container(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            child: Center(
                              child: Text(
                                widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You matched with ${widget.otherUser.name}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.otherUser.age} • ${widget.otherUser.occupation ?? 'Not specified'}',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start the conversation with a friendly message 👋',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Conversation starters
            _buildConversationStarters(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationStarters() {
    final starters = [
      'Hey ${widget.otherUser.name.split(' ')[0]}! 👋',
      'How\'s your day going?',
      'What brings you to this event?',
      'I noticed we both like similar things!',
      'Would love to get to know you better!',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick starters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: starters.map((starter) {
            return GestureDetector(
              onTap: () {
                _messageController.text = starter;
                _sendMessage();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  starter,
                  style: TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _shouldShowAvatar(List<MessageModel> messages, int index, String currentUserId) {
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];

    // Show avatar if:
    // 1. Next message is from different sender, OR
    // 2. There's a significant time gap (more than 5 minutes)
    final timeDiff = currentMessage.timestamp.difference(nextMessage.timestamp).abs();

    return currentMessage.senderId != nextMessage.senderId ||
        timeDiff.inMinutes > 5;
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, bool showAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: widget.otherUser.photoUrls.isNotEmpty
                    ? PrivateNetworkImage(
                  imageUrl: widget.otherUser.photoUrls.first,
                  fit: BoxFit.cover,
                  seedForFallbackColor: widget.otherUser.uid,
                )
                    : Container(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 40), // Space for alignment when no avatar
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isMe ? const Radius.circular(6) : null,
                      bottomLeft: !isMe ? const Radius.circular(6) : null,
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppConstants.textPrimary,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppConstants.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: _scrollToBottom,
        mini: true,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (Category? category, Emoji emoji) {
          _onEmojiSelected(emoji);
        },
        // config: Config(
        //   columns: 7,
        //   emojiSizeMax: 32,
        //   verticalSpacing: 0,
        //   horizontalSpacing: 0,
        //   initCategory: Category.RECENT,
        //   bgColor: Colors.white,
        //   indicatorColor: AppConstants.primaryColor,
        //   iconColor: Colors.grey,
        //   iconColorSelected: AppConstants.primaryColor,
        //   skinToneDialogBgColor: Colors.white,
        //   skinToneIndicatorColor: Colors.grey,
        //   enableSkinTones: true,
        //   showRecentsTab: true,
        //   recentsLimit: 28,
        //   noRecentsText: 'No Recents',
        //   tabIndicatorAnimDuration: kTabScrollDuration,
        //   categoryIcons: const CategoryIcons(),
        //   buttonMode: ButtonMode.MATERIAL,
        // ),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Emoji button
            IconButton(
              onPressed: _toggleEmojiPicker,
              icon: Icon(
                _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                color: _showEmojiPicker ? AppConstants.primaryColor : AppConstants.textLight,
              ),
            ),

            // Message input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Message ${widget.otherUser.name.split(' ')[0]}...',
                    hintStyle: TextStyle(color: AppConstants.textLight),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 5,
                  minLines: 1,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final hasText = _messageController.text.trim().isNotEmpty;

                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: hasText
                        ? LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: hasText ? null : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: hasText && !chatProvider.isLoading ? _sendMessage : null,
                    icon: chatProvider.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(
                      Icons.send,
                      color: hasText ? Colors.white : Colors.grey.shade500,
                      size: 20,
                    ),
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