import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class LikesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<UserModel> _clearLikes = [];
  List<UserModel> _hiddenLikes = [];
  bool _isLoading = false;
  String? _error;

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

  Future<void> loadLikes(String eventId, String userId) async {
    _setLoading(true);
    _setError(null);

    try {
      // Get users who liked me (clear likes)
      final clearLikeUserIds = await _databaseService.getUsersWhoLikedMe(eventId, userId);
      final clearLikeUsers = <UserModel>[];
      
      for (String uid in clearLikeUserIds) {
        final user = await _databaseService.getUser(uid);
        if (user != null) clearLikeUsers.add(user);
      }
      
      // Get users who sent hidden likes
      final hiddenLikeUserIds = await _databaseService.getHiddenLikes(eventId, userId);
      final hiddenLikeUsers = <UserModel>[];
      
      for (String uid in hiddenLikeUserIds) {
        final user = await _databaseService.getUser(uid);
        if (user != null) hiddenLikeUsers.add(user);
      }

      _clearLikes = clearLikeUsers;
      _hiddenLikes = hiddenLikeUsers;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void resetLikes() {
    _clearLikes = [];
    _hiddenLikes = [];
    _error = null;
    notifyListeners();
  }
}
