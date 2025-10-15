import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToMatches();
    });
  }

  void _listenToMatches() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      matchProvider.listenToMatches(userProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Your Matches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer2<UserProvider, MatchProvider>(
        builder: (context, userProvider, matchProvider, child) {
          if (matchProvider.isLoading && matchProvider.matches.isEmpty) {
            return _buildLoadingState();
          }

          final matches = matchProvider.matches;

          if (matches.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Stats Card
              _buildStatsCard(matches.length),

              // Matches List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final otherUser = matchProvider.getMatchedUser(
                      match,
                      userProvider.currentUser!.uid,
                    );

                    if (otherUser == null) {
                      return const SizedBox.shrink();
                    }
                    return _buildMatchCard(match, otherUser, userProvider.currentUser!.uid);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your matches...',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int matchCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            Colors.purple,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$matchCount ${matchCount == 1 ? 'Match' : 'Matches'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Start conversations with your matches!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match, UserModel user, String currentUserId) {
    // Fix: Get unread count for current user from the map
    final unreadCountForUser = match.unreadCount[currentUserId] ?? 0;
    final hasUnread = unreadCountForUser > 0;

    final timeAgo = match.lastMessageTime != null
        ? Helpers.getTimeAgo(match.lastMessageTime!)
        : 'Just now';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            // User Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: user.photoUrls.isNotEmpty
                    ? Image.network(
                  user.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Online indicator - Only show if user has isOnline property
            // if (user.isOnline == true)
            //   Positioned(
            //     bottom: 2,
            //     right: 2,
            //     child: Container(
            //       width: 12,
            //       height: 12,
            //       decoration: BoxDecoration(
            //         color: Colors.green,
            //         shape: BoxShape.circle,
            //         border: Border.all(color: Colors.white, width: 2),
            //       ),
            //     ),
            //   ),
          ],
        ),
        title: Row(
          children: [
            Text(
              user.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: hasUnread ? AppConstants.textPrimary : AppConstants.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            // Show verification badge only if user has isVerified property
            // if (user.isVerified == true)
            //   Icon(Icons.verified, color: AppConstants.primaryColor, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (match.lastMessage != null && match.lastMessage!.isNotEmpty) ...[
              Text(
                match.lastMessage!,
                style: TextStyle(
                  color: hasUnread ? AppConstants.textPrimary : AppConstants.textSecondary,
                  fontSize: 14,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              Text(
                'Say hello! 👋',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: TextStyle(
                color: AppConstants.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasUnread) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCountForUser > 9 ? '9+' : unreadCountForUser.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.chat_bubble_outline,
                color: AppConstants.primaryColor,
              ),
            ],
          ],
        ),
        onTap: () => _openChat(match, user),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                color: AppConstants.primaryColor,
                size: 40,
              ),
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
              "When you and someone else like each other,\nyou'll see them here",
              style: TextStyle(
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to events screen to find people
                Navigator.pop(context);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Discover People'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
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