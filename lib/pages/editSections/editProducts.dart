import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProducts extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const EditProducts({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  _EditProductsState createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
  late DatabaseReference _shopRef;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  List<Map<String, dynamic>> productsList = [];
  File? _selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    _loadProducts();
  }

  void _loadProducts() {
    if (widget.shopData['Products'] != null) {
      productsList = (widget.shopData['Products'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile, String title) async {
    Reference storageRef = FirebaseStorage.instance.ref().child('products/${widget.shopId}/${DateTime.now().millisecondsSinceEpoch}_$title.jpg');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  Future<void> _addProduct() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter product title")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = "https://www.infopedia.ai/no-image.png";
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!, titleController.text);
      }

      setState(() {
        productsList.add({
          "title": titleController.text,
          "description": descriptionController.text,
          "productprice": priceController.text,
          "itemLeft": stockController.text,
          "purchaseLink": linkController.text,
          "image": imageUrl,
          "likes": 0,
          "dislikes": 0,
        });
        titleController.clear();
        descriptionController.clear();
        priceController.clear();
        stockController.clear();
        linkController.clear();
        _selectedImage = null;
      });
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

  void _removeProduct(int index) {
    setState(() {
      productsList.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _shopRef.update({
        "Products": productsList,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Products updated successfully!")),
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
          "Edit Products",
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
                  Text(
                    "Add Product",
                    style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(hintText: 'Product name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    maxLines: 2,
                    decoration: InputDecoration(hintText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                          decoration: InputDecoration(hintText: 'Price', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                          decoration: InputDecoration(hintText: 'Stock', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: linkController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(hintText: 'Purchase link (optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text(_selectedImage == null ? "Pick Image" : "Selected"),
                        style: ElevatedButton.styleFrom(backgroundColor: _selectedImage == null ? Colors.grey[700] : Colors.green, foregroundColor: Colors.white),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addProduct,
                        child: Text("Add Product"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Products (${productsList.length})",
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  ...productsList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(product['image'], width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stack) => Icon(Icons.image, size: 60)),
                        ),
                        title: Text(product['title'], style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text("₹${product['productprice']} • Stock: ${product['itemLeft']}", style: GoogleFonts.blinker(fontSize: 14, color: Colors.grey[600])),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeProduct(index),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
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
                      child: Text("Save Changes", style: GoogleFonts.blinker(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
