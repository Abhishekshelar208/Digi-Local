import 'package:firebase_database/firebase_database.dart';
import '../models/parsed_query_model.dart';
import '../models/shop_candidate_model.dart';

class ProductSearchService {
  final DatabaseReference _dbRef;
  
  ProductSearchService() 
      : _dbRef = FirebaseDatabase.instance.ref('DigiLocal');

  /// Search for products matching the parsed query
  Future<List<ShopCandidate>> searchProducts(
    ParsedQuery query, {
    double? userLat,
    double? userLng,
    double maxDistanceKm = 10.0,
  }) async {
    try {
      print('🔎 Starting product search...');
      print('  Query product: "${query.product}"');
      print('  Price limit: ${query.priceLimit}');
      
      // Fetch all shops
      final snapshot = await _dbRef.once();
      if (snapshot.snapshot.value == null) {
        print('  ❌ No data in Firebase!');
        return [];
      }

      final shopsData = Map<String, dynamic>.from(
        snapshot.snapshot.value as Map
      );
      
      print('  📍 Found ${shopsData.length} shops in database');

      List<ShopCandidate> candidates = [];
      int totalProducts = 0;

      // Iterate through all shops
      int shopsWithProducts = 0;
      int shopsSkipped = 0;
      int shopsParsed = 0;
      String skipReason = '';
      
      for (final entry in shopsData.entries) {
        final shopId = entry.key;
        shopsParsed++;
        
        try {
          final shopData = Map<String, dynamic>.from(entry.value as Map);
          
          // Debug: Log first shop structure
          if (shopsWithProducts == 0 && shopsParsed == 1) {
            print('  🏪 First shop structure:');
            print('    Shop ID: $shopId');
            print('    Keys: ${shopData.keys.take(15).join(", ")}');
            print('    Has Products? ${shopData.containsKey("Products")}');
            if (shopData.containsKey('Products')) {
              print('    Products type: ${shopData['Products'].runtimeType}');
              final prodList = shopData['Products'] as List?;
              print('    Products length: ${prodList?.length ?? 0}');
              if (prodList != null && prodList.isNotEmpty) {
                final firstProd = prodList[0];
                print('    First product type: ${firstProd.runtimeType}');
                if (firstProd is Map) {
                  final prodMap = Map<String, dynamic>.from(firstProd as Map);
                  print('    First product keys: ${prodMap.keys.join(", ")}');
                  print('    Product title: ${prodMap['title']}');
                  print('    Product price: ${prodMap['productprice']}');
                  print('    Product stock: ${prodMap['itemLeft']}');
                }
              }
            }
          }

        // Filter by shop name if specified
        if (query.hasShopName) {
          final shopName = (shopData['shopInfo']?['shopName'] ?? shopData['name'] ?? '').toString().toLowerCase();
          if (!shopName.contains(query.shopName!.toLowerCase())) {
            shopsSkipped++;
            skipReason = 'shop name mismatch';
            continue;
          }
        }

        // Filter by category if specified
        // ONLY filter if user explicitly mentioned a specific category
        // Don't filter on generic food items like "pizza", "cake", etc.
        if (query.category != null && query.category!.isNotEmpty) {
          final categoryLower = query.category!.toLowerCase();
          // Skip category filter for generic food/product terms
          final isGenericTerm = ['food', 'product', 'item', 'goods'].contains(categoryLower);
          
          if (!isGenericTerm) {
            final shopCategory = (shopData['category'] ?? '').toString().toLowerCase();
            if (shopCategory.isNotEmpty && !shopCategory.contains(categoryLower)) {
              shopsSkipped++;
              skipReason = 'category mismatch (shop: "$shopCategory" vs query: "$categoryLower")';
              continue;
            }
          }
        }

        // Filter by rating if specified
        if (query.minRating != null) {
          final ratingStr = shopData['googleRating'] ?? shopData['rating'];
          if (ratingStr != null) {
            final rating = double.tryParse(ratingStr.toString()) ?? 0.0;
            if (rating < query.minRating!) {
              continue;
            }
          }
        }

        // Check if shop is open (if field exists)
        final isOpen = shopData['open'] ?? true;
        if (!isOpen) {
          shopsSkipped++;
          skipReason = 'shop closed';
          continue; // Skip closed shops
        }

        // Calculate distance if location available
        double? distance;
        if (userLat != null && 
            userLng != null && 
            shopData['latitude'] != null && 
            shopData['longitude'] != null) {
          distance = ShopCandidate.calculateDistance(
            userLat,
            userLng,
            shopData['latitude'].toDouble(),
            shopData['longitude'].toDouble(),
          );
          
          // Filter by max distance
          if (distance > maxDistanceKm) {
            shopsSkipped++;
            skipReason = 'too far (${distance.toStringAsFixed(1)} km)';
            continue;
          }
        }

        // Search products in this shop
        if (shopData['Products'] != null) {
          shopsWithProducts++;
          final products = shopData['Products'] as List;
          totalProducts += products.length;
          
          for (int i = 0; i < products.length; i++) {
            final product = Map<String, dynamic>.from(products[i] as Map);
            
            // Match product name with query
            if (query.hasProduct) {
              final productName = (product['title'] ?? '').toString().toLowerCase();
              final productDesc = (product['description'] ?? '').toString().toLowerCase();
              final queryProduct = query.product!.toLowerCase();
              
              // Extract key words from query (remove common words)
              final queryWords = queryProduct
                  .split(' ')
                  .where((w) => !['the', 'a', 'an', 'for', 'me', 'best', 'good', 'order', 'get', 'find'].contains(w))
                  .toList();
              
              // Check if ANY key word matches
              bool hasMatch = false;
              for (final word in queryWords) {
                if (word.length < 3) continue; // Skip very short words
                if (productName.contains(word) || productDesc.contains(word)) {
                  hasMatch = true;
                  break;
                }
              }
              
              // If no word match found, skip this product
              if (!hasMatch && queryWords.isNotEmpty) {
                continue;
              }
            }

            // Parse product price
            final price = double.tryParse(
              product['productprice']?.toString() ?? '0'
            ) ?? 0.0;
            
            // Filter by price limit
            if (query.hasPriceLimit && price > query.priceLimit!) {
              continue;
            }

            if (query.priceLimitMin != null && price < query.priceLimitMin!) {
              continue;
            }

            // Check stock
            final stock = int.tryParse(
              product['itemLeft']?.toString() ?? '0'
            ) ?? 0;
            
            if (stock <= 0) {
              continue; // Out of stock
            }

            // Create candidate
            final candidate = ShopCandidate.fromShopAndProduct(
              shopId: shopId,
              shopData: shopData,
              productIndex: i,
              productData: product,
              userLat: userLat,
              userLng: userLng,
            );

            candidates.add(candidate);
          }
        }
        } catch (e) {
          print('  ⚠️ Error parsing shop $shopId: $e');
          shopsSkipped++;
          skipReason = 'parse error';
        }
      }
      
      print('  ✅ Shops parsed: $shopsParsed');
      print('  ✅ Shops skipped: $shopsSkipped (last reason: $skipReason)');
      print('  ✅ Shops with Products field: $shopsWithProducts');
      print('  ✅ Searched $totalProducts total products');
      print('  ✅ Found ${candidates.length} matching candidates');

      return candidates;
    } catch (e) {
      print('❌ Product Search Error: $e');
      print('   Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Get specific product from shop
  Future<ShopCandidate?> getProduct({
    required String shopId,
    required int productIndex,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final snapshot = await _dbRef.child(shopId).once();
      if (snapshot.snapshot.value == null) {
        return null;
      }

      final shopData = Map<String, dynamic>.from(
        snapshot.snapshot.value as Map
      );

      if (shopData['Products'] == null) {
        return null;
      }

      final products = shopData['Products'] as List;
      if (productIndex >= products.length) {
        return null;
      }

      final product = Map<String, dynamic>.from(products[productIndex] as Map);

      return ShopCandidate.fromShopAndProduct(
        shopId: shopId,
        shopData: shopData,
        productIndex: productIndex,
        productData: product,
        userLat: userLat,
        userLng: userLng,
      );
    } catch (e) {
      print('Get Product Error: $e');
      return null;
    }
  }
}
