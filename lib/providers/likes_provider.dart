import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class LikesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<UserModel> _clearLikes = [];
  List<UserModel> _hiddenLikes = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<String>>? _clearLikesSubscription;
  StreamSubscription<List<String>>? _hiddenLikesSubscription;

  List<UserModel> get clearLikes => _clearLikes;
  List<UserModel> get hiddenLikes => _hiddenLikes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalLikes => _clearLikes.length + _hiddenLikes.length;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void listenToLikes(String eventId, String userId) {
    _setLoading(true);
    _setError(null);

    _clearLikesSubscription?.cancel();
    _clearLikesSubscription = _databaseService.getUsersWhoLikedMeStream(eventId, userId).listen((userIds) async {
      final users = <UserModel>[];
      for (String uid in userIds) {
        final user = await _databaseService.getUser(uid);
        if (user != null) users.add(user);
      }
      _clearLikes = users;
      _setLoading(false);
      notifyListeners();
    }, onError: (e) {
      _setError(e.toString());
      _setLoading(false);
    });

    _hiddenLikesSubscription?.cancel();
    _hiddenLikesSubscription = _databaseService.getHiddenLikesStream(eventId, userId).listen((userIds) async {
      final users = <UserModel>[];
      for (String uid in userIds) {
        final user = await _databaseService.getUser(uid);
        if (user != null) users.add(user);
      }
      _hiddenLikes = users;
      notifyListeners();
    }, onError: (e) {
      _setError(e.toString());
      _setLoading(false);
    });
  }

  void resetLikes() {
    _clearLikesSubscription?.cancel();
    _hiddenLikesSubscription?.cancel();
    _clearLikes = [];
    _hiddenLikes = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _clearLikesSubscription?.cancel();
    _hiddenLikesSubscription?.cancel();
    super.dispose();
  }
}

