import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evelink/models/user_model.dart';
import 'package:evelink/providers/user_provider.dart';
import 'package:evelink/services/storage_service.dart';
import 'package:evelink/utils/app_constants.dart';
import 'package:evelink/utils/helpers.dart';
import 'package:evelink/widgets/interest_chip.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;

  List<String> _existingPhotoUrls = [];
  List<XFile> _newImages = [];
  List<String> _selectedInterests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _ageController = TextEditingController(text: user.age.toString());
      _bioController = TextEditingController(text: user.bio);
      _locationController = TextEditingController(text: user.location);
      _occupationController = TextEditingController(text: user.occupation);
      _educationController = TextEditingController(text: user.education);
      _existingPhotoUrls = List.from(user.photoUrls);
      _selectedInterests = List.from(user.interests);
    } else {
      // Handle case where user is null, perhaps pop the screen
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_existingPhotoUrls.length + _newImages.length >= 6) {
      Helpers.showSnackBar(context, 'You can have a maximum of 6 photos.', isError: true);
      return;
    }
    final StorageService storageService = StorageService();
    final images = await storageService.pickImages(maxImages: 6 - (_existingPhotoUrls.length + _newImages.length));
    setState(() {
      _newImages.addAll(images);
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 10) {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? currentUser.age,
      bio: _bioController.text.trim(),
      interests: _selectedInterests,
      location: _locationController.text.trim(),
      occupation: _occupationController.text.trim(),
      education: _educationController.text.trim(),
      photoUrls: _existingPhotoUrls, // Pass existing urls to be combined in provider
    );

    final success = await userProvider.updateProfile(updatedUser, newImages: _newImages);

    if (mounted) {
      if (success) {
        Helpers.showSnackBar(context, 'Profile updated successfully!');
        Navigator.of(context).pop();
      } else {
        Helpers.showSnackBar(context, userProvider.error ?? 'Failed to update profile.', isError: true);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            _isLoading
                ? const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            )
                : TextButton(
              onPressed: _updateProfile,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      body: Form(
    key: _formKey,
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _buildSectionHeader('Photos'),
    _buildPhotosGrid(),
    const SizedBox(height: 24),
    _buildSectionHeader('Basic Info'),
    TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(labelText: 'Name'),
    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null,
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _ageController,
    decoration: const InputDecoration(labelText: 'Age'),
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value == null || value.isEmpty) return 'Please enter your age';
    final age = int.tryParse(value);
    if (age == null || !Helpers.isValidAge(age)) return 'Please enter a valid age (18-100)';
    return null;
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _bioController,
    decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true),
    maxLines: 4,
    validator: (value) => value == null || !Helpers.isValidBio(value) ? 'Please enter a bio (10-500 characters)' : null,
    ),
    const SizedBox(height: 24),
    _buildSectionHeader('Interests (${_selectedInterests.length}/10)'),
    _buildInterestsSection(),
    const SizedBox(height: 24),
    _buildSectionHeader('Additional Details'),
    TextFormField(
    controller: _locationController,
    decoration: const InputDecoration(labelText: 'Location'),
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _occupationController,
    decoration: const InputDecoration(labelText: 'Occupation'),
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _educationController,
    decoration: const InputDecoration(labelText: 'Education'),
    ),
    ],
    ),
    ),
    ),
    );
    }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _existingPhotoUrls.length + _newImages.length + 1,
      itemBuilder: (context, index) {
        if (index < _existingPhotoUrls.length) {
          // Display existing photos from URLs
          return _buildPhotoItem(
            imageProvider: CachedNetworkImageProvider(_existingPhotoUrls[index]),
            onDelete: () {
              setState(() {
                _existingPhotoUrls.removeAt(index);
              });
            },
          );
        } else if (index < _existingPhotoUrls.length + _newImages.length) {
          // Display newly picked photos from files
          final newImageIndex = index - _existingPhotoUrls.length;
          return _buildPhotoItem(
            imageProvider: FileImage(File(_newImages[newImageIndex].path)),
            onDelete: () {
              setState(() {
                _newImages.removeAt(newImageIndex);
              });
            },
          );
        } else if (_existingPhotoUrls.length + _newImages.length < 6) {
          // Display the "add more" button
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPhotoItem({required ImageProvider imageProvider, required VoidCallback onDelete}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.interests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return InterestChip(
          label: interest,
          isSelected: isSelected,
          onTap: () => _toggleInterest(interest),
        );
      }).toList(),
    );
  }
}
