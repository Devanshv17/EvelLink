import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class EventProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  EventModel? _currentEvent;
  List<UserModel> _eventParticipants = [];
  Map<String, dynamic>? _userInteractions;
  bool _isLoading = false;
  String? _error;

  EventModel? get currentEvent => _currentEvent;
  List<UserModel> get eventParticipants => _eventParticipants;
  Map<String, dynamic>? get userInteractions => _userInteractions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInEvent => _currentEvent != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> joinEvent(QRDataModel qrData, String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate QR data
      if (!qrData.isValid) {
        _setError('Event has expired or not yet started');
        return false;
      }

      // Get event details
      final event = await _databaseService.getEvent(qrData.eventId);
      if (event == null) {
        _setError('Event not found');
        return false;
      }

      // Join the event
      await _databaseService.joinEvent(qrData.eventId, userId);
      
      _currentEvent = event;
      await loadEventParticipants(userId);
      await loadUserInteractions(qrData.eventId, userId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEventParticipants(String currentUserId) async {
    if (_currentEvent == null) return;

    try {
      final participants = await _databaseService.getEventParticipants(
        _currentEvent!.eventId, 
        currentUserId,
      );
      _eventParticipants = participants;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUserInteractions(String eventId, String userId) async {
    try {
      final interactions = await _databaseService.getUserInteractions(eventId, userId);
      _userInteractions = interactions;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  List<UserModel> getFilteredParticipants() {
    if (_userInteractions == null) return _eventParticipants;

    final likes = (_userInteractions!['likes'] as Map<String, dynamic>?) ?? {};
    final passes = (_userInteractions!['passes'] as Map<String, dynamic>?) ?? {};
    final hiddenLikes = (_userInteractions!['hiddenLikes'] as Map<String, dynamic>?) ?? {};

    // Filter out users already interacted with
    return _eventParticipants.where((user) {
      return !likes.containsKey(user.uid) && 
             !passes.containsKey(user.uid) && 
             !hiddenLikes.containsKey(user.uid);
    }).toList();
  }

  Future<bool> swipeUser(String eventId, String currentUserId, String targetUserId, bool isLike, {bool isHidden = false}) async {
    try {
      if (isLike) {
        await _databaseService.recordLike(eventId, currentUserId, targetUserId, isHidden: isHidden);
      } else {
        await _databaseService.recordPass(eventId, currentUserId, targetUserId);
      }

      // Reload interactions
      await loadUserInteractions(eventId, currentUserId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void leaveEvent() {
    _currentEvent = null;
    _eventParticipants = [];
    _userInteractions = null;
    _error = null;
    notifyListeners();
  }
}
