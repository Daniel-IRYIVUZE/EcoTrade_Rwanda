import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EcotradeMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final MapController? mapController;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final List<Widget> children;

  const EcotradeMap({
    super.key,
    this.center = const LatLng(-1.9441, 30.0619),
    this.zoom = 13,
    this.mapController,
    this.markers = const [],
    this.polylines = const [],
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'rw.ecotrade.mobile',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ...children,
      ],
    );
  }
}
