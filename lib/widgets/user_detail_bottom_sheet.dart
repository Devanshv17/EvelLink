import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/interest_chip.dart';

class UserDetailBottomSheet extends StatelessWidget {
  final UserModel user;
  final bool showLikeButtons;
  final Function(bool isHidden)? onLike;
  final VoidCallback? onPass;

  const UserDetailBottomSheet({
    super.key,
    required this.user,
    this.showLikeButtons = true,
    this.onLike,
    this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos
                  _buildPhotosSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Basic info
                  _buildBasicInfo(),
                  
                  const SizedBox(height: 20),
                  
                  // Bio
                  if (user.bio.isNotEmpty) _buildBioSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Interests
                  if (user.interests.isNotEmpty) _buildInterestsSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Additional details
                  _buildAdditionalDetails(),
                  
                  const SizedBox(height: 100), // Space for buttons
                ],
              ),
            ),
          ),
          
          // Action buttons
          if (showLikeButtons) _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    if (user.photoUrls.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Helpers.getRandomColor(user.uid),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Center(
          child: Text(
            user.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 400,
      child: PageView.builder(
        itemCount: user.photoUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: CachedNetworkImage(
                imageUrl: user.photoUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.error,
                    size: 50,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${user.age}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.profileType.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppConstants.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          user.bio,
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.interests.map((interest) {
            return InterestChip(
              label: interest,
              isSelected: false,
              onTap: () {}, // Read-only
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    final details = <MapEntry<String, String>>[];
    
    if (user.location != null && user.location!.isNotEmpty) {
      details.add(MapEntry('Location', user.location!));
    }
    
    if (user.occupation != null && user.occupation!.isNotEmpty) {
      details.add(MapEntry('Occupation', user.occupation!));
    }
    
    if (user.education != null && user.education!.isNotEmpty) {
      details.add(MapEntry('Education', user.education!));
    }

    if (details.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...details.map((detail) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  detail.key,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ),
              
              Expanded(
                child: Text(
                  detail.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            // Pass button
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onPass?.call();
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    'Pass',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Hidden like button
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onLike?.call(true);
                  },
                  icon: Icon(Icons.favorite_border, color: AppConstants.primaryColor),
                  label: Text(
                    'Like',
                    style: TextStyle(color: AppConstants.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppConstants.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Clear like button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onLike?.call(false);
                  },
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text(
                    'Super Like',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
