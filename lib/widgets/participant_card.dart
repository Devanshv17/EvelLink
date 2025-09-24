import 'package:evelink/widgets/private_network_image.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class ParticipantCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const ParticipantCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded image takes up most of the space
            Expanded(
              child: _buildUserPhoto(),
            ),
            // Name below the image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPhoto() {
    if (user.photoUrls.isNotEmpty) {
      // Use the PrivateNetworkImage inside a circular clip
      return ClipOval(
        child: PrivateNetworkImage(
          imageUrl: user.photoUrls.first,
          seedForFallbackColor: user.uid,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Fallback avatar if no photo is available
      return CircleAvatar(
        radius: 45, // Adjust size as needed
        backgroundColor: Helpers.getRandomColor(user.uid),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}