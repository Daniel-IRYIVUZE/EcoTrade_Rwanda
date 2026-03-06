class NotificationHandler {
  static void handleForegroundMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    switch (type) {
      case 'new_bid': _handleNewBid(message); break;
      case 'bid_accepted': _handleBidAccepted(message); break;
      case 'collection_update': _handleCollectionUpdate(message); break;
      default: break;
    }
  }

  static void _handleNewBid(Map<String, dynamic> data) {}
  static void _handleBidAccepted(Map<String, dynamic> data) {}
  static void _handleCollectionUpdate(Map<String, dynamic> data) {}
}
