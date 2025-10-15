import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../widgets/interest_chip.dart';
import 'private_network_image.dart';

class UserDetailBottomSheet extends StatelessWidget {
  final UserModel user;
  final bool showActionButtons;
  final VoidCallback? onSkip;
  final VoidCallback? onSpark;
  final bool isHiddenLike;
  final VoidCallback? onLike;

  const UserDetailBottomSheet({
    super.key,
    required this.user,
    this.showActionButtons = true,
    this.onSkip,
    this.isHiddenLike = false,
    this.onSpark,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Custom Header with gradient
          _buildHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos Carousel - with blur if hidden like
                  _buildPhotosSection(),

                  const SizedBox(height: 24),

                  // Basic Info with improved layout
                  _buildBasicInfo(),

                  const SizedBox(height: 20),

                  // Bio Section - hide if hidden like
                  if (!isHiddenLike && user.bio.isNotEmpty) _buildBioSection(),

                  const SizedBox(height: 20),

                  // Interests with better chips - hide if hidden like
                  if (!isHiddenLike && user.interests.isNotEmpty) _buildInterestsSection(),

                  const SizedBox(height: 20),

                  // Additional Details in card layout - hide if hidden like
                  if (!isHiddenLike) _buildAdditionalDetails(),

                  // Hidden like message
                  if (isHiddenLike) _buildHiddenLikeMessage(),

                  const SizedBox(height: 100), // Space for buttons
                ],
              ),
            ),
          ),

          // New Action Buttons - show different buttons for hidden likes
          if (showActionButtons) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHiddenLikeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: Colors.purple, size: 40),
          const SizedBox(height: 12),
          Text(
            'Secret Admirer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This person sparked you! Like them back to reveal their identity and see their full profile.',
            style: TextStyle(
              color: Colors.purple.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.9),
            AppConstants.secondaryColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
          const Spacer(),
          Text(
            isHiddenLike ? 'Secret Admirer' : 'Profile Details',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    if (isHiddenLike) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.withOpacity(0.3),
        ),
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 60, color: Colors.purple),
                const SizedBox(height: 16),
                Text(
                  'Profile Hidden',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Like back to reveal photos',
                  style: TextStyle(
                    color: Colors.purple.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (user.photoUrls.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor.withOpacity(0.7),
              AppConstants.secondaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No Photos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: user.photoUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PrivateNetworkImage(
                    imageUrl: user.photoUrls[index],
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                        ),
                      ),
                    ),
                    errorWidget: Container(
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppConstants.textLight,
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: AppConstants.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Photo count indicator
          if (user.photoUrls.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '1/${user.photoUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    if (isHiddenLike) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Blurred Avatar for hidden like
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.5),
                border: Border.all(
                  color: Colors.purple,
                  width: 3,
                ),
              ),
              child: BackdropFilter(
                filter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Center(
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secret Admirer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Spark Received',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        'Like back to reveal identity',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.primaryColor,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: user.photoUrls.isNotEmpty
                  ? PrivateNetworkImage(
                imageUrl: user.photoUrls.first,
                fit: BoxFit.cover,
              )
                  : Container(
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${user.age}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (user.profileType != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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

                const SizedBox(height: 8),

                if (user.location != null && user.location!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppConstants.textLight),
                      const SizedBox(width: 4),
                      Text(
                        user.location!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'About Me',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            user.bio,
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.interests_outlined, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Interests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor.withOpacity(0.8),
                      AppConstants.secondaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    final details = <Map<String, dynamic>>[];

    if (user.occupation != null && user.occupation!.isNotEmpty) {
      details.add({
        'icon': Icons.work_outline,
        'label': 'Occupation',
        'value': user.occupation!,
      });
    }

    if (user.education != null && user.education!.isNotEmpty) {
      details.add({
        'icon': Icons.school_outlined,
        'label': 'Education',
        'value': user.education!,
      });
    }

    if (user.location != null && user.location!.isNotEmpty) {
      details.add({
        'icon': Icons.location_on_outlined,
        'label': 'Location',
        'value': user.location!,
      });
    }

    if (details.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.details_outlined, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    detail['icon'] as IconData,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail['value'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isHiddenLike) {
      // Special action buttons for hidden likes - only Skip and Like (no Spark)
      return Container(
        padding: const EdgeInsets.all(20),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Skip Button
              _buildActionButton(
                Icons.close,
                'Skip',
                Colors.red,
                onSkip ?? () {},
              ),

              // Like Button (to reveal hidden admirer)
              _buildActionButton(
                Icons.favorite,
                'Like Back',
                AppConstants.primaryColor,
                onLike ?? () {},
                isHighlighted: true,
              ),
            ],
          ),
        ),
      );
    }

    // Normal action buttons for regular profiles
    return Container(
      padding: const EdgeInsets.all(20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Skip Button
            _buildActionButton(
              Icons.close,
              'Skip',
              Colors.red,
              onSkip ?? () {},
            ),

            // Spark Button (Hidden Like)
            _buildActionButton(
              Icons.auto_awesome,
              'Spark',
              Colors.purple,
              onSpark ?? () {},
              isHighlighted: true,
            ),

            // Like Button
            _buildActionButton(
              Icons.favorite,
              'Like',
              AppConstants.primaryColor,
              onLike ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isHighlighted ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isHighlighted ? color : Colors.transparent,
              width: 3,
            ),
            boxShadow: isHighlighted ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 32),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}