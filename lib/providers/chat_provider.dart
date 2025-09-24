import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'dart:async';

class ChatProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  List<MessageModel> get messages => _messages;
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

  void startListeningToMessages(String matchId) {
    _messagesSubscription?.cancel();
    
    _messagesSubscription = _databaseService.getChatMessages(matchId).listen(
      (messages) {
        _messages = messages;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  Future<bool> sendMessage(String matchId, String senderId, String text) async {
    if (text.trim().isEmpty) return false;

    try {
      await _databaseService.sendMessage(matchId, senderId, text.trim());
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void stopListeningToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  void clearMessages() {
    stopListeningToMessages();
    _messages = [];
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListeningToMessages();
    super.dispose();
  }
}
