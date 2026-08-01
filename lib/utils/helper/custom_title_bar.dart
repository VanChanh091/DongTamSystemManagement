import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return SizedBox(
        height: 24,
        child: WindowCaption(
          backgroundColor: themeController.currentColor.value,
          brightness: Brightness.dark, // Icon nút bấm màu trắng
        ),
      );
    });
  }
}
