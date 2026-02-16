import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/ar_view/screens/ar_view_screen.dart';


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
  TextEditingController modelUrlController = TextEditingController();
  List<Map<String, dynamic>> productsList = [];
  XFile? _selectedImage;
  XFile? _selectedModel;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopRef = FirebaseDatabase.instance.ref("DigiLocal/${widget.shopId}");
    debugPrint("DEBUG: EditProducts initialized for Shop ID: ${widget.shopId}");
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
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _pickModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['glb'],
    );

    if (result != null && result.count > 0) {
      setState(() {
        final pickedFile = result.files.first;
        if (kIsWeb) {
          _selectedModel = XFile.fromData(pickedFile.bytes!, name: pickedFile.name);
        } else {
          _selectedModel = XFile(pickedFile.path!);
        }
      });
    }
  }

  Future<String> _uploadFile(XFile file, String folder, String title, String ext) async {
    Reference storageRef = FirebaseStorage.instance.ref().child('$folder/${widget.shopId}/${DateTime.now().millisecondsSinceEpoch}_$title.$ext');
    
    // Web requires putData or putBlob. putData works everywhere.
    final bytes = await file.readAsBytes();
    await storageRef.putData(bytes, SettableMetadata(contentType: ext == 'glb' ? 'model/gltf-binary' : 'image/jpeg'));
    
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
        imageUrl = await _uploadFile(_selectedImage!, 'products', titleController.text, 'jpg');
      }

      String modelUrl = modelUrlController.text;
      if (_selectedModel != null) {
        modelUrl = await _uploadFile(_selectedModel!, 'models', titleController.text, 'glb');
      }

      setState(() {
        productsList.add({
          "title": titleController.text,
          "description": descriptionController.text,
          "productprice": priceController.text,
          "itemLeft": stockController.text,
          "purchaseLink": linkController.text,
          "modelUrl": modelUrl,
          "image": imageUrl,
          "likes": 0,
          "dislikes": 0,
        });
        titleController.clear();
        descriptionController.clear();
        priceController.clear();
        stockController.clear();
        linkController.clear();
        modelUrlController.clear();
        _selectedImage = null;
        _selectedModel = null;
      });
      
      debugPrint("DEBUG: Product added to local list. Current count: ${productsList.length}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added to list! Click 'Save Changes' at bottom to sync."),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
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
      debugPrint("DEBUG: Attempting to save ${productsList.length} products to Firebase at DigiLocal/${widget.shopId}");
      
      await _shopRef.update({
        "Products": productsList,
      });

      debugPrint("DEBUG: Firebase update successful.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("SUCCESS! All changes saved to database."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("DEBUG: Firebase update FAILED: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showARHelperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.view_in_ar, color: Colors.blue),
            SizedBox(width: 10),
            Text("How to get 3D Models?", style: GoogleFonts.blinker(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStep(1, "Download a scanning app like Polycam or Scaniverse (Free on iOS/Android)."),
            _buildStep(2, "Open the app and walk around your furniture to scan it from all sides."),
            _buildStep(3, "Export your scan as a .GLB file and upload it to your hosting/Firebase."),
            _buildStep(4, "Paste the generated .glb URL into the field below."),
            SizedBox(height: 10),
            Text("Tip: Good lighting and slow movement make the best 3D scans!", 
              style: GoogleFonts.blinker(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it!", style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(number.toString(), style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
          SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.blinker(fontSize: 16))),
        ],
      ),
    );
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
                  TextField(
                    controller: modelUrlController,
                    style: GoogleFonts.blinker(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    decoration: InputDecoration(
                      hintText: '3D Model URL (.glb)',
                      helperText: 'Required for AR view',
                      helperStyle: GoogleFonts.blinker(color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: Icon(Icons.view_in_ar, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.help_outline, color: Colors.blue),
                        onPressed: _showARHelperDialog,
                        tooltip: "Learn how to get 3D models",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text(_selectedImage == null ? "Product Image" : "Image Picked"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedImage == null ? Colors.grey[700] : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      // New 3D Model Pick Button
                      ElevatedButton.icon(
                        onPressed: _pickModel,
                        icon: Icon(Icons.view_in_ar),
                        label: Text(_selectedModel == null ? "3D Model" : "Model Picked"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedModel == null ? Colors.blue[700] : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addProduct,
                      child: Text("Add Product to List"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
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
                        onLongPress: product['modelUrl'] != null && product['modelUrl'].toString().isNotEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ARViewScreen(
                                      modelUrl: product['modelUrl'],
                                      productName: product['title'],
                                    ),
                                  ),
                                );
                              }
                            : null,
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
