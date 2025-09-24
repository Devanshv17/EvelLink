import 'dart:convert';
import '../models/models.dart';

class QRService {
  static QRDataModel? parseQRData(String qrData) {
    try {
      // Try parsing as JSON first
      final Map<String, dynamic> data = json.decode(qrData);
      return QRDataModel.fromMap(data);
    } catch (e) {
      // If JSON parsing fails, treat as simple event ID
      print('QR data parsing error: $e');
      return null;
    }
  }

  static String generateQRData(QRDataModel qrData) {
    return json.encode(qrData.toMap());
  }

  static bool isValidQRFormat(String qrData) {
    try {
      final data = json.decode(qrData);
      return data is Map<String, dynamic> && 
             data.containsKey('eventId') &&
             data.containsKey('eventName') &&
             data.containsKey('startTime') &&
             data.containsKey('endTime');
    } catch (e) {
      return false;
    }
  }
}
