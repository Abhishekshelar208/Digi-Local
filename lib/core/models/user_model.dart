class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? profilePic;
  final UserRole userRole;
  final DateTime createdAt;
  final List<String>? shopIds; // For shop owners
  final Map<String, Address>? addresses; // For customers

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.userRole,
    required this.createdAt,
    this.shopIds,
    this.addresses,
  });

  // Convert from Firebase JSON
  factory UserModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserModel(
      userId: userId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['contactNo'] ?? json['phone'] ?? '',
      profilePic: json['shopPic'] ?? json['profilePic'],
      userRole: _parseUserRole(json['userRole']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      shopIds: json['shopIds'] != null 
          ? List<String>.from(json['shopIds']) 
          : null,
      addresses: json['addresses'] != null
          ? (json['addresses'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, Address.fromJson(value)))
          : null,
    );
  }

  // Convert to Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'contactNo': phone,
      'phone': phone,
      'shopPic': profilePic,
      'profilePic': profilePic,
      'userRole': userRole.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      if (shopIds != null) 'shopIds': shopIds,
      if (addresses != null)
        'addresses': addresses!.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  static UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.customer; // Default
    
    String roleStr = role.toString().toLowerCase();
    switch (roleStr) {
      case 'customer':
        return UserRole.customer;
      case 'shop_owner':
      case 'shopowner':
        return UserRole.shopOwner;
      case 'both':
        return UserRole.both;
      default:
        return UserRole.customer;
    }
  }

  // Helper methods
  bool isCustomer() => userRole == UserRole.customer || userRole == UserRole.both;
  bool isShopOwner() => userRole == UserRole.shopOwner || userRole == UserRole.both;
  bool hasShop() => shopIds != null && shopIds!.isNotEmpty;

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    UserRole? userRole,
    DateTime? createdAt,
    List<String>? shopIds,
    Map<String, Address>? addresses,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
      shopIds: shopIds ?? this.shopIds,
      addresses: addresses ?? this.addresses,
    );
  }
}

enum UserRole {
  customer,    // Customer only
  shopOwner,   // Shop owner only
  both,        // Both customer and shop owner
}

class Address {
  final String addressId;
  final String label; // "Home", "Work", "Other"
  final String fullAddress;
  final String city;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    required this.addressId,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'] ?? '',
      label: json['label'] ?? 'Home',
      fullAddress: json['fullAddress'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    String? addressId,
    String? label,
    String? fullAddress,
    String? city,
    String? zipCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      addressId: addressId ?? this.addressId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
