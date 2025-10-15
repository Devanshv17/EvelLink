import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class MatchProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<MatchModel> _matches = [];
  Map<String, UserModel> _matchedUsers = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<MatchModel>>? _matchesSubscription;

  List<MatchModel> get matches => _matches;
  Map<String, UserModel> get matchedUsers => _matchedUsers;
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

  void listenToMatches(String userId) {
    _setLoading(true);
    _matchesSubscription?.cancel();
    _matchesSubscription = _databaseService.getUserMatchesStream(userId).listen((matches) async {
      _matches = matches;
      final userIds = matches.expand((match) => match.users).where((uid) => uid != userId).toSet();
      final users = <String, UserModel>{};
      for (String uid in userIds) {
        if (!_matchedUsers.containsKey(uid)) {
          final user = await _databaseService.getUser(uid);
          if (user != null) users[uid] = user;
        } else {
          users[uid] = _matchedUsers[uid]!;
        }
      }
      _matchedUsers = users;
      _setLoading(false);
      notifyListeners();
    }, onError: (e) {
      _setError(e.toString());
      _setLoading(false);
    });
  }

  UserModel? getMatchedUser(MatchModel match, String currentUserId) {
    final otherUserId = match.getOtherUserId(currentUserId);
    return _matchedUsers[otherUserId];
  }
  MatchModel? getMatchWithUser(String otherUserId) {
    try {
      return _matches.firstWhere(
            (match) => match.users.contains(otherUserId),
      );
    } catch (e) {
      return null;
    }
  }
  void clearMatches() {
    _matchesSubscription?.cancel();
    _matches = [];
    _matchedUsers = {};
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    super.dispose();
  }
}

