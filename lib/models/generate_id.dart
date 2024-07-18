class UserId {
  static String? _userId;
  static String? _authToken;

  UserId(String userId) {
    setUserId(userId);
  }

  static void setUserId(String userIdGenerated) {
    _userId = userIdGenerated;
  }

  static String? get getUserId => _userId;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static String? get getAuthToken => _authToken;
}
