import 'package:flutter/material.dart';

enum WindowSize { xcompact, compact, medium, expanded }

class WindowSizeCalculator {
  static WindowSize getWindowSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= 620) {
      return WindowSize.xcompact;
    } else if (screenWidth <= 820) {
      return WindowSize.compact;
    } else if (screenWidth <= 1199) {
      return WindowSize.medium;
    } else {
      return WindowSize.expanded;
    }
  }
}
