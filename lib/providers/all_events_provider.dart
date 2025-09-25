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

  List<EventModel> get allEvents => _allEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  void stopListening() {
    _eventsSubscription?.cancel();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
