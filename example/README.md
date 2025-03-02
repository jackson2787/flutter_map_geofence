# Google Geofence Helper Example

This example project demonstrates the usage of the `google_geofence_helper` package in a Flutter application. It showcases both built-in controls and custom controls implementations.

## Getting Started

### Prerequisites

1. Flutter SDK installed and configured
2. Google Maps API key
3. A physical device or emulator

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/google_geofence_helper.git
cd google_geofence_helper/example
```

2. Set up environment variables:
```bash
# Copy the environment template
cp .env.example .env

# Edit .env and add your Google Maps API key
# GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

3. The API key from your `.env` file will be used for all platforms. However, you still need to replace the placeholder in the platform-specific files:

#### Android
In `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

#### iOS
In `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

#### Web
In `web/index.html`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
```

4. Install dependencies:
```bash
flutter pub get
```

5. Run the example:
```bash
flutter run
```

## Features Demonstrated

### 1. Default Controls Example
- Built-in floating action buttons for map controls
- Toggle between satellite and normal views
- Enter/exit edit mode
- Add polygon vertices by tapping
- Delete last vertex
- Clear entire polygon
- Real-time display of polygon coordinates

### 2. Custom Controls Example
- Custom UI controls in a top bar
- Same functionality as default controls but with custom UI
- Demonstrates use of the `InteractiveMapGeofenceController`
- Shows how to implement external controls
- Real-time display of polygon coordinates

### 3. Navigation
- Clean navigation between examples
- Material Design UI
- Demonstrates different implementation approaches

## Code Structure

```
lib/
├── main.dart              # Main application entry
├── config.dart            # Configuration handling
└── screens/
    ├── default_example.dart    # Built-in controls demo
    └── custom_controls_example.dart  # Custom controls demo
```

## Implementation Details

### Default Example
```dart
InteractiveMapGeofence(
  initialPosition: const LatLng(51.5074, -0.1278),
  initialZoom: 13,
  onPolygonUpdated: (points) {
    setState(() {
      _points = points;
    });
  },
)
```

### Custom Controls Example
```dart
InteractiveMapGeofence(
  key: _mapKey,
  showControls: false,
  initialPosition: const LatLng(51.5074, -0.1278),
  initialZoom: 13,
  onPolygonUpdated: (points) {
    setState(() {
      _points = points;
    });
  },
)
```

## Usage Tips

1. **Map Interaction**:
   - Single tap to add vertices in edit mode
   - Drag vertices to adjust their position
   - Use the satellite toggle to switch map types
   - Enter edit mode to modify the polygon

2. **Custom Controls**:
   - Use the `GlobalKey` to access the map's controller
   - Implement your own UI for controls
   - Maintain local state for UI updates

3. **Polygon Data**:
   - Access polygon points through the `onPolygonUpdated` callback
   - Points are provided as `List<LatLng>`
   - Update your UI or store the points as needed

## Troubleshooting

1. **Map Not Showing**:
   - Verify your Google Maps API key is correctly set up
   - Ensure you have internet connectivity
   - Check platform-specific configuration

2. **Controls Not Working**:
   - Verify the controller is properly initialized
   - Check if edit mode is enabled for vertex manipulation
   - Ensure the map has finished loading

3. **Performance Issues**:
   - Avoid unnecessary rebuilds in `onPolygonUpdated`
   - Use `const` constructors where possible
   - Implement proper state management

## Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)
- [Main Package Documentation](../README.md)
