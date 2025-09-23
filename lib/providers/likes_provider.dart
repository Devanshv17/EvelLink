import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class LikesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  int _remainingLikes = 20;
  int _remainingHiddenLikes = 5;
  List<UserModel> _usersWhoLiked = [];
  Map<String, bool> _hiddenLikesMap = {};
  Map<String, dynamic> _userInteractions = {};
  
  int get remainingLikes => _remainingLikes;
  int get remainingHiddenLikes => _remainingHiddenLikes;
  List<UserModel> get usersWhoLiked => _usersWhoLiked;
  Map<String, bool> get hiddenLikesMap => _hiddenLikesMap;
  
  bool hasLiked(String userId) {
    return _userInteractions['likes']?[userId] != null;
  }
  
  bool hasPassed(String userId) {
    return _userInteractions['passes']?[userId] != null;
  }
  
  bool hasHiddenLiked(String userId) {
    return _userInteractions['hiddenLikes']?[userId] != null;
  }
  
  Future<void> loadUserInteractions(String eventId) async {
    if (_authService.currentUser == null) return;
    
    try {
      final interactions = await _databaseService.getUserInteractions(
        eventId, 
        _authService.currentUser!.uid
      );
      
      _userInteractions = interactions ?? {};
      
      // Calculate remaining likes
      final likesCount = (_userInteractions['likes'] as Map?)?.length ?? 0;
      final hiddenLikesCount = (_userInteractions['hiddenLikes'] as Map?)?.length ?? 0;
      
      _remainingLikes = 20 - likesCount;
      _remainingHiddenLikes = 5 - hiddenLikesCount;
      
      notifyListeners();
    } catch (e) {
      print('Error loading user interactions: $e');
    }
  }
  
  Future<bool> likeUser(String eventId, String userId, {bool isHidden = false}) async {
    if (_authService.currentUser == null) return false;
    
    if (isHidden && _remainingHiddenLikes <= 0) return false;
    if (!isHidden && _remainingLikes <= 0) return false;
    
    try {
      await _databaseService.recordLike(
        eventId, 
        _authService.currentUser!.uid, 
        userId, 
        isHidden: isHidden
      );
      
      // Update local state
      final field = isHidden ? 'hiddenLikes' : 'likes';
      _userInteractions[field] ??= {};
      _userInteractions[field][userId] = DateTime.now();
      
      if (isHidden) {
        _remainingHiddenLikes--;
      } else {
        _remainingLikes--;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error liking user: $e');
      return false;
    }
  }
  
  Future<bool> passUser(String eventId, String userId) async {
    if (_authService.currentUser == null) return false;
    
    try {
      await _databaseService.recordPass(
        eventId, 
        _authService.currentUser!.uid, 
        userId
      );
      
      _userInteractions['passes'] ??= {};
      _userInteractions['passes'][userId] = DateTime.now();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error passing user: $e');
      return false;
    }
  }
  
  Future<void> loadUsersWhoLiked(String eventId, List<UserModel> allUsers) async {
    if (_authService.currentUser == null) return;
    
    try {
      final likedByIds = await _databaseService.getUsersWhoLiked(
        eventId, 
        _authService.currentUser!.uid
      );
      
      _usersWhoLiked = allUsers.where((user) => likedByIds.contains(user.uid)).toList();
      
      // Check which are hidden likes
      _hiddenLikesMap.clear();
      for (String likerId in likedByIds) {
        final isHidden = await _databaseService.isHiddenLike(
          eventId, 
          likerId, 
          _authService.currentUser!.uid
        );
        _hiddenLikesMap[likerId] = isHidden;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading users who liked: $e');
    }
  }
  
  void reset() {
    _remainingLikes = 20;
    _remainingHiddenLikes = 5;
    _usersWhoLiked = [];
    _hiddenLikesMap = {};
    _userInteractions = {};
    notifyListeners();
  }
}
