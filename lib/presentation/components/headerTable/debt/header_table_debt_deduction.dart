import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDebtDeduction = [
  {"key": "index", "title": "STT"},
  {"key": "customerName", "title": "Tên Khách Hàng"},

  {"key": "createdAt", "title": "Ngày Tạo"},
  {"key": "amountRequested", "title": "Số Tiền Yêu Cầu"},
  {"key": "currentDebt", "title": "Công Nợ Hiện Tại"},
  {"key": "paymentMethod", "title": "Kiểu Thanh Toán"},
  {"key": "requestedBy", "title": "Người Yêu Cầu"},
  {"key": "isUrgent", "title": "Khẩn Cấp?"},
  {"key": "status", "title": "Trạng Thái"},

  //hidden field
  {"key": "requestId", "title": "", "visible": false},
];

List<GridColumn> buildDebtDeductionColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerDebtDeduction)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
