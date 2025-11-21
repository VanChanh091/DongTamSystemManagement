import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> headerStage = [
  {"key": "machine", "title": "Loại Máy"},
  {"key": "dayStart", "title": "Ngày SX"},
  {"key": "dayCompleted", "title": "Ngày Hoàn Thành"},
  {"key": "timeRunning", "title": "Thời Gian Chạy"},
  {"key": "runningPlan", "title": "Kế Hoạch Chạy"},
  {"key": "qtyProduced", "title": "SL Đã SX"},
  {"key": "wasteBox", "title": "PL Thực Tế"},
  {"key": "rpWasteLoss", "title": "PL Hao Hụt"},
  {"key": "shiftManagement", "title": "Trưởng Máy"},

  //hide
  {"key": "planningBoxId", "title": "", "visible": false},
];

List<GridColumn> buildStageColumn({required ThemeController themeController}) {
  return [
    for (var item in headerStage)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
