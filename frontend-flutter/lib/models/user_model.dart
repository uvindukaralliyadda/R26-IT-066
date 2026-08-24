class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String farmName;
  final String location;
  final double farmAreaHectares;
  final String createdAt;
  final bool isLoggedIn;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.farmName,
    required this.location,
    required this.farmAreaHectares,
    required this.createdAt,
    this.isLoggedIn = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'farmName': farmName,
      'location': location,
      'farmAreaHectares': farmAreaHectares,
      'createdAt': createdAt,
      'isLoggedIn': isLoggedIn,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? 'Paddy Farmer',
      farmName: json['farmName'] ?? 'AgriSmart Farm',
      location: json['location'] ?? 'Polonnaruwa, Sri Lanka',
      farmAreaHectares: (json['farmAreaHectares'] as num?)?.toDouble() ?? 2.5,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      isLoggedIn: json['isLoggedIn'] ?? true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? farmName,
    String? location,
    double? farmAreaHectares,
    String? createdAt,
    bool? isLoggedIn,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      farmAreaHectares: farmAreaHectares ?? this.farmAreaHectares,
      createdAt: createdAt ?? this.createdAt,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  static UserModel defaultGuest() {
    return UserModel(
      uid: 'guest_001',
      email: 'farmer@agrismart.ai',
      fullName: 'Kamal Perera',
      farmName: 'Green Valley Paddy Field',
      location: 'Polonnaruwa Sector 4',
      farmAreaHectares: 3.2,
      createdAt: DateTime.now().toIso8601String(),
      isLoggedIn: true,
    );
  }
}
