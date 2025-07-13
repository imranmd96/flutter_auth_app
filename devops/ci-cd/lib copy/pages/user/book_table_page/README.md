# Table Booking System Documentation

## Overview
The Table Booking System is a Flutter-based feature that allows users to book tables at a restaurant. It provides multiple layout views (2D, 3D, VR) and interactive table selection.

## Directory Structure
```
book_table_page/
├── constants/
│   └── book_table_constants.dart    # App-wide constants and styling
├── controllers/
│   └── book_table_controller.dart   # State management and business logic
├── models/
│   └── table_booking_model.dart     # Data models
├── sections/
│   ├── layouts/                     # Different layout implementations
│   │   ├── layout_2d.dart
│   │   ├── layout_3d.dart
│   │   └── layout_vr.dart
│   ├── components/                  # Reusable layout components
│   │   ├── table_widget.dart
│   │   ├── bar_widget.dart
│   │   └── entrance_widget.dart
│   └── restaurant_layout_illustration.dart  # Layout orchestrator
├── widgets/                         # UI components
│   ├── date_time_selector.dart
│   ├── layout_selector.dart
│   └── people_selector.dart
└── book_table_page.dart            # Main page
```

## Components

### 1. Main Page (`book_table_page.dart`)
- Entry point for the table booking feature
- Manages overall layout and state
- Integrates all components

### 2. Layouts
#### 2D Layout (`layout_2d.dart`)
- Traditional top-down view
- Features:
  - 7 numbered tables (1-7)
  - Centered CUCINA area
  - BAR area
  - Entrance indicator
  - Yellow background theme

#### 3D Layout (`layout_3d.dart`)
- Perspective view with depth
- Features:
  - Same table arrangement as 2D
  - 3D styling and shadows
  - Orange background theme
  - Enhanced visual depth

#### VR Layout (`layout_vr.dart`)
- Modern, immersive view
- Features:
  - 3 tables in center
  - Gradient background
  - Dotted pattern
  - WALKWAY indicator
  - Virtual overlay effect

### 3. Components
#### Table Widget (`table_widget.dart`)
- Reusable table component
- Features:
  - Multiple styles (circle, 3D, VR, large)
  - Table number display
  - Interactive tap handling
  - Consistent styling

#### Bar Widget (`bar_widget.dart`)
- Displays BAR and CUCINA areas
- Features:
  - Customizable label
  - Consistent styling
  - Shadow effects

#### Entrance Widget (`entrance_widget.dart`)
- Entrance indicator
- Features:
  - Blue accent color
  - Consistent styling
  - Shadow effects

### 4. Selectors
#### Date Time Selector
- Date and time selection
- Features:
  - Chip-based selection
  - Multiple time slots
  - Visual feedback

#### Layout Selector
- Layout type selection
- Features:
  - 2D, 3D, VR options
  - Icon-based selection
  - Visual feedback

#### People Selector
- Guest count selection
- Features:
  - Number-based selection
  - Visual feedback

## Constants (`book_table_constants.dart`)
```dart
class BookTableConstants {
  // Colors
  static const Color primaryColor = Color(0xFF002366);
  static const Color accentBlue = Color(0xFF1769FF);
  static const Color orange = Color(0xFFFF9000);
  static const Color pink = Color(0xFFFF6F91);
  
  // Dimensions
  static const double previewHeight = 500.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 24.0;
  
  // Default Values
  static const List<String> defaultDates = ['Today', 'Tomorrow', 'Wed', 'Thu', 'Fri'];
  static const List<String> defaultTimes = ['12:00', '13:00', '14:00', '19:00', '20:00'];
  static const List<int> defaultPeople = [2, 4, 6, 8];
}
```

## Usage
```dart
// Basic usage
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const BookTablePage()),
);

// With custom controller
final controller = BookTableController();
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider.value(
      value: controller,
      child: const BookTablePage(),
    ),
  ),
);
```

## State Management
- Uses Provider for state management
- `BookTableController` handles:
  - Selected date/time
  - Number of people
  - Layout type
  - Table selection
  - Waiting list functionality

## Styling
- Consistent color scheme
- Responsive layout
- Shadow effects
- Rounded corners
- Interactive feedback

## Future Enhancements
1. Table availability status
2. Real-time updates
3. Table customization
4. Advanced VR features
5. Integration with backend services

## Contributing
1. Follow the existing code structure
2. Maintain consistent styling
3. Add proper documentation
4. Include unit tests
5. Update this documentation

## Dependencies
- Flutter
- Provider (for state management)
- Material Design components 