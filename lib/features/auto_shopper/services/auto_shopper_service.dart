import 'package:geolocator/geolocator.dart';
import '../models/parsed_query_model.dart';
import '../models/auto_shopper_result.dart';
import '../models/shop_candidate_model.dart';
import 'nlp_parsing_service.dart';
import 'product_search_service.dart';
import 'ranking_service.dart';

class AutoShopperService {
  final NLPParsingService _nlpService;
  final ProductSearchService _searchService;
  final RankingService _rankingService;

  AutoShopperService({required String geminiApiKey})
      : _nlpService = NLPParsingService(apiKey: geminiApiKey),
        _searchService = ProductSearchService(),
        _rankingService = RankingService();

  /// Main auto-shopping pipeline
  Future<AutoShopperResult> processQuery(String userQuery) async {
    try {
      // Step 1: Check for simple query bypass (Optimization)
      ParsedQuery parsedQuery;
      if (_isSimpleQuery(userQuery)) {
        print('⚡️ Simple query detected: Skipping NLP');
        parsedQuery = ParsedQuery(
          intent: 'search',
          product: userQuery,
          originalQuery: userQuery,
        );
      } else {
        // Complex query: Use Gemini NLP
        parsedQuery = await _nlpService.parseQuery(userQuery);
      }

      // Debug: Log parsed query
      print('🔍 Parsed Query:');
      print('  Product: ${parsedQuery.product}');
      print('  Price Limit: ${parsedQuery.priceLimit}');
      print('  Preference: ${parsedQuery.preference}');
      print('  Intent: ${parsedQuery.intent}');
      print('  Category: ${parsedQuery.category}');
      print('  Shop Name: ${parsedQuery.shopName}');
      print('  Min Rating: ${parsedQuery.minRating}');

      // Step 2: Get user location (optional)
      Position? userPosition;
      try {
        // Check and request permission first
        final hasPermission = await checkLocationPermission();
        if (hasPermission) {
          userPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print('Location not available: $e');
      }

      // Step 3: Search for matching products
      final candidates = await _searchService.searchProducts(
        parsedQuery,
        userLat: userPosition?.latitude,
        userLng: userPosition?.longitude,
        maxDistanceKm: 10.0,
      );
      
      // Debug: Log search results
      print('📦 Found ${candidates.length} matching products');
      if (candidates.isNotEmpty) {
        print('  Top 3: ${candidates.take(3).map((c) => c.productName).join(", ")}');
      }

      if (candidates.isEmpty) {
        return _handleNoResults(parsedQuery);
      }

      // Step 4: Rank candidates
      final rankedCandidates = _rankingService.rankCandidates(
        candidates,
        parsedQuery,
      );

      // Step 5: Decide action (confirm or clarify)
      if (_rankingService.isAmbiguous(rankedCandidates)) {
        // Ask clarifying question
        final question = _rankingService.getClarifyingQuestion(
          rankedCandidates.take(2).toList(),
        );
        return AutoShopperResult.clarify(
          question: question ?? 'Would you prefer faster delivery or better quality?',
          candidates: rankedCandidates.take(3).toList(),
        );
      } else {
        // Return top candidate for confirmation
        return AutoShopperResult.confirm(rankedCandidates.first);
      }
    } catch (e) {
      print('Auto-Shopper Error: $e');
      return AutoShopperResult.error('Failed to process your request: $e');
    }
  }

  /// Process clarification response and re-rank
  Future<AutoShopperResult> processClarification({
    required List<ShopCandidate> candidates,
    required String userResponse,
    required ParsedQuery originalQuery,
  }) async {
    try {
      // Update preference based on user response
      String? updatedPreference = _extractPreferenceFromResponse(userResponse);
      
      final updatedQuery = ParsedQuery(
        intent: originalQuery.intent,
        product: originalQuery.product,
        quantity: originalQuery.quantity,
        priceLimit: originalQuery.priceLimit,
        priceLimitMin: originalQuery.priceLimitMin,
        shopName: originalQuery.shopName,
        area: originalQuery.area,
        preference: updatedPreference ?? originalQuery.preference,
        deliveryTimeMinutes: originalQuery.deliveryTimeMinutes,
        category: originalQuery.category,
        minRating: originalQuery.minRating,
        originalQuery: originalQuery.originalQuery,
      );

      // Re-rank with updated preference
      final rankedCandidates = _rankingService.rankCandidates(
        candidates,
        updatedQuery,
      );

      return AutoShopperResult.confirm(rankedCandidates.first);
    } catch (e) {
      print('Clarification Error: $e');
      return AutoShopperResult.error('Failed to process clarification: $e');
    }
  }

  /// Handle no results scenario
  AutoShopperResult _handleNoResults(ParsedQuery query) {
    String suggestion = 'Try:\n';
    
    if (query.hasPriceLimit) {
      suggestion += '• Increasing your budget\n';
    }
    if (query.hasProduct) {
      suggestion += '• Using different product keywords\n';
    }
    if (query.hasArea) {
      suggestion += '• Expanding the search area\n';
    }
    
    suggestion += '• Browsing all available shops';

    return AutoShopperResult.noResults(suggestion: suggestion);
  }

  /// Extract preference from clarification response
  String? _extractPreferenceFromResponse(String response) {
    final lowerResponse = response.toLowerCase();
    
    if (lowerResponse.contains(RegExp(r'\b(fast|quick|nearest|closer)\b'))) {
      return 'fast';
    } else if (lowerResponse.contains(RegExp(r'\b(cheap|cheaper|lowest|less)\b'))) {
      return 'cheap';
    } else if (lowerResponse.contains(RegExp(r'\b(quality|best|better|rated)\b'))) {
      return 'quality';
    }
    
    return null;
  }

  /// Check location permission
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Check if query is simple enough to skip NLP
  bool _isSimpleQuery(String query) {
    final words = query.trim().split(' ');
    // If more than 3 words, treat as complex
    if (words.length > 3) return false;
    
    // If contains numbers or price keywords, treat as complex
    final lower = query.toLowerCase();
    if (lower.contains(RegExp(r'[0-9]')) || 
        lower.contains('price') || 
        lower.contains('under') || 
        lower.contains('cheap') || 
        lower.contains('best') || 
        lower.contains('near')) {
      return false;
    }
    
    return true;
  }
}
