import 'package:algoliasearch/algoliasearch.dart';
import '../../../config/algolia_config.dart';
import '../models/parsed_query_model.dart';
import '../models/shop_candidate_model.dart';

class ProductSearchService {
  final SearchClient _algoliaClient;
  
  ProductSearchService() 
      : _algoliaClient = SearchClient(
          appId: AlgoliaConfig.appId,
          apiKey: AlgoliaConfig.searchApiKey,
        );

  /// Search for products using Algolia
  Future<List<ShopCandidate>> searchProducts(
    ParsedQuery query, {
    double? userLat,
    double? userLng,
    double maxDistanceKm = 10.0,
  }) async {
    try {
      if (!query.hasProduct && !query.hasCategory && !query.hasIntent) {
        return [];
      }

      print('🔎 Starting Algolia search for: "${query.product ?? query.category}"');

      // 1. Build Algolia Query & Execute
      final response = await _algoliaClient.search(
        searchMethodParams: SearchMethodParams(
          requests: [
            SearchForHits(
              indexName: AlgoliaConfig.indexName,
              query: query.product ?? query.category ?? '',
              hitsPerPage: 20,
              filters: _buildFilters(query),
              aroundLatLng: (userLat != null && userLng != null) 
                  ? '$userLat, $userLng' 
                  : null,
              aroundRadius: (maxDistanceKm * 1000).toInt(), // Convert km to meters
            ),
          ],
        ),
      );

      // 3. Convert Hit to ShopCandidate
      List<ShopCandidate> candidates = [];
      
      if (response.results.isNotEmpty) {
        final hits = response.results.first.hits;
        print('  ✅ Algolia found ${hits.length} matches');

        for (final hit in hits) {
        try {
          // Parse fields from Algolia Hit
          final shopId = hit['shopId'] as String;
          final productId = hit['objectID'] as String;
          
          // Construct candidate from hit data
          // We assume 'productIndex' isn't critical anymore or we map it differently.
          // For now, we mock productIndex as 0 since we have the direct product data.
          
          final candidate = ShopCandidate(
            shopId: shopId,
            shopName: hit['shopName'] as String? ?? 'Unknown Shop',
            productId: productId,
            productName: hit['title'] as String? ?? 'Unknown Product',
            productImage: hit['image'] as String? ?? '',
            price: (hit['price'] as num?)?.toDouble() ?? 0.0,
            stock: (hit['isInStock'] as bool? ?? false) ? 100 : 0, // Mock stock if simplified
            rating: (hit['rating'] as num?)?.toDouble() ?? 0.0,
            distanceKm: _calculateDistance(userLat, userLng, hit),
            deliveryMinutes: 30,
            category: hit['category'] as String?,
            shopAddress: hit['shopArea'] as String?,
            latitude: (hit['_geoloc'] as Map?)?['lat'] as double?,
            longitude: (hit['_geoloc'] as Map?)?['lng'] as double?,
          );
          
          candidates.add(candidate);
        } catch (e) {
          print('Error parsing hit: $e');
        }
      }
      } // Closing the if-block

      return candidates;
    } catch (e) {
      print('❌ Algolia Search Error: $e');
      if (e.toString().contains("ApplicationID")) {
         print("⚠️ It looks like API keys are missing. Please configure lib/config/algolia_config.dart");
      }
      return [];
    }
  }

  String? _buildFilters(ParsedQuery query) {
    List<String> filters = [];
    
    if (query.hasPriceLimit) {
      filters.add('price <= ${query.priceLimit}');
    }
    
    if (query.priceLimitMin != null) {
      filters.add('price >= ${query.priceLimitMin}');
    }
    
    if (query.minRating != null) {
      filters.add('rating >= ${query.minRating}');
    }
    
    if (filters.isEmpty) return null;
    return filters.join(' AND ');
  }

  double? _calculateDistance(double? lat1, double? long1, Map<String, dynamic> hit) {
    if (lat1 == null || long1 == null) return null;
    final geo = hit['_geoloc'] as Map?;
    if (geo == null) return null;
    
    final lat2 = geo['lat'] as double?;
    final long2 = geo['lng'] as double?;
    
    if (lat2 == null || long2 == null) return null;
    
    return ShopCandidate.calculateDistance(lat1, long1, lat2, long2);
  }
}
