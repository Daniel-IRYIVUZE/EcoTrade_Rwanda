import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../services/offline/offline_service.dart';

class DriverCollectionScreen extends StatefulWidget {
  const DriverCollectionScreen({super.key});
  @override
  State<DriverCollectionScreen> createState() => _DriverCollectionScreenState();
}

class _DriverCollectionScreenState extends State<DriverCollectionScreen> {
  final _pinController = TextEditingController();
  final _weightController = TextEditingController(text: '0');
  double _weight = 0.0;
  bool _photoCaptured = false;
  bool _pinVerified = false;
  bool _isCompleting = false;

  @override
  void dispose() {
    _pinController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _canComplete => _weight > 0 && _photoCaptured && _pinVerified;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Collection Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHotelInfoCard(),
          const SizedBox(height: 16),
          _buildWeighingSection(),
          const SizedBox(height: 16),
          _buildPhotoSection(),
          const SizedBox(height: 16),
          _buildPinSection(),
          const SizedBox(height: 24),
          _buildChecklist(),
          const SizedBox(height: 20),
          _buildCompleteButton(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildHotelInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.hotel, color: AppColors.primary, size: 24)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Marriott Hotel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Contact: John Doe • +250 788 123 456', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('In Progress', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
        const Divider(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _infoCol('Type', 'UCO', Icons.opacity),
          _infoCol('Expected', '120 kg', Icons.monitor_weight),
          _infoCol('Quality', 'Grade A', Icons.grade),
          _infoCol('Address', 'KG 7 Ave', Icons.location_on),
        ]),
      ]),
    );
  }

  Widget _infoCol(String label, String value, IconData icon) => Column(children: [
    Icon(icon, color: AppColors.primary, size: 18),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);

  Widget _buildWeighingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Actual Weight', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Center(child: Column(children: [
          Text('${_weight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const Text('Actual collected weight', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.primary, thumbColor: AppColors.primary, inactiveTrackColor: Colors.grey.shade200, trackHeight: 6),
          child: Slider(value: _weight, min: 0, max: 300, divisions: 300, onChanged: (v) => setState(() => _weight = v)),
        ),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0 kg', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text('300 kg', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [80, 100, 120, 150].map((w) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: () => setState(() => _weight = w.toDouble()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _weight == w ? AppColors.primary : Colors.grey.shade100,
              foregroundColor: _weight == w ? Colors.white : Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('$w kg', style: const TextStyle(fontSize: 12)),
          ),
        )).toList()),
      ]),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Collection Photo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_photoCaptured) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 14), SizedBox(width: 4), Text('Captured', style: TextStyle(color: Colors.green, fontSize: 11))])),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _capturePhoto,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _photoCaptured ? Colors.green.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _photoCaptured ? Colors.green.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: _photoCaptured
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 8),
                    const Text('Photo captured successfully', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                    TextButton(onPressed: _capturePhoto, child: const Text('Retake Photo', style: TextStyle(color: AppColors.primary, fontSize: 12))),
                  ])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.camera_alt, size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    const Text('Tap to capture collection photo', style: TextStyle(color: AppColors.textSecondary)),
                    const Text('Required for verification', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildPinSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Hotel Staff PIN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_pinVerified) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.verified, color: Colors.green, size: 14), SizedBox(width: 4), Text('Verified', style: TextStyle(color: Colors.green, fontSize: 11))])),
        ]),
        const SizedBox(height: 6),
        const Text('Enter the 4-digit PIN provided by hotel staff', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: _pinController,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '• • • •',
              counterText: '',
              prefixIcon: Icon(Icons.pin, color: _pinVerified ? Colors.green : AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              filled: true,
              fillColor: _pinVerified ? Colors.green.withValues(alpha: 0.05) : Colors.white,
            ),
          )),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _verifyPin,
            style: ElevatedButton.styleFrom(backgroundColor: _pinVerified ? Colors.green : AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            child: Text(_pinVerified ? 'Verified' : 'Verify', style: const TextStyle(color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR scanner coming soon'), behavior: SnackBarBehavior.floating)),
          icon: const Icon(Icons.qr_code_scanner, size: 18),
          label: const Text('Scan QR Code Instead'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    );
  }

  Widget _buildChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Collection Checklist', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _checkItem('Weight recorded', _weight > 0),
        _checkItem('Photo captured', _photoCaptured),
        _checkItem('Staff PIN verified', _pinVerified),
      ]),
    );
  }

  Widget _checkItem(String label, bool done) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : Colors.grey.shade300, size: 20),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: done ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: done ? FontWeight.w500 : FontWeight.normal)),
    ]),
  );

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: _canComplete && !_isCompleting ? _completeCollection : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: Colors.grey.shade200,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _isCompleting
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(
              _canComplete ? 'Complete Collection' : 'Complete checklist above',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _canComplete ? Colors.white : Colors.grey.shade400),
            ),
    );
  }

  void _capturePhoto() {
    setState(() => _photoCaptured = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo captured!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  void _verifyPin() {
    if (_pinController.text.length == 4) {
      setState(() => _pinVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN verified successfully!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a 4-digit PIN'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
    }
  }

  void _completeCollection() {
    setState(() => _isCompleting = true);

    // Save offline action
    OfflineService.addPendingAction({
      'type': 'collection_completed',
      'data': {'hotelId': 'hotel_1', 'weight': _weight, 'timestamp': DateTime.now().toIso8601String()},
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isCompleting = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: Colors.green, size: 44)),
            const SizedBox(height: 16),
            const Text('Collection Complete!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${_weight.toStringAsFixed(0)} kg UCO collected\nfrom Marriott Hotel', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _summaryItem('Collected', '${_weight.toStringAsFixed(0)} kg'),
                _summaryItem('Earned', '+RWF 15,000'),
              ]),
            ),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Next Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryItem(String label, String val) => Column(children: [
    Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}
