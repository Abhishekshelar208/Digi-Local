import 'package:flutter/material.dart';
import 'package:digilocal/pages/shopAnalyticsPage.dart';

/// Dashboard screen for shop owners
/// This screen reuses the existing ShopAnalytics page
class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Directly reuse the existing analytics page
    return ShopAnalytics();
  }
}
