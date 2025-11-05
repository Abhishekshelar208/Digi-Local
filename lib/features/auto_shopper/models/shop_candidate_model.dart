import 'dart:math' as math;

/// Model for shop and product candidates during auto-shopping
class ShopCandidate {
  final String shopId;
  final String shopName;
  final String productId; // Index in products array
  final String productName;
  final String productImage;
  final double price;
  final int stock;
  final double? rating;
  final double? distanceKm;
  final int? deliveryMinutes;
  final String? category;
  final String? shopAddress;
  final double? latitude;
  final double? longitude;
  final bool isOpen;
  
  // Scoring
  double score = 0.0;
  
  ShopCandidate({
    required this.shopId,
    required this.shopName,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.stock,
    this.rating,
    this.distanceKm,
    this.deliveryMinutes,
    this.category,
    this.shopAddress,
    this.latitude,
    this.longitude,
    this.isOpen = true,
  });

  factory ShopCandidate.fromShopAndProduct({
    required String shopId,
    required Map<String, dynamic> shopData,
    required int productIndex,
    required Map<String, dynamic> productData,
    double? userLat,
    double? userLng,
  }) {
    // Calculate distance if coordinates available
    double? distance;
    if (userLat != null && 
        userLng != null && 
        shopData['latitude'] != null && 
        shopData['longitude'] != null) {
      distance = calculateDistance(
        userLat, 
        userLng, 
        shopData['latitude'].toDouble(), 
        shopData['longitude'].toDouble(),
      );
    }

    // Estimate delivery time based on distance (rough estimate: 2 min per km + 15 min prep)
    int? deliveryMins;
    if (distance != null) {
      deliveryMins = (15 + (distance * 2)).toInt();
    }

    return ShopCandidate(
      shopId: shopId,
      shopName: shopData['shopInfo']?['shopName'] ?? shopData['name'] ?? 'Unknown Shop',
      productId: productIndex.toString(),
      productName: productData['title'] ?? 'Unknown Product',
      productImage: productData['image'] ?? '',
      price: double.tryParse(productData['productprice']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(productData['itemLeft']?.toString() ?? '0') ?? 0,
      rating: shopData['googleRating'] != null 
          ? double.tryParse(shopData['googleRating'].toString()) 
          : (shopData['rating'] != null 
              ? double.tryParse(shopData['rating'].toString()) 
              : null),
      distanceKm: distance,
      deliveryMinutes: deliveryMins,
      category: shopData['category'],
      shopAddress: shopData['shopInfo']?['address'] ?? shopData['address'] ?? 'No address',
      latitude: shopData['latitude']?.toDouble(),
      longitude: shopData['longitude']?.toDouble(),
      isOpen: shopData['open'] ?? true,
    );
  }

  // Haversine formula for distance calculation
  static double calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * 0.017453292519943295) * 
        math.cos(lat2 * 0.017453292519943295) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
        
    double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * 0.017453292519943295; // pi / 180
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'stock': stock,
      'rating': rating,
      'distanceKm': distanceKm,
      'deliveryMinutes': deliveryMinutes,
      'category': category,
      'shopAddress': shopAddress,
      'latitude': latitude,
      'longitude': longitude,
      'isOpen': isOpen,
      'score': score,
    };
  }

  String get displayDistance {
    if (distanceKm == null) return 'Distance unknown';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).toInt()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  String get displayDelivery {
    if (deliveryMinutes == null) return 'Delivery time unknown';
    if (deliveryMinutes! < 60) return '$deliveryMinutes min';
    return '${(deliveryMinutes! / 60).toStringAsFixed(1)} hr';
  }
}
