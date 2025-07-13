import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/booking.dart' as booking_models;
import 'package:my_flutter_app/services/booking_service.dart';

import '../constants/book_table_constants.dart';
import '../models/layout_option.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

final bookTableControllerProvider = StateNotifierProvider<BookTableController, BookTableState>((ref) {
  return BookTableController(ref);
});

class BookTableState {
  final String selectedDate;
  final String selectedTime;
  final int selectedPeople;
  final String selectedLayout;
  final List<booking_models.Table> availableTables;
  final bool isLoading;
  final String? error;

  BookTableState({
    this.selectedDate = '',
    this.selectedTime = '',
    this.selectedPeople = 2,
    this.selectedLayout = '',
    this.availableTables = const [],
    this.isLoading = false,
    this.error,
  });

  BookTableState copyWith({
    String? selectedDate,
    String? selectedTime,
    int? selectedPeople,
    String? selectedLayout,
    List<booking_models.Table>? availableTables,
    bool? isLoading,
    String? error,
  }) {
    return BookTableState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedPeople: selectedPeople ?? this.selectedPeople,
      selectedLayout: selectedLayout ?? this.selectedLayout,
      availableTables: availableTables ?? this.availableTables,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookTableController extends StateNotifier<BookTableState> {
  final Ref ref;
  late final BookingService _bookingService;

  BookTableController(this.ref) : super(BookTableState(
    selectedDate: BookTableConstants.defaultDates[0],
    selectedTime: BookTableConstants.defaultTimes[2],
    selectedPeople: 2,
    selectedLayout: BookTableConstants.layoutOptions[0]['title'] as String,
  )) {
    _bookingService = ref.read(bookingServiceProvider);
    _fetchAvailableTables();
  }

  List<LayoutOption> get layoutOptions => BookTableConstants.layoutOptions
      .map((option) => LayoutOption.fromMap(option))
      .toList();

  void selectDate(String date) {
    state = state.copyWith(selectedDate: date);
    _fetchAvailableTables();
  }

  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
    _fetchAvailableTables();
  }

  void selectPeople(int count) {
    state = state.copyWith(selectedPeople: count);
    _fetchAvailableTables();
  }

  void selectLayout(String layout) {
    state = state.copyWith(selectedLayout: layout);
  }

  Future<void> _fetchAvailableTables() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final date = DateTime.parse(state.selectedDate);
      final time = DateTime.parse('${state.selectedDate}T${state.selectedTime}');
      
      final tables = await _bookingService.getAvailableTables(
        restaurantId: 'current_restaurant_id', // Replace with actual restaurant ID
        date: date,
        partySize: state.selectedPeople,
      );
      
      state = state.copyWith(availableTables: tables, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createBooking({
    required String tableId,
    String? specialRequests,
    required String contactPhone,
    String? contactEmail,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final date = DateTime.parse(state.selectedDate);
      final startTime = DateTime.parse('${state.selectedDate}T${state.selectedTime}');
      final endTime = startTime.add(const Duration(hours: 2)); // Default 2-hour booking

      await _bookingService.createBooking(
        restaurantId: 'current_restaurant_id', // Replace with actual restaurant ID
        tableId: tableId,
        bookingDate: date,
        startTime: startTime,
        endTime: endTime,
        partySize: state.selectedPeople,
        specialRequests: specialRequests,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
      );

      await _fetchAvailableTables();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> joinWaitingList() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final date = DateTime.parse(state.selectedDate);
      final time = DateTime.parse('${state.selectedDate}T${state.selectedTime}');

      await _bookingService.joinWaitlist(
        restaurantId: 'current_restaurant_id', // Replace with actual restaurant ID
        partySize: state.selectedPeople,
        date: date,
        time: time,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }
} 