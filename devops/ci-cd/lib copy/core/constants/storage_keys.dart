/// Enum for storage keys used across the app
enum StorageKeys {
  /// Key for storing authentication state
  authState('auth_state'),
  
  /// Key for storing sidebar state
  sidebarState('sidebar_auth_state');

  final String value;
  const StorageKeys(this.value);
} 