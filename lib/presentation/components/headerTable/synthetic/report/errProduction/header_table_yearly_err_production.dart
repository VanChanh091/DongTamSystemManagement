import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/data/controller/theme_controller.dart";
import 'package:flutter/material.dart';
import "package:syncfusion_flutter_datagrid/datagrid.dart";

// Cột cố định đầu bảng: STT + Tên Tiêu Chí + Tổng (Lỗi, Tấn, Tỉ Lệ)
const List<Map<String, dynamic>> _fixedHeaderYearlyErr = [
  {"key": "index", "title": "STT"},
  {"key": "criteriaName", "title": "Tên Tiêu Chí"},
  {"key": "totalTonnage", "title": "Tổng Tấn Giấy"},
  {"key": "totalErrors", "title": "Tổng Lỗi"},
  {"key": "totalErrorRate", "title": "Tỉ Lệ (%)"},
];

List<GridColumn> buildYearlyErrProductionColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: [
    ..._fixedHeaderYearlyErr,
    for (int m = 1; m <= 12; m++) ...[
      {"key": "m_${m}_tonnage", "title": "Tấn Giấy"},
      {"key": "m_${m}_errors", "title": "Số Lỗi"},
      {"key": "m_${m}_rate", "title": "Tỉ Lệ (%)"},
    ],
  ],
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildYearlyErrProductionSHR({
  required ThemeController themeController,
  required int selectedYear,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: const ["totalTonnage", "totalErrors", "totalErrorRate"],
          label: "Cả Năm $selectedYear",
          themeController: themeController,
          zoom: zoom,
        ),
        for (int m = 1; m <= 12; m++)
          buildStackedHeaderCell(
            columnNames: ["m_${m}_tonnage", "m_${m}_errors", "m_${m}_rate"],
            label: "Tháng $m",
            themeController: themeController,
            zoom: zoom,
          ),
      ],
    ),
  ];
}
