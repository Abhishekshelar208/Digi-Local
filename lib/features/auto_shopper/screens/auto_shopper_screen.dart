import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auto_shopper_result.dart';
import '../models/shop_candidate_model.dart';
import '../models/parsed_query_model.dart';
import '../models/navigation_step_model.dart';
import '../services/auto_shopper_service.dart';
import '../services/ai_navigation_controller.dart';
import '../widgets/ai_journey_overlay.dart';
import 'ai_navigation_screen.dart';

class AutoShopperScreen extends StatefulWidget {
  final String geminiApiKey;

  const AutoShopperScreen({
    super.key,
    required this.geminiApiKey,
  });

  @override
  State<AutoShopperScreen> createState() => _AutoShopperScreenState();
}

class _AutoShopperScreenState extends State<AutoShopperScreen> {
  final TextEditingController _queryController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  late AutoShopperService _autoShopperService;
  AINavigationController? _navigationController;
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isNavigating = false;
  AutoShopperResult? _currentResult;
  ParsedQuery? _currentQuery;
  NavigationStep? _currentNavigationStep;
  int _currentStepIndex = 0;
  int _totalSteps = 0;

  @override
  void initState() {
    super.initState();
    _autoShopperService = AutoShopperService(geminiApiKey: widget.geminiApiKey);
    _initSpeech();
  }
  
  void _initNavigationController() {
    _navigationController = AINavigationController(
      navigatorKey: _navigatorKey,
      context: context,
      onStepChange: (step) {
        setState(() {
          _currentNavigationStep = step;
          _currentStepIndex = _navigationController!.journey.indexOf(step);
        });
      },
      onThinking: (message) {
        // AI is thinking - visual feedback already handled by overlay
      },
    );
  }


  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _queryController.text = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _processQuery() async {
    if (_queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or speak your request')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _currentResult = null;
    });

    try {
      final result = await _autoShopperService.processQuery(_queryController.text);
      setState(() {
        _currentResult = result;
        _currentQuery = ParsedQuery(
          intent: 'order',
          product: null,
          originalQuery: _queryController.text,
        );
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _currentResult = AutoShopperResult.error(e.toString());
        _isProcessing = false;
      });
    }
  }

  Future<void> _processClarification(String response) async {
    if (_currentResult == null || !_currentResult!.needsClarification) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final preference = _extractPreference(response);
      
      // If user selects fast delivery, request location permission
      if (preference == 'fast') {
        final hasPermission = await _autoShopperService.checkLocationPermission();
        if (!hasPermission && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission needed for fastest delivery option'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
      // Create a simple query with the preference from user response
      final simpleQuery = ParsedQuery(
        intent: 'order',
        product: null,
        preference: preference,
        originalQuery: _queryController.text,
      );
      
      final result = await _autoShopperService.processClarification(
        candidates: _currentResult!.candidates,
        userResponse: response,
        originalQuery: simpleQuery,
      );
      setState(() {
        _currentResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _currentResult = AutoShopperResult.error(e.toString());
        _isProcessing = false;
      });
    }
  }

  String? _extractPreference(String response) {
    final lower = response.toLowerCase();
    if (lower.contains('fast') || lower.contains('quick')) return 'fast';
    if (lower.contains('cheap') || lower.contains('price')) return 'cheap';
    if (lower.contains('quality') || lower.contains('best')) return 'quality';
    return null;
  }

  Future<void> _startAutoNavigation(ShopCandidate candidate) async {
    if (_currentQuery == null) return;
    
    // Navigate to REAL navigation screen that shows actual app screens
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AINavigationScreen(
          query: _currentQuery!,
          targetProduct: candidate,
        ),
      ),
    );
    
    // After navigation completes, add to cart
    await _addToCart(candidate);
  }

  Future<void> _addToCart(ShopCandidate candidate) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please login to add items to cart');
      }

      final cartRef = FirebaseDatabase.instance
          .ref('carts')
          .child(user.uid)
          .child('items')
          .push();

      await cartRef.set({
        'shopId': candidate.shopId,
        'shopName': candidate.shopName,
        'productId': candidate.productId,
        'productName': candidate.productName,
        'productImage': candidate.productImage,
        'price': candidate.price,
        'quantity': _currentQuery?.quantity ?? 1,
        'addedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${candidate.productName} added to cart!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to cart
                // Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
              },
            ),
          ),
        );

      // Clear state
      setState(() {
        _queryController.clear();
        _currentResult = null;
        _currentQuery = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  void _stopNavigation() {
    _navigationController?.stopNavigation();
    setState(() {
      _isNavigating = false;
      _currentNavigationStep = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EF),
      appBar: AppBar(
        title: Text(
          'Auto-Shopper',
          style: GoogleFonts.blinker(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F0EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildQueryInput(),
              Expanded(child: _buildResultArea()),
            ],
          ),
          // AI Navigation Overlay
          if (_isNavigating && _currentNavigationStep != null)
            AIJourneyOverlay(
              currentStep: _currentNavigationStep!,
              currentIndex: _currentStepIndex,
              totalSteps: _totalSteps,
              onStop: _stopNavigation,
            ),
        ],
      ),
    );
  }

  Widget _buildQueryInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to order?',
            style: GoogleFonts.blinker(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  style: GoogleFonts.blinker(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., "Order chocolate cake under ₹300"',
                    hintStyle: GoogleFonts.blinker(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _processQuery(),
                ),
              ),
              const SizedBox(width: 8),
              // Voice button
              Material(
                color: _isListening ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isListening ? _stopListening : _startListening,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Search button
              Material(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _isProcessing ? null : _processQuery,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea() {
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentResult == null) {
      return _buildWelcomeMessage();
    }

    switch (_currentResult!.action) {
      case AutoShopperAction.confirm:
        return _buildConfirmationCard(_currentResult!.topCandidate!);
      case AutoShopperAction.clarify:
        return _buildClarificationCard();
      case AutoShopperAction.noResults:
        return _buildNoResultsCard();
      case AutoShopperAction.error:
        return _buildErrorCard();
    }
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Your AI Shopping Assistant',
              style: GoogleFonts.blinker(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tell me what you need and I\'ll find the best options for you!',
              style: GoogleFonts.blinker(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildExampleChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChips() {
    final examples = [
      'Chocolate cake under ₹300',
      'Pizza for dinner',
      'Phone charger nearby',
      'Fresh vegetables',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: examples.map((example) {
        return ActionChip(
          label: Text(
            example,
            style: GoogleFonts.blinker(fontSize: 12),
          ),
          onPressed: () {
            _queryController.text = example;
            _processQuery();
          },
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmationCard(ShopCandidate candidate) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Found it!',
                    style: GoogleFonts.blinker(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Product image
              if (candidate.productImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    candidate.productImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                candidate.productName,
                style: GoogleFonts.blinker(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                candidate.shopName,
                style: GoogleFonts.blinker(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.currency_rupee,
                    label: candidate.price.toStringAsFixed(0),
                    color: Colors.green,
                  ),
                  if (candidate.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.location_on,
                      label: candidate.displayDistance,
                      color: Colors.blue,
                    ),
                  ],
                  if (candidate.deliveryMinutes != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.delivery_dining,
                      label: candidate.displayDelivery,
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
              if (candidate.rating != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      candidate.rating!.toStringAsFixed(1),
                      style: GoogleFonts.blinker(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startAutoNavigation(candidate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      label: Text(
                        'Watch AI Shop',
                        style: GoogleFonts.blinker(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentResult = null;
                        _queryController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.blinker(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.blinker(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClarificationCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentResult!.clarificationQuestion ?? 'Need clarification',
                      style: GoogleFonts.blinker(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildClarificationOption('Fastest delivery', 'fast'),
              const SizedBox(height: 12),
              _buildClarificationOption('Best quality', 'quality'),
              const SizedBox(height: 12),
              _buildClarificationOption('Cheapest price', 'cheap'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClarificationOption(String label, String preference) {
    return OutlinedButton(
      onPressed: () => _processClarification(preference),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.blinker(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildNoResultsCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: GoogleFonts.blinker(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentResult!.suggestionMessage ?? 'Try different keywords',
              style: GoogleFonts.blinker(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: GoogleFonts.blinker(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentResult!.errorMessage ?? 'Something went wrong',
              style: GoogleFonts.blinker(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    _speech.stop();
    super.dispose();
  }
}
