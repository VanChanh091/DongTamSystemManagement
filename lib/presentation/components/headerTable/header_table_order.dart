import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> orderColumns = [
  // Order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "dayReceive", "title": "Ngày Nhận"},
  {"key": "dateShipping", "title": "Ngày Giao"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},
  {"key": "typeProduct", "title": "Loại SP"},
  {"key": "productName", "title": "Tên SP"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "canLan", "title": "Cấn Lằn"},
  {"key": "daoXaOrd", "title": "Dao Xả"},
  {"key": "lengthCus", "title": "Dài (KH)"},
  {"key": "lengthMf", "title": "Dài (SX)"},
  {"key": "sizeCustomer", "title": "Khổ (KH)"},
  {"key": "sizeManufacture", "title": "Khổ (SX)"},
  {"key": "quantityCustomer", "title": "Số Lượng (KH)"},
  {"key": "qtyManufacture", "title": "Số Lượng (SX)"},
  {"key": "child", "title": "Số con"},
  {"key": "dvt", "title": "Đơn Vị Tính"},
  {"key": "acreage", "title": "Diện Tích"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "pricePaper", "title": "Giá Tấm"},
  {"key": "discounts", "title": "Chiết Khấu"},
  {"key": "profitOrd", "title": "Lợi Nhuận"},
  {"key": "vat", "title": "VAT"},
  {"key": "HD_special", "title": "HD Đặc Biệt"},
  {"key": "totalPrice", "title": "Tổng Tiền"},
  {"key": "totalPriceAfterVAT", "title": "Tổng Tiền Sau VAT"},

  // Box
  {"key": "inMatTruoc", "title": "In Mặt Trước"},
  {"key": "inMatSau", "title": "In Mặt Sau"},
  {"key": "chongTham", "title": "Chống Thấm"},
  {"key": "canLanBox", "title": "Cấn Lằn"},
  {"key": "canMang", "title": "Cán Màng"},
  {"key": "xa", "title": "Xả"},
  {"key": "catKhe", "title": "Cắt Khe"},
  {"key": "be", "title": "Bế"},
  {"key": "maKhuon", "title": "Mã Khuôn"},
  {"key": "dan_1_Manh", "title": "Dán 1 Mảnh"},
  {"key": "dan_2_Manh", "title": "Dán 2 Mảnh"},
  {"key": "dongGhimMotManh", "title": "Đóng Ghim 1 Mảnh"},
  {"key": "dongGhimHaiManh", "title": "Đóng Ghim 2 Mảnh"},
  {"key": "dongGoi", "title": "Đóng Gói"},

  // Role-based
  {
    "key": "staffOrder",
    "title": "Nhân Viên",
    "showIfRole": ["admin", "manager"],
  },

  // Status
  {"key": "status", "title": "Trạng thái"},
  {"key": "rejectReason", "title": "Lý do"},
];

List<GridColumn> buildOrderColumns({
  required ThemeController themeController,
  required UserController userController,
}) {
  return [
    for (var item in orderColumns)
      if (!item.containsKey("showIfRole") ||
          userController.hasAnyRole(item["showIfRole"] as List<String>))
        GridColumn(
          columnName: item["key"]!,
          label: Obx(
            () => formatColumn(
              label: item["title"]!,
              themeController: themeController,
            ),
          ),
        ),
  ];
}
