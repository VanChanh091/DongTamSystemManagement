import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _reportInboundColumns = [
  {"key": "dateInbound", "title": "Ngày Nhập"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "qtyInbound", "title": "Nhập Kho"},

  //hidden
  {"key": "inboundId", "title": "", "visible": false},
];

List<GridColumn> buildReportInboundColumn({required ThemeController themeController}) {
  return [
    for (var item in _reportInboundColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
