import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import '../models/models.dart';
import '../utils/utils.dart';
import 'private_network_image.dart'; // Import the new widget

class UserCard extends StatelessWidget {
  final UserModel user;
  final bool isBlurred;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.isBlurred = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // User Photo
              _buildUserPhoto(),

              // Blur overlay for hidden likes
              if (isBlurred) _buildBlurOverlay(),

              // Gradient overlay
              _buildGradientOverlay(),

              // User info
              _buildUserInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserPhoto() {
    if (user.photoUrls.isNotEmpty) {
      // --- USE THE NEW WIDGET ---
      return PrivateNetworkImage(
        imageUrl: user.photoUrls.first,
        seedForFallbackColor: user.uid,
      );
      // --- END ---
    } else {
      return _buildFallbackAvatar();
    }
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: Helpers.getRandomColor(user.uid),
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBlurOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: const Center(
          child: Icon(
            Icons.visibility_off,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          Text(
            '${user.age} years old',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),

          if (user.interests.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.interests.take(2).join(' • '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

