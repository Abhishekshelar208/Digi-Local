import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditDeliverySettings extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditDeliverySettings({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditDeliverySettingsState createState() => _EditDeliverySettingsState();
}

class _EditDeliverySettingsState extends State<EditDeliverySettings> {
  late DatabaseReference _shopRef;
  bool deliveryAvailable = false;
  TextEditingController deliveryRadiusController = TextEditingController();
  TextEditingController minimumOrderController = TextEditingController();
  TextEditingController deliveryFeeController = TextEditingController();
  TextEditingController deliveryTimingsController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadDeliverySettings();
  }

  void _loadDeliverySettings() {
    final deliverySettings = widget.shopData['deliverySettings'] as Map?;
    if (deliverySettings != null) {
      deliveryAvailable = deliverySettings['available'] ?? false;
      deliveryRadiusController.text = deliverySettings['radius']?.toString() ?? '';
      minimumOrderController.text = deliverySettings['minimumOrder']?.toString() ?? '';
      deliveryFeeController.text = deliverySettings['deliveryFee']?.toString() ?? '';
      deliveryTimingsController.text = deliverySettings['timings']?.toString() ?? '';
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "deliverySettings": {
          "available": deliveryAvailable,
          "radius": deliveryRadiusController.text.trim(),
          "minimumOrder": minimumOrderController.text.trim(),
          "deliveryFee": deliveryFeeController.text.trim(),
          "timings": deliveryTimingsController.text.trim(),
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delivery settings updated successfully!")),
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
          "Delivery Settings",
          style: GoogleFonts.blinker(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF2F0EF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Available Toggle
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: SwitchListTile(
                      title: Text(
                        "Delivery Available",
                        style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Text(
                        deliveryAvailable ? "Currently offering delivery" : "Delivery not available",
                        style: GoogleFonts.blinker(fontSize: 14, color: Colors.black54),
                      ),
                      value: deliveryAvailable,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          deliveryAvailable = value;
                        });
                      },
                      secondary: Icon(
                        deliveryAvailable ? Icons.delivery_dining : Icons.delivery_dining_outlined,
                        color: deliveryAvailable ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  if (deliveryAvailable) ...[
                    Text(
                      "Delivery Details",
                      style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 12),

                    // Delivery Radius
                    TextField(
                      controller: deliveryRadiusController,
                      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      decoration: InputDecoration(
                        labelText: 'Delivery Radius',
                        hintText: 'e.g., 5 km',
                        prefixIcon: Icon(Icons.location_on),
                        hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                        labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
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
                    ),
                    SizedBox(height: 12),

                    // Minimum Order
                    TextField(
                      controller: minimumOrderController,
                      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Minimum Order Value',
                        hintText: 'e.g., ₹200',
                        prefixIcon: Icon(Icons.shopping_cart),
                        hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                        labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
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
                    ),
                    SizedBox(height: 12),

                    // Delivery Fee
                    TextField(
                      controller: deliveryFeeController,
                      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Delivery Fee',
                        hintText: 'e.g., ₹50 or Free',
                        prefixIcon: Icon(Icons.currency_rupee),
                        hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                        labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
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
                    ),
                    SizedBox(height: 12),

                    // Delivery Timings
                    TextField(
                      controller: deliveryTimingsController,
                      style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Delivery Timings',
                        hintText: 'e.g., 30-45 minutes',
                        prefixIcon: Icon(Icons.access_time),
                        hintStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.grey),
                        labelStyle: GoogleFonts.blinker(fontSize: 16, color: Colors.black54),
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
                    ),
                  ],

                  SizedBox(height: 32),

                  // Save Button
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
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    deliveryRadiusController.dispose();
    minimumOrderController.dispose();
    deliveryFeeController.dispose();
    deliveryTimingsController.dispose();
    super.dispose();
  }
}
