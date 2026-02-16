/// Model for parsed natural language query
class ParsedQuery {
  final String intent; // 'order', 'search', 'find'
  final String? product;
  final int? quantity;
  final double? priceLimit;
  final double? priceLimitMin;
  final String? shopName;
  final String? area;
  final String? preference; // 'fast', 'quality', 'cheap'
  final int? deliveryTimeMinutes;
  final String? category;
  final double? minRating;
  final String originalQuery;

  ParsedQuery({
    required this.intent,
    this.product,
    this.quantity,
    this.priceLimit,
    this.priceLimitMin,
    this.shopName,
    this.area,
    this.preference,
    this.deliveryTimeMinutes,
    this.category,
    this.minRating,
    required this.originalQuery,
  });

  factory ParsedQuery.fromJson(Map<String, dynamic> json) {
    return ParsedQuery(
      intent: json['intent'] ?? 'search',
      product: json['product'],
      quantity: json['quantity']?.toInt() ?? 1,
      priceLimit: json['price_limit'] != null 
          ? double.tryParse(json['price_limit'].toString()) 
          : null,
      priceLimitMin: json['price_limit_min'] != null
          ? double.tryParse(json['price_limit_min'].toString())
          : null,
      shopName: json['shop_name'],
      area: json['area'],
      preference: json['preference'],
      deliveryTimeMinutes: json['delivery_time']?.toInt(),
      category: json['category'],
      minRating: json['min_rating'] != null
          ? double.tryParse(json['min_rating'].toString())
          : null,
      originalQuery: json['original_query'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intent': intent,
      'product': product,
      'quantity': quantity,
      'price_limit': priceLimit,
      'price_limit_min': priceLimitMin,
      'shop_name': shopName,
      'area': area,
      'preference': preference,
      'delivery_time': deliveryTimeMinutes,
      'category': category,
      'min_rating': minRating,
      'original_query': originalQuery,
    };
  }

  bool get hasProduct => product != null && product!.isNotEmpty;
  bool get hasPriceLimit => priceLimit != null;
  bool get hasShopName => shopName != null && shopName!.isNotEmpty;
  bool get hasArea => area != null && area!.isNotEmpty;
  bool get hasPreference => preference != null && preference!.isNotEmpty;
  bool get hasCategory => category != null && category!.isNotEmpty;
  bool get hasIntent => intent.isNotEmpty;
}
