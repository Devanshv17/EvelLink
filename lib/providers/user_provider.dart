import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/services.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadUser(String uid) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _databaseService.getUser(uid);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProfile(UserModel user, List<XFile> images) async {
    _setLoading(true);
    _setError(null);

    try {
      // Upload images first
      List<String> photoUrls = [];
      if (images.isNotEmpty) {
        photoUrls = await _storageService.uploadUserPhotos(user.uid, images);
      }

      // Create user with photo URLs
      final userWithPhotos = user.copyWith(photoUrls: photoUrls);
      await _databaseService.createUser(userWithPhotos);

      _currentUser = userWithPhotos;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(UserModel updatedUser, {List<XFile>? newImages}) async {
    _setLoading(true);
    _setError(null);

    try {
      UserModel finalUser = updatedUser;

      // Upload new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        final newPhotoUrls = await _storageService.uploadUserPhotos(
          updatedUser.uid,
          newImages,
        );

        // Combine existing and new photos
        final allPhotos = [...updatedUser.photoUrls, ...newPhotoUrls];
        finalUser = updatedUser.copyWith(photoUrls: allPhotos);
      }

      await _databaseService.createUser(finalUser); // This will update if exists
      _currentUser = finalUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
