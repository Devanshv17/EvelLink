import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class EventProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  EventModel? _currentEvent;
  List<UserModel> _eventUsers = [];
  bool _isLoading = false;
  
  EventModel? get currentEvent => _currentEvent;
  List<UserModel> get eventUsers => _eventUsers;
  bool get isLoading => _isLoading;
  bool get hasJoinedEvent => _currentEvent != null;
  
  Future<bool> joinEvent(String eventId) async {
    if (_authService.currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final event = await _databaseService.getEvent(eventId);
      if (event != null) {
        await _databaseService.joinEvent(eventId, _authService.currentUser!.uid);
        _currentEvent = event;
        await _loadEventUsers();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error joining event: $e');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }
  
  Future<void> _loadEventUsers() async {
    if (_currentEvent == null || _authService.currentUser == null) return;
    
    try {
      _eventUsers = await _databaseService.getEventUsers(
        _currentEvent!.id, 
        _authService.currentUser!.uid
      );
      notifyListeners();
    } catch (e) {
      print('Error loading event users: $e');
    }
  }
  
  Future<void> refreshEventUsers() async {
    await _loadEventUsers();
  }
  
  void clearEvent() {
    _currentEvent = null;
    _eventUsers = [];
    notifyListeners();
  }
}
