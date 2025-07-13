import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking.dart';

class BookingService {
  final String baseUrl = ApiConfig.bookingServiceUrl;

  Future<Booking> createBooking({
    required String restaurantId,
    required String tableId,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required int partySize,
    String? specialRequests,
    required String contactPhone,
    String? contactEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token here
        },
        body: jsonEncode({
          'restaurant_id': restaurantId,
          'table_id': tableId,
          'booking_date': bookingDate.toIso8601String(),
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'party_size': partySize,
          'special_requests': specialRequests,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
        }),
      );

      if (response.statusCode == 201) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create booking: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  Future<List<Table>> getAvailableTables({
    required String restaurantId,
    required DateTime date,
    required int partySize,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tables?restaurant_id=$restaurantId&date=${date.toIso8601String()}&min_capacity=$partySize'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token here
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['items'];
        return data.map((json) => Table.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get tables: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting tables: $e');
    }
  }

  Future<Booking> joinWaitlist({
    required String restaurantId,
    required int partySize,
    required DateTime date,
    required DateTime time,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings/waitlist'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token here
        },
        body: jsonEncode({
          'restaurant_id': restaurantId,
          'party_size': partySize,
          'date': date.toIso8601String(),
          'time': time.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return Booking.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to join waitlist: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error joining waitlist: $e');
    }
  }
} 