class MatchModel {
  final String id;
  final List<String> users;
  final DateTime createdAt;
  final String? lastMessage;

  MatchModel({
    required this.id,
    required this.users,
    required this.createdAt,
    this.lastMessage,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      users: List<String>.from(map['users'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
    };
  }
}
