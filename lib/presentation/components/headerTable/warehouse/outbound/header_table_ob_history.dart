import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerOutboundHistory = [
  {"key": "dateOutbound", "title": "Ngày Xuất Kho"},
  {"key": "outboundSlipCode", "title": "Mã Số PXK"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "totalOutboundQty", "title": "Số Lượng Xuất"},
  {"key": "dueDate", "title": "Ngày Đến Hạn"},

  //money
  {"key": "totalPriceOrder", "title": "Hàng"},
  {"key": "totalPriceVAT", "title": "Thuế"},
  {"key": "totalPricePayment", "title": "Cần Thanh Toán"},
  {"key": "paidAmount", "title": "Đã Thanh Toán"},
  {"key": "remainingAmount", "title": "Còn Lại"},

  {"key": "status", "title": "Trạng Thái"},

  //hidden
  {"key": "outboundId", "title": "", "visible": false},
];

List<GridColumn> buildOutboundHistoryColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerOutboundHistory)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
