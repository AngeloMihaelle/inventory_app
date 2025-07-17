# Inventario Móvil

A Flutter mobile application for inventory management with search, CSV import/export, and customizable item characteristics.

## Features

- **Item Management**: Add, edit, and delete inventory items
- **Search Functionality**: Search items by name, ID, or characteristics
- **Custom Characteristics**: Add key-value pairs to describe item properties
- **CSV Import/Export**: Backup and restore inventory data
- **Offline Storage**: SQLite database for local data persistence
- **Clean UI**: Material Design with pink theme

## Screenshots

*Add screenshots of your app here*

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  sqflite: ^2.2.8
  path_provider: ^2.0.14
  permission_handler: ^10.2.0
  file_picker: ^5.2.10
  uuid: ^3.0.7
  path: ^1.8.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

### Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd inventario_movil
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── item.dart            # Item data model
├── providers/
│   └── inventory_provider.dart  # State management
├── screens/
│   ├── main_screen.dart     # Home screen with item list
│   ├── add_edit_screen.dart # Add/Edit item form
│   └── config_screen.dart   # Settings and data management
├── services/
│   └── csv_service.dart     # CSV import/export functionality
└── database/
    └── database_helper.dart # SQLite database operations
```

## Usage

### Adding Items

1. Tap the **+** floating action button on the main screen
2. Fill in the item name and quantity (required fields)
3. Add custom characteristics using key-value pairs
4. Tap **Save** to add the item

### Editing Items

1. Tap on any item in the list
2. Modify the item details
3. Tap **Save** to update

### Deleting Items

1. Tap the three-dot menu on any item
2. Select **Delete**
3. Confirm the deletion

### Searching

Use the search bar at the top of the main screen to find items by:

- Item name
- Item ID
- Characteristics (keys and values)

### CSV Operations

Access the **Configuration** screen (gear icon) to:

#### Export Data

- Exports all items to a CSV file
- Saved to device Downloads folder
- Format: `ID, Name, Quantity, Characteristics (JSON)`

#### Import Data

- Select a CSV file from device storage
- Supports the same format as export
- Adds items to existing inventory

#### Clear Database

- Removes all items from inventory
- **Warning**: This action is irreversible

## Data Model

### Item Structure

```dart
class Item {
  final String id;              // Unique identifier (UUID)
  final String name;            // Item name
  final int quantity;           // Quantity in stock
  final Map<String, String> characteristics; // Custom properties
}
```

### CSV Format

```csv
ID,Name,Quantity,Characteristics
"abc123","Screw","50","{\"color\":\"silver\",\"size\":\"M6\"}"
"def456","Bolt","25","{\"material\":\"steel\",\"length\":\"2cm\"}"
```

## Database Schema

The app uses SQLite with the following table structure:

```sql
CREATE TABLE items(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  characteristics TEXT NOT NULL  -- JSON string
);
```

## State Management

The app uses the **Provider** pattern for state management:

- `InventoryProvider`: Manages item CRUD operations, search functionality, and data persistence
- Uses `ChangeNotifier` to update UI when data changes

## Permissions

### Android

The app requires the following permissions for CSV operations:

- `WRITE_EXTERNAL_STORAGE`
- `READ_EXTERNAL_STORAGE`
- `MANAGE_EXTERNAL_STORAGE` (Android 11+)

Permissions are handled automatically by the `permission_handler` package.

## Key Features Implementation

### Search Algorithm

- Tokenizes search query by spaces
- Searches across item name, ID, and characteristics
- Case-insensitive matching
- Returns items that match any token

### CSV Processing

- Custom CSV parser handles quoted fields and escaped quotes
- JSON serialization for characteristics
- Error handling for malformed data
- Automatic UUID generation for items without IDs

### Data Persistence

- SQLite database with automatic initialization
- Async operations for database interactions
- Proper error handling and transaction management

## Customization

### Theming

The app uses a pink color scheme defined in `main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.pink,
  visualDensity: VisualDensity.adaptivePlatformDensity,
),
```

### Adding New Features

1. **New item properties**: Modify the `Item` model and database schema
2. **Additional export formats**: Extend the `CSVService` class
3. **Enhanced search**: Update the search algorithm in `InventoryProvider`

## Error Handling

The app includes comprehensive error handling for:

- Database operations
- File system access
- CSV parsing errors
- Network connectivity issues
- Permission denials

## Performance Considerations

- Lazy loading for large inventories
- Efficient search with indexed database queries
- Memory management for large CSV files
- Optimized UI updates using Provider

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Future Enhancements

- [ ] Barcode scanning for item identification
- [ ] Cloud synchronization
- [ ] Advanced analytics and reporting
- [ ] Multiple inventory locations
- [ ] Image attachments for items
- [ ] Batch operations for multiple items

## Version History

- **v1.0.0**: Initial release with basic inventory management
- Basic CRUD operations
- Search functionality
- CSV import/export
- Local database storage
