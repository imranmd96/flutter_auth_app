/// BookTablePage
///
/// This page allows users to book a table at a restaurant.
/// It features:
///   - Date, time, and people selection using visually styled chips
///   - A segmented control for choosing between 2D, 3D, and VR restaurant layouts
///   - A dynamic, visually rich restaurant layout illustration that updates with the selected layout
///   - A prominent 'Join Waiting List' button
///
/// Usage:
///   - Import and use as a route/page in your app for table booking flows.
///   - The page is fully modular and uses Provider for state management.
///
/// Example:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const BookTablePage()));

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/table_preview.dart';
import 'components/waiting_list_button.dart';
import 'constants/book_table_constants.dart';
import 'controllers/book_table_controller.dart';
import 'widgets/date_time_selector.dart';
import 'widgets/layout_selector.dart';

class BookTablePage extends ConsumerWidget {
  const BookTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomPadding;

    final state = ref.watch(bookTableControllerProvider);
    final controller = ref.read(bookTableControllerProvider.notifier);

    return Scaffold(
      backgroundColor: BookTableConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Book a Table',
          style: TextStyle(
            color: BookTableConstants.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: BookTableConstants.textColor),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(BookTableConstants.defaultPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      DateTimeSelector(
                        dates: BookTableConstants.defaultDates,
                        times: BookTableConstants.defaultTimes,
                        selectedDate: state.selectedDate,
                        selectedTime: state.selectedTime,
                        selectedPeople: state.selectedPeople,
                        onDateSelected: controller.selectDate,
                        onTimeSelected: controller.selectTime,
                        onPeopleSelected: controller.selectPeople,
                      ),
                      const SizedBox(height: BookTableConstants.defaultSpacing),
                      LayoutSelector(
                        selectedLayout: state.selectedLayout,
                        onLayoutSelected: controller.selectLayout,
                      ),
                      const SizedBox(height: BookTableConstants.defaultSpacing),
                      SizedBox(
                        height: constraints.maxHeight * 0.6,
                        child: TablePreview(layoutType: state.selectedLayout),
                      ),
                      const SizedBox(height: BookTableConstants.defaultSpacing),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                        child: WaitingListButton(
                          onPressed: () => controller.joinWaitingList(),
                          isLoading: state.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 