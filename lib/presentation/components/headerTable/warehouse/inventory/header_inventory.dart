import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _inventoryColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "customerName", "title": "Khách Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},
  {"key": "qtyCustomer", "title": "Số Lượng"},
  {"key": "dvt", "title": "DVT"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "vat", "title": "VAT"},
  {"key": "totalPrice", "title": "Tổng Tiền"},
  {"key": "totalPriceVAT", "title": "Tổng Tiền VAT"},
  {"key": "totalQtyInbound", "title": "Tổng Nhập"},
  {"key": "totalQtyOutbound", "title": "Tổng Xuất"},
  {"key": "qtyInventory", "title": "Số Lượng Tồn"},
  {"key": "valueInventory", "title": "Giá Trị Tồn"},

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
