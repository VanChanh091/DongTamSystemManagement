import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerStage = [
  {"key": "machine", "title": "Loại Máy"},
  {"key": "dayStart", "title": "Sản Xuất"},
  {"key": "dayCompleted", "title": "Hoàn Thành"},
  {"key": "dayCompletedOvfl", "title": "Hoàn Thành (Tràn)"},
  {"key": "timeRunning", "title": "Chạy"},
  {"key": "timeRunningOvfl", "title": "Tràn"},
  {"key": "runningPlan", "title": "Kế Hoạch Chạy"},
  {"key": "qtyProduced", "title": "SL Đã SX"},
  {"key": "wasteBox", "title": "Thực Tế"},
  {"key": "rpWasteLoss", "title": "Hao Hụt"},
  {"key": "shiftManagement", "title": "Trưởng Máy"},

  //hide
  {"key": "planningBoxId", "title": "", "visible": false},
  {"key": "isRequest", "title": "", "visible": false},
];

List<GridColumn> buildStageColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _headerStage,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);

List<StackedHeaderRow> buildDeliveryStageSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["dayStart", "dayCompleted", "dayCompletedOvfl"],
          label: "Ngày",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["size", "length"],
          label: "Quy Cách (cm)",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["timeRunning", "timeRunningOvfl"],
          label: "Thời Gian",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["runningPlan", "qtyProduced"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["wasteBox", "rpWasteLoss"],
          label: "Phế Liệu",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}

List<StackedHeaderRow> buildWaitingBoxStageSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["dayStart", "dayCompleted", "dayCompletedOvfl"],
          label: "Ngày",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["timeRunning", "timeRunningOvfl"],
          label: "Thời Gian",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["runningPlan", "qtyProduced"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["wasteBox", "rpWasteLoss"],
          label: "Phế Liệu",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
