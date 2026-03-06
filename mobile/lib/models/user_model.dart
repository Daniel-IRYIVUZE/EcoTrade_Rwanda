enum UserRole { hotel, recycler, driver, admin, individual }

class UserModel {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final UserRole role;
  final double greenScore;
  final bool isVerified;
  final Map<String, dynamic>? profileData;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    this.greenScore = 0.0,
    this.isVerified = false,
    this.profileData,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    'role': role.name,
    'greenScore': greenScore,
    'isVerified': isVerified,
    'profileData': profileData,
    'photoUrl': photoUrl,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'].toString(),
    email: json['email'],
    phone: json['phone'] ?? '',
    fullName: json['full_name'] ?? json['fullName'] ?? '',
    role: _parseRole(json['role']),
    greenScore: json['greenScore']?.toDouble() ?? 0.0,
    isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
    profileData: json['profileData'] ?? json['hotel_profile'] ?? json['recycler_profile'] ?? json['driver_profile'],
    photoUrl: json['photoUrl'] ?? json['avatar'],
  );

  static UserRole _parseRole(dynamic value) {
    final raw = (value ?? '').toString();
    final normalized = raw.replaceAll('UserRole.', '');
    return UserRole.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => UserRole.individual,
    );
  }
}