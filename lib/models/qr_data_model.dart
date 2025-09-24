class QRDataModel {
  final String eventId;
  final String eventName;
  final DateTime startTime;
  final DateTime endTime;
  final String location;

  QRDataModel({
    required this.eventId,
    required this.eventName,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
    };
  }

  factory QRDataModel.fromMap(Map<String, dynamic> map) {
    return QRDataModel(
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(map['endTime'] ?? DateTime.now().add(Duration(hours: 4)).toIso8601String()),
      location: map['location'] ?? '',
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}
