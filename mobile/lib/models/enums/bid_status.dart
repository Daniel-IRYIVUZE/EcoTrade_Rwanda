enum BidStatus { pending, accepted, rejected, countered, expired }

extension BidStatusExtension on BidStatus {
  String get label {
    switch (this) {
      case BidStatus.pending: return 'Pending';
      case BidStatus.accepted: return 'Accepted';
      case BidStatus.rejected: return 'Rejected';
      case BidStatus.countered: return 'Countered';
      case BidStatus.expired: return 'Expired';
    }
  }
}
