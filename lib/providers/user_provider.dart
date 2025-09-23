import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authService.isSignedIn;
  
  Future<void> loadCurrentUser() async {
    if (_authService.currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = await _databaseService.getUser(_authService.currentUser!.uid);
      _currentUser = user;
    } catch (e) {
      print('Error loading user: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createUserProfile(UserModel user) async {
    try {
      await _databaseService.createUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }
  
  Future<bool> checkUserExists() async {
    if (_authService.currentUser == null) return false;
    return await _databaseService.userExists(_authService.currentUser!.uid);
  }
  
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
