import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

enum MapEditMode {
  view,
  edit,
}

abstract class InteractiveMapGeofenceController {
  void toggleMapType();
  void toggleEditMode();
  void deleteLastVertex();
  void clearPolygon();
}

class GeofencePolygon {
  final String id;
  final List<LatLng> points;

  GeofencePolygon({
    required this.id,
    required this.points,
  });
}

class InteractiveMapGeofence extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final Function(List<LatLng>)? onPolygonUpdated;
  final Color markerColor;
  final double polygonOpacity;
  final int strokeWidth;
  final bool enableTilt;
  final bool enableRotate;
  final bool enableCompass;
  final double minZoom;
  final double maxZoom;
  final List<LatLng>? initialPoints;
  final bool showControls;

  const InteractiveMapGeofence({
    Key? key,
    this.initialPosition = const LatLng(51.5074, -0.1278),
    this.initialZoom = 8.0,
    this.onPolygonUpdated,
    this.markerColor = Colors.blue,
    this.polygonOpacity = 0.3,
    this.strokeWidth = 2,
    this.enableTilt = true,
    this.enableRotate = true,
    this.enableCompass = true,
    this.minZoom = 1,
    this.maxZoom = 20,
    this.initialPoints,
    this.showControls = true,
  }) : super(key: key);

  static InteractiveMapGeofenceController? of(BuildContext context) {
    return context.findRootAncestorStateOfType<InteractiveMapGeofenceState>();
  }

  @override
  State<InteractiveMapGeofence> createState() => InteractiveMapGeofenceState();
}

class InteractiveMapGeofenceState extends State<InteractiveMapGeofence> implements InteractiveMapGeofenceController {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  List<LatLng> _points = [];
  Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  MapEditMode _editMode = MapEditMode.view;
  BitmapDescriptor? _customMarker;
  LatLng? _originalDragPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPoints != null) {
      _points = List.from(widget.initialPoints!);
      _updateMarkers();
    }
    
    _createCustomMarker().then((marker) {
      setState(() {
        _customMarker = marker;
        if (_points.isNotEmpty) {
          _updateMarkers();
        }
      });
    });
  }

  void _updateMarkers() {
    if (_customMarker == null) return;
    
    setState(() {
      // Only show markers in edit mode
      if (_editMode == MapEditMode.edit) {
        _markers = _points.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          return Marker(
            markerId: MarkerId('vertex_$index'),
            position: point,
            draggable: true,
            icon: _customMarker!,
            anchor: const Offset(0.5, 0.5),
            onDragStart: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onDragEnd: (newPosition) {
              _handleMarkerDragEnd(index, newPosition);
            },
          );
        }).toSet();
      } else {
        _markers = {};  // Clear markers in view mode
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
          mapType: _currentMapType,
          polygons: _createPolygon(),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            _removePOIs();
          },
          onTap: _handleMapTap,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: widget.enableCompass,
          buildingsEnabled: true,
          minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
          rotateGesturesEnabled: widget.enableRotate,
          tiltGesturesEnabled: widget.enableTilt,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
        ),
        if (widget.showControls) _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            FloatingActionButton(
              heroTag: "mapType",
              onPressed: () {
                Future.microtask(_toggleMapType);
              },
              child: Icon(
                _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "editMode",
              onPressed: () {
                Future.microtask(_toggleEditMode);
              },
              child: Icon(_editMode == MapEditMode.view ? Icons.edit : Icons.check),
            ),
            if (_editMode == MapEditMode.edit && _points.isNotEmpty) ...[
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "undo",
                onPressed: () {
                  Future.microtask(_deleteLastVertex);
                },
                child: const Icon(Icons.undo),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: "delete",
                onPressed: () {
                  Future.microtask(_clearPolygon);
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Set<Polygon> _createPolygon() {
    if (_points.length < 3) return {};

    return {
      Polygon(
        polygonId: const PolygonId('building'),
        points: _points,
        strokeWidth: widget.strokeWidth,
        strokeColor: widget.markerColor,
        fillColor: widget.markerColor.withOpacity(widget.polygonOpacity),
        geodesic: true,
      ),
    };
  }

  void _handleMarkerDragEnd(int index, LatLng newPosition) {
    setState(() {
      _isDragging = false;
      _points[index] = newPosition;
      _updateMarkers();
    });
    _notifyPolygonUpdate();
  }

  Future<void> _handleMapTap(LatLng position) async {
    if (_editMode != MapEditMode.edit) return;

    // Get the screen coordinates of the tap
    final GoogleMapController controller = await _controller.future;
    final ScreenCoordinate screenCoordinate = await controller.getScreenCoordinate(position);
    
    // Define the button area (top-right corner)
    final double buttonAreaTop = 0;
    final double buttonAreaRight = 0;
    final double buttonAreaWidth = 80;
    final double buttonAreaHeight = 350;  // Increased height to account for all buttons including delete

    // Check if tap is in the button area
    if (screenCoordinate.x >= MediaQuery.of(context).size.width - buttonAreaWidth &&
        screenCoordinate.y <= buttonAreaHeight) {
      return;
    }

    setState(() {
      _points.add(position);
      _updateMarkers();
    });

    _notifyPolygonUpdate();
  }

  void _notifyPolygonUpdate() {
    if (widget.onPolygonUpdated != null) {
      widget.onPolygonUpdated!(_points);
    }
  }

  Future<BitmapDescriptor> _createCustomMarker() async {
    // Base sizes (logical pixels)
    double visualSize = kIsWeb ? 16.0 : 48.0;
    double touchSize = kIsWeb ? 24.0 : 96.0;

    // Get device pixel ratio
    final double devicePixelRatio = ui.window.devicePixelRatio;

    // Scale sizes for pixel density
    final double scaledVisualSize = visualSize * devicePixelRatio;
    final double scaledTouchSize = touchSize * devicePixelRatio;

    final pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Scale the canvas for pixel density
    canvas.scale(devicePixelRatio);

    final Paint fillPaint = Paint()
      ..color = widget.markerColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = widget.markerColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center of the touch target area (in logical pixels)
    final Offset center = Offset(touchSize / 2, touchSize / 2);
    
    // Draw invisible touch target circle
    canvas.drawCircle(
      center,
      touchSize / 2,
      Paint()..color = Colors.transparent,
    );

    // Draw visible marker centered in the touch target
    canvas.drawCircle(center, visualSize / 2, fillPaint);
    canvas.drawCircle(center, visualSize / 2, borderPaint);

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(
      scaledTouchSize.toInt(),
      scaledTouchSize.toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<void> _removePOIs() async {
    final GoogleMapController controller = await _controller.future;
    await controller.setMapStyle('''
    [
      {
        "featureType": "poi",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.business",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "poi.park",
        "stylers": [{ "visibility": "off" }]
      },
      {
        "featureType": "road",
        "stylers": [{ "visibility": "on" }]
      }
    ]
    ''');
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = _editMode == MapEditMode.view ? MapEditMode.edit : MapEditMode.view;
      _isDragging = false;
      _updateMarkers();
    });
  }

  void _deleteLastVertex() {
    if (_points.isEmpty) return;
    
    setState(() {
      _points.removeLast();
      _updateMarkers();
    });

    _notifyPolygonUpdate();
  }

  void _clearPolygon() {
    setState(() {
      _points.clear();
      _markers.clear();
    });
    _notifyPolygonUpdate();
  }

  @override
  void toggleMapType() {
    _toggleMapType();
  }

  @override
  void toggleEditMode() {
    _toggleEditMode();
  }

  @override
  void deleteLastVertex() {
    _deleteLastVertex();
  }

  @override
  void clearPolygon() {
    _clearPolygon();
  }
} 