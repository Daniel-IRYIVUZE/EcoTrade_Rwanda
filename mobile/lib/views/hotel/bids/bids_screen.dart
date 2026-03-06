import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bid_model.dart';
import '../../../models/waste_listing_model.dart';
import '../../../providers/data_providers.dart';
import '../../../services/api/bid_service.dart';
import '../../../theme/colors.dart';

class HotelBidsScreen extends ConsumerStatefulWidget {
  const HotelBidsScreen({super.key});
  @override
  ConsumerState<HotelBidsScreen> createState() => _HotelBidsScreenState();
}

class _HotelBidsScreenState extends ConsumerState<HotelBidsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load hotel's own listings so we can fetch bids for each
    final listingsAsync = ref.watch(openListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bids Received', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(),
        data: (listings) => _BidsTabView(
          listings: listings,
          tabController: _tabController,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cloud_off, size: 64, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        const Text('Could not load bids', style: TextStyle(fontWeight: FontWeight.bold)),
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
}

// Separate widget to fetch bids for all listings
class _BidsTabView extends ConsumerStatefulWidget {
  final List<WasteListing> listings;
  final TabController tabController;
  const _BidsTabView({required this.listings, required this.tabController});
  @override
  ConsumerState<_BidsTabView> createState() => _BidsTabViewState();
}

class _BidsTabViewState extends ConsumerState<_BidsTabView> {
  List<BidModel> _allBids = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllBids();
  }

  Future<void> _loadAllBids() async {
    setState(() { _loading = true; _error = null; });
    try {
      final service = BidService();
      final futures = widget.listings
          .map((l) => service.getListingBids(l.id).catchError((_) => <BidModel>[]));
      final results = await Future.wait(futures);
      setState(() {
        _allBids = results.expand((b) => b).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<BidModel> _byStatus(String status) =>
      _allBids.where((b) => b.status == status).toList();

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    return TabBarView(
      controller: widget.tabController,
      children: ['pending', 'won', 'lost'].map(_buildBidList).toList(),
    );
  }

  Widget _buildBidList(String status) {
    final bids = _byStatus(status);
    if (bids.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.gavel, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No ${status == 'won' ? 'accepted' : status == 'lost' ? 'rejected' : status} bids',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadAllBids(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bids.length,
        itemBuilder: (_, i) => _buildBidCard(bids[i]),
      ),
    );
  }

  Widget _buildBidCard(BidModel bid) {
    final isPending = bid.status == 'pending';
    final Color statusColor = bid.status == 'won'
        ? Colors.green
        : bid.status == 'lost'
            ? Colors.red
            : Colors.orange;
    final String statusLabel = bid.status == 'won'
        ? 'Accepted'
        : bid.status == 'lost'
            ? 'Rejected'
            : 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.recycling, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bid.recyclerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(bid.createdAt.toString().split(' ').first, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _detail('Bid Amount', 'RWF ${bid.amount.toStringAsFixed(0)}'),
            if (bid.note != null && bid.note!.isNotEmpty)
              Flexible(child: _detail('Note', bid.note!)),
          ]),
        ),
        if (isPending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => _handleBid('lost', bid),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => _handleBid('won', bid),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Accept', style: TextStyle(color: Colors.white)),
            )),
          ]),
        ],
      ]),
    );
  }

  Widget _detail(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    ],
  );

  void _handleBid(String action, BidModel bid) {
    final isAccept = action == 'won';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAccept ? 'Accept Bid' : 'Reject Bid'),
        content: Text('${isAccept ? 'Accept' : 'Reject'} bid from ${bid.recyclerName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await BidService().updateBidStatus(bid.id, action);
                await _loadAllBids();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Bid ${isAccept ? 'accepted' : 'rejected'}!'),
                  backgroundColor: isAccept ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed: ${e.toString().replaceAll('Exception: ', '')}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? AppColors.primary : Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isAccept ? 'Accept' : 'Reject', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
