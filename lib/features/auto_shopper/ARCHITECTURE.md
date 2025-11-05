# AI Auto Shopper - Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INPUT                              │
│  Voice: "Order best pizza under 500" OR Text typing             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                    AUTO SHOPPER SCREEN                          │
│  - Captures voice/text input                                    │
│  - Displays results                                             │
│  - Shows "Watch AI Shop" button                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                  AUTO SHOPPER SERVICE                           │
│                                                                 │
│  1. NLP Parsing Service (Gemini AI)                            │
│     └─> Extracts: product, price, preference                   │
│                                                                 │
│  2. Product Search Service (Firebase)                          │
│     └─> Searches shops and products                            │
│                                                                 │
│  3. Ranking Service                                             │
│     └─> Ranks by price, distance, rating                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                 AI NAVIGATION CONTROLLER                        │
│                                                                 │
│  Planning Phase:                                                │
│  - Creates 11-step journey                                      │
│  - Plans category selection                                     │
│  - Identifies target shop                                       │
│  - Prepares product details                                     │
│                                                                 │
│  Execution Phase:                                               │
│  - Executes each step with timing                              │
│  - Sends updates to UI                                          │
│  - Manages animations                                           │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                   AI JOURNEY OVERLAY                            │
│                                                                 │
│  Visual Components:                                             │
│  ├─ Dark semi-transparent background                           │
│  ├─ Top progress bar                                            │
│  ├─ Animated step icon (center)                                │
│  ├─ Step title and description                                 │
│  ├─ Step counter (e.g., "Step 5 of 11")                        │
│  └─ Stop button                                                 │
│                                                                 │
│  Animations:                                                    │
│  ├─ Pulsing icon effect                                         │
│  ├─ Fade in/out transitions                                    │
│  ├─ Progress bar filling                                        │
│  └─ Color changes per step type                                │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│                      FINAL RESULT                               │
│  - Product added to cart                                        │
│  - Success message shown                                        │
│  - User can view cart or continue shopping                      │
└─────────────────────────────────────────────────────────────────┘
```

## Component Interaction

```
AutoShopperScreen
      │
      ├──> AutoShopperService
      │         │
      │         ├──> NLPParsingService (Gemini AI)
      │         ├──> ProductSearchService (Firebase)
      │         └──> RankingService
      │
      └──> AINavigationController
                │
                ├──> Plans journey
                ├──> Executes steps
                └──> Updates overlay
                      │
                      └──> AIJourneyOverlay (Visual UI)
```

## Data Flow

```
User Query
    ↓
"order pizza under 500"
    ↓
ParsedQuery {
    product: "pizza"
    priceLimit: 500
    category: "Restaurants & Cafes"
}
    ↓
Product Search
    ↓
List<ShopCandidate> [
    {shop: "Pizza Hut", product: "Margherita", price: 399},
    {shop: "Dominos", product: "Cheese Pizza", price: 450},
]
    ↓
Ranking & Selection
    ↓
Best Match: Pizza Hut - Margherita - ₹399
    ↓
Navigation Journey Planning
    ↓
NavigationSteps [
    Step 1: Analyzing
    Step 2: Open Home
    Step 3: Select Category
    ...
    Step 11: Complete
]
    ↓
Visual Execution
    ↓
Cart Updated
```

## State Management

```
_AutoShopperScreenState {
    // Input state
    _queryController: TextEditingController
    _speech: SpeechToText
    _isListening: bool
    
    // Processing state
    _isProcessing: bool
    _currentResult: AutoShopperResult?
    _currentQuery: ParsedQuery?
    
    // Navigation state
    _isNavigating: bool
    _currentNavigationStep: NavigationStep?
    _currentStepIndex: int
    _totalSteps: int
    
    // Controllers
    _autoShopperService: AutoShopperService
    _navigationController: AINavigationController
}
```

## Navigation Steps Model

```
NavigationStep {
    type: NavigationStepType (thinking|navigate|tap|scroll|complete)
    title: String
    description: String
    icon: IconData
    targetRoute: String?
    targetElement: String?
    delayMs: int
}
```

## Color Coding System

```
Step Type        Color      Icon
─────────────────────────────────────
Thinking     →   Purple    psychology
Navigate     →   Blue      home/navigation
Tap          →   Green     touch/hand
Scroll       →   Orange    scroll
Complete     →   Teal      celebration
```

## Timing Configuration

```
Default Delays:
- Thinking:  800ms
- Navigate:  600ms
- Tap:       800ms
- Scroll:    1000ms
- Complete:  1000ms

Total Journey Time: ~9 seconds (11 steps)
```

## Integration Points

```
1. Home Screen
   └─> Floating "AI Shop" button
       └─> Opens AutoShopperScreen

2. AutoShopperScreen
   └─> Query input (voice/text)
       └─> Processes query
           └─> Shows result
               └─> "Watch AI Shop" button
                   └─> Starts navigation overlay

3. Navigation Complete
   └─> Adds to Firebase cart
       └─> Shows success message
           └─> Clears state
```

## Technology Stack

```
┌─────────────────────────────────────┐
│         Flutter Framework           │
├─────────────────────────────────────┤
│  - Material Design                  │
│  - Animations                       │
│  - State Management                 │
└─────────────────────────────────────┘
            │
            ├──> Google Gemini AI (NLP)
            ├──> Firebase Realtime DB (Data)
            ├──> Speech-to-Text (Voice)
            └──> Custom UI Automation Engine
```

## Performance Considerations

```
Optimizations:
✅ Async/await for all API calls
✅ Lazy loading of UI components
✅ Efficient state updates
✅ Minimal rebuilds
✅ Memory-efficient animations

Considerations:
⚠️ API rate limits (Gemini)
⚠️ Network latency (Firebase)
⚠️ Animation performance (60 FPS)
```

## Security & Privacy

```
✅ No sensitive data in navigation simulation
✅ User can stop navigation anytime
✅ API keys stored securely
✅ Firebase security rules respected
✅ No PII in logs
```

## Extension Points

```
Future Enhancements:

1. Real Screen Navigation
   └─> Actually navigate through app screens
       └─> Use widget keys and semantic labels
           └─> Trigger real onTap callbacks

2. Screen Recording
   └─> Capture navigation journey
       └─> Save as video
           └─> Share functionality

3. Multi-Product Support
   └─> Handle multiple items in one journey
       └─> Optimize routing
           └─> Batch cart operations

4. Voice Narration
   └─> Text-to-speech for each step
       └─> Accessibility features
           └─> Multiple languages
```

---

**Architecture Pattern**: MVC + Service Layer  
**Design Pattern**: Observer, Strategy, Factory  
**Code Quality**: Production-ready with documentation
