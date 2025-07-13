
enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow
}

enum BookingType {
  regular,
  special,
  group
}

class Booking {
  final String id;
  final String restaurantId;
  final String customerId;
  final String tableId;
  final BookingType type;
  final int partySize;
  final DateTime bookingDate;
  final DateTime startTime;
  final DateTime endTime;
  final String? specialRequests;
  final String contactPhone;
  final String? contactEmail;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.restaurantId,
    required this.customerId,
    required this.tableId,
    required this.type,
    required this.partySize,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.specialRequests,
    required this.contactPhone,
    this.contactEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      customerId: json['customer_id'],
      tableId: json['table_id'],
      type: BookingType.values.firstWhere(
        (e) => e.toString().split('.').last == json['booking_type'],
      ),
      partySize: json['party_size'],
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      specialRequests: json['special_requests'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'customer_id': customerId,
      'table_id': tableId,
      'booking_type': type.toString().split('.').last,
      'party_size': partySize,
      'booking_date': bookingDate.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'special_requests': specialRequests,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Table {
  final String id;
  final String restaurantId;
  final String tableNumber;
  final int capacity;
  final String status;
  final String? location;
  final List<String> features;
  final DateTime createdAt;
  final DateTime updatedAt;

  Table({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.location,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
      status: json['status'],
      location: json['location'],
      features: List<String>.from(json['features']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
      'location': location,
      'features': features,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 