import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/likes_provider.dart';
import '../../widgets/profile_card.dart';
import 'profile_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final likesProvider = Provider.of<LikesProvider>(context, listen: false);
    
    if (eventProvider.currentEvent != null) {
      await likesProvider.loadUserInteractions(eventProvider.currentEvent!.id);
      await likesProvider.loadUsersWhoLiked(
        eventProvider.currentEvent!.id, 
        eventProvider.eventUsers
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventProvider, LikesProvider>(
      builder: (context, eventProvider, likesProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventProvider.eventUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No one else has joined this event yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Filter out users who have been interacted with
        final availableUsers = eventProvider.eventUsers.where((user) {
          return !likesProvider.hasLiked(user.uid) && 
                 !likesProvider.hasPassed(user.uid) &&
                 !likesProvider.hasHiddenLiked(user.uid);
        }).toList();

        if (availableUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                SizedBox(height: 16),
                Text(
                  'You have seen everyone!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check your matches or wait for more people to join',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await eventProvider.refreshEventUsers();
            await _loadData();
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: availableUsers.length,
            itemBuilder: (context, index) {
              final user = availableUsers[index];
              return ProfileCard(
                user: user,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileDetailScreen(user: user),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
