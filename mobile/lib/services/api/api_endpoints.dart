class ApiEndpoints {
  // Android emulator: 10.0.2.2 maps to host machine localhost
  // iOS simulator: localhost | Real device: your machine's LAN IP (e.g. 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String refreshToken = '/auth/refresh';

  // User
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Listings
  static const String listings = '/listings';
  static String listingById(String id) => '/listings/$id';
  static const String nearbyListings = '/listings/nearby';

  // Bids (recycler's own bids)
  static const String bids = '/bids';
  static String bidById(String id) => '/bids/$id';
  // Bids nested under a listing
  static String listingBids(String listingId) => '/listings/$listingId/bids';
  static String acceptBid(String listingId, String bidId) =>
      '/listings/$listingId/bids/$bidId/accept';

  // Collections
  static const String collections = '/collections';
  static const String activeCollections = '/collections/active';
  static String collectionById(String id) => '/collections/$id';
  static String rateCollection(String id) => '/collections/$id/rate';

  // Routes (driver)
  static const String routes = '/routes';
  static String routeById(String id) => '/routes/$id';

  // Payments
  static const String payments = '/payments';
  static const String paymentsSummary = '/payments/summary';
  static const String withdrawal = '/payments/withdrawal';

  // Drivers
  static const String drivers = '/drivers';
  static String driverById(String id) => '/drivers/$id';

  // Notifications
  static const String notifications = '/notifications';
}
