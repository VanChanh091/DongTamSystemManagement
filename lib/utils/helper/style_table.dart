import 'package:flutter/material.dart';

Widget styleText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.white,
    ),
  );
}

//editing on table, update a little data
Widget styleCellAdmin(
  String text,
  ValueChanged<String> onChanged, {
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
    child: Text(text, maxLines: 2, style: TextStyle(fontSize: 14)),
  );
}
