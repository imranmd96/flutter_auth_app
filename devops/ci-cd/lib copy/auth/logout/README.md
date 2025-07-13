# Logout Module

This module provides a comprehensive logout functionality for the Flutter app, handling both API-based logout and force logout scenarios.

## Structure

```
lib/auth/logout/
├── services/
│   └── logout_service.dart          # Core logout service
├── providers/
│   └── logout_provider.dart         # State management for logout
├── widgets/
│   └── logout_button.dart           # Reusable logout button widgets
├── pages/
│   └── logout_page.dart             # Dedicated logout page
├── utils/
│   └── logout_utils.dart            # Utility functions
└── index.dart                       # Module exports
```

## Features

- **API-based logout**: Calls the backend logout endpoint and clears local state
- **Force logout**: Clears local state without API call (for token expiration)
- **Loading states**: Shows loading indicators during logout process
- **Error handling**: Graceful error handling with user feedback
- **Reusable widgets**: Pre-built logout buttons for different use cases
- **Confirmation dialogs**: Optional confirmation before logout
- **Navigation**: Automatic navigation to login page after logout

## Usage

### Basic Logout Button

```dart
import 'package:my_flutter_app/auth/logout/widgets/logout_button.dart';

// In your widget
LogoutButton(
  onLogoutComplete: () {
    // Additional cleanup if needed
  },
)
```

### Compact Logout Button

```dart
import 'package:my_flutter_app/auth/logout/widgets/logout_button.dart';

// In your app bar
AppBar(
  actions: [
    CompactLogoutButton(
      iconColor: Colors.white,
      tooltip: 'Logout',
    ),
  ],
)
```

### Programmatic Logout

```dart
import 'package:my_flutter_app/auth/logout/utils/logout_utils.dart';

// Simple logout
await LogoutUtils.performLogout(context, ref);

// Logout with confirmation
await LogoutUtils.logoutWithConfirmation(context, ref);

// Force logout (for token expiration)
await LogoutUtils.forceLogout(context, ref);
```

### Using the Provider Directly

```dart
import 'package:my_flutter_app/auth/logout/providers/logout_provider.dart';

// In your widget
final logoutNotifier = ref.read(logoutProvider.notifier);
final logoutState = ref.watch(logoutProvider);

// Perform logout
final success = await logoutNotifier.logout();

// Force logout
await logoutNotifier.forceLogout();
```

## Integration

The logout module is automatically integrated with:

- **Auth Interceptor**: Uses force logout when token refresh fails
- **Token Refresh Service**: Uses force logout when refresh token expires
- **Sidebar**: Uses LogoutButton in the drawer footer

## State Management

The logout provider manages the following state:

- `isLoading`: Whether logout is in progress
- `error`: Error message if logout fails
- `isLoggedOut`: Whether logout was successful

## Error Handling

The module handles various error scenarios:

- **API failures**: Still clears local state for security
- **Network errors**: Graceful fallback to force logout
- **Token expiration**: Automatic force logout
- **Navigation errors**: Safe navigation to login page

## Security Features

- **Local state clearing**: Always clears stored tokens
- **API call failure handling**: Clears local state even if API fails
- **Force logout**: Available for emergency logout scenarios
- **Token validation**: Checks token expiry before operations 