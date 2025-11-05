# 🔐 Authentication & Role-Based Navigation

## ✅ **Implementation Complete!**

Your DigiLocal app now has a **complete role-based authentication system** that automatically navigates users to the correct app based on their role.

---

## 🎯 **How It Works**

### **1. New Users (First Sign-In)**
When a user signs in with Google for the first time:

1. **Google Authentication** → User signs in with Google account
2. **Role Selection Dialog** → Beautiful dialog appears with 3 options:
   - 🛍️ **I'm a Customer** - Browse and shop
   - 🏪 **I'm a Shop Owner** - Manage business
   - 👥 **Both** - Customer + Shop Owner
3. **Role Saved** → Selected role saved to Firebase (`/users/{userId}/userRole`)
4. **Auto Navigation** → User redirected to appropriate app

### **2. Existing Users (Returning)**
When a user signs in who already has an account:

1. **Google Authentication** → User signs in
2. **Check Database** → System checks their saved role
3. **Auto Navigation** → Directly navigates to their app:
   - `customer` → Customer App
   - `shopOwner` → Shop Owner App
   - `both` → Shows app selection dialog

---

## 🎨 **User Interface**

### **Role Selection Dialog (New Users)**
```
┌─────────────────────────────────────┐
│   Welcome to DigiLocal!             │
│   How would you like to use         │
│   the app?                          │
├─────────────────────────────────────┤
│  🛍️  I'm a Customer                 │
│     Browse local shops and make     │
│     purchases                    →  │
├─────────────────────────────────────┤
│  🏪  I'm a Shop Owner               │
│     Manage my shop and sell         │
│     products                     →  │
├─────────────────────────────────────┤
│  👥  Both                           │
│     I want to shop and manage my    │
│     business                     →  │
└─────────────────────────────────────┘
```

### **App Selection Dialog (Users with "Both" Role)**
```
┌─────────────────────────────────────┐
│          Choose App                  │
│   Which app would you like to       │
│   open?                             │
├─────────────────────────────────────┤
│   🛍️          │        🏪           │
│  Customer     │     Shop Owner      │
│               │                     │
└─────────────────────────────────────┘
```

---

## 📊 **Navigation Flow Chart**

```
                    Google Sign-In
                          ↓
                  ┌───────┴───────┐
                  │               │
            New User?        Existing User?
                  │               │
                  ↓               ↓
         Role Selection    Check userRole
         Dialog Appears    from Database
                  │               │
         ┌────────┼────────┐      │
         │        │        │      │
    Customer  ShopOwner  Both    │
         │        │        │      │
         ↓        ↓        ↓      ↓
         │        │    App Selection
         │        │    Dialog Shows
         │        │        │
         └────────┼────────┼──────┘
                  │        │
         ┌────────┴────┬───┴────────┐
         │             │            │
    Customer App   Shop Owner   Shop Creation
    (Direct)       App (Direct)  (CreateUserID)
```

---

## 🔥 **Features**

### **✅ Smart Navigation**
- New users: Role selection dialog
- Existing customers: Direct to Customer App
- Existing shop owners: Direct to Shop Owner App
- Users with both roles: App selection choice

### **✅ Beautiful UI**
- Gradient cards for each role option
- Clear icons and descriptions
- Smooth animations
- Loading states during authentication

### **✅ Firebase Integration**
- Saves user role to `/users/{userId}/userRole`
- Automatically creates user profile on first sign-in
- Updates role if user changes preference

### **✅ Error Handling**
- Shows error messages for failed sign-ins
- Handles context-mounted checks
- Graceful error recovery

---

## 🗂️ **Firebase Database Structure**

### **User Node:**
```json
{
  "users": {
    "{userId}": {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "profilePic": "https://...",
      "userRole": "customer",  // or "shopOwner" or "both"
      "createdAt": "2025-10-31T13:00:00.000Z",
      "shopIds": ["shop123"],  // Only for shop owners
      "addresses": {           // Only for customers
        "home": {
          "addressId": "addr1",
          "label": "Home",
          "fullAddress": "123 Main St",
          "city": "New York",
          "zipCode": "10001",
          "latitude": 40.7128,
          "longitude": -74.0060,
          "isDefault": true
        }
      }
    }
  }
}
```

### **User Roles:**
- `customer` - Can browse and shop
- `shopOwner` - Can manage shop and sell
- `both` - Can do both (dual access)

---

## 🚀 **Testing the Flow**

### **Test as New Customer:**
1. Run the app
2. Click "Get Started" on last onboarding slide
3. Sign in with Google
4. Select "I'm a Customer"
5. ✅ Should navigate to Customer App (5 tabs: Home, Cart, Orders, Chats, Profile)

### **Test as New Shop Owner:**
1. Run the app
2. Click "Get Started"
3. Sign in with Google
4. Select "I'm a Shop Owner"
5. ✅ Should navigate to Shop Creation flow (CreateUserID page)

### **Test as Both:**
1. Run the app
2. Click "Get Started"
3. Sign in with Google
4. Select "Both"
5. ✅ Should show app selection dialog
6. Choose either Customer or Shop Owner
7. ✅ Navigate to selected app

### **Test as Returning User:**
1. Sign out from app
2. Sign in again with same Google account
3. ✅ Should automatically navigate to your app (no role selection)

---

## 📝 **Code Changes**

### **Modified File:**
`lib/pages/googleSingin.dart`

### **Key Additions:**

1. **Imports:**
   ```dart
   import 'package:firebase_database/firebase_database.dart';
   import 'package:digilocal/core/models/user_model.dart';
   import 'package:digilocal/customer_app/navigation/customer_main_screen.dart';
   import 'package:digilocal/shop_owner_app/navigation/owner_main_screen.dart';
   ```

2. **New Methods:**
   - `_parseUserRole()` - Parse user role from Firebase
   - `_navigateBasedOnRole()` - Navigate based on user's role
   - `_showRoleSelectionDialog()` - Show role selection for new users
   - `_showAppSelectionDialog()` - Show app selection for "both" users
   - `_saveUserRole()` - Save selected role to Firebase
   - `_buildRoleCard()` - UI for role selection cards
   - `_buildAppSelectionCard()` - UI for app selection cards

3. **Updated Sign-In Flow:**
   - Check if user exists in database
   - If exists: Auto-navigate based on role
   - If new: Show role selection dialog
   - Save role to Firebase
   - Navigate accordingly

---

## 🎨 **Design Details**

### **Color Schemes:**

**Customer Option:**
- Gradient: Purple to Violet (`#667EEA` → `#764BA2`)
- Icon: Shopping Bag

**Shop Owner Option:**
- Gradient: Pink to Red (`#F093FB` → `#F5576C`)
- Icon: Store

**Both Option:**
- Gradient: Blue to Cyan (`#4FACFE` → `#00F2FE`)
- Icon: People

---

## 🔧 **Customization Options**

### **Change Default Role:**
Edit line 255 in `googleSingin.dart`:
```dart
if (role == null) return UserRole.customer; // Change to shopOwner or both
```

### **Skip Role Selection (Force Customer):**
Replace `_showRoleSelectionDialog()` call with:
```dart
await _saveUserRole(user, UserRole.customer);
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => CustomerMainScreen()),
);
```

### **Skip Role Selection (Force Shop Owner):**
Replace with:
```dart
await _saveUserRole(user, UserRole.shopOwner);
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => CreateUserID()),
);
```

---

## ✅ **Benefits**

### **For Users:**
- ✅ Clear role selection on first use
- ✅ Automatic navigation on subsequent logins
- ✅ Beautiful, intuitive UI
- ✅ No confusion about which app to use

### **For You (Developer):**
- ✅ Clean separation between customer and shop owner flows
- ✅ Single authentication point
- ✅ Reusable role-based logic
- ✅ Easy to extend with new roles

### **For Your Business:**
- ✅ Clear user segmentation
- ✅ Better analytics (know who are customers vs shop owners)
- ✅ Targeted features per user type
- ✅ Professional onboarding experience

---

## 🐛 **Troubleshooting**

### **Issue: Role selection doesn't appear**
**Solution:** Check Firebase permissions - ensure write access to `/users/{userId}`

### **Issue: Navigation doesn't work**
**Solution:** Verify imports for `CustomerMainScreen` and `OwnerMainScreen`

### **Issue: Existing users stuck**
**Solution:** Manually add `userRole` field to their Firebase user node:
```json
{
  "userRole": "customer"  // or "shopOwner" or "both"
}
```

---

## 📱 **What Users See**

### **First Launch (New User):**
1. Onboarding slides (3 slides)
2. "Get Started" button on last slide
3. Google Sign-In popup
4. Beautiful role selection dialog
5. Direct navigation to appropriate app

### **Subsequent Launches (Existing User):**
1. Onboarding slides (can skip)
2. "Get Started" button
3. Google Sign-In popup
4. **Instant navigation** to their app (no dialog!)

### **Users with "Both" Role:**
1. Every login shows app selection
2. Can choose Customer or Shop Owner app
3. Quick, 2-button dialog

---

## 🎊 **Success Metrics**

- ✅ **Clear User Segmentation** - Know who's who from day 1
- ✅ **Smooth Onboarding** - No confusion, clear choices
- ✅ **Automatic Returns** - Existing users go straight to their app
- ✅ **Professional UX** - Beautiful dialogs and smooth transitions
- ✅ **Flexible System** - Easy to add more roles or change logic

---

## 🚀 **Next Steps**

### **Option A: Test the Flow**
```bash
flutter run
```
Test all three role selections!

### **Option B: Add Role Switching**
Allow users to switch roles from Profile screen:
```dart
// In Profile screen
ElevatedButton(
  onPressed: () {
    _showRoleSelectionDialog(context);
  },
  child: Text("Switch Role"),
)
```

### **Option C: Add Analytics**
Track which role users select:
```dart
// After role selection
FirebaseAnalytics().logEvent(
  name: 'role_selected',
  parameters: {'role': role.toString()},
);
```

---

## 🏆 **Summary**

You now have a **complete, production-ready authentication system** with:

- ✅ Beautiful role selection UI
- ✅ Automatic navigation based on user role
- ✅ Firebase integration for role persistence
- ✅ Support for users with multiple roles
- ✅ Loading states and error handling
- ✅ Clean, maintainable code

**Your app is ready for users!** 🎉

---

## 📚 **Related Files**

- `lib/pages/googleSingin.dart` - Updated authentication
- `lib/core/models/user_model.dart` - User role definitions
- `lib/customer_app/navigation/customer_main_screen.dart` - Customer app
- `lib/shop_owner_app/navigation/owner_main_screen.dart` - Shop owner app
- `lib/pages/createShops.dart` - Shop creation flow

---

**Need help? Check the code comments or test different scenarios!** 🚀
