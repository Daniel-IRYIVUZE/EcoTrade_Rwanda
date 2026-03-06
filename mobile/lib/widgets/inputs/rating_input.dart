import 'package:flutter/material.dart';

class RatingInput extends StatefulWidget {
  final void Function(double)? onRatingChanged;
  final double initialRating;
  const RatingInput({super.key, this.onRatingChanged, this.initialRating = 0});

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  late double _rating;

  @override
  void initState() { super.initState(); _rating = widget.initialRating; }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => GestureDetector(
      onTap: () { setState(() => _rating = i + 1); widget.onRatingChanged?.call(_rating); },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(i < _rating ? Icons.star : Icons.star_border, color: const Color(0xFFF59E0B), size: 28),
      ),
    )));
  }
}
