import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerMachinePaper = [
  {"key": "changeDiffSize", "title": "Khác khổ"},
  {"key": "changeSameSize", "title": "Cùng khổ"},
  {"key": "speed2Layer", "title": "2 Lớp"},
  {"key": "speed3Layer", "title": "3 Lớp"},
  {"key": "speed4Layer", "title": "4 Lớp"},
  {"key": "speed5Layer", "title": "5 Lớp"},
  {"key": "speed6Layer", "title": "6 Lớp"},
  {"key": "speed7Layer", "title": "7 Lớp"},
  {"key": "machineRollPaper", "title": "Quấn Cuồn"},
  {"key": "efficiency", "title": "Hiệu Suất"},
  {"key": "machineName", "title": "Tên Máy"},
  {"key": "type", "title": "Loại"},

  //hidden field
  {"key": "machineId", "title": "", "visible": false},
];

List<GridColumn> buildMachinePaperColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerMachinePaper,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildMachinePaperSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "speed2Layer",
            "speed3Layer",
            "speed4Layer",
            "speed5Layer",
            "speed6Layer",
            "speed7Layer",
            "machineRollPaper",
          ],
          label: "Tốc Độ Máy",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["changeDiffSize", "changeSameSize"],
          label: "Thời Gian Đổi",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
