import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final apiKey = 'AIzaSyCQktw7dH6hdRn0PMF1xd2vg238yh9KgPU'; // The key we hardcoded
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

  print('Testing Shop Chat API...');

  final shopData = {
    "shopInfo": {
      "shopName": "Test Bakery",
      "address": "123 Sugar Lane",
    },
    "ShopTimings": "9 AM - 9 PM",
    "Products": [
      {"name": "Chocolate Cake", "price": "15"},
      {"name": "Croissant", "price": "5"}
    ]
  };

  final systemPrompt = """
You are the AI for 'Test Bakery'.
Products:
- Chocolate Cake (\$15)
- Croissant (\$5)
""";

  final requestBody = {
    'contents': [
      {
        'role': 'user',
        'parts': [{'text': systemPrompt}]
      },
      {
        'role': 'model',
        'parts': [{'text': 'Understood.'}]
      },
      {
        'role': 'user',
        'parts': [{'text': 'How much is the cake?'}]
      }
    ]
  };

  try {
    final client = HttpClient();
    final request = await client.postUrl(url);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(requestBody));
    
    final response = await request.close();
    
    print('Response Status: ${response.statusCode}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response Body: $responseBody');

    if (response.statusCode == 200) {
      print('\n✅ SUCCESS: API is working!');
    } else {
      print('\n❌ FAILURE: API rejected the request.');
    }
  } catch (e) {
    print('\n❌ EXCEPTION: $e');
  }
}
