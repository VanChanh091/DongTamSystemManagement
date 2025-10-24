import 'package:flutter/material.dart';

enum ResponsiveType { small, medium, large, xLarge }

class ResponsiveSize {
  static double getWidth(BuildContext context, ResponsiveType type) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base width theo loại form
    double baseWidth;
    switch (type) {
      case ResponsiveType.small:
        baseWidth = 400;
        break;
      case ResponsiveType.medium:
        baseWidth = 600;
        break;
      case ResponsiveType.large:
        baseWidth = 900;
        break;
      case ResponsiveType.xLarge:
        baseWidth = 1200;
        break;
    }

    // Giới hạn tối đa & scale nhẹ theo màn hình
    if (screenWidth < 600) {
      return screenWidth * 0.9; // mobile
    } else if (screenWidth < 900) {
      return baseWidth * 0.9;
    } else if (screenWidth < 1200) {
      return baseWidth;
    } else if (screenWidth < 1600) {
      return baseWidth + 100;
    } else {
      return baseWidth + 200;
    }
  }
}
