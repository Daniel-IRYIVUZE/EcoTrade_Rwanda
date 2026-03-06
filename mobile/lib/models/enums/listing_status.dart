enum ListingStatus { draft, active, bidding, accepted, completed, cancelled }

extension ListingStatusExtension on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.draft: return 'Draft';
      case ListingStatus.active: return 'Active';
      case ListingStatus.bidding: return 'Bidding';
      case ListingStatus.accepted: return 'Accepted';
      case ListingStatus.completed: return 'Completed';
      case ListingStatus.cancelled: return 'Cancelled';
    }
  }
}
