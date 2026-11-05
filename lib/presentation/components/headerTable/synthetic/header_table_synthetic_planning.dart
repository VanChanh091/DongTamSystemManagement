import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

const List<Map<String, dynamic>> _headerSyntheticPaper = [
  // Order
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  // Customer & Product
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "isFSC", "title": "Đơn FSC"},

  //structure
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},

  //day
  {"key": "dayReceive", "title": "Nhận Đơn"},
  {"key": "dayStartProduction", "title": "Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Hoàn Thành"},
  {"key": "dayCompletedOvfl", "title": "Hoàn Thành (Tràn)"},

  //other fields
  {"key": "flute", "title": "Sóng"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "QcBox", "title": "QC Thùng"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "child", "title": "Số Con"},
  {"key": "dvt", "title": "DVT"},

  {"key": "size", "title": "Khổ"},
  {"key": "length", "title": "Dài"},

  // Quantity
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "qtyInventory", "title": "Tồn Kho"},

  //time running
  {"key": "timeRunningProd", "title": "Chạy"},
  {"key": "timeRunningOvfl", "title": "Tràn"},

  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  //Waste
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteE2", "title": "Sóng E2"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "fluteA", "title": "Sóng A"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},

  // Sản xuất
  {"key": "qtyWastes", "title": "PL Thực Tế"},
  {"key": "shiftProduct", "title": "Ca Sản Xuất"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "machine", "title": "Loại Máy"},

  {"key": "chongTham", "title": "Chống Thấm"},
  {"key": "isBox", "title": "Làm Thùng?"},

  // Hidden
  {"key": "planningId", "title": "", "visible": false},
];

List<GridColumn> buildSyntheticPaperColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  required String page,
}) => buildGridColumns(
  headerConfig: _headerSyntheticPaper,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
  page: page,
);

List<StackedHeaderRow> buildSyntheticPlanningPaperSHR({
  required ThemeController themeController,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "dayReceive",
            "dateShipping",
            "dayStartProduction",
            "dayCompletedProd",
            "dayCompletedOvfl",
          ],
          label: "Ngày",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["size", "length"],
          label: "Quy Cách (cm)",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: [
            "quantityOrd",
            "qtyProduced",
            "runningPlanProd",
            "totalOutbound",
            "qtyInventory",
          ],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["timeRunningProd", "timeRunningOvfl"],
          label: "Thời Gian",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: [
            "bottom",
            "fluteE",
            "fluteE2",
            "fluteB",
            "fluteC",
            "knife",
            "totalLoss",
          ],
          label: "Định Mức Phế Liệu (Kg)",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}

List<StackedHeaderRow> buildSyntheticPlanningStageSHR({
  required ThemeController themeController,
  double zoom = 1.0,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "dayStart",
            "dayCompleted",
            "dayCompletedOvfl",
          ],
          label: "Ngày",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["timeRunning", "timeRunningOvfl"],
          label: "Thời Gian",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["runningPlan", "qtyProduced"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["wasteBox", "rpWasteLoss"],
          label: "Phế Liệu",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
