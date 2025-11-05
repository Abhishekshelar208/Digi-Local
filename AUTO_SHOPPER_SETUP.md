# Auto-Shopper Feature - Setup & Integration Guide

## 🎯 Overview

The Auto-Shopper is an AI-powered conversational ordering agent that allows users to find and order products using natural language (text or voice).

**Key Features:**
- 🗣️ Natural language understanding (text & voice)
- 🔍 Smart product search with filters
- 📊 Intelligent ranking (price, rating, distance, delivery)
- ❓ Minimal clarifying questions
- 🛒 Direct cart integration
- 📍 Location-based recommendations

---

## 📋 Prerequisites

### 1. Google Gemini API Key

You need a Google Gemini API key for NLP parsing.

**Get your API key:**
1. Visit: https://makersuite.google.com/app/apikey
2. Create a new API key
3. Copy the key

### 2. Permissions (Android)

Add these to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Location permission -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Microphone permission for voice input -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### 3. iOS Configuration

Add these to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby shops</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice shopping</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition for voice shopping</string>
```

---

## 🚀 Installation Steps

### Step 1: Install Dependencies

```bash
cd /Users/abhishekshelar/StudioProjects/Digi-Local
flutter pub get
```

### Step 2: Create Config File

Create `lib/config/api_keys.dart`:

```dart
class ApiKeys {
  // Replace with your actual Gemini API key
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
}
```

**⚠️ IMPORTANT:** Add `lib/config/api_keys.dart` to `.gitignore` to avoid exposing your API key!

### Step 3: Integration with Navigation

Add Auto-Shopper to your navigation. There are two approaches:

#### Option A: Add to Customer Navigation (Recommended)

Edit `lib/customer_app/navigation/customer_main_screen.dart` and add:

```dart
import 'package:digilocal/features/auto_shopper/screens/auto_shopper_screen.dart';
import 'package:digilocal/config/api_keys.dart';

// Add to your navigation tabs
NavigationDestination(
  icon: Icon(Icons.psychology),
  label: 'Auto-Shop',
),

// Add to your pages list
AutoShopperScreen(geminiApiKey: ApiKeys.geminiApiKey),
```

#### Option B: Add as Floating Action Button

```dart
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutoShopperScreen(
          geminiApiKey: ApiKeys.geminiApiKey,
        ),
      ),
    );
  },
  child: Icon(Icons.psychology),
  tooltip: 'Auto-Shopper',
)
```

---

## 🎨 Usage Examples

Users can type or speak queries like:

### Product Search with Price
- "Order chocolate cake under ₹300"
- "Find pizza below 200 rupees"
- "Get a phone charger between ₹200 and ₹400"

### Location-Based
- "Find cake shops near me"
- "Order burger from nearby"

### With Preferences
- "Order fastest delivery pizza"
- "Get the best quality cake under ₹300"
- "Find cheapest phone charger"

### Specific Shop
- "Order from SweetBake Bakery"

### Time-Based
- "I need lunch delivered in 30 minutes"

---

## 🔧 Customization

### 1. Adjust Ranking Weights

Edit `lib/features/auto_shopper/services/ranking_service.dart`:

```dart
// Default weights (balanced)
const RankingWeights({
  this.price = 0.4,      // 40% weight on price
  this.rating = 0.3,     // 30% weight on rating
  this.distance = 0.2,   // 20% weight on distance
  this.delivery = 0.1,   // 10% weight on delivery speed
});
```

### 2. Change Max Search Distance

Edit `lib/features/auto_shopper/services/auto_shopper_service.dart`:

```dart
final candidates = await _searchService.searchProducts(
  parsedQuery,
  userLat: userPosition?.latitude,
  userLng: userPosition?.longitude,
  maxDistanceKm: 10.0,  // Change this value
);
```

### 3. Customize UI Theme

The UI uses your existing theme (`Color(0xFFF2F0EF)` and `GoogleFonts.blinker`). To customize, edit colors in:
- `lib/features/auto_shopper/screens/auto_shopper_screen.dart`

---

## 📊 Database Structure Requirements

Your Firebase shops should have this structure:

```json
DigiLocal/
  {shopId}/
    name: "Shop Name"
    category: "Food"
    rating: 4.5
    open: true
    latitude: 18.5204
    longitude: 73.8567
    address: "123 Main St"
    Products: [
      {
        title: "Product Name"
        description: "Product description"
        productprice: "299"
        itemLeft: "10"
        image: "https://..."
      }
    ]
```

**Required fields for Auto-Shopper:**
- ✅ `name` - shop name
- ✅ `Products` - array of products
- ✅ `Products[].title` - product name
- ✅ `Products[].productprice` - price
- ✅ `Products[].itemLeft` - stock

**Optional but recommended:**
- `rating` - shop rating (0-5)
- `latitude`, `longitude` - for distance calculation
- `open` - shop open status
- `category` - shop category
- `Products[].description` - for better search matching

---

## 🧪 Testing

### Test Queries to Try:

1. **Basic Search:**
   - "chocolate cake"
   - "pizza"

2. **With Price Filter:**
   - "cake under 300"
   - "phone charger below 500"

3. **With Preference:**
   - "cheapest pizza"
   - "fastest delivery burger"
   - "best quality cake under 400"

4. **Location-Based:**
   - "nearby grocery"
   - "shops near me"

### Voice Testing:
1. Tap the microphone button
2. Speak your query clearly
3. Watch it convert to text
4. Submit the query

---

## 🐛 Troubleshooting

### Issue: "No response from AI model"

**Solution:** 
- Check your Gemini API key is correct
- Ensure you have internet connection
- The service will fall back to keyword extraction

### Issue: "No products found"

**Possible causes:**
- Product names don't match query
- All products out of stock
- Price filters too restrictive
- No shops in database

**Solution:**
- Check your Firebase `DigiLocal` node has shops with Products
- Ensure `itemLeft` > 0 for products
- Try broader search terms

### Issue: Location not working

**Solution:**
- Check location permissions are granted
- Location is optional; system works without it
- Distance-based features won't work without location

### Issue: Voice input not working

**Solution:**
- Check microphone permission
- Ensure device has speech recognition support
- Try typing the query instead

---

## 📈 Performance Optimization

### For Large Databases:

If you have 100+ shops, consider these optimizations:

1. **Add indexing** in Firebase:
```json
{
  "rules": {
    "DigiLocal": {
      ".indexOn": ["category", "rating", "open"]
    }
  }
}
```

2. **Implement caching:**
- Cache shop list locally
- Update on app launch
- Reduce Firebase reads

3. **Lazy load products:**
- Only fetch products for top-ranked shops
- Don't load all shops at once

---

## 💰 Cost Considerations

### Gemini API:
- Free tier: 60 requests/minute
- Cost per query: ~1 request
- For production: consider implementing caching or using the free tier strategically

### Firebase:
- Each search reads all shops once
- Consider Firebase pricing for your scale
- Optimize by caching shop data

---

## 🔐 Security Best Practices

1. **Never commit API keys:**
   ```bash
   # Add to .gitignore
   lib/config/api_keys.dart
   ```

2. **Use environment variables in production:**
   ```dart
   static const String geminiApiKey = 
     String.fromEnvironment('GEMINI_API_KEY');
   ```

3. **Implement Firebase Security Rules:**
   ```json
   {
     "rules": {
       "DigiLocal": {
         ".read": "auth != null",
         ".write": "auth != null"
       }
     }
   }
   ```

---

## 📱 Future Enhancements

Consider adding:

1. **Order history analysis:** Learn user preferences
2. **Multi-shop orders:** Combine items from multiple shops
3. **Scheduled orders:** "Order cake for tomorrow 5 PM"
4. **Voice feedback:** Text-to-speech responses
5. **Image search:** "Find products like this image"
6. **Recommendations:** "Users also bought..."

---

## 📞 Support

If you encounter issues:

1. Check Firebase Console for data structure
2. Verify API keys are correct
3. Check Flutter logs: `flutter logs`
4. Ensure all dependencies are installed: `flutter pub get`

---

## 📄 File Structure

```
lib/features/auto_shopper/
├── models/
│   ├── parsed_query_model.dart       # Query parsing result
│   ├── shop_candidate_model.dart     # Shop/product candidate
│   └── auto_shopper_result.dart      # Service result
├── services/
│   ├── nlp_parsing_service.dart      # AI query parsing
│   ├── product_search_service.dart   # Firebase search
│   ├── ranking_service.dart          # Scoring algorithm
│   └── auto_shopper_service.dart     # Main orchestrator
└── screens/
    └── auto_shopper_screen.dart      # UI screen
```

---

**🎉 You're all set! The Auto-Shopper feature is ready to use.**

Test it with simple queries first, then explore advanced features like voice input and location-based search.
