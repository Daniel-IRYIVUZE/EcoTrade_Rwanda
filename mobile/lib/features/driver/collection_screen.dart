import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/live_tracking_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  int _step = 0;
  String _filter = 'started';
  bool _isLoading = false;

  final List<String> _steps = ['Arrive', 'Weigh & Photo', 'PIN Verify', 'Complete'];
  final TextEditingController _weightCtrl = TextEditingController();
  String _unit = 'kg';
  final List<String> _photos = [];
  final TextEditingController _pinCtrl = TextEditingController();
  bool _pinError = false;

  // Actual weight captured in step 2, used for the API call in step 3
  double? _capturedWeight;
  // Data returned from the last advance call (for the summary step)
  Map<String, dynamic> _lastAdvanceResult = {};

  @override
  void dispose() {
    _weightCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  /// Calls the backend to advance this collection's status, then moves to the next step.
  Future<void> _advance(Collection? collection, {double? actualWeight, String? notes}) async {
    final collectionId = int.tryParse(collection?.id ?? '');
    if (collectionId == null) {
      // No real collection, just advance UI (offline / no assignment yet)
      setState(() => _step++);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(collectionsNotifierProvider.notifier)
          .advanceStatus(collectionId, actualWeight: actualWeight, notes: notes);
      if (mounted) {
        setState(() {
          _lastAdvanceResult = result;
          _step++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(driverCollectionsProvider);
    final started = collections.where((c) =>
        c.status == CollectionStatus.enRoute ||
        c.status == CollectionStatus.scheduled ||
        c.status == CollectionStatus.collected).toList();
    final done = collections.where((c) =>
        c.status == CollectionStatus.completed ||
        c.status == CollectionStatus.verified ||
        c.status == CollectionStatus.missed).toList();
    final visible = _filter == 'started' ? started : done;
    final currentCollection = visible.isNotEmpty ? visible.first : null;
    final completedCount = done.length;

    final route = ref.watch(driverRouteProvider);
    final stops = route.stops;
    final stopIdx = stops.indexWhere((s) =>
        s.status == RouteStopStatus.collecting ||
        s.status == RouteStopStatus.arrived ||
        s.status == RouteStopStatus.pending);
    final currentStop = stopIdx >= 0 ? stops[stopIdx] : (stops.isNotEmpty ? stops.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Collection'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filter,
                borderRadius: BorderRadius.circular(10),
                items: const [
                  DropdownMenuItem(value: 'started', child: Text('Started')),
                  DropdownMenuItem(value: 'done', child: Text('Done')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _filter = value);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: Text('Stop ${completedCount + 1} of ${stops.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              backgroundColor: AppColors.primaryLight,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _StepBar(current: _step, steps: _steps),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0.3, 0), end: Offset.zero)
                      .animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: [
                  _ArriveStep(
                    stop: currentStop,
                    currentCollection: currentCollection,
                    isLoading: _isLoading,
                    onNext: () => _advance(currentCollection),
                  ),
                  _WeighPhotoStep(
                    weightCtrl: _weightCtrl,
                    unit: _unit,
                    photos: _photos,
                    expectedVolume: currentCollection?.volume,
                    onUnitChange: (u) => setState(() => _unit = u),
                    onAddPhoto: () =>
                        setState(() => _photos.add('photo_${_photos.length}')),
                    isLoading: _isLoading,
                    onNext: () {
                      _capturedWeight = double.tryParse(_weightCtrl.text);
                      _advance(currentCollection, actualWeight: _capturedWeight);
                    },
                  ),
                  _PinVerifyStep(
                    pinCtrl: _pinCtrl,
                    error: _pinError,
                    isLoading: _isLoading,
                    onNext: () {
                      if (_pinCtrl.text.length >= 4) {
                        setState(() => _pinError = false);
                        _advance(
                          currentCollection,
                          actualWeight: _capturedWeight,
                          notes: 'Verified by hotel staff',
                        );
                      } else {
                        setState(() => _pinError = true);
                      }
                    },
                  ),
                  _CompleteStep(
                    collection: currentCollection,
                    actualWeight: _capturedWeight,
                    advanceResult: _lastAdvanceResult,
                    onDone: () => setState(() {
                      _step = 0;
                      _weightCtrl.clear();
                      _pinCtrl.clear();
                      _photos.clear();
                      _capturedWeight = null;
                      _lastAdvanceResult = {};
                    }),
                  ),
                ][_step],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Bar ─────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int current;
  final List<String> steps;
  const _StepBar({required this.current, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.cSurf,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final idx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: idx < current ? AppColors.primary : context.cBorder,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < current;
          final active = idx == current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primary
                      : active
                          ? context.cPrimaryLight
                          : context.cSurf,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done || active ? AppColors.primary : context.cBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : Text('${idx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active ? AppColors.primary : context.cTextSec,
                          )),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[idx],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active || done ? FontWeight.w600 : FontWeight.w400,
                  color: active || done ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Step 1 — Arrive ──────────────────────────────────────────────────────────

class _ArriveStep extends StatelessWidget {
  final RouteStop? stop;
  final Collection? currentCollection;
  final bool isLoading;
  final VoidCallback onNext;

  const _ArriveStep({
    required this.onNext,
    this.stop,
    this.currentCollection,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final businessName = currentCollection?.businessName ?? stop?.businessName ?? 'Business';
    final location = currentCollection?.location ?? stop?.location ?? 'Kigali';
    final wasteLabel = currentCollection?.wasteType.label ?? stop?.wasteType.label ?? 'Waste';
    final unit = (currentCollection?.wasteType ?? stop?.wasteType) == WasteType.uco ? 'L' : 'kg';
    final volume = currentCollection?.volume.toStringAsFixed(0) ?? stop?.volume.toStringAsFixed(0) ?? '—';
    final scheduledTime = currentCollection?.scheduledTime ?? stop?.eta ?? '';
    final notes = currentCollection?.notes;

    return Column(
      key: const ValueKey('arrive'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentCollection != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LiveTrackingScreen(
                            collection: currentCollection!,
                            pushDriverLocation: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('Show Map'),
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.business, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(businessName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(location,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling contact...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.call, size: 14),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _DetailRow(icon: Icons.recycling, label: 'Waste Type', value: wasteLabel),
              const SizedBox(height: 8),
              _DetailRow(icon: Icons.inventory_2, label: 'Est. Volume', value: '$volume $unit'),
              if (scheduledTime.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DetailRow(icon: Icons.access_time, label: 'Scheduled', value: scheduledTime),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Show real collection notes from the database if available
        if (notes != null && notes.isNotEmpty)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Collection Notes',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notes,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onNext,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          child: isLoading
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('I Have Arrived',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── Step 2 — Weigh & Photo ───────────────────────────────────────────────────

class _WeighPhotoStep extends StatelessWidget {
  final TextEditingController weightCtrl;
  final String unit;
  final List<String> photos;
  final double? expectedVolume;
  final ValueChanged<String> onUnitChange;
  final VoidCallback onAddPhoto;
  final VoidCallback onNext;
  final bool isLoading;

  const _WeighPhotoStep({
    required this.weightCtrl,
    required this.unit,
    required this.photos,
    this.expectedVolume,
    required this.onUnitChange,
    required this.onAddPhoto,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('weigh'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Actual Weight',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: '0.0',
                        hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'kg', label: Text('kg')),
                      ButtonSegment(value: 'tonnes', label: Text('T')),
                    ],
                    selected: {unit},
                    onSelectionChanged: (s) => onUnitChange(s.first),
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.primary,
                      selectedForegroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (expectedVolume != null && expectedVolume! > 0) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.inventory_2,
                  label: 'Expected',
                  value: '${expectedVolume!.toStringAsFixed(0)} kg',
                  small: true,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Photos',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('${photos.length}/5 photos',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...photos.map((p) => Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.image, color: AppColors.primary),
                        )),
                    if (photos.length < 5)
                      GestureDetector(
                        onTap: onAddPhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: context.cSurf,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.cBorder),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: AppColors.primary, size: 24),
                              SizedBox(height: 4),
                              Text('Add',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onNext,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          child: isLoading
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Continue to Verification',
                  style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── Step 3 — PIN Verify ──────────────────────────────────────────────────────

class _PinVerifyStep extends StatelessWidget {
  final TextEditingController pinCtrl;
  final bool error;
  final bool isLoading;
  final VoidCallback onNext;

  const _PinVerifyStep({
    required this.pinCtrl,
    required this.error,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('pin'),
      children: [
        const SizedBox(height: 12),
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 16),
        const Text('Hotel Staff Verification',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        const SizedBox(height: 6),
        const Text(
          'Ask the hotel staff to enter their\n4-digit collection PIN',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 28),
        _Card(
          child: TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
            decoration: InputDecoration(
              counterText: '',
              hintText: '• • • •',
              errorText: error ? 'Incorrect PIN. Please try again.' : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : onNext,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          child: isLoading
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Verify & Complete',
                  style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── Step 4 — Complete ────────────────────────────────────────────────────────

class _CompleteStep extends StatelessWidget {
  final Collection? collection;
  final double? actualWeight;
  final Map<String, dynamic> advanceResult;
  final VoidCallback onDone;

  const _CompleteStep({
    required this.onDone,
    this.collection,
    this.actualWeight,
    this.advanceResult = const {},
  });

  @override
  Widget build(BuildContext context) {
    final hotelName = collection?.businessName ?? 'Business';
    final wasteLabel = collection?.wasteType.label ?? 'Waste';
    final weight = actualWeight ?? collection?.actualWeight;
    final weightStr = weight != null ? '${weight.toStringAsFixed(1)} kg' : '—';
    final earnings = collection?.earnings ?? 0.0;
    final now = TimeOfDay.now();
    final timeStr = '${now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} '
        '${now.period == DayPeriod.am ? 'AM' : 'PM'}';

    return Column(
      key: const ValueKey('complete'),
      children: [
        const SizedBox(height: 24),
        Container(
          width: 100, height: 100,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 56),
        ).animate().scale(delay: 100.ms, duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        const Text(
          'Collection Complete!',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        const SizedBox(height: 6),
        const Text(
          'Great work! This stop is marked as collected.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 28),
        _Card(
          child: Column(
            children: [
              _SummaryRow(label: 'Business', value: hotelName),
              _SummaryRow(label: 'Waste Type', value: wasteLabel),
              _SummaryRow(label: 'Actual Weight', value: weightStr),
              _SummaryRow(label: 'Collection Time', value: timeStr),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Card(
          color: AppColors.primaryLight,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.payments, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Earnings for this stop',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    earnings > 0 ? 'RWF ${earnings.toStringAsFixed(0)}' : 'Pending',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onDone,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          child: const Text('Next Stop →', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onDone,
          child: const Text('Report an Issue'),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _Card({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? context.cSurf,
        borderRadius: BorderRadius.circular(16),
        border: color == null ? Border.all(color: context.cBorder) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool small;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: small ? 14 : 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: small ? 12 : 13)),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: small ? 12 : 13)),
      ],
    );
  }
}
