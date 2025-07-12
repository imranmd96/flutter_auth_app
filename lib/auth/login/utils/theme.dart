import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF9C27B0);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  
  // Text Colors
  static const Color textLight = Color(0xFF757575);
  static const Color textDark = Color(0xFF212121);
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;
  static const Color textWhite54 = Colors.white54;
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFF00BCD4);
  
  // Login Specific Colors
  static const Color loginGradientStart = Color(0xFF2196F3);
  static const Color loginGradientEnd = Color(0xFF1976D2);
  static const Color loginFormBackground = Colors.white;
  static const Color loginFormShadow = Color(0x1A000000); // 10% opacity black
  static const Color loginErrorBackground = Color(0x1AFF0000); // 10% opacity red
  static const Color loginErrorBorder = Colors.red;
  static const Color loginInputBackground = Color(0x1AFFFFFF); // 10% opacity white
  static const Color loginInputBorder = Colors.white54;
  static const Color loginInputFocusBorder = Colors.white;
  
  // Profile Colors
  static const Color profileAvatarBackground = Color(0xFF2196F3);
  static const Color profileTextSecondary = Color(0xB3FFFFFF); // 70% opacity white
}

class AppTextStyles {
  // Login Page Text Styles
  static const TextStyle loginTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );
  
  static const TextStyle loginSubtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textWhite,
  );
  
  static const TextStyle loginButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle loginLink = TextStyle(
    color: AppColors.textWhite,
    fontSize: 16,
  );
  
  // Profile Text Styles
  static const TextStyle profileName = TextStyle(
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle profileEmail = TextStyle(
    color: AppColors.profileTextSecondary,
  );
  
  // Form Text Styles
  static const TextStyle formInput = TextStyle(
    color: AppColors.textWhite,
  );
  
  static const TextStyle formLabel = TextStyle(
    color: AppColors.textWhite70,
  );
  
  static const TextStyle formError = TextStyle(
    color: AppColors.error,
  );
}

class AppDecorations {
  // Login Page Decorations
  static const BoxDecoration loginBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.loginGradientStart,
        AppColors.loginGradientEnd,
      ],
    ),
  );
  
  static BoxDecoration loginFormCard = BoxDecoration(
    color: AppColors.loginFormBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: AppColors.loginFormShadow,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration loginErrorContainer = BoxDecoration(
    color: AppColors.loginErrorBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.loginErrorBorder),
  );
  
  // Form Input Decorations
  static const InputDecoration formInputDecoration = InputDecoration(
    filled: true,
    fillColor: AppColors.loginInputBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.loginInputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.loginInputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.loginInputFocusBorder),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: AppColors.error),
    ),
    errorStyle: TextStyle(color: AppColors.error),
  );
}

class AppSizes {
  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;
  
  // Component Sizes
  static const double iconSizeLarge = 60;
  static const double iconSizeMedium = 40;
  static const double iconSizeSmall = 24;
  static const double buttonHeight = 48;
  static const double avatarRadius = 40;
  static const double borderRadius = 8;
  static const double borderRadiusLarge = 12;
  
  // Padding
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingAll = EdgeInsets.all(24);
  static const EdgeInsets paddingSmall = EdgeInsets.all(12);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: Color(0xFF1E88E5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
} 