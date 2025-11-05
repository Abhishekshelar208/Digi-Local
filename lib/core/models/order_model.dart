class OrderModel {
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DeliveryAddress deliveryAddress;
  final Map<String, OrderItem> items;
  final OrderSummary orderSummary;
  final PaymentInfo paymentInfo;
  final OrderStatus status;
  final Map<String, ShopOrder> shopOrders;
  final List<OrderTimeline> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.orderSummary,
    required this.paymentInfo,
    required this.status,
    required this.shopOrders,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String orderId) {
    return OrderModel(
      orderId: orderId,
      orderNumber: json['orderNumber'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
      items: (json['items'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, OrderItem.fromJson(value, key)),
          ) ?? {},
      orderSummary: OrderSummary.fromJson(json['orderSummary'] ?? {}),
      paymentInfo: PaymentInfo.fromJson(json['paymentInfo'] ?? {}),
      status: _parseOrderStatus(json['status']),
      shopOrders: (json['shopOrders'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, ShopOrder.fromJson(value, key)),
          ) ?? {},
      timeline: (json['timeline'] as List?)
              ?.map((item) => OrderTimeline.fromJson(item))
              .toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress.toJson(),
      'items': items.map((key, value) => MapEntry(key, value.toJson())),
      'orderSummary': orderSummary.toJson(),
      'paymentInfo': paymentInfo.toJson(),
      'status': status.toString().split('.').last,
      'shopOrders': shopOrders.map((key, value) => MapEntry(key, value.toJson())),
      'timeline': timeline.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;
    
    String statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'out_for_delivery':
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get unique shops from order
  Set<String> get shopIds => items.values.map((item) => item.shopId).toSet();
  
  int get totalItemsCount => items.values.fold(0, (sum, item) => sum + item.quantity);
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderItem {
  final String itemId;
  final String shopId;
  final String shopName;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItem({
    required this.itemId,
    required this.shopId,
    required this.shopName,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json, String itemId) {
    return OrderItem(
      itemId: itemId,
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
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
      'subtotal': subtotal,
    };
  }
}

class DeliveryAddress {
  final String fullAddress;
  final String city;
  final String zipCode;
  final double latitude;
  final double longitude;

  DeliveryAddress({
    required this.fullAddress,
    required this.city,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      fullAddress: json['fullAddress'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullAddress': fullAddress,
      'city': city,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class OrderSummary {
  final double subtotal;
  final double deliveryCharge;
  final double tax;
  final double total;

  OrderSummary({
    required this.subtotal,
    required this.deliveryCharge,
    required this.tax,
    required this.total,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'tax': tax,
      'total': total,
    };
  }
}

class PaymentInfo {
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime? paidAt;

  PaymentInfo({
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: _parsePaymentMethod(json['method']),
      status: _parsePaymentStatus(json['status']),
      transactionId: json['transactionId'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last,
      if (transactionId != null) 'transactionId': transactionId,
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
    };
  }

  static PaymentMethod _parsePaymentMethod(dynamic method) {
    if (method == null) return PaymentMethod.cod;
    
    String methodStr = method.toString().toLowerCase();
    switch (methodStr) {
      case 'cod':
        return PaymentMethod.cod;
      case 'upi':
        return PaymentMethod.upi;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.cod;
    }
  }

  static PaymentStatus _parsePaymentStatus(dynamic status) {
    if (status == null) return PaymentStatus.pending;
    
    String statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}

enum PaymentMethod { cod, upi, card }
enum PaymentStatus { pending, paid, failed }

class ShopOrder {
  final String shopId;
  final String shopName;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;

  ShopOrder({
    required this.shopId,
    required this.shopName,
    required this.status,
    required this.items,
    required this.subtotal,
    this.confirmedAt,
    this.deliveredAt,
  });

  factory ShopOrder.fromJson(Map<String, dynamic> json, String shopId) {
    return ShopOrder(
      shopId: shopId,
      shopName: json['shopName'] ?? '',
      status: OrderModel._parseOrderStatus(json['status']),
      items: (json['items'] as List?)
              ?.asMap()
              .map((index, item) => MapEntry(
                    index.toString(),
                    OrderItem.fromJson(item, index.toString()),
                  ))
              .values
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
      if (deliveredAt != null) 'deliveredAt': deliveredAt!.toIso8601String(),
    };
  }
}

class OrderTimeline {
  final OrderStatus status;
  final DateTime timestamp;
  final String message;

  OrderTimeline({
    required this.status,
    required this.timestamp,
    required this.message,
  });

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(
      status: OrderModel._parseOrderStatus(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }
}
