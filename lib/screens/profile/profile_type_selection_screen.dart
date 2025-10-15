import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../../models/models.dart';
import 'profile_creation_screen.dart';

class ProfileTypeSelectionScreen extends StatefulWidget {
  const ProfileTypeSelectionScreen({super.key});

  @override
  State<ProfileTypeSelectionScreen> createState() => _ProfileTypeSelectionScreenState();
}

class _ProfileTypeSelectionScreenState extends State<ProfileTypeSelectionScreen> {
  ProfileType? _selectedType;

  void _selectProfileType(ProfileType type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _continue() {
    if (_selectedType == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileCreationScreen(profileType: _selectedType!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Journey'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            Text(
              'What brings you to EveLink?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Select the type of connections you\'re looking to make',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Profile Type Cards
            Expanded(
              child: Column(
                children: [
                  _ProfileTypeCard(
                    type: ProfileType.dating,
                    icon: Icons.favorite,
                    title: 'Dating',
                    description: 'Find romantic connections and meaningful relationships',
                    isSelected: _selectedType == ProfileType.dating,
                    onTap: () => _selectProfileType(ProfileType.dating),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ProfileTypeCard(
                    type: ProfileType.networking,
                    icon: Icons.business_center,
                    title: 'Networking',
                    description: 'Connect with professionals and build your network',
                    isSelected: _selectedType == ProfileType.networking,
                    onTap: () => _selectProfileType(ProfileType.networking),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ProfileTypeCard(
                    type: ProfileType.friendship,
                    icon: Icons.people,
                    title: 'Friendship',
                    description: 'Make new friends and expand your social circle',
                    isSelected: _selectedType == ProfileType.friendship,
                    onTap: () => _selectProfileType(ProfileType.friendship),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedType != null ? _continue : null,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileTypeCard extends StatelessWidget {
  final ProfileType type;
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileTypeCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimationDuration,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppConstants.primaryColor : AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppConstants.primaryColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppConstants.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
