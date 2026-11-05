import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import 'package:flutter/material.dart';
import "package:syncfusion_flutter_datagrid/datagrid.dart";

// Cột cố định (không phụ thuộc vào danh sách năm)
const List<Map<String, dynamic>> _fixedHeaderYearlyRevenue = [
  {"key": "index", "title": "STT"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "currentDebt", "title": "Công Nợ"},
  {"key": "grandTotal", "title": "Tổng Cộng"},

  //hidden
  {"key": "customerId", "title": "", "visible": false},
];

List<GridColumn> buildYearlyRevenueColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  List<int> years = const [],
}) => buildGridColumns(
  headerConfig: [
    ..._fixedHeaderYearlyRevenue,
    for (final y in years) ...[
      for (int m = 1; m <= 12; m++)
        {"key": "y_${y}_m_$m", "title": "T$m"},
      {"key": "y_${y}_total", "title": "Tổng $y"},
    ],
  ],
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildYearlyRevenueSHR({
  required ThemeController themeController,
  required List<int> years,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: years.map((y) {
        return buildStackedHeaderCell(
          columnNames: [
            for (int m = 1; m <= 12; m++) "y_${y}_m_$m",
            "y_${y}_total",
          ],
          label: "Năm $y",
          themeController: themeController,
          zoom: zoom,
        );
      }).toList(),
    ),
  ];
}
