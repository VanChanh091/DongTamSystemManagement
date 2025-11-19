import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> headerDbPaper = [
  // planning
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  //customer
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "companyName", "title": "Tên Công Ty"},

  //product
  {"key": "typeProduct", "title": "Loại SP"},
  {"key": "productName", "title": "Tên SP"},

  //planning
  {"key": "dayReceive", "title": "Nhận Đơn"},
  {"key": "dateShipping", "title": "Dự Kiến"},
  {"key": "dayStartProduction", "title": "Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Hoàn Thành"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},

  //quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},

  {"key": "instructSpecial", "title": "HD Đặc Biệt"},
  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},

  //order
  {"key": "dvt", "title": "DVT"},
  {"key": "acreage", "title": "Diện Tích"},
  {"key": "price", "title": "Đơn Giá"},
  {"key": "pricePaper", "title": "Giá Tấm"},
  {"key": "discounts", "title": "Chiết Khấu"},
  {"key": "profitOrd", "title": "Lợi Nhuận"},
  {"key": "vat", "title": "VAT"},
  {"key": "totalPrice", "title": "Tổng Tiền"},
  {"key": "totalPriceAfterVAT", "title": "Tổng Tiền Sau VAT"},

  //Phe lieu
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteE2", "title": "Sóng E2"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},

  //san xuat
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},

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

  //user
  {"key": "staffOrder", "title": "Nhân Viên"},

  //have box
  {"key": "haveMadeBox", "title": "Làm Thùng?"},

  // hidden technical fields
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
