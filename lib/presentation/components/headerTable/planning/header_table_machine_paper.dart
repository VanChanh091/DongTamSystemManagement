import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/utils/helper/style_table.dart";
import 'package:flutter/material.dart';
import "package:syncfusion_flutter_datagrid/datagrid.dart";

final List<Map<String, dynamic>> _machinePaperColumns = [
  // planning
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  {
    "key": "dateShipping",
    "title": "Ngày Dự Kiến",
    "visiblePages": ["planning"],
  },

  {"key": "customerName", "title": "Tên Khách Hàng"},

  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "isFSC", "title": "Đơn FSC"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},
  {"key": "flute", "title": "Sóng"},

  {"key": "size", "title": "Khổ (cm)"},
  {"key": "length", "title": "Dài (cm)"},

  {
    "key": "note",
    "title": "Ghi Chú",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "qcBox",
    "title": "QC Thùng",
    "visiblePages": ["planning", "production"],
  },

  {"key": "canLan", "title": "Cấn Lằn"},
  {"key": "daoXa", "title": "Dao Xả"},
  {"key": "child", "title": "Số Con"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},
  {"key": "chongTham", "title": "Chống Thấm"},
  {"key": "haveMadeBox", "title": "Làm Thùng?"},

  {
    "key": "quantityOrd",
    "title": "Đơn Hàng",
    "visiblePages": ["planning"],
  },
  {"key": "qtyProduced", "title": "Đã Sản Xuất"},
  {
    "key": "runningPlanProd",
    "title": "Kế Hoạch Chạy",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "inboundQty",
    "title": "Đã Nhập Kho",
    "visiblePages": ["checking"],
  },
  {"key": "dvt", "title": "DVT"},

  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},

  {
    "key": "totalPrice",
    "title": "Tổng Tiền (VNĐ)",
    "visiblePages": ["planning"],
  },

  //waste
  {
    "key": "bottom",
    "title": "Đáy",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "fluteE",
    "title": "Sóng E",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "fluteE2",
    "title": "Sóng E2",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "fluteB",
    "title": "Sóng B",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "fluteC",
    "title": "Sóng C",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "fluteA",
    "title": "Sóng A",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "knife",
    "title": "Dao",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "totalLoss",
    "title": "Tổng PL",
    "visiblePages": ["planning", "production"],
  },
  {
    "key": "qtyWastes",
    "title": "PL Thực Tế",
    "visiblePages": ["planning", "production"],
  },

  {"key": "shiftProduct", "title": "Ca SX"},
  {
    "key": "shiftManager",
    "title": "Trưởng Máy",
    "visiblePages": ["planning"],
  },

  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {
    "key": "dayCompletedProd",
    "title": "Ngày Hoàn Thành",
    "visiblePages": ["planning"],
  },

  //statusRequest
  {"key": "statusRequest", "title": "Kiểm Hàng"},
  {
    "key": "action",
    "title": "Kiểm Lỗi",
    "visiblePages": ["production"],
  },

  // hidden technical fields
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
  {"key": "planningId", "title": "", "visible": false},
  {"key": "statusCheck", "title": "", "visible": false},
];

List<GridColumn> buildMachinePaperColumns({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  required String page,
}) => buildGridColumns(
  headerConfig: _machinePaperColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
  page: page,
);

List<StackedHeaderRow> buildInspectPaperSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["qtyProduced", "runningPlanProd"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["bottom", "fluteE", "fluteE2", "fluteB", "fluteC", "fluteA", "knife", "totalLoss"],
          label: "Định Mức Phế Liệu",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}

List<StackedHeaderRow> buildWaitingCheckPaperSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["qtyProduced", "inboundQty"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["bottom", "fluteE", "fluteE2", "fluteB", "fluteC", "knife", "totalLoss"],
          label: "Định Mức Phế Liệu",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}

List<StackedHeaderRow> buildProductionQueuePaperSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "runningPlanProd", "qtyProduced"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["bottom", "fluteE", "fluteE2", "fluteB", "fluteC", "fluteA", "knife", "totalLoss"],
          label: "Định Mức Phế Liệu (Kg)",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}

List<StackedHeaderRow> buildPlanningStopSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "runningPlanProd", "qtyProduced"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["bottom", "fluteE", "fluteE2", "fluteB", "fluteC", "knife", "totalLoss"],
          label: "Định Mức Phế Liệu",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: [
            "inMatTruoc",
            "inMatSau",
            "canLanBox",
            "canMang",
            "xa",
            "catKhe",
            "be",
            "dan_1_Manh",
            "dan_2_Manh",
            "dongGhimMotManh",
            "dongGhimHaiManh",
            "chongTham",
            "dongGoi",
            "maKhuon",
          ],
          label: "Công Đoạn Thùng",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
