import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPaymentMethods extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditPaymentMethods({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditPaymentMethodsState createState() => _EditPaymentMethodsState();
}

class _EditPaymentMethodsState extends State<EditPaymentMethods> {
  late DatabaseReference _shopRef;
  List<String> selectedPaymentMethods = [];
  bool isLoading = false;

  final List<Map<String, dynamic>> paymentOptions = [
    {'value': 'Cash', 'label': 'Cash', 'icon': Icons.money},
    {'value': 'UPI', 'label': 'UPI (GPay, PhonePe, Paytm)', 'icon': Icons.qr_code},
    {'value': 'Credit Card', 'label': 'Credit Card', 'icon': Icons.credit_card},
    {'value': 'Debit Card', 'label': 'Debit Card', 'icon': Icons.credit_card_outlined},
    {'value': 'Net Banking', 'label': 'Net Banking', 'icon': Icons.account_balance},
    {'value': 'Wallets', 'label': 'Mobile Wallets', 'icon': Icons.wallet},
    {'value': 'COD', 'label': 'Cash on Delivery', 'icon': Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    selectedPaymentMethods = (widget.shopData['paymentMethods'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  void _togglePaymentMethod(String method) {
    setState(() {
      if (selectedPaymentMethods.contains(method)) {
        selectedPaymentMethods.remove(method);
      } else {
        selectedPaymentMethods.add(method);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (selectedPaymentMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one payment method")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "paymentMethods": selectedPaymentMethods,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment methods updated successfully!")),
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
          "Payment Methods",
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
                  // Info Card
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Select all payment methods that your shop accepts",
                              style: GoogleFonts.blinker(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    "Select Payment Methods",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 12),

                  // Payment Method Options
                  ...paymentOptions.map((option) {
                    final isSelected = selectedPaymentMethods.contains(option['value']);
                    return GestureDetector(
                      onTap: () => _togglePaymentMethod(option['value']),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option['icon'],
                              color: isSelected ? Colors.green : Colors.grey,
                              size: 32,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option['label'],
                                style: GoogleFonts.blinker(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              activeColor: Colors.green,
                              onChanged: (value) => _togglePaymentMethod(option['value']),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 24),

                  // Selected Count
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payment, color: Colors.black54, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payment Methods Selected",
                                style: GoogleFonts.blinker(fontSize: 14, color: Colors.black54),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${selectedPaymentMethods.length} method${selectedPaymentMethods.length != 1 ? 's' : ''}",
                                style: GoogleFonts.blinker(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

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
}
