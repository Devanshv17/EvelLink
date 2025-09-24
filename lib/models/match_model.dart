import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final List<String> users;
  final String eventId;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;

  MatchModel({
    required this.matchId,
    required this.users,
    required this.eventId,
    required this.matchedAt,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  String getOtherUserId(String currentUserId) {
    return users.firstWhere((uid) => uid != currentUserId);
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'users': users,
      'eventId': eventId,
      'matchedAt': Timestamp.fromDate(matchedAt),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'unreadCount': unreadCount,
    };
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
