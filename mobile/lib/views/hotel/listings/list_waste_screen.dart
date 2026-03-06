import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../theme/colors.dart';

class ListWasteScreen extends StatefulWidget {
  const ListWasteScreen({super.key});

  @override
  State<ListWasteScreen> createState() => _ListWasteScreenState();
}

class _ListWasteScreenState extends State<ListWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _volumeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _wasteType;
  String _unit = 'kg';
  double _qualityGrade = 3;
  DateTime? _pickupDate;
  final List<XFile> _photos = [];
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _wasteTypes = [
    {'label': 'Used Cooking Oil (UCO)', 'icon': Icons.opacity, 'color': const Color(0xFFD97706)},
    {'label': 'Glass & Bottles', 'icon': Icons.wine_bar, 'color': const Color(0xFF2563EB)},
    {'label': 'Cardboard & Paper', 'icon': Icons.inventory_2, 'color': const Color(0xFF7C3AED)},
    {'label': 'Plastic', 'icon': Icons.local_drink, 'color': const Color(0xFF059669)},
    {'label': 'Organic Waste', 'icon': Icons.eco, 'color': AppColors.primary},
    {'label': 'Metal & Cans', 'icon': Icons.hardware, 'color': const Color(0xFF6B7280)},
  ];

  final List<String> _qualityLabels = ['Very Low', 'Low', 'Average', 'Good', 'Excellent'];

  @override
  void dispose() {
    _volumeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List Waste', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Waste Type', _buildWasteTypeGrid()),
              const SizedBox(height: 20),
              _buildSection('Volume & Unit', _buildVolumeInput()),
              const SizedBox(height: 20),
              _buildSection('Quality Grade', _buildQualitySlider()),
              const SizedBox(height: 20),
              _buildSection('Photos (up to 5)', _buildPhotoUpload()),
              const SizedBox(height: 20),
              _buildSection('Preferred Pickup Time', _buildPickupTime()),
              const SizedBox(height: 20),
              _buildSection('Pickup Location', _buildMapSection()),
              const SizedBox(height: 20),
              _buildSection('Additional Notes (Optional)', _buildNotesField()),
              const SizedBox(height: 28),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildWasteTypeGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: _wasteTypes.map((wt) {
        final isSelected = _wasteType == wt['label'];
        final color = wt['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _wasteType = wt['label'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: isSelected ? 2 : 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(wt['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 26),
              const SizedBox(height: 4),
              Text(
                (wt['label'] as String).split(' ').first,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? color : AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVolumeInput() {
    return Row(children: [
      Expanded(
        flex: 3,
        child: TextFormField(
          controller: _volumeCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter volume',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _unit,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'kg', child: Text('kg')),
                DropdownMenuItem(value: 'L', child: Text('L')),
                DropdownMenuItem(value: 'tons', child: Text('tons')),
              ],
              onChanged: (v) => setState(() => _unit = v!),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildQualitySlider() {
    final grade = _qualityGrade.toInt() - 1;
    final colors = [Colors.red, Colors.orange, Colors.yellow.shade700, Colors.lightGreen, Colors.green];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_qualityLabels[grade], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors[grade])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: colors[grade].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('Grade ${_qualityGrade.toInt()}', style: TextStyle(color: colors[grade], fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: colors[grade], thumbColor: colors[grade], inactiveTrackColor: Colors.grey.shade200),
          child: Slider(value: _qualityGrade, min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => _qualityGrade = v)),
        ),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Low Quality', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text('High Quality', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildPhotoUpload() {
    return Column(children: [
      GestureDetector(
        onTap: _photos.length < 5 ? _pickImages : null,
        child: Container(
          height: _photos.isEmpty ? 100 : null,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primary.withValues(alpha: 0.03),
          ),
          child: _photos.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_photo_alternate, size: 40, color: AppColors.primary),
                  const SizedBox(height: 6),
                  const Text('Tap to add photos', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                  Text('Max 5 photos', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ]))
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(spacing: 8, runSpacing: 8, children: [
                    ..._photos.asMap().entries.map((e) => Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(e.value.path), width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(top: 0, right: 0, child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(e.key)),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      )),
                    ])),
                    if (_photos.length < 5)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                          child: const Icon(Icons.add, color: AppColors.primary, size: 30),
                        ),
                      ),
                  ]),
                ),
        ),
      ),
    ]);
  }

  Widget _buildPickupTime() {
    return GestureDetector(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _pickupDate != null ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today, color: _pickupDate != null ? AppColors.primary : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(
            _pickupDate != null
                ? '${_pickupDate!.day}/${_pickupDate!.month}/${_pickupDate!.year}  ${_pickupDate!.hour.toString().padLeft(2, '0')}:${_pickupDate!.minute.toString().padLeft(2, '0')}'
                : 'Select preferred pickup time',
            style: TextStyle(color: _pickupDate != null ? AppColors.textPrimary : Colors.grey),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ]),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('KG 7 Ave, Kigali City Centre', style: TextStyle(fontWeight: FontWeight.w500))),
            TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location picker coming soon'))), child: const Text('Change', style: TextStyle(color: AppColors.secondary))),
          ]),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
          child: SizedBox(
            height: 160,
            child: FlutterMap(
              options: const MapOptions(initialCenter: LatLng(-1.9441, 30.0619), initialZoom: 15, interactionOptions: InteractionOptions(flags: 0)),
              children: [
                TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'rw.ecotrade.mobile'),
                MarkerLayer(markers: [
                  Marker(
                    point: const LatLng(-1.9441, 30.0619),
                    width: 40, height: 40,
                    child: Container(
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.hotel, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Any special instructions for the recycler...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitListing,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _isSubmitting
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Submit Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 5 - _photos.length);
    setState(() => _photos.addAll(images));
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(data: ThemeData(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(data: ThemeData(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (!mounted || time == null) return;

    setState(() => _pickupDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submitListing() {
    if (_wasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a waste type'), backgroundColor: Colors.orange));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 16),
            const Text('Listing Published!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Recyclers in your area will be notified.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    });
  }
}
