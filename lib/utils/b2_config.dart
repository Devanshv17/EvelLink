class B2Config {
  // Replace with your actual credentials from Step 2
  static const String keyId = '005e83ae236ce0e0000000002'; // Your Key ID
  static const String applicationKey = 'K005N6GMbr9sO/ja3Vqo7C8PXCCej7Y'; // Your Application Key
  static const String bucketName = 'EveLink'; // Your bucket name from Step 3

  // Optional: Custom domain (leave as null for default)
  static const String? customDomain = null;

  static const String userPhotosPrefix = 'user_photos/';
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  static const List<String> supportedFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];
}