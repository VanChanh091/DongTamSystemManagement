import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _headerSyntheticPlanningBox = [
  {"key": "qtyPrinted", "title": "In"},
  {"key": "qtyCanLan", "title": "Cấn Lằn"},
  {"key": "qtyCanMang", "title": "Cán Màng"},
  {"key": "qtyXa", "title": "Xả"},
  {"key": "qtyCatKhe", "title": "Cắt Khe"},
  {"key": "qtyBe", "title": "Bế"},
  {"key": "qtyDan", "title": "Dán"},
  {"key": "qtyDongGhim", "title": "Đóng Ghim"},

  // hidden
  {"key": "planningBoxId", "title": "", "visible": false},
];

List<GridColumn> buildSyntheticBoxesColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerSyntheticPlanningBox)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
