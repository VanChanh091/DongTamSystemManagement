import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDebt = [
  {"key": "index", "title": "STT"},
  {"key": "customerId", "title": "Mã Khách Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "unpaidOutboundCount", "title": "Số Đơn Chưa TT"},
  {"key": "dueIn1_3", "title": "Sắp Tới Hạn (≤ 3 Ngày)"},

  // Tóm tắt công nợ
  {"key": "totalDebt", "title": "Tổng Nợ"},
  {"key": "closedDebt", "title": "Đã Chốt"},
  {"key": "currentPeriodDebt", "title": "Chưa Chốt"},
  {"key": "notDueDebt", "title": "Trong Hạn"},
  {"key": "dueDebt", "title": "Đến Hạn"},

  // Chi tiết tuổi nợ (Aging)
  {"key": "overdue1_30", "title": "1-30 Ngày"},
  {"key": "overdue31_60", "title": "31-60 Ngày"},
  {"key": "overdue61_90", "title": "61-90 Ngày"},
  {"key": "overdueOver90", "title": "Hơn 90 Ngày"},
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
