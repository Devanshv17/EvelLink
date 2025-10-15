import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class AllEventsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<List<EventModel>>? _eventsSubscription;

  List<EventModel> _allEvents = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedTag;

  List<EventModel> get allEvents => _allEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedTag => _selectedTag;

  List<EventModel> get filteredEvents {
    List<EventModel> events = _allEvents;

    if (_searchQuery.isNotEmpty) {
      events = events.where((event) {
        final query = _searchQuery.toLowerCase();
        return event.name.toLowerCase().contains(query) ||
            event.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    if (_selectedTag != null) {
      events = events.where((event) => event.tags.contains(_selectedTag)).toList();
    }

    return events;
  }

  Set<String> get uniqueTags {
    return _allEvents.expand((event) => event.tags).toSet();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void listenToAllEvents() {
    _setLoading(true);
    _eventsSubscription?.cancel();
    _eventsSubscription = _databaseService.getAllEventsStream().listen(
          (events) {
        _allEvents = events;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void stopListening() {
    _eventsSubscription?.cancel();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}