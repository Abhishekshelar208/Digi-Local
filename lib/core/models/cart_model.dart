class CartModel {
  final String userId;
  final Map<String, CartItem> items;
  final int totalItems;
  final DateTime updatedAt;

  CartModel({
    required this.userId,
    required this.items,
    required this.totalItems,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json, String userId) {
    Map<String, CartItem> items = {};
    
    if (json['items'] != null) {
      (json['items'] as Map<String, dynamic>).forEach((key, value) {
        items[key] = CartItem.fromJson(value, key);
      });
    }

    return CartModel(
      userId: userId,
      items: items,
      totalItems: json['totalItems'] ?? items.length,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((key, value) => MapEntry(key, value.toJson())),
      'totalItems': totalItems,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Calculate total price
  double get totalPrice {
    return items.values.fold(0, (sum, item) => sum + item.subtotal);
  }

  // Group items by shop
  Map<String, List<CartItem>> get itemsByShop {
    Map<String, List<CartItem>> grouped = {};
    
    items.forEach((key, item) {
      if (!grouped.containsKey(item.shopId)) {
        grouped[item.shopId] = [];
      }
      grouped[item.shopId]!.add(item);
    });
    
    return grouped;
  }

  // Get total per shop
  Map<String, double> get totalPricePerShop {
    Map<String, double> shopTotals = {};
    
    itemsByShop.forEach((shopId, shopItems) {
      shopTotals[shopId] = shopItems.fold(
        0, 
        (sum, item) => sum + item.subtotal
      );
    });
    
    return shopTotals;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartModel copyWith({
    String? userId,
    Map<String, CartItem>? items,
    int? totalItems,
    DateTime? updatedAt,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CartItem {
  final String cartItemId;
  final String shopId;
  final String shopName;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.cartItemId,
    required this.shopId,
    required this.shopName,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, String cartItemId) {
    return CartItem(
      cartItemId: cartItemId,
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  double get subtotal => price * quantity;

  CartItem copyWith({
    String? cartItemId,
    String? shopId,
    String? shopName,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
