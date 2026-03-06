import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/waste_listing_model.dart';
import '../../../providers/data_providers.dart';
import '../../../services/api/bid_service.dart';
import '../../../theme/colors.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'All';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _filters = ['All', 'UCO', 'Glass', 'Cardboard', 'Plastic', 'Metal', 'Organic'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WasteListing> _applyFilters(List<WasteListing> all) {
    var list = _filter == 'All' ? all : all.where((l) => l.wasteType == _filter).toList();
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((l) =>
              l.hotelName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              l.wasteType.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(openListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(openListingsProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt, size: 18), text: 'List View'),
            Tab(icon: Icon(Icons.map, size: 18), text: 'Map View'),
          ],
        ),
      ),
      body: Column(children: [
        _buildSearchAndFilters(),
        Expanded(
          child: listingsAsync.when(
            loading: () => _buildSkeleton(),
            error: (e, _) => _buildError(e),
            data: (listings) {
              final filtered = _applyFilters(listings);
              return TabBarView(
                controller: _tabController,
                children: [_buildListView(filtered), _buildMapView(filtered)],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 140, height: 12, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 80, height: 10, color: Colors.grey.shade100),
              ]),
            ]),
            const SizedBox(height: 12),
            Container(height: 40, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10))),
          ]),
        ),
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cloud_off, size: 64, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        const Text('Could not load listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Using offline mode', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => ref.invalidate(openListingsProvider),
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text('Retry', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
      ]),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(children: [
      Container(
        color: AppColors.primary,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search hotels, waste types...',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    })
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      Container(
        color: Colors.white,
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => FilterChip(
            label: Text(_filters[i],
                style: TextStyle(fontSize: 11, color: _filter == _filters[i] ? AppColors.primary : AppColors.textSecondary)),
            selected: _filter == _filters[i],
            onSelected: (_) => setState(() => _filter = _filters[i]),
            selectedColor: AppColors.primary.withValues(alpha: 0.12),
            checkmarkColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(color: _filter == _filters[i] ? AppColors.primary : Colors.grey.shade200),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    ]);
  }

  Widget _buildListView(List<WasteListing> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No listings found', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(openListingsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildListingCard(items[i]),
      ),
    );
  }

  Widget _buildListingCard(WasteListing l) {
    final typeColors = {
      'UCO': const Color(0xFFD97706), 'Glass': const Color(0xFF2563EB),
      'Cardboard': const Color(0xFF7C3AED), 'Plastic': const Color(0xFF059669),
      'Metal': const Color(0xFF6B7280),
    };
    final color = typeColors[l.wasteType] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.hotel, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Row(children: [
                const Icon(Icons.eco, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Text(l.wasteType, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(l.status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _detailCol('Volume', '${l.volume.toStringAsFixed(0)} ${l.unit}'),
              _detailCol('Quality', l.quality),
              _detailCol('Min Bid', 'RWF ${l.minBid.toStringAsFixed(0)}'),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => _showListingDetail(l),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Details', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => _showPlaceBidModal(l),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Place Bid', style: TextStyle(color: Colors.white, fontSize: 13)),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _detailCol(String label, String value) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
  ]);

  Widget _buildMapView(List<WasteListing> items) {
    return FlutterMap(
      options: const MapOptions(initialCenter: LatLng(-1.9441, 30.0619), initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'rw.ecotrade.mobile',
        ),
        MarkerLayer(
          markers: items
              .where((l) => l.location != null)
              .map((l) => Marker(
                    point: const LatLng(-1.9441, 30.0619), // TODO: parse location coords
                    width: 60, height: 56,
                    child: GestureDetector(
                      onTap: () => _showPlaceBidModal(l),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                          ),
                          child: Text(l.wasteType, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                      ]),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showListingDetail(WasteListing l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          Text(l.hotelName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _row('Waste Type', l.wasteType),
          _row('Volume', '${l.volume.toStringAsFixed(0)} ${l.unit}'),
          _row('Quality', l.quality),
          _row('Min Bid', 'RWF ${l.minBid.toStringAsFixed(0)}'),
          _row('Status', l.status),
          if (l.expiresAt != null)
            _row('Expires', '${l.expiresAt!.day}/${l.expiresAt!.month}/${l.expiresAt!.year}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _showPlaceBidModal(l); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Place Bid', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );

  void _showPlaceBidModal(WasteListing l) {
    final ctrl = TextEditingController(text: l.minBid.toStringAsFixed(0));
    bool isSubmitting = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setModal) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          Text(l.hotelName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${l.wasteType} • ${l.volume.toStringAsFixed(0)} ${l.unit} • ${l.quality}', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Min bid: RWF ${l.minBid.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Your Bid Amount (RWF)',
              prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitting ? null : () async {
              setModal(() => isSubmitting = true);
              try {
                await BidService().placeBid(
                  listingId: l.id,
                  amount: double.tryParse(ctrl.text) ?? l.minBid,
                );
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Bid of RWF ${ctrl.text} placed on ${l.hotelName}!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
                ref.invalidate(myBidsProvider);
              } catch (e) {
                setModal(() => isSubmitting = false);
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text('Failed to place bid: ${e.toString().replaceAll('Exception: ', '')}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isSubmitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Bid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      )),
    );
  }
}
