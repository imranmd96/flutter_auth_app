/// DateTimeSelector
///
/// A section widget for selecting date, time, and number of people as chips.
/// Used in BookTablePage to allow users to pick their reservation details.
///
/// Usage:
///   - Pass lists of dates and times, the selected values, and callbacks for selection.
///   - Designed for horizontal scrolling and visual clarity.

import 'package:flutter/material.dart';
import '../components/date_time_chip.dart';
import '../constants/book_table_constants.dart';

class DateTimeSelector extends StatelessWidget {
  final List<String> dates;
  final List<String> times;
  final String selectedDate;
  final String selectedTime;
  final int selectedPeople;
  final Function(String) onDateSelected;
  final Function(String) onTimeSelected;
  final Function(int) onPeopleSelected;

  const DateTimeSelector({
    super.key,
    required this.dates,
    required this.times,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedPeople,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onPeopleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Date chips
          ...dates.map((date) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DateTimeChip(
              label: date,
              isSelected: date == selectedDate,
              onTap: () => onDateSelected(date),
              color: BookTableConstants.orange,
            ),
          )),
          // Time chips
          ...times.map((time) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DateTimeChip(
              label: time,
              isSelected: time == selectedTime,
              onTap: () => onTimeSelected(time),
              color: BookTableConstants.pink,
            ),
          )),
          // People chips (1-8)
          ...List.generate(8, (i) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DateTimeChip(
              label: '${i + 1} people',
              isSelected: (i + 1) == selectedPeople,
              onTap: () => onPeopleSelected(i + 1),
              color: BookTableConstants.pink,
            ),
          )),
        ],
      ),
    );
  }
} 