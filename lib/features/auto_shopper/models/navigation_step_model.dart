import 'package:flutter/material.dart';

/// Types of navigation steps AI can perform
enum NavigationStepType {
  thinking,   // AI is analyzing/thinking
  navigate,   // Navigate to a new screen
  tap,        // Tap on a UI element
  scroll,     // Scroll through a list
  complete,   // Journey complete
}

/// Represents a single step in the AI navigation journey
class NavigationStep {
  final NavigationStepType type;
  final String title;
  final String description;
  final IconData icon;
  final String? targetRoute;
  final String? targetElement;
  final int delayMs;

  NavigationStep({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.targetRoute,
    this.targetElement,
    this.delayMs = 1000,
  });

  bool get isThinking => type == NavigationStepType.thinking;
  bool get isNavigation => type == NavigationStepType.navigate;
  bool get isTap => type == NavigationStepType.tap;
  bool get isScroll => type == NavigationStepType.scroll;
  bool get isComplete => type == NavigationStepType.complete;
}
