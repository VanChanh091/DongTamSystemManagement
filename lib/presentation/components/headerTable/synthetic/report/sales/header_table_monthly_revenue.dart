import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerMonthlyRevenue = [
  {"key": "index", "title": "STT"},
  {"key": "date", "title": "Ngày"},
  {"key": "orderApprovedAmount", "title": "DS Nhận Đơn"},
  {"key": "productionAmount", "title": "DS Sản Xuất"},
  {"key": "salesAmount", "title": "DS Bán Hàng"},
  {"key": "returnAmount", "title": "DS Trả Về"},
];

List<GridColumn> buildMonthlyRevenueColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerMonthlyRevenue)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
