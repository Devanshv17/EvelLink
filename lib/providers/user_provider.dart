import 'dart:async';
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
  StreamSubscription<UserModel?>? _userSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _currentUser != null;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void listenToUser(String uid) {
    _setLoading(true);
    _userSubscription?.cancel();
    _userSubscription = _databaseService.getUserStream(uid).listen((user) {
      _currentUser = user;
      _setLoading(false);
    }, onError: (e) {
      _setError(e.toString());
      _setLoading(false);
    });
  }

  Future<bool> createProfile(UserModel user, List<XFile> images) async {
    _setLoading(true);
    _setError(null);
    try {
      List<String> photoUrls = [];
      if (images.isNotEmpty) {
        photoUrls = await _storageService.uploadUserPhotos(user.uid, images);
      }
      final userWithPhotos = user.copyWith(photoUrls: photoUrls);
      await _databaseService.createUser(userWithPhotos);
      _currentUser = userWithPhotos;
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
      if (newImages != null && newImages.isNotEmpty) {
        final newPhotoUrls = await _storageService.uploadUserPhotos(updatedUser.uid, newImages);
        final allPhotos = [...updatedUser.photoUrls, ...newPhotoUrls];
        finalUser = updatedUser.copyWith(photoUrls: allPhotos);
      }
      await _databaseService.updateUser(finalUser);
      _currentUser = finalUser;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearUser() {
    _userSubscription?.cancel();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

