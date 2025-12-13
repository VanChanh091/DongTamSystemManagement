import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerOutboundHistory = [
  {"key": "dateOutbound", "title": "Ngày Xuất Kho"},
  {"key": "outboundSlipCode", "title": "Mã Số PXK"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "totalPriceOrder", "title": "Tiền Hàng"},
  {"key": "totalPriceVAT", "title": "Tiền Thuế"},
  {"key": "totalPricePayment", "title": "Tiền Phải Trả"},
  {"key": "totalOutboundQty", "title": "Số Lượng Xuất"},

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
