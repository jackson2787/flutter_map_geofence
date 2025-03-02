import 'package:flutter/material.dart';
import 'package:google_geofence_helper/google_geofence_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DefaultExample extends StatefulWidget {
  const DefaultExample({super.key});

  @override
  State<DefaultExample> createState() => _DefaultExampleState();
}

class _DefaultExampleState extends State<DefaultExample> {
  List<LatLng> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Default Controls Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveMapGeofence(
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
              onPolygonUpdated: (points) {
                setState(() {
                  _points = points;
                });
              },
            ),
          ),
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