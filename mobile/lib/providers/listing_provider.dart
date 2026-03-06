import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/waste_listing_model.dart';
import '../services/api/listing_service.dart';

class ListingState {
  final List<WasteListing> listings;
  final bool isLoading;
  final String? error;

  const ListingState({this.listings = const [], this.isLoading = false, this.error});

  ListingState copyWith({List<WasteListing>? listings, bool? isLoading, String? error}) =>
      ListingState(listings: listings ?? this.listings, isLoading: isLoading ?? this.isLoading, error: error);
}

class ListingNotifier extends StateNotifier<ListingState> {
  final ListingService _service = ListingService();
  ListingNotifier() : super(const ListingState());

  Future<void> loadListings({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final listings = await _service.getListings(filters: filters);
      state = state.copyWith(listings: listings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createListing(Map<String, dynamic> data) async {
    final newListing = await _service.createListing(data);
    state = state.copyWith(listings: [...state.listings, newListing]);
  }

  Future<void> deleteListing(String id) async {
    await _service.deleteListing(id);
    state = state.copyWith(listings: state.listings.where((l) => l.id != id).toList());
  }
}

final listingProvider = StateNotifierProvider<ListingNotifier, ListingState>((_) => ListingNotifier());
