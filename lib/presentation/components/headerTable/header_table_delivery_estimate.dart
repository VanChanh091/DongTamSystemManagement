import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDeliveryEstimate = [
  // Order
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến"},

  // Customer & Product
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên SP"},

  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},

  // Quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "qtyInventory", "title": "Tồn Kho"},

  {"key": "dvt", "title": "DVT"},
  {"key": "volume", "title": "Khối Lượng"},

  //structure
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  // Staff
  {"key": "staffOrder", "title": "Nhân Viên"},

  // Hidden
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildDeliveryEstimateColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerDeliveryEstimate)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
