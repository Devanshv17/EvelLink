class EventModel {
  final String id;
  final String name;
  final DateTime endTime;
  final List<String> activeUsers;

  EventModel({
    required this.id,
    required this.name,
    required this.endTime,
    required this.activeUsers,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      name: map['name'] ?? '',
      endTime: map['endTime']?.toDate() ?? DateTime.now(),
      activeUsers: List<String>.from(map['activeUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'endTime': endTime,
      'activeUsers': activeUsers,
    };
  }
}
