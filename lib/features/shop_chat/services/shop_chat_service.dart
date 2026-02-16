import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:digilocal/config/api_keys.dart';

class ShopChatService {
  // Static cache to persist chat history during the app session
  static final Map<String, List<Map<String, String>>> _chatCache = {};

  List<Map<String, String>> getHistory(String shopId) {
    return List<Map<String, String>>.from(_chatCache[shopId] ?? []);
  }

  void saveMessage(String shopId, Map<String, String> message) {
    if (!_chatCache.containsKey(shopId)) {
      _chatCache[shopId] = [];
    }
    _chatCache[shopId]!.add(message);
  }

  void clearHistory(String shopId) {
    _chatCache.remove(shopId);
  }

  Future<String> sendMessage({
    required String message,
    required Map<String, dynamic> shopData,
    List<Map<String, String>> history = const [],
  }) async {
    try {
      // 1. Construct System Context from Shop Data
      final systemPrompt = _buildSystemPrompt(shopData);
      
      // 2. Build Robust Prompt (One-shot)
      String fullPrompt = "$systemPrompt\n\n";
      if (history.isNotEmpty) {
        fullPrompt += "RECENT CONVERSATION:\n";
        for (var msg in history) {
          final role = msg['role'] == 'model' ? 'AI' : 'User';
          fullPrompt += "$role: ${msg['message']}\n";
        }
      }
      fullPrompt += "\nUSER QUERY: $message\n";
      fullPrompt += "HELPFUL SALES RESPONSE:";

      // 3. Initialize model - EXACTLY like nlp_parsing_service.dart
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiKeys.geminiApiKey,
      );
      
      // 4. Send request
      final response = await model.generateContent([Content.text(fullPrompt)]);

      if (response.text != null) {
        return response.text!;
      }
      
      return "I'm having a quiet moment. Could you try asking me again?";
      
    } catch (e) {
      debugPrint('Shop Chat Error: $e');
      if (e.toString().contains('quota')) {
        return "I've reached my free-tier limit for this minute! ⏳ Please wait 30-60 seconds and try again. AI Shopping also shares this limit!";
      }
      return "Connectivity issue: $e";
    }
  }

  String _buildSystemPrompt(Map<String, dynamic> shopData) {
    final shopName = shopData["shopInfo"]["shopName"] ?? "this shop";
    final address = shopData["shopInfo"]["address"] ?? "Unknown location";
    final timings = shopData["ShopTimings"] ?? "Not specified";
    final rating = shopData["averageRating"] ?? "Not rated";
    
    // Build Products List
    String productsList = "No products listed.";
    if (shopData["Products"] != null && (shopData["Products"] as List).isNotEmpty) {
      productsList = (shopData["Products"] as List).map((p) => 
        "- ${p['name']} (Price: ₹${p['price']}) - ${p['description'] ?? ''}"
      ).join('\n');
    }

    // Build Services List
    String servicesList = "No services listed.";
    if (shopData["services"] != null && (shopData["services"] as List).isNotEmpty) {
      servicesList = (shopData["services"] as List).map((s) => "- $s").join('\n');
    }

    return """
You are the charismatic and highly persuasive Sales AI Assistant for "$shopName".
Your goal is not just to answer questions, but to CONVINCE the user to visit the shop or make a purchase.

SHOP IDENTITY:
- Shop Name: $shopName
- Location: $address
- Timings: $timings
- Rating: $rating/5 stars

AVAILABLE PRODUCTS:
$productsList

AVAILABLE SERVICES:
$servicesList

YOUR CORE RULES:
1. IMPACTFUL BREVITY: Keep responses ULTRA-CONCISE. Your goal is to be read in under 5 seconds. NEVER exceed 2-3 short lines.
2. PERSUASIVE PERSONA: Be extremely friendly and enthusiastic. Use punchy phrases like "You'll love it!", "Best in town!", or "See you soon!"
3. SMART ANSWERS: Give the direct answer immediately, followed by a one-sentence "hook" (e.g., "We're open until 9 PM, so come grab your favorites now!").
4. ONE FOLLOW-UP: End with a single, short follow-up question.
5. NO HALLUCINATIONS: Only use provided data. If unknown, redirect to a listed product quickly.
6. FORMAT: Use 1-2 lines of text total. Make every word count.

EXAMPLE FLOW:
User: "What time do you close?"
AI: "We're open until $timings! Grab your favorites before we close—would you like our location?"
""";
  }
}
