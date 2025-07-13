/// Constants and validation for user types
class UserType {
  // Constants
  static const String admin = 'admin';
  static const String user = 'user';
  static const String guest = 'guest';

  /// List of all valid user types
  static const List<String> validTypes = [admin, user, guest];

  /// Default user type
  static const String defaultType = user;

  /// Check if a user type is valid
  static bool isValidType(String type) {
    return validTypes.contains(type);
  }

  /// Validate user type and return default if invalid
  static String validateType(String? type) {
    if (type == null || !isValidType(type)) {
      return defaultType;
    }
    return type;
  }

  /// Get display name for user type
  static String getDisplayName(String type) {
    switch (type) {
      case admin:
        return 'admin';
      case guest:
        return 'Guest';
      default:
        return 'User';
    }
  }

  /// Check if type is admin
  static bool isAdmin(String type) => type == admin;

  /// Check if type is regular user
  static bool isRegularUser(String type) => type == user;

  /// Check if type is guest
  static bool isGuest(String type) => type == guest;
} 