class DashboardResponse {
  final bool success;
  final DashboardData data;

  DashboardResponse({
    required this.success,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] as bool,
      data: DashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class DashboardData {
  final String message;
  final DashboardStats stats;

  DashboardData({
    required this.message,
    required this.stats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      message: json['message'] as String,
      stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }
}

class DashboardStats {
  final int? users;
  final int? restaurants;
  final int? orders;
  final int? bookings;
  final int? favorites;

  DashboardStats({
    this.users,
    this.restaurants,
    this.orders,
    this.bookings,
    this.favorites,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      users: json['users'] as int?,
      restaurants: json['restaurants'] as int?,
      orders: json['orders'] as int?,
      bookings: json['bookings'] as int?,
      favorites: json['favorites'] as int?,
    );
  }
} 