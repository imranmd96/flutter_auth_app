class ApiConfig {
  // API Endpoints
  static const String devBaseUrl = 'http://localhost:3000';
  static const String userServiceUrl = '$devBaseUrl/api/users';
  static const String restaurantServiceUrl = '$devBaseUrl/api/restaurants';
  static const String orderServiceUrl = '$devBaseUrl/api/orders';
  static const String adminServiceUrl = '$devBaseUrl/api/admin';
///api/auth
///   baseUrl: '${ApiConfig.devBaseUrl}/api', ref: ref);
//http://localhost:3000
  // Auth endpoints  '$authServiceUrl/login';
  static String get authServiceUrl => '/auth';
  static final String login = '$authServiceUrl/login';
  static const String refreshToken = '/refresh-token';
  static final String register = '$authServiceUrl/register';
  static final String logout = '$authServiceUrl/logout';
  static final String me = '$authServiceUrl/me';
  static final String updateProfile = '$authServiceUrl/profile';
  static final String updateProfilePicture = '$authServiceUrl/profile/picture';
//http://localhost:3000/auth/refresh-token 
  // API Endpoints
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String profile = '/api/auth/profile';
  static const String changePassword = '/api/auth/change-password';
  static const String searchRestaurants = '/search/restaurants';
  static const String searchDishes = '/search/dishes';
  static const String loyaltyPoints = '/loyalty/points';
  static const String loyaltyRewards = '/loyalty/rewards';
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/{id}/read';
  static const String paymentMethods = '/payments/methods';
  static const String processPayment = '/payments/process';
  static const String userAnalytics = '/analytics/user';
  static const String restaurantAnalytics = '/analytics/restaurant';

  // Restaurant endpoints
  static String get bookingServiceUrl => devBaseUrl;
  static String get menuServiceUrl => '$devBaseUrl/menu';
  static String get reviewServiceUrl => '$devBaseUrl/reviews';
  static String get loyaltyServiceUrl => '$devBaseUrl/loyalty';
  static String get geolocationServiceUrl => '$devBaseUrl/geolocation';
  static String get mediaServiceUrl => '$devBaseUrl/media';
  static String get chatServiceUrl => '$devBaseUrl/chat';
  static String get inventoryServiceUrl => '$devBaseUrl/inventory';
  
  // Restaurant endpoints
  static const String restaurants = '';  // Empty string since base URL already includes /restaurants
  static const String restaurantDetails = '/{id}';
  static const String restaurantMenu = '/{id}/menu';
  
  // Booking endpoints
  static const String bookings = '/bookings';
  static const String availableTables = '/bookings/tables/available';
  static const String waitlist = '/bookings/waitlist';
  
  // Menu endpoints
  static const String dishes = '/menu/dishes';
  static const String categories = '/menu/categories';
  
  // Review endpoints
  static const String restaurantReviews = '/reviews/restaurant/{id}';
  
  // Service URLs - Using API Gateway for all services
  static String get notificationServiceUrl => '$devBaseUrl/api/notifications';
  static String get fileServiceUrl => '$devBaseUrl/api/files';
  static String get searchServiceUrl => '$devBaseUrl/api/search';
  static String get recommendationServiceUrl => '$devBaseUrl/api/recommendations';
  static String get analyticsServiceUrl => '$devBaseUrl/api/analytics';
  static String get paymentServiceUrl => '$devBaseUrl/api/payments';
  static String get subscriptionServiceUrl => '$devBaseUrl/api/subscriptions';
  static String get contentServiceUrl => '$devBaseUrl/api/content';
  static String get interactionServiceUrl => '$devBaseUrl/api/interactions';
  static String get moderationServiceUrl => '$devBaseUrl/api/moderation';
  static String get reportingServiceUrl => '$devBaseUrl/api/reports';
  static String get feedbackServiceUrl => '$devBaseUrl/api/feedback';
  static String get supportServiceUrl => '$devBaseUrl/api/support';
  static String get apiGatewayUrl => devBaseUrl;
} 