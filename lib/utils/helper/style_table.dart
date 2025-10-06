import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';

Widget styleText(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.white,
    ),
  );
}

//editing on table, update a little data
Widget styleCellAdmin(
  String text,
  ValueChanged<String>? onChanged, {
  double width = 100,
}) {
  return SizedBox(
    width: double.infinity,
    child: TextFormField(
      initialValue: text,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      onChanged: onChanged,
    ),
  );
}

Widget styleCell(String text, {double? width}) {
  return SizedBox(
    width: width,
    child: Text(text, maxLines: 2, style: const TextStyle(fontSize: 15)),
  );
}

Widget formatColumn({
  required String label,
  required ThemeController themeController,
}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: themeController.currentColor.value,
      border: Border(right: BorderSide(color: Colors.grey.shade400, width: 1)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.white,
      ),
    ),
  );
}
