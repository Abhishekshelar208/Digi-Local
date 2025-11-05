# Auto-Shopper Flow Diagram

## 🎯 Complete System Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                           │
│                    (auto_shopper_screen.dart)                    │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  │ User types/speaks: "Order chocolate cake under ₹300"
                  ↓
┌─────────────────────────────────────────────────────────────────┐
│               STEP 1: NLP PARSING SERVICE                        │
│              (nlp_parsing_service.dart)                          │
│                                                                   │
│  ┌────────────┐        ┌──────────────┐       ┌──────────┐     │
│  │   Gemini   │──────→ │ Extract JSON │─────→ │  Fallback│     │
│  │  AI Call   │        │   Response   │       │  Parsing │     │
│  └────────────┘        └──────────────┘       └──────────┘     │
│         │                      │                     ↑           │
│         │                      │                     │           │
│         └──────────────────────┴─────────────────────┘           │
│                                │                                  │
└────────────────────────────────┼──────────────────────────────────┘
                                 ↓
                        ParsedQuery Object
                        {
                          intent: "order",
                          product: "chocolate cake",
                          priceLimit: 300
                        }
                                 │
                                 ↓
┌─────────────────────────────────────────────────────────────────┐
│             STEP 2: GET USER LOCATION (Optional)                 │
│                    (auto_shopper_service.dart)                   │
│                                                                   │
│  ┌──────────────┐        ┌─────────────────┐                   │
│  │  Geolocator  │──────→ │  Lat/Lng or     │                   │
│  │  Permission  │        │  null (no GPS)  │                   │
│  └──────────────┘        └─────────────────┘                   │
└────────────────────────────────┼──────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────────┐
│          STEP 3: PRODUCT SEARCH SERVICE                          │
│             (product_search_service.dart)                        │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Firebase Query (DigiLocal)              │       │
│  │  .ref('DigiLocal').once() → All shops & products    │       │
│  └────────────────────┬─────────────────────────────────┘       │
│                       ↓                                          │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Client-Side Filtering                    │       │
│  │  ✓ Product name match (title + description)         │       │
│  │  ✓ Price <= priceLimit                              │       │
│  │  ✓ Stock > 0                                         │       │
│  │  ✓ Shop open = true                                 │       │
│  │  ✓ Distance <= maxDistanceKm                        │       │
│  │  ✓ Shop name match (if specified)                   │       │
│  │  ✓ Category match (if specified)                    │       │
│  └────────────────────┬─────────────────────────────────┘       │
└────────────────────────┼──────────────────────────────────────────┘
                         ↓
                List<ShopCandidate>
                [
                  {
                    shopName: "SweetBake",
                    productName: "Chocolate Cake",
                    price: 280,
                    distance: 2.3 km,
                    rating: 4.5
                  },
                  { ... },
                  { ... }
                ]
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│             STEP 4: RANKING SERVICE                              │
│                (ranking_service.dart)                            │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │          Calculate Normalized Scores                  │       │
│  │                                                        │       │
│  │  For each candidate:                                  │       │
│  │                                                        │       │
│  │  priceScore = w_price × (1 - normalized_price)       │       │
│  │  ratingScore = w_rating × normalized_rating          │       │
│  │  distanceScore = w_distance × (1 - normalized_dist)  │       │
│  │  deliveryScore = w_delivery × (1 - normalized_time)  │       │
│  │                                                        │       │
│  │  totalScore = sum of all scores                       │       │
│  └────────────────────┬─────────────────────────────────┘       │
│                       ↓                                          │
│  ┌──────────────────────────────────────────────────────┐       │
│  │          Sort by Score (descending)                   │       │
│  │  [highest score first, ..., lowest score last]       │       │
│  └────────────────────┬─────────────────────────────────┘       │
└────────────────────────┼──────────────────────────────────────────┘
                         ↓
                Ranked Candidates
                [
                  {score: 0.85, ...}, ← Best match
                  {score: 0.82, ...},
                  {score: 0.65, ...}
                ]
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│            STEP 5: DECISION LOGIC                                │
│                (auto_shopper_service.dart)                       │
│                                                                   │
│              Is top candidate clear winner?                      │
│                  (score difference > 0.05)                       │
│                         │                                        │
│          ┌──────────────┴──────────────┐                        │
│          │                               │                        │
│         YES                              NO                       │
│          │                               │                        │
│          ↓                               ↓                        │
│  ┌─────────────┐               ┌────────────────┐               │
│  │   CONFIRM   │               │    CLARIFY     │               │
│  │  Top Product│               │ Ask Question   │               │
│  └─────────────┘               └────────────────┘               │
└────────┼──────────────────────────────┼───────────────────────────┘
         │                               │
         ↓                               ↓
┌─────────────────────┐        ┌─────────────────────────┐
│  CONFIRMATION CARD  │        │  CLARIFICATION CARD     │
│                     │        │                         │
│  ┌───────────────┐ │        │ "I found options at     │
│  │ Product Image │ │        │  ₹280 and ₹250.         │
│  └───────────────┘ │        │  Cheaper or better      │
│                     │        │  quality?"              │
│  Chocolate Cake     │        │                         │
│  SweetBake          │        │  [Fastest delivery]     │
│  ₹280 · 2.3 km      │        │  [Best quality]         │
│  ⭐ 4.5             │        │  [Cheapest price]       │
│                     │        │                         │
│  [Add to Cart]      │        └──────────┬──────────────┘
│  [Cancel]           │                   │
│                     │                   │ User selects preference
└─────────┬───────────┘                   │
          │                               ↓
          │                       ┌───────────────────┐
          │                       │   RE-RANK WITH    │
          │                       │ NEW PREFERENCE    │
          │                       └────────┬──────────┘
          │                                │
          └────────────────────────────────┘
                         │
                         ↓
                 ┌───────────────┐
                 │ ADD TO CART   │
                 │  (Firebase)   │
                 └───────────────┘
                         │
                         ↓
               ┌─────────────────────┐
               │  Success Message    │
               │ "Added to cart! 🎉" │
               └─────────────────────┘
```

---

## 🔄 Alternative Paths

### Path A: No Results Found
```
Search → No Candidates → No Results Screen
                              │
                              ↓
                     ┌──────────────────┐
                     │  "Try:            │
                     │  • Broader search │
                     │  • Higher budget  │
                     │  • Different area"│
                     └──────────────────┘
```

### Path B: Error Handling
```
Any Step → Exception → Error Screen
                           │
                           ↓
                   ┌──────────────────┐
                   │ "Oops!           │
                   │ [Error message]  │
                   │ Try again"       │
                   └──────────────────┘
```

### Path C: Fallback Parsing (No API)
```
NLP Service → Gemini fails → Regex Fallback
                                    │
                                    ↓
                           Basic keyword extraction
                           (Still functional!)
```

---

## 📊 Data Flow with Examples

### Example 1: Simple Query
```
Input: "pizza"
  ↓
ParsedQuery: {intent: "search", product: "pizza"}
  ↓
Search: All products matching "pizza"
  ↓
Results: 5 pizzas found
  ↓
Rank: by price+rating+distance
  ↓
Top: "Margherita Pizza at PizzaHut, ₹200"
  ↓
Confirm: "Found it!" → Add to Cart
```

### Example 2: Complex Query with Clarification
```
Input: "Order best cake under ₹400"
  ↓
ParsedQuery: {
  intent: "order",
  product: "cake",
  priceLimit: 400,
  preference: "quality"
}
  ↓
Search: 8 cakes under ₹400
  ↓
Rank: with quality preference (rating weight = 50%)
  ↓
Top 2: Score 0.87 vs 0.86 (too close!)
  ↓
Clarify: "₹350 (nearby) or ₹380 (better rated)?"
  ↓
User: "Better rated"
  ↓
Re-rank: with quality preference boosted
  ↓
Confirm: "₹380 cake from SweetBake"
```

---

## 🎭 State Machine

```
┌──────────┐
│  IDLE    │ ←──────────────────────────┐
└────┬─────┘                            │
     │ User enters query                │
     ↓                                  │
┌──────────┐                            │
│PROCESSING│                            │
└────┬─────┘                            │
     │                                  │
     ├──→ [CONFIRMING] ─→ Add to Cart ─┤
     │                                  │
     ├──→ [CLARIFYING] ─→ Re-rank ─────┤
     │                                  │
     ├──→ [NO_RESULTS] ─→ Cancel ──────┤
     │                                  │
     └──→ [ERROR] ─────→ Cancel ────────┘
```

---

## 🔢 Scoring Example

```
Candidate A: Chocolate Cake
  - Price: ₹280 (normalized: 0.4)
  - Rating: 4.5 (normalized: 0.9)
  - Distance: 2 km (normalized: 0.2)
  - Delivery: 25 min (normalized: 0.5)

Score Calculation:
  price_score = 0.4 × (1 - 0.4) = 0.24
  rating_score = 0.3 × 0.9 = 0.27
  distance_score = 0.2 × (1 - 0.2) = 0.16
  delivery_score = 0.1 × (1 - 0.5) = 0.05
  
  Total Score = 0.24 + 0.27 + 0.16 + 0.05 = 0.72
```

---

## 🧩 Component Dependencies

```
AutoShopperScreen
        │
        ↓
AutoShopperService
        │
        ├──→ NLPParsingService
        │         │
        │         └──→ Google Gemini API
        │
        ├──→ ProductSearchService
        │         │
        │         └──→ Firebase Realtime DB
        │
        └──→ RankingService
                  │
                  └──→ Math calculations
```

---

## 🎨 UI State Transitions

```
Welcome Screen
     │
     │ User enters query
     ↓
Loading Spinner
     │
     ├──→ Confirmation Card (if clear match)
     │         │
     │         ├──→ [Add to Cart] → Success → Welcome
     │         └──→ [Cancel] → Welcome
     │
     ├──→ Clarification Card (if ambiguous)
     │         │
     │         └──→ User selects → Loading → Confirmation
     │
     ├──→ No Results Card
     │         │
     │         └──→ [Try Again] → Welcome
     │
     └──→ Error Card
               │
               └──→ [Try Again] → Welcome
```

---

## 📱 Real Example Walkthrough

```
1. User opens Auto-Shopper screen
   UI: Welcome screen with example chips

2. User taps "Chocolate cake under ₹300" chip
   UI: Loading spinner
   Backend: Parse → Search → Rank (2 seconds)

3. System finds clear match
   UI: Confirmation card with:
       - Image of chocolate cake
       - "Chocolate Cake"
       - "SweetBake Bakery"
       - "₹280 · 2.3 km · 25 min"
       - ⭐ 4.5
       - [Add to Cart] [Cancel]

4. User taps "Add to Cart"
   Backend: Firebase cart.push({...})
   UI: Success snackbar "Added to cart!"
   UI: Returns to welcome screen

Total time: ~4 seconds
Total interactions: 2 taps
Result: Product in cart ✅
```

---

**This diagram illustrates the complete flow from user input to final result!** 🎯
