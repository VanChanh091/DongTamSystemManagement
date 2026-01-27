import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static const _keyThemeColor = "theme_color";
  static const _keyButtonColor = "button_color";
  static const _keyIsThemeCustomized = "is_theme_customized";

  final _storage = const FlutterSecureStorage();

  //default color
  static const Color defaultThemeColor = Color(0xffcfa381);
  static const Color defaultButtonColor = Color(0xff78D761);

  final Rx<Color> currentColor = defaultThemeColor.obs;
  final Rx<Color> buttonColor = defaultButtonColor.obs;
  final RxBool isThemeCustomized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final hexColor = await _storage.read(key: _keyThemeColor);
    final hexButtonColor = await _storage.read(key: _keyButtonColor);
    final customizedFlag = await _storage.read(key: _keyIsThemeCustomized);

    if (hexColor != null) {
      currentColor.value = Color(int.parse(hexColor, radix: 16));
    }
    if (hexButtonColor != null) {
      buttonColor.value = Color(int.parse(hexButtonColor, radix: 16));
    }

    isThemeCustomized.value = customizedFlag == "true";
  }

  Future<void> updateColor({required Color newColor}) async {
    currentColor.value = newColor;
    buttonColor.value = newColor;
    isThemeCustomized.value = true;

    await _storage.write(key: _keyThemeColor, value: newColor.toARGB32().toRadixString(16));

    await _storage.write(key: _keyButtonColor, value: newColor.toARGB32().toRadixString(16));

    await _storage.write(key: _keyIsThemeCustomized, value: "true");
  }

  void resetColor() async {
    currentColor.value = defaultThemeColor;
    buttonColor.value = defaultButtonColor;
    isThemeCustomized.value = false;

    await _storage.write(
      key: _keyThemeColor,
      value: defaultThemeColor.toARGB32().toRadixString(16),
    );

    await _storage.write(
      key: _keyButtonColor,
      value: defaultButtonColor.toARGB32().toRadixString(16),
    );

    await _storage.write(key: _keyIsThemeCustomized, value: "false");
  }
}
