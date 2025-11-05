import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../pages/UsersListPage.dart';
import '../../pages/userdatapageforall.dart';

/// AI Shopping Bot that physically navigates through app screens
class AIShoppingBot {
  final BuildContext context;
  final GlobalKey<NavigatorState> navigatorKey;

  AIShoppingBot({
    required this.context,
    required this.navigatorKey,
  });

  /// Start AI shopping journey
  Future<void> startShopping(String userPrompt) async {
    // Show thinking overlay
    _showThinkingOverlay('Analyzing your request...');
    await Future.delayed(const Duration(seconds: 1));

    // Parse the prompt
    final category = _detectCategory(userPrompt);
    final productKeyword = _extractProductKeyword(userPrompt);

    _updateThinking('Searching in $category...');
    await Future.delayed(const Duration(milliseconds: 800));

    // Fetch shops for category
    _updateThinking('Loading shops...');
    final shops = await _fetchShops(category);
    
    if (shops.isEmpty) {
      _hideThinking();
      _showError('No shops found for "$userPrompt"');
      return;
    }

    _updateThinking('Found ${shops.length} shops');
    await Future.delayed(const Duration(milliseconds: 500));

    // NAVIGATE TO SHOP LIST - User sees the screen!
    _hideThinking();
    final selectedShop = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (context) => _AINavigatingShopList(
          category: category,
          shops: shops,
          searchKeyword: productKeyword,
        ),
      ),
    );

    if (selectedShop == null) {
      _showError('Product "$productKeyword" not found in any shop');
      return;
    }

    // NAVIGATE TO SHOP DETAILS - User sees products!
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AINavigatingShopDetails(
          shopData: selectedShop,
          searchKeyword: productKeyword,
        ),
      ),
    );
  }

  String _detectCategory(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('pizza') || lower.contains('food') || 
        lower.contains('cake') || lower.contains('restaurant')) {
      return 'Restaurants & Cafes';
    } else if (lower.contains('phone') || lower.contains('laptop') || 
               lower.contains('electronics')) {
      return 'Electronics';
    } else if (lower.contains('clothes') || lower.contains('shirt') || 
               lower.contains('dress')) {
      return 'Fashion & Clothing';
    }
    return 'All Categories';
  }

  String _extractProductKeyword(String prompt) {
    // Extract main product keyword
    final words = prompt.toLowerCase().split(' ');
    for (var word in words) {
      if (word.length > 3 && !['under', 'above', 'best', 'good'].contains(word)) {
        return word;
      }
    }
    return prompt;
  }

  Future<List<Map<String, dynamic>>> _fetchShops(String category) async {
    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("DigiLocal");
      DataSnapshot snapshot = await databaseRef.get();

      if (!snapshot.exists) return [];

      Map<String, dynamic> usersMap = Map<String, dynamic>.from(snapshot.value as Map);
      List<Map<String, dynamic>> shops = [];

      usersMap.forEach((key, value) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(value);
        String userCategory = userData["category"] ?? "";

        if (category == "All Categories" || _matchesCategory(userCategory, category)) {
          shops.add({
            "userId": key,
            "fullName": userData["shopInfo"]["shopName"] ?? "No Name",
            "userTitle": userCategory,
            "profilePicture": userData["shopInfo"]["shopImage"] ?? "",
            "userData": userData,
          });
        }
      });

      return shops;
    } catch (e) {
      print('Error fetching shops: $e');
      return [];
    }
  }

  bool _matchesCategory(String shopCategory, String targetCategory) {
    return shopCategory.toLowerCase().contains(targetCategory.toLowerCase()) ||
           targetCategory.toLowerCase().contains(shopCategory.toLowerCase());
  }

  // Overlay management
  OverlayEntry? _thinkingOverlay;

  void _showThinkingOverlay(String message) {
    _thinkingOverlay = OverlayEntry(
      builder: (context) => _ThinkingOverlay(message: message),
    );
    Overlay.of(context).insert(_thinkingOverlay!);
  }

  void _updateThinking(String message) {
    _thinkingOverlay?.markNeedsBuild();
  }

  void _hideThinking() {
    _thinkingOverlay?.remove();
    _thinkingOverlay = null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

/// Thinking overlay
class _ThinkingOverlay extends StatelessWidget {
  final String message;

  const _ThinkingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI-navigating shop list with auto-selection
class _AINavigatingShopList extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> shops;
  final String searchKeyword;

  const _AINavigatingShopList({
    required this.category,
    required this.shops,
    required this.searchKeyword,
  });

  @override
  State<_AINavigatingShopList> createState() => _AINavigatingShopListState();
}

class _AINavigatingShopListState extends State<_AINavigatingShopList> {
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _autoNavigate();
  }

  Future<void> _autoNavigate() async {
    Map<String, dynamic>? foundShop;
    
    // Search through ALL shops for the product
    for (int i = 0; i < widget.shops.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      
      setState(() => _highlightedIndex = i);
      
      // Check if this shop has the product
      final shop = widget.shops[i];
      final hasProduct = await _checkShopHasProduct(shop);
      
      if (hasProduct) {
        foundShop = shop;
        // Highlight found shop longer
        await Future.delayed(const Duration(milliseconds: 800));
        break;
      }
    }

    if (!mounted) return;
    
    if (foundShop != null) {
      // Found it! Navigate to this shop
      Navigator.pop(context, foundShop);
    } else {
      // No shop has the product
      Navigator.pop(context);
    }
  }
  
  Future<bool> _checkShopHasProduct(Map<String, dynamic> shop) async {
    try {
      final products = shop["userData"]["Products"] as List?;
      if (products == null || products.isEmpty) return false;
      
      for (var product in products) {
        final productName = (product["productName"] ?? "").toString().toLowerCase();
        if (productName.contains(widget.searchKeyword.toLowerCase())) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: Color(0xFF4C6EF5), size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Searching...',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C6EF5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // AI status banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Color(0xFF4C6EF5).withOpacity(0.1),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bot is scanning shops for "${widget.searchKeyword}"...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF4C6EF5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Shop list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.shops.length,
              itemBuilder: (context, index) {
                final shop = widget.shops[index];
                final isHighlighted = index == _highlightedIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isHighlighted 
                        ? Color(0xFF4C6EF5).withOpacity(0.2)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHighlighted 
                          ? const Color(0xFF4C6EF5)
                          : const Color(0xFFE5E7EB),
                      width: isHighlighted ? 3 : 1,
                    ),
                    boxShadow: isHighlighted
                        ? [
                            BoxShadow(
                              color: Color(0xFF4C6EF5).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(shop["profilePicture"]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop["fullName"],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                shop["userTitle"],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isHighlighted)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C6EF5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// AI-navigating shop details with product search
class _AINavigatingShopDetails extends StatefulWidget {
  final Map<String, dynamic> shopData;
  final String searchKeyword;

  const _AINavigatingShopDetails({
    required this.shopData,
    required this.searchKeyword,
  });

  @override
  State<_AINavigatingShopDetails> createState() => _AINavigatingShopDetailsState();
}

class _AINavigatingShopDetailsState extends State<_AINavigatingShopDetails> {
  bool _productFound = false;
  int? _foundProductIndex;

  @override
  void initState() {
    super.initState();
    _searchProduct();
  }

  Future<void> _searchProduct() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Search for product in shop's products
    final products = widget.shopData["userData"]["Products"] as List?;
    
    if (products != null) {
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        final productName = (product["productName"] ?? "").toString().toLowerCase();
        
        if (productName.contains(widget.searchKeyword.toLowerCase())) {
          if (!mounted) return;
          setState(() {
            _productFound = true;
            _foundProductIndex = i;
          });
          break;
        }
      }
    }

    // Show result
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    if (_productFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Product found!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product not found in this shop'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserDataPageForAll(userData: widget.shopData["userData"]);
  }
}
