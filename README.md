# Google Geofence Helper

A Flutter package that provides an interactive map widget for creating and editing geofences. This package simplifies the process of drawing polygonal regions on Google Maps, perfect for defining delivery zones, service areas, or any other geofenced regions.

## Features

- 🗺️ Interactive polygon drawing on Google Maps
- 🎨 Built-in and custom controls
- 📱 Responsive design for both mobile and web
- 🎯 Precise vertex placement and editing
- 🔄 Real-time polygon updates
- 🎨 Customizable styling options
- 🔍 Satellite/Normal view toggle
- ✏️ Edit mode with draggable vertices

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  google_geofence_helper: ^1.0.0
```

### Platform Configuration

#### Android
Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
```

#### iOS
Add your Google Maps API key to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Web
Add your Google Maps API key to `web/index.html`:

```html
<head>
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
</head>
```

## Usage

### Basic Usage with Built-in Controls

```dart
import 'package:google_geofence_helper/google_geofence_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

InteractiveMapGeofence(
  initialPosition: const LatLng(51.5074, -0.1278), // London
  initialZoom: 13,
  onPolygonUpdated: (points) {
    // Handle updated polygon points
    print('Polygon points: $points');
  },
)
```

### Custom Controls

You can create your own controls by setting `showControls: false` and using the controller:

```dart
class CustomMapScreen extends StatefulWidget {
  @override
  State<CustomMapScreen> createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends State<CustomMapScreen> {
  final _mapKey = GlobalKey<InteractiveMapGeofenceState>();
  List<LatLng> _points = [];
  bool _isEditMode = false;
  bool _isSatelliteMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Controls
          Row(
            children: [
              IconButton(
                icon: Icon(_isSatelliteMode ? Icons.map : Icons.satellite),
                onPressed: () {
                  setState(() {
                    _isSatelliteMode = !_isSatelliteMode;
                    _mapKey.currentState?.toggleMapType();
                  });
                },
              ),
              IconButton(
                icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditMode = !_isEditMode;
                    _mapKey.currentState?.toggleEditMode();
                  });
                },
              ),
            ],
          ),
          // Map
          Expanded(
            child: InteractiveMapGeofence(
              key: _mapKey,
              showControls: false,
              onPolygonUpdated: (points) {
                setState(() => _points = points);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialPosition` | `LatLng` | London | Initial map center position |
| `initialZoom` | `double` | 8.0 | Initial map zoom level |
| `onPolygonUpdated` | `Function(List<LatLng>)?` | null | Callback when polygon is modified |
| `markerColor` | `Color` | Colors.blue | Color of vertices and polygon |
| `polygonOpacity` | `double` | 0.3 | Opacity of the polygon fill |
| `strokeWidth` | `int` | 2 | Width of the polygon border |
| `enableTilt` | `bool` | true | Enable map tilt gestures |
| `enableRotate` | `bool` | true | Enable map rotation |
| `enableCompass` | `bool` | true | Show compass when map is rotated |
| `minZoom` | `double` | 1 | Minimum allowed zoom level |
| `maxZoom` | `double` | 20 | Maximum allowed zoom level |
| `initialPoints` | `List<LatLng>?` | null | Initial polygon points |
| `showControls` | `bool` | true | Show built-in controls |

## Controller Methods

The `InteractiveMapGeofenceController` provides the following methods:

- `toggleMapType()`: Switch between normal and satellite view
- `toggleEditMode()`: Toggle between view and edit modes
- `deleteLastVertex()`: Remove the last added vertex
- `clearPolygon()`: Remove all vertices

## Examples

Check out the [example](example) folder for complete implementation examples:

- Default example with built-in controls
- Custom controls example
- Navigation between examples

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 