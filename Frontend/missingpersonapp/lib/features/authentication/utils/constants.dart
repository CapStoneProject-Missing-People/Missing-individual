class Constants {
  static String postUri = 'http://192.168.188.102:4000';
  static String faceApi = 'http://192.168.188.102:6000';
  static String wsUri = '192.168.188.102:4000';

  // Token-related constants
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refresh_token';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';
  static const String lastLoginKey = 'last_login';

  // Token expiry times (matching backend)
  static const int accessTokenExpiryMinutes = 15;
  static const int refreshTokenExpiryDays = 7;

  // Auto-refresh threshold (in minutes)
  static const int tokenRefreshThreshold = 2; // Refresh 2 minutes before expiry
  static const String fcmTokenKey = 'fcm_token';
}
