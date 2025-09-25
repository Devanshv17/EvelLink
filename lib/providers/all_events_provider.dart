import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

class AllEventsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  static const String _currentEventKey = 'current_event_id';

  EventModel? _currentEvent;
  List<UserModel> _eventParticipants = [];
  Map<String, dynamic>? _userInteractions;
  List<EventModel> _allEvents = [];
  bool _isLoading = false;
  String? _error;

  EventModel? get currentEvent => _currentEvent;
  List<UserModel> get eventParticipants => _eventParticipants;
  Map<String, dynamic>? get userInteractions => _userInteractions;
  List<EventModel> get allEvents => _allEvents;
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

  Future<void> fetchAllEvents() async {
    _setLoading(true);
    try {
      _allEvents = await _databaseService.getAllEvents();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> tryRejoinPreviousEvent(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final eventId = prefs.getString(_currentEventKey);

    if (eventId == null) {
      return false;
    }

    final event = await _databaseService.getEvent(eventId);
    if (event != null && event.isActive) {
      final qrData = QRDataModel(
        eventId: event.eventId,
        eventName: event.name,
        startTime: event.startTime,
        endTime: event.endTime,
        location: event.location,
      );
      await joinEvent(qrData, userId, isRejoining: true);
      return true;
    } else {
      await _clearPersistedEvent();
      return false;
    }
  }

  Future<bool> joinEvent(QRDataModel qrData, String userId, {bool isRejoining = false}) async {
    if (!isRejoining) {
      _setLoading(true);
    }
    _setError(null);

    try {
      if (!qrData.isValid) {
        _setError('Event has expired or not yet started');
        if (!isRejoining) _setLoading(false);
        return false;
      }

      final event = await _databaseService.getEvent(qrData.eventId);
      if (event == null) {
        _setError('Event not found');
        if (!isRejoining) _setLoading(false);
        return false;
      }

      await _databaseService.joinEvent(qrData.eventId, userId);

      _currentEvent = event;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentEventKey, qrData.eventId);

      await loadEventParticipants(userId);
      await loadUserInteractions(qrData.eventId, userId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      if (!isRejoining) {
        _setLoading(false);
      }
    }
  }

  Future<void> _clearPersistedEvent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentEventKey);
  }

  Future<void> leaveEvent() async {
    _currentEvent = null;
    _eventParticipants = [];
    _userInteractions = null;
    _error = null;
    await _clearPersistedEvent();
    notifyListeners();
  }

  Future<void> loadEventParticipants(String currentUserId) async {
    if (_currentEvent == null) return;

    _setLoading(true);
    try {
      _eventParticipants = await _databaseService.getEventParticipants(
        _currentEvent!.eventId,
        currentUserId,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserInteractions(String eventId, String userId) async {
    try {
      _userInteractions = await _databaseService.getUserInteractions(eventId, userId);
      notifyListeners();
    } catch (e) {
      print('Error loading user interactions: $e');
    }
  }

  List<UserModel> getFilteredParticipants() {
    if (_userInteractions == null) {
      return _eventParticipants;
    }

    final Set<String> likedIds = _userInteractions!['likes']?.keys.toSet().cast<String>() ?? {};
    final Set<String> hiddenLikedIds = _userInteractions!['hiddenLikes']?.keys.toSet().cast<String>() ?? {};
    final Set<String> passedIds = _userInteractions!['passes']?.keys.toSet().cast<String>() ?? {};

    final interactedIds = {...likedIds, ...hiddenLikedIds, ...passedIds};

    return _eventParticipants
        .where((p) => !interactedIds.contains(p.uid))
        .toList();
  }

  Future<bool> swipeUser(String eventId, String currentUserId, String targetUserId, bool isLike, {bool isHidden = false}) async {
    try {
      if (isLike) {
        final isMatch = await _databaseService.recordLike(eventId, currentUserId, targetUserId, isHidden: isHidden);
        await loadUserInteractions(eventId, currentUserId);
        return isMatch;
      } else {
        await _databaseService.recordPass(eventId, currentUserId, targetUserId);
        await loadUserInteractions(eventId, currentUserId);
        return false;
      }
    } catch (e) {
      print('Error swiping user: $e');
      _setError('Could not perform action. Please try again.');
      return false;
    }
  }
}

