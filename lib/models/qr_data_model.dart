// lib/models/qr_data_model.dart

import 'package:flutter/foundation.dart';

/// A data model representing the structured information from an event QR code.
///
/// This class is immutable, meaning its properties cannot be changed after creation.
@immutable
class QRDataModel {
  final String eventId;
  final String eventName;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  const QRDataModel({
    required this.eventId,
    required this.eventName,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  /// A factory constructor for creating a new [QRDataModel] instance from a map.
  ///
  /// This constructor is strict and will throw a [FormatException] if any of the
  /// required keys ('eventId', 'eventName', 'startTime', 'endTime', 'location')
  /// are missing or have null values in the map. This ensures data integrity.
  factory QRDataModel.fromMap(Map<String, dynamic> map) {
    // Check for the presence of all required keys to ensure the QR code is valid.
    final requiredKeys = ['eventId', 'eventName', 'startTime', 'endTime', 'location'];
    for (final key in requiredKeys) {
      if (map[key] == null) {
        throw FormatException("Missing required key in QR data: '$key'");
      }
    }

    return QRDataModel(
      eventId: map['eventId'],
      eventName: map['eventName'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      location: map['location'],
    );
  }

  /// Converts the [QRDataModel] instance into a map.
  ///
  /// Dates are converted to ISO 8601 string format, which is ideal for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
    };
  }

  /// Checks if the event is currently active.
  ///
  /// **IMPORTANT**: It compares the current time in UTC with the event's start
  /// and end times to avoid timezone-related issues.
  bool get isValid {
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.isAfter(startTime) && nowUtc.isBefore(endTime);
  }
}