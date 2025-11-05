# 🚀 Auto-Shopper Quick Start Guide

## ⚡ Get Started in 5 Minutes

### Step 1: Get Gemini API Key (2 minutes)

1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with Google
3. Click "Create API Key"
4. Copy the key

### Step 2: Add API Key (1 minute)

Edit `lib/config/api_keys.dart` and replace:

```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

With your actual key:

```dart
static const String geminiApiKey = 'AIzaSy...your_key_here';
```

### Step 3: Install Dependencies (1 minute)

```bash
flutter pub get
```

### Step 4: Add to Navigation (1 minute)

Find your main customer screen (probably `lib/customer_app/navigation/customer_main_screen.dart` or similar) and add:

```dart
import 'package:digilocal/features/auto_shopper/screens/auto_shopper_screen.dart';
import 'package:digilocal/config/api_keys.dart';

// Option A: As a navigation tab
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
)

// Option B: As a button somewhere
ElevatedButton(
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
  child: Text('Auto-Shopper'),
)
```

### Step 5: Run & Test! 🎉

```bash
flutter run
```

**Test with these queries:**
- "chocolate cake under 300"
- "pizza"
- "nearest grocery"

---

## 📱 Permissions Setup

### Android (Optional but Recommended)

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS (Optional but Recommended)

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Find nearby shops</string>
<key>NSMicrophoneUsageDescription</key>
<string>Voice shopping</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Voice shopping</string>
```

---

## 🎯 Example Queries

**Basic:**
- "chocolate cake"
- "pizza"
- "burger"

**With Price:**
- "cake under 300"
- "pizza below 200"

**With Preference:**
- "cheapest cake"
- "fastest pizza"
- "best quality burger"

**Voice:** 
- Tap mic button and speak!

---

## ⚠️ Common Issues

**"No response from AI"**
- Check API key is correct
- Check internet connection

**"No results found"**
- Make sure you have shops in Firebase DigiLocal node
- Make sure shops have Products array
- Check products have stock (`itemLeft > 0`)

**Voice not working?**
- Grant microphone permission
- Or just type instead!

---

## 📚 Full Documentation

See `AUTO_SHOPPER_SETUP.md` for:
- Advanced configuration
- Database structure
- Customization options
- Performance optimization
- Security best practices

---

## 🎨 What It Does

The Auto-Shopper:
1. **Understands** your natural language query
2. **Searches** Firebase for matching products
3. **Ranks** results by price, rating, distance
4. **Asks** clarifying questions if needed
5. **Adds** to cart with one tap

---

## 🛠️ Tech Stack

- **NLP**: Google Gemini AI
- **Database**: Firebase Realtime Database
- **Location**: Geolocator
- **Voice**: Speech to Text
- **UI**: Flutter with Material Design

---

**That's it! You're ready to go! 🚀**

Need help? Check the full setup guide or your Firebase console for data structure.
