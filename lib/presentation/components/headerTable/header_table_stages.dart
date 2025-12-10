import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
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
  {"key": "wasteBox", "title": "PL Thực Tế"},
  {"key": "rpWasteLoss", "title": "PL Hao Hụt"},
  {"key": "shiftManagement", "title": "Trưởng Máy"},

  //hide
  {"key": "planningBoxId", "title": "", "visible": false},
];

List<GridColumn> buildStageColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerStage)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
