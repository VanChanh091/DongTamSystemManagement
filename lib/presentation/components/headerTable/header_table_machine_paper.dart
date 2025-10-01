import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> machinePaperColumns = [
  // planning
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "planningId", "title": "", "visible": false},
  {"key": "customerName", "title": "Tên KH"},
  {"key": "dateShipping", "title": "Ngày YC Giao"},
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Ngày Hoàn Thành"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "quantityOrd", "title": "SL Đơn Hàng"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "qtyProduced", "title": "SL Sản Xuất"},
  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},
  {"key": "HD_special", "title": "HD Đặc Biệt"},
  {"key": "totalPrice", "title": "Doanh thu"},
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},

  // box (render nếu isShowPlanningPaper == true)
  {
    "key": "inMatTruoc",
    "title": "In Mặt Trước",
    "showIf": "isShowPlanningPaper",
  },
  {"key": "inMatSau", "title": "In Mặt Sau", "showIf": "isShowPlanningPaper"},
  {"key": "chongTham", "title": "Chống Thấm", "showIf": "isShowPlanningPaper"},
  {"key": "canLanBox", "title": "Cấn Lằn", "showIf": "isShowPlanningPaper"},
  {"key": "canMang", "title": "Cán Màng", "showIf": "isShowPlanningPaper"},
  {"key": "xa", "title": "Xả", "showIf": "isShowPlanningPaper"},
  {"key": "catKhe", "title": "Cắt Khe", "showIf": "isShowPlanningPaper"},
  {"key": "be", "title": "Bế", "showIf": "isShowPlanningPaper"},
  {"key": "maKhuon", "title": "Mã Khuôn", "showIf": "isShowPlanningPaper"},
  {"key": "dan_1_Manh", "title": "Dán 1 Mảnh", "showIf": "isShowPlanningPaper"},
  {"key": "dan_2_Manh", "title": "Dán 2 Mảnh", "showIf": "isShowPlanningPaper"},
  {
    "key": "dongGhimMotManh",
    "title": "Đóng Ghim 1 Mảnh",
    "showIf": "isShowPlanningPaper",
  },
  {
    "key": "dongGhimHaiManh",
    "title": "Đóng Ghim 2 Mảnh",
    "showIf": "isShowPlanningPaper",
  },
  {"key": "dongGoi", "title": "Đóng Gói", "showIf": "isShowPlanningPaper"},

  // box extra (render nếu hasBox == true)
  {"key": "hasMadeBox", "title": "Làm Thùng?", "showIf": "hasBox"},

  // hidden technical fields
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
];

List<GridColumn> buildMachineColumns({
  required ThemeController themeController,
  bool isShowPlanningPaper = false,
  bool hasBox = false,
}) {
  return [
    for (var item in machinePaperColumns)
      if (!item.containsKey("showIf") ||
          (item["showIf"] == "isShowPlanningPaper" && isShowPlanningPaper) ||
          (item["showIf"] == "hasBox" && hasBox))
        GridColumn(
          columnName: item["key"]!,
          label: Obx(
            () => formatColumn(
              label: item["title"]!,
              themeController: themeController,
            ),
          ),
          visible: item.containsKey("visible") ? item["visible"] as bool : true,
        ),
  ];
}
