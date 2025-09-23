import 'package:flutter/services.dart';

class QRService {
  static const String _eventIdPrefix = 'CULTFEST2025_';

  static bool isValidEventQR(String qrData) {
    return qrData.startsWith(_eventIdPrefix) && qrData.length > _eventIdPrefix.length;
  }

  static String? extractEventId(String qrData) {
    if (isValidEventQR(qrData)) {
      return qrData;
    }
    return null;
  }

  static Future<void> hapticFeedback() async {
    await HapticFeedback.mediumImpact();
  }

  // For testing purposes - generates sample QR codes
  static List<String> getSampleEventIds() {
    return [
      'CULTFEST2025_STARLIGHT_BALL',
      'CULTFEST2025_ROCK_CONCERT',
      'CULTFEST2025_DANCE_NIGHT',
      'CULTFEST2025_CULTURAL_EVENING',
      'CULTFEST2025_MUSIC_FESTIVAL',
    ];
  }
}
