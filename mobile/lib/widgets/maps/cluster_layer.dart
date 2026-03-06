import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ClusterLayer extends StatelessWidget {
  final List<List<LatLng>> clusters;
  const ClusterLayer({super.key, required this.clusters});

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    for (int i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      if (cluster.isEmpty) continue;
      final lat = cluster.map((p) => p.latitude).reduce((a, b) => a + b) / cluster.length;
      final lng = cluster.map((p) => p.longitude).reduce((a, b) => a + b) / cluster.length;
      markers.add(Marker(
        point: LatLng(lat, lng), width: 56, height: 56,
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFF0F4C3A).withValues(alpha: 0.85), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: Center(child: Text('${cluster.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ));
    }
    return MarkerLayer(markers: markers);
  }
}
