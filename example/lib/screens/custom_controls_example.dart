import 'package:flutter/material.dart';
import 'package:google_geofence_helper/google_geofence_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomControlsExample extends StatefulWidget {
  const CustomControlsExample({super.key});

  @override
  State<CustomControlsExample> createState() => _CustomControlsExampleState();
}

class _CustomControlsExampleState extends State<CustomControlsExample> {
  List<LatLng> _points = [];
  bool _isEditMode = false;
  bool _isSatelliteMode = false;
  InteractiveMapGeofenceController? _controller;
  final _mapKey = GlobalKey<InteractiveMapGeofenceState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Controls Example'),
      ),
      body: Column(
        children: [
          // Custom Controls Bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(_isSatelliteMode ? Icons.map : Icons.satellite),
                  onPressed: () {
                    setState(() {
                      _isSatelliteMode = !_isSatelliteMode;
                      _mapKey.currentState?.toggleMapType();
                    });
                  },
                  tooltip: 'Toggle Map Type',
                ),
                IconButton(
                  icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                      _mapKey.currentState?.toggleEditMode();
                    });
                  },
                  tooltip: 'Toggle Edit Mode',
                ),
                if (_points.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      _mapKey.currentState?.deleteLastVertex();
                    },
                    tooltip: 'Undo Last Point',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _mapKey.currentState?.clearPolygon();
                    },
                    tooltip: 'Clear All Points',
                  ),
                ],
              ],
            ),
          ),
          // Map
          Expanded(
            child: InteractiveMapGeofence(
              key: _mapKey,
              initialPosition: const LatLng(51.5074, -0.1278), // London
              initialZoom: 13,
              markerColor: Colors.blue,
              polygonOpacity: 0.3,
              strokeWidth: 2,
              enableTilt: true,
              enableRotate: true,
              enableCompass: true,
              minZoom: 3,
              maxZoom: 22,
              showControls: false, // Hide built-in controls
              onPolygonUpdated: (points) {
                setState(() {
                  _points = points;
                });
              },
            ),
          ),
          // Points Display
          if (_points.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Building Outline Points: ${_points.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _points.map((point) => 
                      '(${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})'
                    ).join('\n'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}