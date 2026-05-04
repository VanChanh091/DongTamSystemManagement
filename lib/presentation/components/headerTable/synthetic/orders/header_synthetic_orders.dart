import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _headerSyntheticOrder = [
  // Order
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "dayReceive", "title": "Ngày Nhận Đơn"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},

  {"key": "sizeCust", "title": "Khổ TT"},
  {"key": "lengthCust", "title": "Dài TT"},
  {"key": "sizeManu", "title": "Khổ (SX)"},
  {"key": "lengthManu", "title": "Dài (SX)"},

  {"key": "quantityCustomer", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Giấy Tấm"},
  {"key": "qtyOutbound", "title": "Xuất Kho"},
  {"key": "qtyInventory", "title": "Tồn Kho"},
  {"key": "qtyWasteNorm", "title": "Phế Liệu"},

  {"key": "unit", "title": "DVT"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  {"key": "staffOrder", "title": "Nhân Viên"},
  {"key": "isBox", "title": "Làm Thùng?"},

  // Status
  {"key": "status", "title": "Trạng thái"},
];

List<GridColumn> buildSyntheticOrderColumn({required ThemeController themeController}) {
  return [
    for (var item in _headerSyntheticOrder)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
