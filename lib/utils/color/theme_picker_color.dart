import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showThemeColorDialog(BuildContext context) async {
  final themeController = Get.find<ThemeController>();
  Color tempColor = themeController.currentColor.value;

  Widget formatButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    Color bgColor = const Color(0xff78D761),
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Chọn Màu Theme",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) => tempColor = color,
            labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hueWheel, // hueWheel hoặc hsvWithHue
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          //cancel
          formatButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.close,
            text: "Hủy",
            bgColor: Color(0xffEA4346),
          ),

          //reset color
          formatButton(
            onPressed: () {
              themeController.resetColor();
              Navigator.pop(context);
            },
            icon: Icons.refresh,
            text: "Đặt lại",
          ),

          //confirm color
          formatButton(
            onPressed: () {
              themeController.updateColor(tempColor);
              Navigator.pop(context);
            },
            icon: Icons.check_circle,
            text: "OK",
          ),
        ],
      );
    },
  );
}
