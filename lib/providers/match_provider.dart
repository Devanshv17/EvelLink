import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class MatchProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<MatchModel> _matches = [];
  Map<String, UserModel> _matchedUsers = {};
  bool _isLoading = false;
  String? _error;

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

  Future<void> loadMatches(String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      final matches = await _databaseService.getUserMatches(userId);
      _matches = matches;

      // Load user profiles for matched users
      final userIds = matches
          .expand((match) => match.users)
          .where((uid) => uid != userId)
          .toSet();

      final users = <String, UserModel>{};
      for (String uid in userIds) {
        final user = await _databaseService.getUser(uid);
        if (user != null) users[uid] = user;
      }

      _matchedUsers = users;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  UserModel? getMatchedUser(MatchModel match, String currentUserId) {
    final otherUserId = match.getOtherUserId(currentUserId);
    return _matchedUsers[otherUserId];
  }

  void clearMatches() {
    _matches = [];
    _matchedUsers = {};
    _error = null;
    notifyListeners();
  }
}
