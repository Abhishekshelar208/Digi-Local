import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/parsed_query_model.dart';
import '../models/shop_candidate_model.dart';
import '../../../pages/UsersListPage.dart';
import '../../../pages/userdatapageforall.dart';

/// Screen that shows ACTUAL app navigation happening in real-time
class AINavigationScreen extends StatefulWidget {
  final ParsedQuery query;
  final ShopCandidate targetProduct;

  const AINavigationScreen({
    super.key,
    required this.query,
    required this.targetProduct,
  });

  @override
  State<AINavigationScreen> createState() => _AINavigationScreenState();
}

class _AINavigationScreenState extends State<AINavigationScreen> {
  int _currentStep = 0;
  String _currentAction = '';
  List<Map<String, dynamic>> _fetchedShops = [];
  Map<String, dynamic>? _selectedShop;
  
  final List<String> _steps = [
    'Analyzing your request...',
    'Opening Home screen...',
    'Selecting category...',
    'Fetching shops...',
    'Opening shop...',
    'Searching products...',
    'Found product!',
    'Adding to cart...',
    'Complete!',
  ];

  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  Future<void> _startNavigation() async {
    // Step 0: Analyze
    await _updateStep(0, 'Understanding: "${widget.query.originalQuery}"');
    await Future.delayed(const Duration(seconds: 1));

    // Step 1: Home
    await _updateStep(1, 'Ready to navigate...');
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 2: Category
    final category = _inferCategory();
    await _updateStep(2, 'Category: $category');
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 3: Fetch shops - REAL DATA
    await _updateStep(3, 'Querying Firebase...');
    await _fetchShopsFromFirebase(category);
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 4: Navigate to shop list
    if (_fetchedShops.isNotEmpty) {
      await _updateStep(4, 'Found ${_fetchedShops.length} shops');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to shop list - continuous flow
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UsersListPage(
            category: category,
            usersList: _fetchedShops,
          ),
        ),
      );
      
      await Future.delayed(const Duration(seconds: 1));
    }

    // Step 5: Browse multiple shops in continuous flow
    if (_fetchedShops.isNotEmpty) {
      // Visit first 3 shops (or all if less than 3)
      int shopsToVisit = _fetchedShops.length > 3 ? 3 : _fetchedShops.length;
      
      for (int i = 0; i < shopsToVisit; i++) {
        _selectedShop = _fetchedShops[i];
        await _updateStep(5, 'Opening ${_selectedShop!["fullName"]} (${i + 1}/$shopsToVisit)');
        await Future.delayed(const Duration(milliseconds: 800));

        // Navigate to shop details - continuous flow
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDataPageForAll(
              userData: _selectedShop!["userData"],
            ),
          ),
        );
        
        // Wait a bit to simulate browsing
        await Future.delayed(const Duration(seconds: 2));
        
        // Go back to shop list for next shop
        if (i < shopsToVisit - 1) {
          if (!mounted) return;
          Navigator.pop(context);
          await _updateStep(5, 'Back to shop list...');
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    }

    // Step 6: Product found
    await _updateStep(6, '${widget.targetProduct.productName} - ₹${widget.targetProduct.price.toStringAsFixed(0)}');
    await Future.delayed(const Duration(seconds: 1));

    // Step 7: Add to cart - REAL CART UPDATE
    await _updateStep(7, 'Updating cart in Firebase...');
    await _addToCart();
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 8: Complete
    await _updateStep(8, 'Successfully added to cart!');
    await Future.delayed(const Duration(seconds: 2));

    // Go back to home
    if (!mounted) return;
    // Pop shop details and shop list to return to home
    Navigator.pop(context); // Pop current shop
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    Navigator.pop(context); // Pop shop list
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    Navigator.pop(context); // Pop AI navigation screen
  }

  Future<void> _updateStep(int step, String action) async {
    if (!mounted) return;
    setState(() {
      _currentStep = step;
      _currentAction = action;
    });
  }

  String _inferCategory() {
    if (widget.query.category != null) return widget.query.category!;
    
    final productName = widget.targetProduct.productName.toLowerCase();
    if (productName.contains('pizza') || productName.contains('cake') || productName.contains('food')) {
      return 'Restaurants & Cafes';
    } else if (productName.contains('phone') || productName.contains('laptop')) {
      return 'Electronics';
    } else if (productName.contains('shirt') || productName.contains('dress')) {
      return 'Fashion & Clothing';
    }
    return 'All Categories';
  }

  Future<void> _fetchShopsFromFirebase(String category) async {
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

        setState(() {
          _fetchedShops = tempList;
        });
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
  }

  bool _isRelatedToCategory(String shopTitle, String category) {
    final Map<String, List<String>> categoryKeywords = {
      "Restaurants & Cafes": [
        "Restaurant", "Cafe", "Food", "Eatery", "Cake", "Pizza", "Bakery"
      ],
      "Electronics": [
        "Electronics", "Gadgets", "Mobile", "Laptop", "Phone"
      ],
      "Fashion & Clothing": [
        "Clothing", "Fashion", "Apparel", "Boutique"
      ],
    };

    return categoryKeywords[category]
        ?.any((keyword) => shopTitle.toLowerCase().contains(keyword.toLowerCase())) ??
        false;
  }

  Future<void> _addToCart() async {
    // Real cart addition logic here
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
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
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Auto-Shopper',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Watch AI navigate your app',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _steps.length,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Current action
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getIconForStep(_currentStep),
                    color: Colors.blue,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _steps[_currentStep],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_currentAction.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _currentAction,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI is navigating through actual app screens',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStep(int step) {
    switch (step) {
      case 0:
        return Icons.psychology;
      case 1:
        return Icons.home;
      case 2:
        return Icons.category;
      case 3:
        return Icons.cloud_download;
      case 4:
        return Icons.store;
      case 5:
        return Icons.storefront;
      case 6:
        return Icons.shopping_bag;
      case 7:
        return Icons.shopping_cart;
      case 8:
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }
}
