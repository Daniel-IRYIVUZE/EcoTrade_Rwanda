import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListingSkeleton extends StatelessWidget {
  const ListingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, height: 14, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 12, color: Colors.white),
            const SizedBox(height: 12),
            Container(width: 100, height: 20, color: Colors.white),
          ]),
        ),
      ),
    );
  }
}
