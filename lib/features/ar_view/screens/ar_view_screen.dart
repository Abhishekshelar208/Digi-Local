import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewScreen extends StatefulWidget {
  final String modelUrl;
  final String productName;

  const ARViewScreen({
    super.key,
    required this.modelUrl,
    required this.productName,
  });

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    // Hide loading after 5 seconds to ensure it doesn't block the model forever
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("DEBUG: ARViewScreen loading model from: ${widget.modelUrl}");
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          widget.productName,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ModelViewer(
            backgroundColor: const Color(0xFF1A1A1A),
            src: widget.modelUrl,
            alt: "A 3D model of ${widget.productName}",
            ar: true,
            autoRotate: true,
            cameraControls: true,
            loading: Loading.eager,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
          ),
          // Loading Indicator Overlay - only show if _showLoading is true
          if (_showLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.blue),
                    const SizedBox(height: 15),
                    Text("Downloading Trophy...", 
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    const Text("Usually takes 5-10 seconds", 
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Wait for loading, then tap the cube icon to see in AR!",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
