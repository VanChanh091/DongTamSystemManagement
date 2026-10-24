import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDebt = [
  {"key": "index", "title": "STT"},
  {"key": "customerId", "title": "Mã Khách Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "unpaidOutboundCount", "title": "Số Đơn Chưa TT"},
  {"key": "totalDebt", "title": "Tổng Nợ (VNĐ)"},

  // Nợ trong hạn
  {"key": "notDueDebt", "title": "Nợ Trong Hạn"},
  {"key": "currentPeriodDebt", "title": "Nợ Chưa Chốt"},
  {"key": "closedDebt", "title": "Nợ Đã Chốt"},
  {"key": "dueIn1_3", "title": "Sắp Tới Hạn"},

  // Nợ quá hạn
  {"key": "overdue1_30", "title": "1-30 Ngày"},
  {"key": "overdue31_60", "title": "31-60 Ngày"},
  {"key": "overdue61_90", "title": "61-90 Ngày"},
  {"key": "overdue91_120", "title": "91-120 Ngày"},
  {"key": "overdueOver120", "title": "Hơn 120 Ngày"},
  {"key": "dueDebt", "title": "Tổng Quá Hạn"},
];

List<GridColumn> buildDebtColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerDebt)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
