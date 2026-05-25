import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _inventoryColumns = [
  {"key": "index", "title": "STT"},

  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "typeProduct", "title": "Loại Sản Phẩm"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "size", "title": "Khổ (SX)"},
  {"key": "length", "title": "Dài (SX)"},

  {"key": "totalQtyInbound", "title": "Nhập Kho"},
  {"key": "totalQtyOutbound", "title": "Tổng Xuất"},
  {"key": "qtyInventory", "title": "Tồn"},

  {"key": "dvt", "title": "DVT"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "valueInventory", "title": "Giá Trị Tồn"},

  {"key": "fullName", "title": "Nhân Viên"},

  //hidden
  {"key": "inventoryId", "title": "", "visible": false},
];

List<GridColumn> buildInventoryColumn({required ThemeController themeController}) {
  return [
    for (var item in _inventoryColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
