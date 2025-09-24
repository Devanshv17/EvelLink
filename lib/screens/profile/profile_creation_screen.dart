import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ProfileCreationScreen extends StatefulWidget {
  final ProfileType profileType;

  const ProfileCreationScreen({
    super.key,
    required this.profileType,
  });

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();

  List<XFile> _selectedImages = [];
  List<String> _selectedInterests = [];
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Basic Info',
    'Photos',
    'Interests',
    'Additional Details',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
    _bioController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {
      // Refresh UI when input text changes to enable/disable buttons correctly
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onInputChanged);
    _ageController.removeListener(_onInputChanged);
    _bioController.removeListener(_onInputChanged);
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final StorageService storageService = StorageService();
    final images = await storageService.pickImages(maxImages: 6);
    setState(() {
      _selectedImages = images;
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

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty &&
            _ageController.text.trim().isNotEmpty &&
            _bioController.text.trim().isNotEmpty;
      case 1:
        return _selectedImages.isNotEmpty;
      case 2:
        return _selectedInterests.length >= 3;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _createProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn) return;

    // ... (user model creation code is the same)
    final user = UserModel(
      uid: authService.currentUser!.uid,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      bio: _bioController.text.trim(),
      photoUrls: [],
      interests: _selectedInterests,
      profileType: widget.profileType,
      createdAt: DateTime.now(),
      location:
      _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      occupation: _occupationController.text.trim().isNotEmpty
          ? _occupationController.text.trim()
          : null,
      education:
      _educationController.text.trim().isNotEmpty ? _educationController.text.trim() : null,
    );

    final success = await userProvider.createProfile(user, _selectedImages);

    if (success && mounted) {
      // This is the important change. We replace the current navigation
      // stack with the MainNavigationScreen, so the user can't go "back"
      // to the profile creation flow.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            (Route<dynamic> route) => false,
      );
    } else if (mounted) {
      Helpers.showSnackBar(
        context,
        userProvider.error ?? 'Failed to create profile',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[_currentStep]),
        leading: _currentStep > 0
            ? IconButton(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back),
        )
            : null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / _stepTitles.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            Expanded(
              child: Padding(
                padding: AppConstants.screenPadding,
                child: _buildStepContent(),
              ),
            ),
            Container(
              padding: AppConstants.screenPadding,
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: userProvider.isLoading || !_canContinue()
                          ? null
                          : _nextStep,
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _currentStep == _stepTitles.length - 1
                            ? 'Create Profile'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildPhotosStep();
      case 2:
        return _buildInterestsStep();
      case 3:
        return _buildAdditionalDetailsStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Your first name',
            ),
            validator: (value) {
              if (value == null || !Helpers.isValidName(value)) {
                return 'Please enter a valid name (min 2 characters)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
              hintText: 'Your age',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              final age = int.tryParse(value);
              if (age == null || !Helpers.isValidAge(age)) {
                return 'Please enter a valid age (18-100)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell everyone about yourself...',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value == null || !Helpers.isValidBio(value)) {
                return 'Please enter a bio (10-500 characters)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Add your best photos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add at least 2 photos. First photo will be your main photo.',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: _selectedImages.isEmpty
              ? _buildEmptyPhotosState()
              : _buildPhotosGrid(),
        ),
      ],
    );
  }

  Widget _buildEmptyPhotosState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 60,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No photos added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos to show your personality',
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Photos'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                // Add more button
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.grey.shade600,
                      size: 32,
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(_selectedImages[index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'MAIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_selectedImages.length}/6 photos added',
          style: TextStyle(
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'What are your interests?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least 3 interests to help others get to know you better.',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
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
          ),
          const SizedBox(height: 24),
          Text(
            '${_selectedInterests.length}/10 interests selected',
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Additional Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These details are optional but help others connect with you.',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'City, State',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _occupationController,
            decoration: const InputDecoration(
              labelText: 'Occupation',
              hintText: 'What do you do?',
              prefixIcon: Icon(Icons.work_outline),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _educationController,
            decoration: const InputDecoration(
              labelText: 'Education',
              hintText: 'School/University',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
