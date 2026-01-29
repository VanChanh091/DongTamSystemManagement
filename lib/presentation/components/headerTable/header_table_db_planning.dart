import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerDbPaper = [
  // Order
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  // Customer
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},

  // Product
  {"key": "typeProduct", "title": "Loại SP"},
  {"key": "productName", "title": "Tên SP"},

  //structure
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},

  //day
  {"key": "dayReceive", "title": "Nhận Đơn"},
  {"key": "dateShipping", "title": "Dự Kiến"},
  {"key": "dayStartProduction", "title": "Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Hoàn Thành"},
  {"key": "dayCompletedOvfl", "title": "Hoàn Thành (Tràn)"},

  //other fields
  {"key": "flute", "title": "Sóng"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "volume", "title": "Thể Tích"},
  {"key": "child", "title": "Số Con"},

  // Quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "totalOutbound", "title": "Đã Xuất Kho"},

  //time running
  {"key": "timeRunningProd", "title": "Chạy"},
  {"key": "timeRunningOvfl", "title": "Tràn"},

  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  // Order money
  {"key": "dvt", "title": "DVT"},
  {
    "key": "acreage",
    "title": "Diện Tích",
    "visiblePages": ["dashboard"],
  },
  {"key": "price", "title": "Đơn Giá"},
  {
    "key": "pricePaper",
    "title": "Giá Tấm",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "discounts",
    "title": "Chiết Khấu",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "profitOrd",
    "title": "Lợi Nhuận",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "vat",
    "title": "VAT",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "totalPrice",
    "title": "Tổng Tiền",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "totalPriceAfterVAT",
    "title": "Tổng Tiền VAT",
    "visiblePages": ["dashboard"],
  },

  //Waste
  {
    "key": "bottom",
    "title": "Đáy",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "fluteE",
    "title": "Sóng E",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "fluteE2",
    "title": "Sóng E2",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "fluteB",
    "title": "Sóng B",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "fluteC",
    "title": "Sóng C",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "knife",
    "title": "Dao",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "totalLoss",
    "title": "Tổng PL",
    "visiblePages": ["dashboard"],
  },

  // Sản xuất
  {
    "key": "qtyWastes",
    "title": "PL Thực Tế",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "shiftProduct",
    "title": "Ca Sản Xuất",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "shiftManager",
    "title": "Trưởng Máy",
    "visiblePages": ["dashboard"],
  },
  {
    "key": "machine",
    "title": "Loại Máy",
    "visiblePages": ["dashboard"],
  },

  // Staff
  {"key": "staffOrder", "title": "Nhân Viên"},

  // Hidden
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildDbPaperColumn({
  required ThemeController themeController,
  required String page,
}) {
  return [
    for (var item in _headerDbPaper)
      if (!item.containsKey("visiblePages") || (item["visiblePages"] as List).contains(page))
        GridColumn(
          columnName: item["key"]!,
          label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
          visible: item.containsKey("visible") ? item["visible"]! as bool : true,
        ),
  ];
}
