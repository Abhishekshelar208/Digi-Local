# DigiLocal - App Separation Implementation Plan

## 🎯 Goal
Separate the unified DigiLocal app into two distinct applications:
1. **DigiLocal Customer App** - For customers to browse and buy
2. **DigiLocal Shop Owner App** - For shop owners to manage their business

---

## 📂 Proposed Project Structure

```
Digi-Local/
├── lib/
│   ├── core/                          # Shared code between both apps
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── shop_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── order_model.dart
│   │   │   └── cart_model.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── database_service.dart
│   │   │   ├── storage_service.dart
│   │   │   └── location_service.dart
│   │   ├── utils/
│   │   │   ├── constants.dart
│   │   │   ├── validators.dart
│   │   │   └── helpers.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── loading_widget.dart
│   │       └── error_widget.dart
│   │
│   ├── customer_app/                  # Customer-facing app
│   │   ├── main_customer.dart         # Entry point for customer app
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_customer_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── customer_home_screen.dart
│   │   │   │   ├── category_screen.dart
│   │   │   │   └── shop_list_screen.dart
│   │   │   ├── cart/
│   │   │   │   ├── cart_screen.dart
│   │   │   │   └── checkout_screen.dart
│   │   │   ├── orders/
│   │   │   │   ├── orders_list_screen.dart
│   │   │   │   ├── order_detail_screen.dart
│   │   │   │   └── order_tracking_screen.dart
│   │   │   ├── shop/
│   │   │   │   └── shop_detail_screen.dart
│   │   │   ├── chat/
│   │   │   │   ├── chats_list_screen.dart
│   │   │   │   └── chat_screen.dart
│   │   │   └── profile/
│   │   │       └── customer_profile_screen.dart
│   │   ├── widgets/
│   │   │   ├── shop_card.dart
│   │   │   ├── product_card.dart
│   │   │   ├── cart_item_widget.dart
│   │   │   └── order_card.dart
│   │   └── navigation/
│   │       └── customer_bottom_nav.dart
│   │
│   └── shop_owner_app/                # Shop owner-facing app
│       ├── main_shop_owner.dart       # Entry point for shop owner app
│       ├── screens/
│       │   ├── auth/
│       │   │   ├── login_screen.dart
│       │   │   └── register_shop_screen.dart
│       │   ├── dashboard/
│       │   │   ├── shop_dashboard_screen.dart
│       │   │   └── analytics_screen.dart
│       │   ├── orders/
│       │   │   ├── orders_management_screen.dart
│       │   │   ├── order_detail_screen.dart
│       │   │   └── qr_scanner_screen.dart
│       │   ├── products/
│       │   │   ├── products_list_screen.dart
│       │   │   ├── add_product_screen.dart
│       │   │   └── edit_product_screen.dart
│       │   ├── shop/
│       │   │   ├── shop_profile_screen.dart
│       │   │   ├── edit_shop_screen.dart
│       │   │   └── shop_sections_menu.dart
│       │   ├── chat/
│       │   │   ├── inquiries_list_screen.dart
│       │   │   └── chat_screen.dart
│       │   └── profile/
│       │       └── owner_profile_screen.dart
│       ├── widgets/
│       │   ├── order_card.dart
│       │   ├── product_card.dart
│       │   ├── analytics_card.dart
│       │   └── inquiry_card.dart
│       └── navigation/
│           └── owner_bottom_nav.dart
│
├── main_customer.dart                 # Customer app entry (root)
└── main_shop_owner.dart               # Shop owner app entry (root)
```

---

## 🗄️ Updated Database Schema

```javascript
// Firebase Realtime Database Structure

users/ {
  {userId}: {
    name: "John Doe",
    email: "john@example.com",
    phone: "+1234567890",
    profilePic: "https://...",
    userRole: "customer", // "customer" | "shop_owner" | "both"
    createdAt: "2025-01-31T12:00:00Z",
    
    // Customer-specific fields
    addresses: {
      {addressId}: {
        label: "Home",
        fullAddress: "123 Main St",
        city: "New York",
        zipCode: "10001",
        latitude: 40.7128,
        longitude: -74.0060,
        isDefault: true
      }
    },
    
    // Shop owner-specific fields (if userRole = "shop_owner" or "both")
    shopIds: ["SHOP001", "SHOP002"], // List of shops owned
  }
}

shops/ { // Previously "DigiLocal"
  {shopId}: {
    ownerId: "userId123",
    ownerEmail: "owner@example.com",
    shopInfo: { ... },
    products: { ... },
    services: { ... },
    // ... existing shop fields
    
    // New fields
    isActive: true,
    subscriptionPlan: "basic", // "free" | "basic" | "premium"
    bankDetails: { ... }, // For payments
  }
}

carts/ {
  {userId}: {
    items: {
      {cartItemId}: {
        shopId: "SHOP001",
        productId: "PROD123",
        productName: "Product Name",
        productImage: "https://...",
        price: 999,
        quantity: 2,
        addedAt: "2025-01-31T12:00:00Z"
      }
    },
    totalItems: 3,
    updatedAt: "2025-01-31T12:00:00Z"
  }
}

orders/ {
  {orderId}: {
    orderNumber: "ORD20250131001",
    customerId: "userId123",
    customerName: "John Doe",
    customerEmail: "john@example.com",
    customerPhone: "+1234567890",
    
    deliveryAddress: {
      fullAddress: "123 Main St",
      city: "New York",
      zipCode: "10001",
      latitude: 40.7128,
      longitude: -74.0060
    },
    
    items: {
      {itemId}: {
        shopId: "SHOP001",
        shopName: "ABC Store",
        productId: "PROD123",
        productName: "Product Name",
        productImage: "https://...",
        price: 999,
        quantity: 2,
        subtotal: 1998
      }
    },
    
    orderSummary: {
      subtotal: 1998,
      deliveryCharge: 50,
      tax: 100,
      total: 2148
    },
    
    paymentInfo: {
      method: "UPI", // "COD" | "UPI" | "Card"
      status: "pending", // "pending" | "paid" | "failed"
      transactionId: "TXN123456",
      paidAt: null
    },
    
    status: "pending", // "pending" | "confirmed" | "preparing" | "out_for_delivery" | "delivered" | "cancelled"
    
    shopOrders: {
      // Separate order per shop for multi-shop orders
      "SHOP001": {
        shopId: "SHOP001",
        shopName: "ABC Store",
        status: "pending",
        items: [...],
        subtotal: 1998,
        confirmedAt: null,
        deliveredAt: null
      }
    },
    
    timeline: [
      {
        status: "pending",
        timestamp: "2025-01-31T12:00:00Z",
        message: "Order placed"
      }
    ],
    
    createdAt: "2025-01-31T12:00:00Z",
    updatedAt: "2025-01-31T12:00:00Z"
  }
}

// Keep existing: offers, jobs, chats, requests
```

---

## 🎨 Customer App Features

### Bottom Navigation (5 tabs):
1. **Home** 🏠
   - Browse categories
   - Featured shops
   - Search functionality
   - Location-based shop listing

2. **Cart** 🛒
   - View cart items (grouped by shop)
   - Update quantities
   - Remove items
   - Checkout button

3. **Orders** 📦
   - Order history (all statuses)
   - Active orders with tracking
   - Past orders
   - Order details with timeline

4. **Chats** 💬
   - Conversations with shops
   - Inquiry history
   - Notifications

5. **Profile** 👤
   - Personal info
   - Saved addresses
   - Favorites/Wishlists
   - Settings
   - Logout

---

## 🏪 Shop Owner App Features

### Bottom Navigation (5 tabs):
1. **Dashboard** 📊
   - Today's sales
   - Pending orders count
   - Visitor analytics
   - Revenue graph

2. **Orders** 📋
   - Incoming orders (pending)
   - Order history (all statuses)
   - QR code scanner for pickup
   - Order management (accept/reject)

3. **Products** 📦
   - Product list
   - Add/Edit products
   - Stock management
   - Categories

4. **Chats** 💬
   - Customer inquiries
   - Active conversations
   - Quick replies

5. **Shop** 🏪
   - Shop profile preview
   - Edit shop details
   - Shop sections (16 sections)
   - Shop settings
   - Profile & logout

---

## 🔐 Authentication Flow

### Customer Registration:
1. Login/Register screen
2. Google Sign-In OR Email/Password
3. Choose user type → "I'm a Customer"
4. Fill basic info (name, phone)
5. Set delivery address
6. Navigate to Customer Home

### Shop Owner Registration:
1. Login/Register screen
2. Google Sign-In OR Email/Password
3. Choose user type → "I'm a Shop Owner"
4. Fill basic info (name, phone)
5. Create shop profile (step-by-step wizard)
6. Navigate to Shop Dashboard

---

## 🚀 Implementation Phases

### Phase 1: Shared Core (Week 1)
- [ ] Create core models
- [ ] Create shared services (auth, database, storage)
- [ ] Create shared widgets
- [ ] Add userRole field to database
- [ ] Update registration flow

### Phase 2: Customer App (Week 2-3)
- [ ] Customer bottom navigation
- [ ] Home screen (browse shops)
- [ ] Cart system
- [ ] Checkout flow
- [ ] Orders list & tracking
- [ ] Customer profile

### Phase 3: Shop Owner App (Week 3-4)
- [ ] Shop owner bottom navigation
- [ ] Dashboard with analytics
- [ ] Order management
- [ ] Product management
- [ ] Shop editing (reuse existing 16 sections)
- [ ] Owner profile

### Phase 4: Testing & Deployment (Week 5)
- [ ] Test customer flow end-to-end
- [ ] Test shop owner flow end-to-end
- [ ] Fix bugs
- [ ] Deploy both apps separately

---

## 📱 Build Configuration

### Customer App:
```yaml
# pubspec.yaml
name: digilocal_customer
description: DigiLocal - Shop Local, Save More

flutter:
  assets:
    - lib/customer_app/assets/
```

### Shop Owner App:
```yaml
# pubspec.yaml
name: digilocal_shop_owner
description: DigiLocal - Grow Your Business Online

flutter:
  assets:
    - lib/shop_owner_app/assets/
```

---

## 🔄 Migration Strategy

### Option A: Hard Separation (Recommended)
1. Create two new Flutter projects:
   - `digilocal_customer/`
   - `digilocal_shop_owner/`
2. Move shared code to a Dart package: `digilocal_core/`
3. Import core package in both apps
4. Build independently

### Option B: Single Project with Multiple Entry Points (Current Approach)
1. Keep single project
2. Create `main_customer.dart` and `main_shop_owner.dart`
3. Use flavors/build configurations
4. Build with: `flutter build apk --target=lib/main_customer.dart`

---

## 📝 Next Steps

1. **Decide on Option A or B**
2. **Create core models and services**
3. **Build customer app first** (higher priority)
4. **Build shop owner app** (reuse existing shop management code)
5. **Test and deploy**

---

## 🎯 Success Metrics

- ✅ Customer can browse shops by category
- ✅ Customer can add products to cart from multiple shops
- ✅ Customer can checkout and place order
- ✅ Customer can track order status
- ✅ Shop owner can view incoming orders
- ✅ Shop owner can accept/reject orders
- ✅ Shop owner can update order status
- ✅ Shop owner can manage products and shop profile

---

## 🔗 Related Files to Modify/Reuse

### From Current Codebase:
- ✅ `home_screen.dart` → Customer home
- ✅ `UsersListPage.dart` → Customer shop list
- ✅ `userdatapageforall.dart` → Customer shop detail
- ✅ `shopAnalyticsPage.dart` → Shop owner dashboard
- ✅ `onlineBookingForSHop.dart` → Shop owner orders
- ✅ `editShopSectionsMenu.dart` → Shop owner shop editing
- ✅ All `editSections/*.dart` → Shop owner shop editing

### To Create New:
- ❌ Cart system (completely new)
- ❌ Checkout flow (completely new)
- ❌ Order management (completely new)
- ❌ Customer orders list (completely new)
- ❌ Order tracking (completely new)
