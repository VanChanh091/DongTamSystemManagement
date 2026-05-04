import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _headerOrder = [
  // Order
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên SP"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "sizeCustomer", "title": "Khổ (KH)"},
  {"key": "lengthCus", "title": "Dài (KH)"},
  {"key": "canLan", "title": "Cấn Lằn"},
  {"key": "daoXaOrd", "title": "Dao Xả"},
  {"key": "quantityCustomer", "title": "Số Lượng (KH)"},
  {"key": "vat", "title": "VAT"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  // Role-based
  {
    "key": "staffOrder",
    "title": "Nhân Viên",
    "showIfRole": ["admin", "manager"],
  },

  // Status
  {"key": "status", "title": "Trạng thái"},
  {"key": "rejectReason", "title": "Lý do"},
  {"key": "orderImage", "title": "Hình ảnh"},
];

List<GridColumn> buildOrderColumns({
  required ThemeController themeController,
  required UserController userController,
}) {
  return [
    for (var item in _headerOrder)
      if (!item.containsKey("showIfRole") ||
          userController.hasAnyRole(roles: item["showIfRole"] as List<String>))
        GridColumn(
          columnName: item["key"]!,
          label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        ),
  ];
}
