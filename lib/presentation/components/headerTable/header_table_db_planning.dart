import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> headerDbPaper = [
  // Order
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  // Customer
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},

  // Product
  {"key": "typeProduct", "title": "Loại SP"},
  {"key": "productName", "title": "Tên SP"},

  //day
  {"key": "dayReceive", "title": "Nhận Đơn"},
  {"key": "dateShipping", "title": "Dự Kiến"},
  {"key": "dayStartProduction", "title": "Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Hoàn Thành"},
  {"key": "dayCompletedOvfl", "title": "Hoàn Thành (Tràn)"},

  //other fields
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},

  // Quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},

  //time running
  {"key": "timeRunningProd", "title": "Chạy"},
  {"key": "timeRunningOvfl", "title": "Tràn"},

  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  // Order money
  {"key": "dvt", "title": "DVT"},
  {"key": "acreage", "title": "Diện Tích"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "pricePaper", "title": "Giá Tấm"},
  {"key": "discounts", "title": "Chiết Khấu"},
  {"key": "profitOrd", "title": "Lợi Nhuận"},
  {"key": "vat", "title": "VAT"},
  {"key": "totalPrice", "title": "Tổng Tiền"},
  {"key": "totalPriceAfterVAT", "title": "Tổng Tiền Sau VAT"},

  //Waste
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteE2", "title": "Sóng E2"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},

  // Sản xuất
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "machine", "title": "Loại Máy"},

  // Staff
  {"key": "staffOrder", "title": "Nhân Viên"},

  // Hidden
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildDbPaperColumn({required ThemeController themeController}) {
  return [
    for (var item in headerDbPaper)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
