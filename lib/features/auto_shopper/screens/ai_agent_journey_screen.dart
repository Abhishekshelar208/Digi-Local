import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../pages/UsersListPage.dart';
import '../../../pages/userdatapageforall.dart';
import '../../../pages/home_screen.dart';

/// AI Agent Journey Screen - Shows complete navigation journey
class AIAgentJourneyScreen extends StatefulWidget {
  final String query;

  const AIAgentJourneyScreen({
    super.key,
    required this.query,
  });

  @override
  State<AIAgentJourneyScreen> createState() => _AIAgentJourneyScreenState();
}

class _AIAgentJourneyScreenState extends State<AIAgentJourneyScreen> {
  String _currentStep = '';
  String _currentAction = '';
  bool _isComplete = false;
  
  @override
  void initState() {
    super.initState();
    _startJourney();
  }

  Future<void> _startJourney() async {
    // Step 1: Analyze query
    _updateStep('Analyzing', 'Understanding: "${widget.query}"');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Step 2: Navigate to Home screen
    _updateStep('Opening Home', 'Navigating to home screen...');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Step 3: Detect category and fetch shops
    final category = _detectCategory(widget.query);
    _updateStep('Category Detected', 'Found: $category');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    _updateStep('Fetching Shops', 'Loading shops in $category...');
    final shops = await _fetchShops(category);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (shops.isEmpty) {
      _updateStep('No Shops Found', 'Try a different search');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context); // Pop home
      if (mounted) Navigator.pop(context); // Pop AI screen
      return;
    }

    // Step 4: Navigate to shop list (category screen)
    _updateStep('Opening Category', 'Showing ${shops.length} shops...');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    // Create a completer to wait for shops to be loaded
    bool shopsLoaded = false;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsersListPage(
          category: category,
          usersList: shops.map((s) => {
            'userId': s['id'],
            'fullName': s['name'],
            'userTitle': category,
            'profilePicture': s['data']['shopInfo']['shopImage'] ?? '',
            'userData': s['data'],
          }).toList(),
          onShopsLoaded: () {
            shopsLoaded = true;
          },
        ),
      ),
    );
    
    // Wait for location permission and shops to be sorted
    _updateStep('Waiting for Location', 'Requesting permission...');
    while (!shopsLoaded && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    _updateStep('Shops Loaded', 'Found ${shops.length} nearby shops');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Step 5: Scan shops and find best product
    print('[AI Agent] Starting to scan ${shops.length} shops');
    final bestMatch = await _scanShops(shops, category);
    print('[AI Agent] Scan complete. Best match: ${bestMatch != null}');
    if (!mounted) return;

    // Step 6: Navigate to best shop with product
    if (bestMatch != null) {
      _updateStep('Best Match Found!', 
                  '${bestMatch['product']['title']} at ${bestMatch['shop']['name']}');
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      
      // Navigate to the winning shop and scroll to product
      final shopData = bestMatch['shop']['data'] as Map<String, dynamic>?;
      if (shopData != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDataPageForAll(
              userData: shopData,
              aiMode: true,
              highlightProductIndex: bestMatch['productIndex'],
              onAINavigationComplete: () {
                if (mounted) {
                  setState(() => _isComplete = true);
                }
              },
            ),
          ),
        );
      }
    } else {
      _updateStep('Search Complete', 'No exact match found');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context); // Pop shop list
      if (mounted) Navigator.pop(context); // Pop home
      if (mounted) Navigator.pop(context); // Pop AI screen
    }
  }

  void _updateStep(String step, String action) {
    if (!mounted) return;
    setState(() {
      _currentStep = step;
      _currentAction = action;
    });
  }

  String _detectCategory(String query) {
    final lower = query.toLowerCase();
    
    // Grocery Stores
    if (lower.contains('grocery') || lower.contains('vegetable') || lower.contains('fruit') ||
        lower.contains('supermarket') || lower.contains('produce') || lower.contains('daily needs')) {
      return 'Grocery Stores';
    }
    
    // Restaurants & Cafes
    if (lower.contains('restaurant') || lower.contains('cafe') || lower.contains('food') ||
        lower.contains('eatery') || lower.contains('cake') || lower.contains('dining') ||
        lower.contains('bakery') || lower.contains('pizza') || lower.contains('burger') ||
        lower.contains('coffee') || lower.contains('tea') || lower.contains('meal') ||
        lower.contains('breakfast') || lower.contains('lunch') || lower.contains('dinner')) {
      return 'Restaurants & Cafes';
    }
    
    // Fashion & Clothing
    if (lower.contains('clothing') || lower.contains('fashion') || lower.contains('apparel') ||
        lower.contains('boutique') || lower.contains('footwear') || lower.contains('accessory') ||
        lower.contains('designer') || lower.contains('shirt') || lower.contains('dress') ||
        lower.contains('pants') || lower.contains('shoes') || lower.contains('jeans') ||
        lower.contains('saree') || lower.contains('kurta') || lower.contains('jewel') ||
        lower.contains('necklace') || lower.contains('ring') || lower.contains('watch')) {
      return 'Fashion & Clothing';
    }
    
    // Electronics
    if (lower.contains('electronic') || lower.contains('gadget') || lower.contains('mobile') ||
        lower.contains('phone') || lower.contains('laptop') || lower.contains('computer') ||
        lower.contains('tv') || lower.contains('appliance') || lower.contains('tech') ||
        lower.contains('camera') || lower.contains('headphone') || lower.contains('speaker')) {
      return 'Electronics';
    }
    
    // Home & Furniture
    if (lower.contains('furniture') || lower.contains('home decor') || lower.contains('interior') ||
        lower.contains('sofa') || lower.contains('bed') || lower.contains('lighting') ||
        lower.contains('curtain') || lower.contains('woodwork') || lower.contains('table') ||
        lower.contains('chair') || lower.contains('wardrobe')) {
      return 'Home & Furniture';
    }
    
    // Beauty & Wellness
    if (lower.contains('beauty') || lower.contains('salon') || lower.contains('spa') ||
        lower.contains('skincare') || lower.contains('cosmetic') || lower.contains('makeup') ||
        lower.contains('haircare') || lower.contains('wellness') || lower.contains('facial') ||
        lower.contains('massage') || lower.contains('manicure') || lower.contains('pedicure')) {
      return 'Beauty & Wellness';
    }
    
    // Automobile Services
    if (lower.contains('automobile') || lower.contains('car') || lower.contains('bike') ||
        lower.contains('vehicle') || lower.contains('mechanic') || lower.contains('repair') ||
        lower.contains('spare part') || lower.contains('maintenance') || lower.contains('garage')) {
      return 'Automobile Services';
    }
    
    // Pharmacies
    if (lower.contains('pharmacy') || lower.contains('medical') || lower.contains('medicine') ||
        lower.contains('healthcare') || lower.contains('chemist') || lower.contains('drugstore') ||
        lower.contains('tablet') || lower.contains('drug') || lower.contains('prescription')) {
      return 'Pharmacies';
    }
    
    // Sports & Fitness
    if (lower.contains('sport') || lower.contains('gym') || lower.contains('fitness') ||
        lower.contains('workout') || lower.contains('exercise') || lower.contains('athletic') ||
        lower.contains('training') || lower.contains('yoga') || lower.contains('cricket') ||
        lower.contains('football') || lower.contains('badminton')) {
      return 'Sports & Fitness';
    }
    
    // Handicrafts & Art
    if (lower.contains('handicraft') || lower.contains('art') || lower.contains('handmade') ||
        lower.contains('gift') || lower.contains('pottery') || lower.contains('craft') ||
        lower.contains('artwork') || lower.contains('painting') || lower.contains('sculpture')) {
      return 'Handicrafts & Art';
    }
    
    // Pet Shops
    if (lower.contains('pet') || lower.contains('animal') || lower.contains('dog') ||
        lower.contains('cat') || lower.contains('veterinary') || lower.contains('pet food') ||
        lower.contains('pet care') || lower.contains('grooming')) {
      return 'Pet Shops';
    }
    
    // Default: All Categories
    return 'All Categories';
  }

  Future<void> _navigateToHome() async {
    // Navigate to HomeScreen (categories screen)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomeScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    
    // Wait briefly to show the screen
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Immediately pop back to show we "visited"
    if (mounted) Navigator.pop(context);
  }

  Future<List<Map<String, dynamic>>> _fetchShops(String category) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('DigiLocal').once();
      if (snapshot.snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      List<Map<String, dynamic>> shops = [];

      data.forEach((key, value) {
        final shopData = Map<String, dynamic>.from(value as Map);
        final shopCategory = shopData['category'] ?? '';
        
        if (_matchesCategory(shopCategory, category)) {
          shops.add({
            'id': key,
            'name': shopData['shopInfo']['shopName'] ?? 'Unknown',
            'data': shopData,
          });
        }
      });

      return shops;
    } catch (e) {
      return [];
    }
  }

  bool _matchesCategory(String shopCat, String targetCat) {
    return shopCat.toLowerCase().contains(targetCat.toLowerCase()) ||
           targetCat.toLowerCase().contains(shopCat.toLowerCase());
  }

  Future<Map<String, dynamic>?> _scanShops(List<Map<String, dynamic>> shops, String category) async {
    final keyword = _extractKeyword(widget.query);
    final intent = _detectIntent(widget.query);
    
    print('[AI Agent] Scanning shops. Count: ${shops.length}, Intent: $intent, Keyword: $keyword');
    
    Map<String, dynamic>? bestShop;
    Map<String, dynamic>? bestProduct;
    int bestProductIndex = 0;
    double bestPrice = double.infinity;
    double bestRating = 0.0;
    double bestDistance = double.infinity;

    // Check if only one shop - special case
    if (shops.length == 1) {
      print('[AI Agent] Only 1 shop found - direct navigation');
      final shop = shops[0];
      _updateStep('Found 1 Shop', 'Opening: ${shop['name']}');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return null;
      
      // Search products in this shop (before navigating)
      final products = shop['data']['Products'] as List?;
      if (products != null) {
        for (int productIdx = 0; productIdx < products.length; productIdx++) {
          final productMap = Map<String, dynamic>.from(products[productIdx] as Map);
          final productName = (productMap['title'] ?? '').toString().toLowerCase();
          
          // Fuzzy matching for single shop too
          bool matches = productName.contains(keyword.toLowerCase());
          
          if (!matches) {
            final variations = _getKeywordVariations(keyword.toLowerCase());
            matches = variations.any((variation) => productName.contains(variation));
          }
          
          if (matches) {
            final price = double.tryParse(productMap['productprice']?.toString() ?? '0') ?? 0;
            
            // Check price limit
            final priceLimit = _extractPriceLimit(widget.query);
            if (priceLimit != null && price > priceLimit) continue;
            
            // Is this the best?
            if (price < bestPrice && price > 0) {
              bestPrice = price;
              bestShop = shop;
              bestProduct = productMap;
              bestProductIndex = productIdx;
            }
          }
        }
      }
      
      // For single shop, navigate to shop with product highlight
      if (bestShop != null && bestProduct != null) {
        _updateStep('Match Found!', 
                    '${bestProduct['title']} - ₹${bestPrice.toStringAsFixed(0)}');
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return null;
        
        // Navigate to the shop and scroll to product - DON'T pop back
        final shopData = bestShop['data'] as Map<String, dynamic>?;
        if (shopData != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDataPageForAll(
                userData: shopData,
                aiMode: true,
                highlightProductIndex: bestProductIndex,
                onAINavigationComplete: () {
                  if (mounted) {
                    setState(() => _isComplete = true);
                  }
                },
              ),
            ),
          );
        }
        
        // Return null since we already navigated
        return null;
      } else {
        // No matching product found in single shop
        _updateStep('Checking Products', 'Searching in ${shop['name']}...');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return null;
        
        // Navigate to shop anyway to browse
        final shopData = shop['data'] as Map<String, dynamic>?;
        if (shopData != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDataPageForAll(
                userData: shopData,
                aiMode: true,
                onAINavigationComplete: () {
                  if (mounted) {
                    setState(() => _isComplete = true);
                  }
                },
              ),
            ),
          );
        }
        return null;
      }
    }

    // Multiple shops - browse and compare
    int shopsToVisit = shops.length > 3 ? 3 : shops.length;
    print('[AI Agent] Multiple shops detected. Will visit $shopsToVisit shops');
    
    for (int i = 0; i < shopsToVisit; i++) {
      print('[AI Agent] Visiting shop ${i + 1}/$shopsToVisit: ${shops[i]['name']}');
      if (!mounted) return null;
      final shop = shops[i];
      
      _updateStep('Scanning Shop ${i + 1}/$shopsToVisit', 
                  'Checking: ${shop['name']}');
      
      // Navigate to shop and auto-scroll
      print('[AI Agent] Navigating to shop: ${shop['name']}');
      await _navigateAndScanShop(shop);
      print('[AI Agent] Back from shop: ${shop['name']}');
      if (!mounted) return null;
      
      // Get shop metrics for comparison
      final shopRating = double.tryParse(shop['data']['googleRating']?.toString() ?? '0') ?? 0.0;
      final shopDistance = double.tryParse(shop['data']['shopInfo']?['distance']?.toString() ?? '999999') ?? double.infinity;
      
      // Search products in this shop
      final products = shop['data']['Products'] as List?;
      if (products != null) {
        for (int productIdx = 0; productIdx < products.length; productIdx++) {
          final productMap = Map<String, dynamic>.from(products[productIdx] as Map);
          final productName = (productMap['title'] ?? '').toString().toLowerCase();
          
          // Fuzzy matching - check if product name contains keyword or keyword is similar
          bool matches = productName.contains(keyword.toLowerCase());
          
          // Also check for common spelling variations
          if (!matches) {
            final variations = _getKeywordVariations(keyword.toLowerCase());
            matches = variations.any((variation) => productName.contains(variation));
          }
          
          if (matches) {
            final price = double.tryParse(productMap['productprice']?.toString() ?? '0') ?? 0;
            
            // Check price limit
            final priceLimit = _extractPriceLimit(widget.query);
            if (priceLimit != null && price > priceLimit) continue;
            
            // Compare based on intent
            bool isBetter = false;
            
            if (intent == 'quality') {
              // Compare by rating (higher is better)
              isBetter = (shopRating > bestRating) || 
                        (shopRating == bestRating && price < bestPrice);
            } else if (intent == 'distance') {
              // Compare by distance (lower is better)
              isBetter = (shopDistance < bestDistance) || 
                        (shopDistance == bestDistance && price < bestPrice);
            } else {
              // Default: compare by price (lower is better)
              isBetter = (price < bestPrice && price > 0);
            }
            
            if (isBetter) {
              bestPrice = price;
              bestRating = shopRating;
              bestDistance = shopDistance;
              bestShop = shop;
              bestProduct = productMap;
              bestProductIndex = productIdx;
            }
          }
        }
      }
      
      // Pop back to shop list for next shop
      if (i < shopsToVisit - 1) {
        if (mounted) Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        // Last shop - pop back to prepare for final navigation
        if (mounted) Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (!mounted) return null;
    }

    // Return best match for multiple shops
    if (bestShop != null && bestProduct != null) {
      return {
        'shop': bestShop,
        'product': bestProduct,
        'productIndex': bestProductIndex,
        'price': bestPrice,
      };
    }
    return null;
  }

  Future<void> _navigateAndScanShop(Map<String, dynamic> shop) async {
    // Navigate to shop details with AI mode enabled
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDataPageForAll(
          userData: shop['data'],
          aiMode: true, // Enable auto-scroll
        ),
      ),
    );
    
    // Wait for complete auto-scroll: render(1s) + scroll down(1.5s) + wait(1s) + horizontal scroll(3s) + wait(0.8s) = ~7.5s
    await Future.delayed(const Duration(milliseconds: 8000));
  }


  String _extractKeyword(String query) {
    final words = query.toLowerCase().split(' ');
    final ignoreWords = [
      'find', 'best', 'good', 'under', 'for', 'me', 'the', 'a', 'an', 'get', 'buy', 'order', 'purchase',
      'fast', 'quick', 'near', 'nearby', 'close', 'closest', 'around',
      'cheapest', 'cheap', 'affordable', 'expensive', 'budget', 'value',
      'top', 'quality', 'rated', 'with', 'from', 'want', 'need', 'show', 'give',
      'some', 'any', 'that', 'this', 'where', 'what', 'which', 'looking'
    ];
    
    // Look for food/product keywords (longer words that aren't in ignore list)
    for (var word in words) {
      // Skip very short words and numbers
      if (word.length < 4) continue;
      if (int.tryParse(word) != null) continue; // Skip numbers like "500"
      if (ignoreWords.contains(word)) continue;
      
      print('[AI Agent] Extracted keyword: $word');
      return word;
    }
    
    // If no keyword found, try 3-letter words
    for (var word in words) {
      if (word.length == 3 && !ignoreWords.contains(word) && int.tryParse(word) == null) {
        print('[AI Agent] Extracted keyword (3-letter): $word');
        return word;
      }
    }
    
    print('[AI Agent] No specific keyword found, using full query');
    return query;
  }
  
  String _detectIntent(String query) {
    final lower = query.toLowerCase();
    
    // Check for quality/rating intent
    if (lower.contains('best') || lower.contains('top') || lower.contains('good') || 
        lower.contains('quality') || lower.contains('rated') || lower.contains('excellent') ||
        lower.contains('premium') || lower.contains('finest') || lower.contains('recommended')) {
      print('[AI Agent] Intent detected: quality (rating-based)');
      return 'quality'; // Compare by rating
    }
    
    // Check for speed/distance intent
    if (lower.contains('fast') || lower.contains('quick') || lower.contains('near') || 
        lower.contains('nearby') || lower.contains('close') || lower.contains('closest') ||
        lower.contains('around') || lower.contains('delivery')) {
      print('[AI Agent] Intent detected: distance (location-based)');
      return 'distance'; // Compare by location
    }
    
    // Check for explicit price intent
    if (lower.contains('cheap') || lower.contains('affordable') || lower.contains('budget') ||
        lower.contains('value') || lower.contains('inexpensive') || lower.contains('economical')) {
      print('[AI Agent] Intent detected: price (cost-based)');
      return 'price';
    }
    
    // Default: compare by price
    print('[AI Agent] Intent detected: price (default)');
    return 'price';
  }

  double? _extractPriceLimit(String query) {
    final match = RegExp(r'under\s+(\d+)').firstMatch(query.toLowerCase());
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }
  
  List<String> _getKeywordVariations(String keyword) {
    // Common spelling variations and synonyms
    final variations = <String>[];
    
    // Add original
    variations.add(keyword);
    
    // Common spelling variations
    if (keyword.contains('cheez')) {
      variations.add(keyword.replaceAll('cheez', 'cheese'));
    }
    if (keyword.contains('piza')) {
      variations.add(keyword.replaceAll('piza', 'pizza'));
    }
    if (keyword.contains('burgr')) {
      variations.add(keyword.replaceAll('burgr', 'burger'));
    }
    if (keyword.contains('chiken') || keyword.contains('chikn')) {
      variations.add('chicken');
    }
    if (keyword.contains('sandwch') || keyword.contains('sandwic')) {
      variations.add('sandwich');
    }
    if (keyword.contains('coffe')) {
      variations.add('coffee');
    }
    
    // Common food synonyms
    final synonyms = {
      'veg': ['vegetable', 'veggie'],
      'non-veg': ['nonveg', 'meat', 'chicken'],
      'paneer': ['cottage', 'cheese'],
      'biryani': ['biriyani', 'briyani'],
      'dosa': ['dose', 'dosai'],
    };
    
    synonyms.forEach((key, values) {
      if (keyword.contains(key)) {
        variations.addAll(values);
      }
      for (var value in values) {
        if (keyword.contains(value)) {
          variations.add(key);
          variations.addAll(values);
        }
      }
    });
    
    // Also add just the core word without common suffixes
    if (keyword.length > 4) {
      variations.add(keyword.substring(0, 4)); // First 4 letters
    }
    
    return variations.toSet().toList(); // Remove duplicates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Shopping Agent',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Watch me find the best deal for you',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Agent Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withOpacity(0.6),
                    Colors.blue.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Current Step
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _currentStep,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentAction,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!_isComplete) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Info
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI is navigating through your app to find the best match',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
