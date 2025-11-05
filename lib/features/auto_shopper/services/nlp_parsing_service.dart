import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/parsed_query_model.dart';

class NLPParsingService {
  final GenerativeModel _model;
  
  NLPParsingService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
        );

  /// Parse natural language query into structured format
  Future<ParsedQuery> parseQuery(String userQuery) async {
    try {
      final prompt = _buildPrompt(userQuery);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null) {
        throw Exception('No response from AI model');
      }

      // Extract JSON from response
      final jsonString = _extractJson(response.text!);
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      parsed['original_query'] = userQuery;
      
      return ParsedQuery.fromJson(parsed);
    } catch (e) {
      print('NLP Parsing Error: $e');
      // Fallback: basic keyword extraction
      return _fallbackParsing(userQuery);
    }
  }

  String _buildPrompt(String query) {
    return '''
You are a shopping assistant that parses natural language queries into structured JSON.

Extract the following information from the user's query:
- intent: "order", "search", "find" (what the user wants to do)
- product: name of the product they want (e.g., "chocolate cake", "pizza", "charger")
- quantity: number of items (default 1)
- price_limit: maximum price in rupees (extract numbers like "under 300", "below 250")
- price_limit_min: minimum price if range specified (e.g., "between 200 and 400")
- shop_name: specific shop name if mentioned
- area: location/area mentioned (e.g., "MG Road", "Kothrud", "Pune")
- preference: "fast", "quality", "cheap" - user's priority
- delivery_time: delivery time in minutes if specified
- category: product category ONLY if explicitly mentioned by user (e.g., "electronics store", "fashion shop"). DO NOT infer from product name.
- min_rating: minimum rating if specified (e.g., "4 star", "4+")

Rules:
- Set fields to null if not mentioned
- Extract numbers from text (e.g., "three hundred" → 300)
- For preference, infer from keywords: "fastest/quick" → "fast", "best quality/rated" → "quality", "cheapest/cheap" → "cheap"
- Intent should be "order" if user says "order/buy/get", otherwise "search"
- IMPORTANT: Do NOT set category based on product name. Only set if user explicitly mentions store type (e.g., "food store", "electronics shop")

User Query: "$query"

Return ONLY valid JSON in this format:
{
  "intent": "order",
  "product": "chocolate cake",
  "quantity": 1,
  "price_limit": 300,
  "price_limit_min": null,
  "shop_name": null,
  "area": null,
  "preference": null,
  "delivery_time": null,
  "category": null,
  "min_rating": null
}
''';
  }

  String _extractJson(String text) {
    // Try to find JSON in the response
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return text.substring(jsonStart, jsonEnd + 1);
    }
    
    throw Exception('No valid JSON found in response');
  }

  /// Fallback parsing using simple keyword matching
  ParsedQuery _fallbackParsing(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Extract intent
    String intent = 'search';
    if (lowerQuery.contains(RegExp(r'\b(order|buy|get|purchase)\b'))) {
      intent = 'order';
    }
    
    // Extract price limit
    double? priceLimit;
    final priceMatch = RegExp(r'(?:under|below|less than|<)\s*₹?\s*(\d+)')
        .firstMatch(lowerQuery);
    if (priceMatch != null) {
      priceLimit = double.tryParse(priceMatch.group(1)!);
    }
    
    // Extract preference
    String? preference;
    if (lowerQuery.contains(RegExp(r'\b(fast|quick|fastest)\b'))) {
      preference = 'fast';
    } else if (lowerQuery.contains(RegExp(r'\b(best|quality|rated|top)\b'))) {
      preference = 'quality';
    } else if (lowerQuery.contains(RegExp(r'\b(cheap|cheapest|lowest)\b'))) {
      preference = 'cheap';
    }
    
    // Extract product name (simple: words between intent and price/area keywords)
    String? product;
    final productMatch = RegExp(
      r'(?:order|buy|get|find|search)\s+(?:a\s+|an\s+)?([a-z\s]+?)(?:\s+(?:under|below|from|in|at)|\s*$)',
      caseSensitive: false,
    ).firstMatch(query);
    if (productMatch != null) {
      product = productMatch.group(1)?.trim();
    }
    
    return ParsedQuery(
      intent: intent,
      product: product,
      quantity: 1,
      priceLimit: priceLimit,
      preference: preference,
      originalQuery: query,
    );
  }
}
