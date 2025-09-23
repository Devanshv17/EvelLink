class AppConstants {
  // App configuration
  static const String appName = 'FestiveLink';
  static const String appDescription = 'Event-based dating app for college cultural festivals';
  
  // User limits
  static const int maxLikes = 20;
  static const int maxHiddenLikes = 5;
  static const int maxPhotos = 4;
  static const int minPhotos = 1;
  static const int maxBioLength = 150;
  static const int minAge = 18;
  
  // QR Code configuration
  static const String eventIdPrefix = 'CULTFEST2025_';
  
  // Available interests
  static const List<String> availableInterests = [
    'Music',
    'Dance', 
    'Tech',
    'Art',
    'Gaming',
    'Sports',
    'Reading',
    'Movies',
    'Photography',
    'Travel',
    'Food',
    'Fashion',
    'Fitness',
    'Nature',
    'Comedy',
  ];
  
  // Firebase collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String interactionsCollection = 'interactions';
  static const String matchesCollection = 'matches';
  static const String chatsCollection = 'chats';
  
  // Storage paths
  static const String userPhotosPath = 'user_photos';
}
