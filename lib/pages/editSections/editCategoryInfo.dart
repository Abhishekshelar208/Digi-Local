import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCategoryInfo extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditCategoryInfo({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditCategoryInfoState createState() => _EditCategoryInfoState();
}

class _EditCategoryInfoState extends State<EditCategoryInfo> {
  late DatabaseReference _shopRef;
  String? selectedCategory;
  String? selectedSubCategory;
  bool isLoading = false;

  final Map<String, List<String>> categories = {
    "Grocery Stores": ["Grocery", "Supermarket", "Fresh Produce", "Vegetables", "Fruits", "Daily Needs", "Food Store"],
    "Restaurants & Cafes": ["Restaurant", "Cafe", "Food", "Eatery", "Cake Shop", "Fine Dining", "Bakery", "Fast Food", "Coffee Shop"],
    "Fashion & Clothing": ["Clothing", "Fashion", "Apparel", "Boutique", "Footwear", "Accessories", "Designer Wear"],
    "Electronics": ["Electronics", "Gadgets", "Mobile", "Laptop", "TV", "Home Appliances", "Computers", "Tech Store"],
    "Home & Furniture": ["Furniture", "Home Decor", "Interior", "Sofa", "Bed", "Lighting", "Curtains", "Woodwork"],
    "Beauty & Wellness": ["Beauty", "Salon", "Spa", "Skincare", "Cosmetics", "Makeup", "Haircare", "Wellness"],
    "Automobile Services": ["Automobile", "Car Service", "Bike Repair", "Mechanic", "Spare Parts", "Vehicle Maintenance"],
    "Pharmacies": ["Pharmacy", "Medical Store", "Medicines", "Healthcare", "Chemist", "Drugstore"],
    "Sports & Fitness": ["Sports", "Gym", "Fitness", "Workout", "Exercise", "Athletic", "Training", "Sports Gear"],
    "Handicrafts & Art": ["Handicrafts", "Art", "Handmade", "Gift Shop", "Local Art", "Pottery", "Traditional Crafts", "Artwork"],
    "Pet Shops": ["Pet", "Animal Store", "Pet Food", "Veterinary", "Pets Accessories", "Pet Grooming"],
  };

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    selectedCategory = widget.shopData['category']?.toString();
    selectedSubCategory = widget.shopData['subCategory']?.toString();
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "category": selectedCategory,
        "subCategory": selectedSubCategory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Category updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F0EF),
      appBar: AppBar(
        title: Text(
          "Edit Category",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Main Category",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    items: categories.keys.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                        selectedSubCategory = null;
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  if (selectedCategory != null) ...[
                    Text(
                      "Sub-Category",
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedSubCategory,
                      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      items: categories[selectedCategory]!.map((String subCategory) {
                        return DropdownMenuItem<String>(
                          value: subCategory,
                          child: Text(subCategory),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubCategory = newValue;
                        });
                      },
                    ),
                  ],
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        minimumSize: Size(200, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        "Save Changes",
                        style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
