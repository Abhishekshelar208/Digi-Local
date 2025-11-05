# AI Auto Shopper - Visual UI Automation

## 🎯 Overview

The **AI Auto Shopper** is an advanced feature that provides **AI-driven UI automation + autonomous shopping**. Unlike traditional backend search systems, this feature visually navigates through your app screens in real-time, mimicking how a human user would shop—similar to ChatGPT's browser feature or Tesla Autopilot.

## ✨ Key Features

### 1. **Visual Navigation Journey**
- AI visually navigates through app screens in real-time
- Users watch the entire journey from Home → Category → Shop List → Product → Purchase
- Each step is animated with smooth transitions and visual feedback

### 2. **Natural Language Understanding**
- User speaks or types: *"Order best pizza for me under ₹500"*
- AI understands intent, product, price limit, and preferences
- Powered by Google's Gemini AI for natural language parsing

### 3. **Autonomous Shopping**
- AI automatically:
  - Opens home screen
  - Selects the right category (e.g., "Restaurants & Cafes")
  - Scrolls through available shops
  - Opens the target shop
  - Searches for the product
  - Compares prices and distances
  - Adds to cart

### 4. **Real-Time Progress Visualization**
- Live overlay showing current step
- Progress bar with step counter
- Color-coded step types:
  - 🟣 Purple: Thinking/Analyzing
  - 🔵 Blue: Navigation
  - 🟢 Green: Tap/Selection
  - 🟠 Orange: Scrolling
  - 🟢 Teal: Complete

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│     Auto Shopper Screen (UI)           │
│  - Voice/Text Input                     │
│  - Visual Journey Overlay               │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│   AI Navigation Controller              │
│  - Plans navigation journey             │
│  - Executes each step                   │
│  - Manages timing & animations          │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│   Auto Shopper Service                  │
│  - NLP parsing (Gemini AI)              │
│  - Product search                       │
│  - Ranking & comparison                 │
└─────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/features/auto_shopper/
├── models/
│   ├── auto_shopper_result.dart      # Result states
│   ├── parsed_query_model.dart       # NLP parsed data
│   ├── shop_candidate_model.dart     # Shop/product candidates
│   └── navigation_step_model.dart    # Navigation step definition
├── screens/
│   └── auto_shopper_screen.dart      # Main UI screen
├── services/
│   ├── auto_shopper_service.dart     # Core shopping logic
│   ├── ai_navigation_controller.dart # Visual navigation engine
│   ├── nlp_parsing_service.dart      # Natural language parsing
│   ├── product_search_service.dart   # Product search
│   └── ranking_service.dart          # Candidate ranking
└── widgets/
    └── ai_journey_overlay.dart       # Visual overlay widget
```

## 🚀 How It Works

### Step-by-Step Journey

1. **User Input**
   ```
   User: "Order chocolate cake under ₹300"
   ```

2. **AI Analyzes Request**
   - Parses: product=chocolate cake, price_limit=300
   - Infers category: "Restaurants & Cafes"

3. **Visual Navigation Begins**
   ```
   Step 1: Analyzing Request          [🟣 Thinking]
   Step 2: Opening Home               [🔵 Navigate]
   Step 3: Selecting Category         [🟢 Tap]
   Step 4: Browsing Shops             [🟠 Scroll]
   Step 5: Opening Shop               [🟢 Tap]
   Step 6: Viewing Products           [🔵 Navigate]
   Step 7: Finding Product            [🟠 Scroll]
   Step 8: Product Found              [🟢 Tap]
   Step 9: Verifying Details          [🟣 Thinking]
   Step 10: Adding to Cart            [🟢 Tap]
   Step 11: Order Complete!           [🟢 Complete]
   ```

4. **Result**
   - Product added to cart
   - User watched entire journey
   - Can stop at any time

## 💡 Usage Example

```dart
// In AutoShopperScreen
void _startAutoNavigation(ShopCandidate candidate) async {
  await _navigationController.startAutoNavigation(
    query: _currentQuery,
    targetCandidate: candidate,
  );
}

// The overlay automatically shows the journey
AIJourneyOverlay(
  currentStep: _currentNavigationStep,
  currentIndex: _currentStepIndex,
  totalSteps: _totalSteps,
  onStop: _stopNavigation,
)
```

## 🎨 Visual Features

### 1. **Animated Overlay**
- Semi-transparent dark background
- Pulsing icon animations
- Smooth transitions between steps
- Progress bar with color coding

### 2. **Step Indicators**
- Icon representing current action
- Step title and description
- Progress counter (e.g., "Step 3 of 11")
- Loading spinner for ongoing actions

### 3. **User Controls**
- Stop button to cancel navigation
- Can watch the entire journey
- Auto-closes when complete

## 🔧 Configuration

### Timing Settings
You can adjust timing in `AINavigationController`:
```dart
delayMs: 800,  // Delay after each step
```

### Step Types
- `NavigationStepType.thinking` - AI analyzing
- `NavigationStepType.navigate` - Screen navigation
- `NavigationStepType.tap` - UI interaction
- `NavigationStepType.scroll` - List scrolling
- `NavigationStepType.complete` - Journey complete

## 🎯 Key Differences from Traditional Search

| Traditional Filter | AI Auto Shopper |
|-------------------|-----------------|
| Backend search only | Visual UI navigation |
| Show results instantly | Show journey step-by-step |
| No visual feedback | Real-time screen navigation |
| User clicks manually | AI clicks automatically |
| Like Google search | Like Tesla Autopilot |

## 🚧 Future Enhancements

1. **Real Screen Navigation**
   - Currently simulated
   - Can be extended to actually navigate screens
   - Use Flutter's widget tree to find and tap elements

2. **Screen Recording**
   - Capture the AI navigation journey
   - Save as video for sharing
   - Replay previous shopping sessions

3. **Multi-Product Shopping**
   - Order multiple items in one journey
   - Compare across multiple shops
   - Build complete shopping list

4. **Voice Feedback**
   - AI speaks each step
   - Narrates the shopping journey
   - Interactive voice commands

## 📱 Integration

The feature is already integrated in your app:
- Accessible from Home screen via floating "AI Shop" button
- Uses existing Firebase data structure
- Works with current shop/product listings
- Compatible with cart system

## 🎓 Learning Resources

This implementation is inspired by:
- **ChatGPT Browser Plugin** - Visual web navigation
- **Tesla Autopilot** - Autonomous with user oversight
- **Selenium WebDriver** - Automated UI testing
- **Puppeteer** - Browser automation

## 📝 Notes

- The navigation is currently **simulated** for visual effect
- To make it fully functional, you need to implement actual screen navigation
- The core logic for finding products is already implemented
- The visual layer makes it feel like autonomous shopping

---

**Built with Flutter, Firebase, and Gemini AI** 🚀
