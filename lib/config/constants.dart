class AppConstants {
  // Error Messages
  static const String defaultErrorMessage =
      'An error occurred. Please try again.';
  static const String networkErrorMessage =
      'No internet connection. Please check your network settings.';
  static const String permissionErrorMessage =
      'Permission denied. Please grant the required permissions.';
  static const String locationErrorMessage =
      'Unable to access location. Please enable location services.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';
  static const String validationErrorMessage =
      'Please check your input and try again.';
  static const String databaseErrorMessage =
      'Database error occurred. Please try again.';
  static const String storageErrorMessage =
      'Storage error occurred. Please try again.';
  static const String notificationErrorMessage =
      'Failed to handle notification. Please try again.';
  static const String bookingErrorMessage =
      'Failed to process booking. Please try again.';
  static const String tripErrorMessage =
      'Failed to process trip. Please try again.';
  static const String vehicleErrorMessage =
      'Failed to process vehicle information. Please try again.';
  static const String messageErrorMessage =
      'Failed to process message. Please try again.';

  // Page Transition Duration
  static const int pageTransitionDuration = 300; // milliseconds

  // Snackbar Duration
  static const int snackBarDuration = 3000; // milliseconds

  // API Timeouts
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Cache Duration
  static const int cacheDuration = 7; // days

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;
  static const int vehicleNumberLength = 10;

  // File Size Limits (in bytes)
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  // Location
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  static const int locationUpdateInterval = 10000; // milliseconds
  static const double minimumLocationAccuracy = 50.0; // meters

  // Map
  static const double defaultZoomLevel = 15.0;
  static const double maxZoomLevel = 20.0;
  static const double minZoomLevel = 5.0;

  // Session
  static const int sessionTimeout = 30; // minutes
  static const int tokenRefreshThreshold = 5; // minutes

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Currency
  static const String currencySymbol = '\$';
  static const int decimalPlaces = 2;

  // Retry
  static const int maxRetryAttempts = 3;
  static const int retryDelayFactor = 2; // seconds

  // Animation
  static const int animationDuration = 300; // milliseconds
  static const double animationScale = 1.2;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  static const double defaultIconSize = 24.0;
  static const double defaultSpacing = 8.0;
}
