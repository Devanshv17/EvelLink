import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String qrData;
  final List<String> activeUsers;
  final DateTime createdAt;
  final String? imageUrl;

  EventModel({
    required this.eventId,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.qrData,
    required this.activeUsers,
    required this.createdAt,
    this.imageUrl,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isExpired {
    return DateTime.now().isAfter(endTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'name': name,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'qrData': qrData,
      'activeUsers': activeUsers,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EventModel(
      eventId: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(hours: 4)),
      location: map['location'] ?? '',
      qrData: map['qrData'] ?? '',
      activeUsers: List<String>.from(map['activeUsers'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  EventModel copyWith({
    String? eventId,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? qrData,
    List<String>? activeUsers,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      qrData: qrData ?? this.qrData,
      activeUsers: activeUsers ?? this.activeUsers,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
