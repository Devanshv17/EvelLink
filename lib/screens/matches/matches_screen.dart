import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import '../chat/chat_screen.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<MatchModel> _matches = [];
  Map<String, UserModel> _matchedUsers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final matches = await _databaseService.getUserMatches(
          userProvider.currentUser!.uid
      );

      final Map<String, UserModel> users = {};

      for (final match in matches) {
        final otherUserId = match.users.firstWhere(
                (id) => id != userProvider.currentUser!.uid
        );

        final user = await _databaseService.getUser(otherUserId);
        if (user != null) {
          users[otherUserId] = user;
        }
      }

      setState(() {
        _matches = matches;
        _matchedUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading matches: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_matches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No matches yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start liking people to make matches!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final otherUserId = match.users.firstWhere(
                  (id) => id != userProvider.currentUser!.uid
          );
          final otherUser = _matchedUsers[otherUserId];

          if (otherUser == null) {
            return const SizedBox.shrink();
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: otherUser.photoUrls.isNotEmpty
                    ? NetworkImage(otherUser.photoUrls.first)
                    : null,
                child: otherUser.photoUrls.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                otherUser.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${otherUser.age}'),
                  if (match.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      match.lastMessage!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              trailing: const Icon(Icons.chat),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      matchId: match.id,
                      otherUser: otherUser,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
