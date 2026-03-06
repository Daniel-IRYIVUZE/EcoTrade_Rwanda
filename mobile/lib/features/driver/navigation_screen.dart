import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final route = ref.watch(driverRouteProvider);
    final stops = route.stops;
    final nextIdx = stops.indexWhere((s) => s.status == RouteStopStatus.pending || s.status == RouteStopStatus.arrived || s.status == RouteStopStatus.collecting);
    final nextStop = nextIdx >= 0 ? stops[nextIdx] : (stops.isNotEmpty ? stops.last : null);
    final completedCount = stops.where((s) => s.status == RouteStopStatus.completed).length;
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: Container(
              color: const Color(0xFFD4EDDA),
              child: Stack(
                children: [
                  // Grid lines
                  ...List.generate(8, (i) => Positioned(
                    left: i * 55.0,
                    top: 0, bottom: 0,
                    child: Container(width: 1, color: Colors.white.withOpacity(0.6)),
                  )),
                  ...List.generate(12, (i) => Positioned(
                    top: i * 70.0,
                    left: 0, right: 0,
                    child: Container(height: 1, color: Colors.white.withOpacity(0.6)),
                  )),

                  // Route polyline simulation
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoutePainter(),
                    ),
                  ),

                  // Stop markers — dynamically reflect completed count
                  ...List.generate(stops.length > 4 ? 4 : stops.length, (i) {
                    const positions = [
                      (left: 0.25, top: 0.65),
                      (left: 0.45, top: 0.48),
                      (left: 0.65, top: 0.32),
                      (left: 0.8, top: 0.2),
                    ];
                    final pos = positions[i];
                    final isDone = i < completedCount;
                    final isNext = i == completedCount;
                    return _StopMarker(left: pos.left, top: pos.top, number: i + 1, done: isDone, isNext: isNext);
                  }),

                  // Animated current location
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.55,
                    top: MediaQuery.of(context).size.height * 0.42,
                    child: _AnimatedDriverMarker(),
                  ),
                ],
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Navigating to ${nextStop?.businessName ?? 'Next Stop'}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Voice indicator
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: const Icon(Icons.volume_up, color: AppColors.primary, size: 22),
            ),
          ),

          // Map controls
          Positioned(
            top: 160,
            right: 16,
            child: Column(
              children: [
                _MapButton(icon: Icons.add),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.remove),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.my_location, color: AppColors.primary),
              ],
            ),
          ),

          // Bottom turn-by-turn panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.turn_right, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turn right onto KN 4 Ave',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'In 300m',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '2.3 km',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                            ),
                            Text(
                              '8 min',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Arrived at Stop', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(52, 52),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.more_horiz),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopMarker extends StatelessWidget {
  final double left;
  final double top;
  final int number;
  final bool done;
  final bool isNext;

  const _StopMarker({
    required this.left,
    required this.top,
    required this.number,
    required this.done,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * left,
      top: MediaQuery.of(context).size.height * top,
      child: Container(
        width: isNext ? 40 : 32,
        height: isNext ? 40 : 32,
        decoration: BoxDecoration(
          color: done ? AppColors.primary : isNext ? Colors.white : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: done ? AppColors.primary : isNext ? AppColors.primary : AppColors.border,
            width: isNext ? 2.5 : 1.5,
          ),
          boxShadow: isNext
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, spreadRadius: 3)]
              : null,
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  '$number',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isNext ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}

class _AnimatedDriverMarker extends StatefulWidget {
  @override
  State<_AnimatedDriverMarker> createState() => _AnimatedDriverMarkerState();
}

class _AnimatedDriverMarkerState extends State<_AnimatedDriverMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.info.withOpacity(0.15 * (1 - _controller.value)),
            ),
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: AppColors.info.withOpacity(0.4), blurRadius: 8)],
          ),
          child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const _MapButton({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.info
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final donePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final donePath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.65)
      ..lineTo(size.width * 0.45, size.height * 0.48)
      ..lineTo(size.width * 0.55, size.height * 0.42);

    canvas.drawPath(donePath, donePaint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.55, size.height * 0.42)
        ..lineTo(size.width * 0.65, size.height * 0.32)
        ..lineTo(size.width * 0.8, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
