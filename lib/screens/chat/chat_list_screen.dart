import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _hasLoaded = false;
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use didChangeDependencies instead of initState to safely access providers
    // and check the flag to ensure data is loaded only once.
    if (!_hasLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMatches();
      });
      setState(() {
        _hasLoaded = true;
      });
    }
  }

  void _loadMatches() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      matchProvider.loadMatches(userProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: Consumer2<UserProvider, MatchProvider>(
        builder: (context, userProvider, matchProvider, child) {
          if (matchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter matches that have messages
          final matchesWithMessages = matchProvider.matches
              .where((match) => match.lastMessage != null)
              .toList();

          if (matchesWithMessages.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: matchesWithMessages.length,
            itemBuilder: (context, index) {
              final match = matchesWithMessages[index];
              final otherUser = matchProvider.getMatchedUser(
                match, 
                userProvider.currentUser!.uid,
              );

              if (otherUser == null) return const SizedBox();

              return _buildChatTile(match, otherUser);
            },
          );
        },
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
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppConstants.textSecondary,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No Chats Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Start chatting with your matches!',
              style: TextStyle(
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(MatchModel match, UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Helpers.getRandomColor(user.uid),
        backgroundImage: user.photoUrls.isNotEmpty 
            ? NetworkImage(user.photoUrls.first) 
            : null,
        child: user.photoUrls.isEmpty 
            ? Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: match.lastMessage != null 
          ? Text(
              match.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppConstants.textSecondary,
              ),
            )
          : null,
      trailing: match.lastMessageTime != null
          ? Text(
              Helpers.getTimeAgo(match.lastMessageTime!),
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      onTap: () => _openChat(match, user),
    );
  }

  void _openChat(MatchModel match, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          match: match,
          otherUser: user,
        ),
      ),
    );
  }
}
