// lib/services/qr_service.dart

import 'dart:convert';
import '../models/models.dart'; // Make sure this path is correct for your project structure

/// A utility class for handling QR code data operations.
class QRService {
  /// Parses the raw string data from a QR code into a [QRDataModel].
  ///
  /// Returns a [QRDataModel] instance on success.
  /// Returns `null` if the data is not valid JSON or if it's missing required fields,
  /// allowing the UI to show an "Invalid QR code" error.
  static QRDataModel? parseQRData(String qrData) {
    try {
      // Decode the raw string into a JSON map.
      final Map<String, dynamic> data = json.decode(qrData);

      // Use the model's strict factory constructor to create an instance.
      // This will throw an exception if the data format is incorrect.
      return QRDataModel.fromMap(data);
    } catch (e) {
      // If any error occurs during decoding or model creation, the QR format is invalid.
      print('Failed to parse QR data: $e');
      return null;
    }
  }

  /// Generates a JSON string from a [QRDataModel] instance.
  ///
  /// Useful for creating QR codes from event data within the app.
  static String generateQRData(QRDataModel qrData) {
    return json.encode(qrData.toMap());
  }

  /// A quick check to see if a string has a valid QR format.
  ///
  /// This is an alternative to `parseQRData` if you only need to validate
  /// the format without creating a full model object.
  static bool isValidQRFormat(String qrData) {
    try {
      final data = json.decode(qrData);
      return data is Map<String, dynamic> &&
          data.containsKey('eventId') &&
          data.containsKey('eventName') &&
          data.containsKey('startTime') &&
          data.containsKey('endTime') &&
          data.containsKey('location');
    } catch (e) {
      return false;
    }
  }
}