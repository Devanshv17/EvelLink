import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class MatchModel {
  final String matchId;
  final List<String> users;
  final String eventId;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;

  // This field is for UI purposes only and won't be saved to Firestore.
  UserModel? matchedUser;

  MatchModel({
    required this.matchId,
    required this.users,
    required this.eventId,
    required this.matchedAt,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    this.matchedUser,
  });

  String getOtherUserId(String currentUserId) {
    return users.firstWhere((uid) => uid != currentUserId);
  }

  factory MatchModel.fromMap(Map<String, dynamic> map, String docId) {
    return MatchModel(
      matchId: docId,
      users: List<String>.from(map['users'] ?? []),
      eventId: map['eventId'] ?? '',
      matchedAt: (map['matchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'],
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }
}