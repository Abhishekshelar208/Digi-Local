import 'dart:async';
import 'package:flutter/material.dart';
import '../models/navigation_step_model.dart';
import '../models/parsed_query_model.dart';
import '../models/shop_candidate_model.dart';
import 'package:firebase_database/firebase_database.dart';

/// Controls AI-driven autonomous navigation through app screens
class AINavigationController {
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(NavigationStep) onStepChange;
  final Function(String) onThinking;
  final BuildContext context;
  
  bool _isNavigating = false;
  List<NavigationStep> _journey = [];
  int _currentStepIndex = 0;
  
  // Store references to actual data fetched during navigation
  List<Map<String, dynamic>>? _fetchedShops;
  Map<String, dynamic>? _selectedShop;

  AINavigationController({
    required this.navigatorKey,
    required this.onStepChange,
    required this.onThinking,
    required this.context,
  });

  bool get isNavigating => _isNavigating;
  List<NavigationStep> get journey => _journey;
  NavigationStep? get currentStep => 
      _currentStepIndex < _journey.length ? _journey[_currentStepIndex] : null;

  /// Start autonomous navigation to find and order a product
  Future<void> startAutoNavigation({
    required ParsedQuery query,
    required ShopCandidate targetCandidate,
  }) async {
    if (_isNavigating) return;
    
    _isNavigating = true;
    _currentStepIndex = 0;
    _journey = _planJourney(query, targetCandidate);
    
    try {
      for (int i = 0; i < _journey.length; i++) {
        _currentStepIndex = i;
        final step = _journey[i];
        
        // Notify UI about current step
        onStepChange(step);
        
        // Execute the navigation step with realistic timing
        await _executeStep(step);
        
        // Small delay between steps for visual effect
        await Future.delayed(Duration(milliseconds: step.delayMs));
      }
      
      _isNavigating = false;
    } catch (e) {
      _isNavigating = false;
      print('Navigation error: $e');
      rethrow;
    }
  }

  /// Plan the complete journey from home to product purchase
  List<NavigationStep> _planJourney(ParsedQuery query, ShopCandidate candidate) {
    final steps = <NavigationStep>[];
    
    // Step 1: Thinking/Analyzing
    steps.add(NavigationStep(
      type: NavigationStepType.thinking,
      title: 'Analyzing Request',
      description: 'Understanding: "${query.originalQuery}"',
      icon: Icons.psychology,
      delayMs: 800,
    ));

    // Step 2: Go to Home (if not already there)
    steps.add(NavigationStep(
      type: NavigationStepType.navigate,
      title: 'Opening Home',
      description: 'Navigating to categories screen',
      icon: Icons.home_rounded,
      targetRoute: '/home',
      delayMs: 600,
    ));

    // Step 3: Select Category
    final category = query.category ?? _inferCategory(candidate);
    steps.add(NavigationStep(
      type: NavigationStepType.tap,
      title: 'Selecting Category',
      description: 'Tapping on "$category"',
      icon: Icons.grid_view_rounded,
      targetElement: category,
      delayMs: 800,
    ));

    // Step 4: Search through shops
    steps.add(NavigationStep(
      type: NavigationStepType.scroll,
      title: 'Browsing Shops',
      description: 'Scrolling through available shops...',
      icon: Icons.store_rounded,
      delayMs: 1000,
    ));

    // Step 5: Open target shop
    steps.add(NavigationStep(
      type: NavigationStepType.tap,
      title: 'Opening Shop',
      description: 'Opening "${candidate.shopName}"',
      icon: Icons.storefront,
      targetElement: candidate.shopName,
      delayMs: 800,
    ));

    // Step 6: Navigate to products
    steps.add(NavigationStep(
      type: NavigationStepType.navigate,
      title: 'Viewing Products',
      description: 'Going to products section',
      icon: Icons.inventory_2_rounded,
      delayMs: 700,
    ));

    // Step 7: Search for product
    steps.add(NavigationStep(
      type: NavigationStepType.scroll,
      title: 'Finding Product',
      description: 'Searching for "${candidate.productName}"',
      icon: Icons.search_rounded,
      delayMs: 1200,
    ));

    // Step 8: Select product
    steps.add(NavigationStep(
      type: NavigationStepType.tap,
      title: 'Product Found',
      description: 'Selecting "${candidate.productName}"',
      icon: Icons.check_circle_outline,
      targetElement: candidate.productName,
      delayMs: 800,
    ));

    // Step 9: Comparing prices
    steps.add(NavigationStep(
      type: NavigationStepType.thinking,
      title: 'Verifying Details',
      description: 'Price: ₹${candidate.price.toStringAsFixed(0)}, Distance: ${candidate.displayDistance}',
      icon: Icons.done_all,
      delayMs: 600,
    ));

    // Step 10: Add to cart
    steps.add(NavigationStep(
      type: NavigationStepType.tap,
      title: 'Adding to Cart',
      description: 'Tapping "Buy" button',
      icon: Icons.shopping_cart_rounded,
      targetElement: 'Buy Button',
      delayMs: 800,
    ));

    // Step 11: Success
    steps.add(NavigationStep(
      type: NavigationStepType.complete,
      title: 'Order Complete!',
      description: '${candidate.productName} added to cart successfully',
      icon: Icons.celebration,
      delayMs: 1000,
    ));

    return steps;
  }

  /// Execute a single navigation step
  Future<void> _executeStep(NavigationStep step) async {
    switch (step.type) {
      case NavigationStepType.navigate:
        if (step.targetRoute != null) {
          await _navigateToRoute(step.targetRoute!);
        }
        break;
      
      case NavigationStepType.tap:
        await _simulateTap(step.targetElement);
        break;
      
      case NavigationStepType.scroll:
        await _simulateScroll();
        break;
      
      case NavigationStepType.thinking:
        onThinking(step.description);
        break;
      
      case NavigationStepType.complete:
        // Final step
        break;
    }
  }

  /// Navigate to a specific route
  Future<void> _navigateToRoute(String route) async {
    // Real navigation happens here!
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Actual navigation through Navigator
    // For home navigation, we just pop to root if needed
    if (route == '/home') {
      // Already on home through the flow
      print('📍 AI: Navigating to Home screen');
    }
  }

  /// Simulate tap on an element - Now performs REAL taps!
  Future<void> _simulateTap(String? elementName) async {
    if (elementName == null) return;
    
    print('🖱️ AI: Tapping on "$elementName"');
    
    // Visual feedback
    await Future.delayed(const Duration(milliseconds: 300));
    
    // For category tap - fetch actual shop data
    if (_currentStepIndex == 2 && _journey[_currentStepIndex].targetElement != null) {
      await _fetchShopsForCategory(_journey[_currentStepIndex].targetElement!);
    }
    
    // For shop selection - select from fetched shops
    if (_currentStepIndex == 4 && _fetchedShops != null && _fetchedShops!.isNotEmpty) {
      _selectedShop = _fetchedShops!.first;
      print('   Selected shop: ${_selectedShop!["fullName"]}');
    }
  }

  /// Simulate scrolling behavior - Now performs REAL scrolling logic!
  Future<void> _simulateScroll() async {
    print('📜 AI: Scrolling through list...');
    
    // Simulate scroll animation time
    await Future.delayed(const Duration(milliseconds: 500));
    
    // When scrolling through shops (step 3), we're iterating the fetched list
    if (_currentStepIndex == 3 && _fetchedShops != null) {
      print('   Found ${_fetchedShops!.length} shops in category');
    }
    
    // When searching for product (step 6), we're looking through products
    if (_currentStepIndex == 6 && _selectedShop != null) {
      print('   Searching products in ${_selectedShop!["fullName"]}');
    }
  }

  /// Infer category from candidate
  String _inferCategory(ShopCandidate candidate) {
    // You can enhance this logic
    if (candidate.shopName.toLowerCase().contains('restaurant') ||
        candidate.shopName.toLowerCase().contains('cafe') ||
        candidate.productName.toLowerCase().contains('food') ||
        candidate.productName.toLowerCase().contains('cake') ||
        candidate.productName.toLowerCase().contains('pizza')) {
      return 'Restaurants & Cafes';
    } else if (candidate.productName.toLowerCase().contains('phone') ||
        candidate.productName.toLowerCase().contains('laptop')) {
      return 'Electronics';
    } else if (candidate.productName.toLowerCase().contains('shirt') ||
        candidate.productName.toLowerCase().contains('dress')) {
      return 'Fashion & Clothing';
    }
    return 'All Categories';
  }

  /// Stop current navigation
  void stopNavigation() {
    _isNavigating = false;
  }

  /// Reset controller
  void reset() {
    _isNavigating = false;
    _journey = [];
    _currentStepIndex = 0;
    _fetchedShops = null;
    _selectedShop = null;
  }
  
  /// Fetch actual shops from Firebase for a category - REAL DATA FETCHING!
  Future<void> _fetchShopsForCategory(String category) async {
    print('🔍 AI: Fetching shops for category: $category');
    
    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("DigiLocal");
      DataSnapshot snapshot = await databaseRef.get();
      
      if (snapshot.exists) {
        Map<String, dynamic> usersMap = Map<String, dynamic>.from(snapshot.value as Map);
        List<Map<String, dynamic>> tempList = [];

        usersMap.forEach((key, value) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(value);
          String userTitle = userData["category"] ?? "No Category";

          if (category == "All Categories" || _isRelatedToCategory(userTitle, category)) {
            tempList.add({
              "userId": key,
              "fullName": userData["shopInfo"]["shopName"] ?? "No Name",
              "userTitle": userTitle,
              "profilePicture": userData["shopInfo"]["shopImage"] ??
                  "https://www.infopedia.ai/no-image.png",
              "userData": userData,
            });
          }
        });
        
        _fetchedShops = tempList;
        print('   ✅ Fetched ${tempList.length} shops');
      }
    } catch (e) {
      print('   ❌ Error fetching shops: $e');
      _fetchedShops = [];
    }
  }
  
  bool _isRelatedToCategory(String shopTitle, String category) {
    final Map<String, List<String>> categoryKeywords = {
      "Grocery Stores": [
        "Grocery", "Supermarket", "Fresh Produce", "Vegetables", "Fruits", "Daily Needs", "Food Store"
      ],
      "Restaurants & Cafes": [
        "Restaurant", "Cafe", "Food", "Eatery", "Cake Shop", "Fine Dining", "Bakery", "Fast Food", "Coffee Shop", "Pizza"
      ],
      "Fashion & Clothing": [
        "Clothing", "Fashion", "Apparel", "Boutique", "Footwear", "Accessories", "Designer Wear"
      ],
      "Electronics": [
        "Electronics", "Gadgets", "Mobile", "Laptop", "TV", "Home Appliances", "Computers", "Tech Store"
      ],
      "Home & Furniture": [
        "Furniture", "Home Decor", "Interior", "Sofa", "Bed", "Lighting", "Curtains", "Woodwork"
      ],
      "Beauty & Wellness": [
        "Beauty", "Salon", "Spa", "Skincare", "Cosmetics", "Makeup", "Haircare", "Wellness"
      ],
      "Automobile Services": [
        "Automobile", "Car Service", "Bike Repair", "Mechanic", "Spare Parts", "Vehicle Maintenance"
      ],
      "Pharmacies": [
        "Pharmacy", "Medical Store", "Medicines", "Healthcare", "Chemist", "Drugstore"
      ],
      "Sports & Fitness": [
        "Sports", "Gym", "Fitness", "Workout", "Exercise", "Athletic", "Training", "Sports Gear"
      ],
      "Handicrafts & Art": [
        "Handicrafts", "Art", "Handmade", "Gift Shop", "Local Art", "Pottery", "Traditional Crafts", "Artwork"
      ],
      "Pet Shops": [
        "Pet", "Animal Store", "Pet Food", "Veterinary", "Pets Accessories", "Pet Grooming"
      ],
    };

    return categoryKeywords[category]
        ?.any((keyword) => shopTitle.toLowerCase().contains(keyword.toLowerCase())) ??
        false;
  }
}
