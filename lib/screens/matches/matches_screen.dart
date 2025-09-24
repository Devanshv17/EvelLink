import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../chat/chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    // This schedules _loadMatches to be called immediately after the first frame is built.
    // This is the correct way to load data that affects the UI from initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }



  void _loadMatches() {
    // Access the providers without listening to prevent unnecessary rebuilds.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    // Make sure we have a user before trying to load their matches.
    if (userProvider.currentUser != null) {
      matchProvider.loadMatches(userProvider.currentUser!.uid);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: Consumer2<UserProvider, MatchProvider>(
        builder: (context, userProvider, matchProvider, child) {
          if (matchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = matchProvider.matches;

          if (matches.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: AppConstants.defaultPadding,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final otherUser = matchProvider.getMatchedUser(
                match,
                userProvider.currentUser!.uid,
              );

              if (otherUser == null) return const SizedBox();

              return _buildMatchCard(match, otherUser);
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
              Icons.people_outline,
              size: 80,
              color: AppConstants.textSecondary,
            ),

            const SizedBox(height: 24),

            Text(
              'No Matches Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'When you and someone else like each other,\nyou\'ll see them here',
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

  Widget _buildMatchCard(MatchModel match, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Helpers.getRandomColor(user.uid),
          child: user.photoUrls.isNotEmpty
              ? ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(30), // Image size
              child: PrivateNetworkImage(
                imageUrl: user.photoUrls.first,
                fit: BoxFit.cover,
                seedForFallbackColor: user.uid,
              ),
            ),
          )
              : Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.age} years old'),
            const SizedBox(height: 4),
            if (match.lastMessage != null) ...[
              Text(
                match.lastMessage!,
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              Text(
                'Start a conversation!',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (match.lastMessageTime != null) ...[
              Text(
                Helpers.getTimeAgo(match.lastMessageTime!),
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Icon(
              Icons.chat_bubble_outline,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
        onTap: () => _openChat(match, user),
      ),
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

