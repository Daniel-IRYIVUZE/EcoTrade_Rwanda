import 'package:flutter/material.dart';
import 'card_skeleton.dart';

class ListSkeleton extends StatelessWidget {
  final int count;
  final double itemHeight;
  const ListSkeleton({super.key, this.count = 5, this.itemHeight = 100});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => CardSkeleton(height: itemHeight),
    );
  }
}
