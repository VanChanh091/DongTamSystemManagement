import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static const _keyThemeColor = "theme_color";
  static const _keyButtonColor = "button_color";
  final _storage = const FlutterSecureStorage();

  final Rx<Color> currentColor = Color(0xffcfa381).obs;
  final Rx<Color> buttonColor = Color(0xff78D761).obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final hexColor = await _storage.read(key: _keyThemeColor);
    final hexButtonColor = await _storage.read(key: _keyButtonColor);

    if (hexColor != null) {
      currentColor.value = Color(int.parse(hexColor, radix: 16));
    }
    if (hexButtonColor != null) {
      buttonColor.value = Color(int.parse(hexButtonColor, radix: 16));
    }
  }

  Future<void> updateColor(Color newColor) async {
    currentColor.value = newColor;
    buttonColor.value = newColor;

    await _storage.write(
      key: _keyThemeColor,
      value: newColor.toARGB32().toRadixString(16),
    );

    await _storage.write(
      key: _keyButtonColor,
      value: newColor.toARGB32().toRadixString(16),
    );
  }

  void resetColor() async {
    final defaultColor = const Color(0xffcfa381);
    final defaultButtonColor = const Color(0xff78D761);

    currentColor.value = defaultColor;
    buttonColor.value = defaultButtonColor;

    await _storage.write(
      key: _keyThemeColor,
      value: defaultColor.toARGB32().toRadixString(16),
    );
    await _storage.write(
      key: _keyButtonColor,
      value: defaultButtonColor.toARGB32().toRadixString(16),
    );
  }
}
