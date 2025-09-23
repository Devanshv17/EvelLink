import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/event_provider.dart';
import '../../providers/likes_provider.dart';
import '../../widgets/photo_carousel.dart';
import '../../widgets/interest_chip.dart';

class ProfileDetailScreen extends StatelessWidget {
  final UserModel user;

  const ProfileDetailScreen({
    super.key,
    required this.user,
  });

  Future<void> _handleAction(BuildContext context, String action) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final likesProvider = Provider.of<LikesProvider>(context, listen: false);
    
    if (eventProvider.currentEvent == null) return;

    bool success = false;
    String message = '';

    switch (action) {
      case 'pass':
        success = await likesProvider.passUser(
          eventProvider.currentEvent!.id, 
          user.uid
        );
        message = success ? 'Passed' : 'Failed to pass';
        break;
      
      case 'like':
        if (likesProvider.remainingLikes <= 0) {
          message = 'No more likes remaining';
          break;
        }
        success = await likesProvider.likeUser(
          eventProvider.currentEvent!.id, 
          user.uid
        );
        message = success ? 'Liked!' : 'Failed to like';
        break;
      
      case 'hidden_like':
        if (likesProvider.remainingHiddenLikes <= 0) {
          message = 'No more hidden likes remaining';
          break;
        }
        success = await likesProvider.likeUser(
          eventProvider.currentEvent!.id, 
          user.uid, 
          isHidden: true
        );
        message = success ? 'Hidden like sent!' : 'Failed to send hidden like';
        break;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: PhotoCarousel(photoUrls: user.photoUrls),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Age
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${user.age}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  const Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Interests
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.interests.map((interest) {
                      return InterestChip(
                        label: interest,
                        isSelected: true,
                        onTap: null, // Read-only
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100), // Space for action buttons
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Action buttons
      bottomNavigationBar: Consumer<LikesProvider>(
        builder: (context, likesProvider, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pass button
                _ActionButton(
                  icon: Icons.close,
                  label: 'Pass',
                  color: Colors.grey,
                  onPressed: () => _handleAction(context, 'pass'),
                ),

                // Like button
                _ActionButton(
                  icon: Icons.favorite,
                  label: 'Like (${likesProvider.remainingLikes} left)',
                  color: Colors.pink,
                  onPressed: likesProvider.remainingLikes > 0
                      ? () => _handleAction(context, 'like')
                      : null,
                ),

                // Hidden like button
                _ActionButton(
                  icon: Icons.visibility_off,
                  label: 'Hidden Like (${likesProvider.remainingHiddenLikes} left)',
                  color: Colors.purple,
                  onPressed: likesProvider.remainingHiddenLikes > 0
                      ? () => _handleAction(context, 'hidden_like')
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: onPressed != null ? color : Colors.grey.shade700,
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPressed != null ? Colors.white : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
