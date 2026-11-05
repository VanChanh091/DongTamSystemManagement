import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

Widget styleText(String text) {
  return Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
  );
}

//editing on table, update a little data
Widget styleCellAdmin({
  required String text,
  required ValueChanged<String>? onChanged,
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

Widget styleCell({required String label, double? width}) {
  return SizedBox(
    width: width,
    child: Text(label, maxLines: 2, style: const TextStyle(fontSize: 15)),
  );
}

Widget formatColumn({
  required String label,
  required ThemeController themeController,
  double fontSize = 15,
}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 3),
    decoration: BoxDecoration(
      color: themeController.currentColor.value,
      border: Border(right: BorderSide(color: Colors.grey.shade400, width: 1)),
    ),
    child: Text(
      label,
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: Colors.white),
    ),
  );
}

Widget formatDataTable({
  required String label,
  required Alignment alignment,
  Color cellColor = Colors.transparent,
  TextStyle? textStyle,
  Color? textColor,
  Widget? leading,
  double zoom = 1.0,
}) {
  final baseFontSize = textStyle?.fontSize ?? 14.0;
  final effectiveFontSize = (baseFontSize * zoom).clamp(10.0, 20.0);
  final effectiveTextStyle = (textStyle ?? TextStyle(fontWeight: FontWeight.w400, color: textColor))
      .copyWith(fontSize: effectiveFontSize);

  return Container(
    alignment: alignment,
    decoration: BoxDecoration(
      color: cellColor,
      border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: (8.0 * zoom).clamp(2.0, 10.0),
      vertical: (4.0 * zoom).clamp(1.0, 6.0),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: effectiveTextStyle,
          ),
        ),
        SizedBox(width: (5 * zoom).clamp(2.0, 8.0)),
        if (leading != null) ...[leading, SizedBox(width: (4 * zoom).clamp(1.0, 6.0))],
      ],
    ),
  );
}

List<GridColumn> buildGridColumns({
  required List<Map<String, dynamic>> headerConfig,
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  double baseFontSize = 15.0,
  String? page,
}) {
  return [
    for (var item in headerConfig)
      if (!item.containsKey("visiblePages") || (item["visiblePages"] as List).contains(page))
        GridColumn(
          columnName: item["key"]!,
          width: item.containsKey("width") ? (item["width"] as num).toDouble() : double.nan,
          label: ValueListenableBuilder<double>(
            valueListenable: zoomNotifier,
            builder:
                (context, zoom, _) => Obx(
                  () => formatColumn(
                    label: item["title"]!,
                    themeController: themeController,
                    fontSize: (baseFontSize * zoom).clamp(12.0, 22.0),
                  ),
                ),
          ),
          visible: item.containsKey("visible") ? item["visible"]! as bool : true,
        ),
  ];
}

StackedHeaderCell buildStackedHeaderCell({
  required List<String> columnNames,
  required String label,
  required ThemeController themeController,
  double zoom = 1.0,
  double baseFontSize = 15.0,
}) {
  return StackedHeaderCell(
    columnNames: columnNames,
    child: Obx(
      () => formatColumn(
        label: label,
        themeController: themeController,
        fontSize: (baseFontSize * zoom).clamp(12.0, 22.0),
      ),
    ),
  );
}
