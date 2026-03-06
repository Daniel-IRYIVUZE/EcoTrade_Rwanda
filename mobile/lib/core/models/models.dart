// Data models matching frontend TypeScript interfaces (dataStore.ts, api.ts)

enum UserRole { admin, business, recycler, driver, individual }

enum WasteType { uco, glass, paperCardboard, mixed }

enum WasteQuality { a, b, c }

enum ListingStatus {
  open,
  assigned,
  collected,
  completed,
  cancelled,
  expired,
  draft
}

enum BidStatus { active, won, lost, withdrawn }

enum CollectionStatus {
  scheduled,
  enRoute,
  collected,
  verified,
  completed,
  missed
}

enum RouteStopStatus { pending, arrived, collecting, completed, skipped }

enum RouteStatus { pending, inProgress, completed }

enum TransactionStatus { pending, completed, disputed, refunded }

enum NotificationType { bid, collection, payment, system, message, alert }

extension WasteTypeLabel on WasteType {
  String get label {
    switch (this) {
      case WasteType.uco:
        return 'UCO';
      case WasteType.glass:
        return 'Glass';
      case WasteType.paperCardboard:
        return 'Paper-Cardboard';
      case WasteType.mixed:
        return 'Mixed';
    }
  }
}

extension QualityLabel on WasteQuality {
  String get label {
    switch (this) {
      case WasteQuality.a:
        return 'Grade A';
      case WasteQuality.b:
        return 'Grade B';
      case WasteQuality.c:
        return 'Grade C';
    }
  }
}

// ─── AppUser ───────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final bool verified;
  final String? businessName;
  final String? companyName;
  final int greenScore;
  final String? vehicleType;
  final String? vehiclePlate;
  final double rating;
  final int completedRoutes;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.verified = true,
    this.businessName,
    this.companyName,
    this.greenScore = 0,
    this.vehicleType,
    this.vehiclePlate,
    this.rating = 0.0,
    this.completedRoutes = 0,
  });

  String get displayName => businessName ?? companyName ?? name;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'verified': verified,
        'businessName': businessName,
        'companyName': companyName,
        'greenScore': greenScore,
        'vehicleType': vehicleType,
        'vehiclePlate': vehiclePlate,
        'rating': rating,
        'completedRoutes': completedRoutes,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'],
        name: m['name'],
        email: m['email'],
        phone: m['phone'] ?? '',
        role: UserRole.values.firstWhere((r) => r.name == m['role'],
            orElse: () => UserRole.individual),
        verified: m['verified'] ?? true,
        businessName: m['businessName'],
        companyName: m['companyName'],
        greenScore: m['greenScore'] ?? 0,
        vehicleType: m['vehicleType'],
        vehiclePlate: m['vehiclePlate'],
        rating: (m['rating'] ?? 0.0).toDouble(),
        completedRoutes: m['completedRoutes'] ?? 0,
      );
}

// ─── WasteListing ──────────────────────────────────────────────────────────

class WasteListing {
  final String id;
  final String businessId;
  final String businessName;
  final WasteType wasteType;
  final double volume;
  final String unit; // kg or liters
  final WasteQuality quality;
  final List<String> photos;
  final double minBid;
  final double? reservePrice;
  final int auctionDuration; // hours
  final double? autoAcceptAbove;
  final ListingStatus status;
  final List<Bid> bids;
  final String? assignedRecycler;
  final String? assignedDriver;
  final DateTime? collectionDate;
  final String location;
  final DateTime createdAt;

  const WasteListing({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.wasteType,
    required this.volume,
    this.unit = 'liters',
    required this.quality,
    this.photos = const [],
    required this.minBid,
    this.reservePrice,
    this.auctionDuration = 24,
    this.autoAcceptAbove,
    this.status = ListingStatus.open,
    this.bids = const [],
    this.assignedRecycler,
    this.assignedDriver,
    this.collectionDate,
    required this.location,
    required this.createdAt,
  });

  double get bestBid =>
      bids.isEmpty ? 0 : bids.map((b) => b.amount).reduce((a, b) => a > b ? a : b);

  int get activeBidCount =>
      bids.where((b) => b.status == BidStatus.active).length;
}

// ─── Bid ───────────────────────────────────────────────────────────────────

class Bid {
  final String id;
  final String listingId;
  final String recyclerId;
  final String recyclerName;
  final double amount;
  final String? note;
  final String collectionPreference;
  final BidStatus status;
  final DateTime createdAt;

  const Bid({
    required this.id,
    required this.listingId,
    required this.recyclerId,
    required this.recyclerName,
    required this.amount,
    this.note,
    this.collectionPreference = 'flexible',
    this.status = BidStatus.active,
    required this.createdAt,
  });
}

// ─── Collection ────────────────────────────────────────────────────────────

class Collection {
  final String id;
  final String listingId;
  final String businessName;
  final String? businessAddress;
  final String recyclerName;
  final String? driverName;
  final String? driverId;
  final WasteType wasteType;
  final double volume;
  final CollectionStatus status;
  final DateTime scheduledDate;
  final String scheduledTime;
  final DateTime? completedAt;
  final List<String> proofPhotos;
  final double? actualWeight;
  final double? rating;
  final String? notes;
  final String location;
  final double earnings;

  const Collection({
    required this.id,
    required this.listingId,
    required this.businessName,
    this.businessAddress,
    required this.recyclerName,
    this.driverName,
    this.driverId,
    required this.wasteType,
    required this.volume,
    required this.status,
    required this.scheduledDate,
    this.scheduledTime = '09:00',
    this.completedAt,
    this.proofPhotos = const [],
    this.actualWeight,
    this.rating,
    this.notes,
    required this.location,
    this.earnings = 0,
  });
}

// ─── Driver Route & Stops ──────────────────────────────────────────────────

class RouteStop {
  final String id;
  final String businessName;
  final String location;
  final WasteType wasteType;
  final double volume;
  final String eta;
  RouteStopStatus status;
  final String contactPerson;
  final String contactPhone;
  final String? specialInstructions;
  double? actualWeight;
  List<String> photos;
  DateTime? completedAt;

  RouteStop({
    required this.id,
    required this.businessName,
    required this.location,
    required this.wasteType,
    required this.volume,
    required this.eta,
    this.status = RouteStopStatus.pending,
    required this.contactPerson,
    required this.contactPhone,
    this.specialInstructions,
    this.actualWeight,
    this.photos = const [],
    this.completedAt,
  });
}

class DriverRoute {
  final String id;
  final String driverId;
  final DateTime date;
  final List<RouteStop> stops;
  RouteStatus status;
  final double totalDistance;
  final double estimatedEarnings;
  double? actualEarnings;
  DateTime? startTime;
  DateTime? endTime;

  DriverRoute({
    required this.id,
    required this.driverId,
    required this.date,
    required this.stops,
    this.status = RouteStatus.pending,
    required this.totalDistance,
    required this.estimatedEarnings,
    this.actualEarnings,
    this.startTime,
    this.endTime,
  });

  int get completedStops =>
      stops.where((s) => s.status == RouteStopStatus.completed).length;
}

// ─── Transaction ───────────────────────────────────────────────────────────

class Transaction {
  final String id;
  final DateTime date;
  final String from;
  final String to;
  final WasteType wasteType;
  final double volume;
  final double amount;
  final double fee;
  final TransactionStatus status;
  final String listingId;
  final String? receipt;

  const Transaction({
    required this.id,
    required this.date,
    required this.from,
    required this.to,
    required this.wasteType,
    required this.volume,
    required this.amount,
    this.fee = 0,
    this.status = TransactionStatus.completed,
    required this.listingId,
    this.receipt,
  });
}

// ─── AppNotification ───────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;
  bool read;
  final String? link;
  final Map<String, dynamic>? meta;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
    this.link,
    this.meta,
  });
}
