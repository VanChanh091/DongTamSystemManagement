import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _machineBoxColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},

  {
    "key": "dateShipping",
    "title": "Ngày Dự Kiến",
    "visiblePages": ["planning"],
  },

  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "isFSC", "title": "Đơn FSC"},
  {"key": "QC_box", "title": "QC Thùng"},

  {"key": "size", "title": "Khổ (cm)"},
  {"key": "length", "title": "Dài (cm)"},

  {"key": "canLan", "title": "Cấn Lằn"},
  {"key": "instructSpecial", "title": "HD Đặc Biệt"},

  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "needProd", "title": "Cần SX"},

  {"key": "timeRunning", "title": "Thời Gian Chạy"},

  //quantity
  {"key": "qtyPrinted", "title": "In"},
  {"key": "qtyCanLan", "title": "Cấn Lằn"},
  {"key": "qtyCanMang", "title": "Cán Màng"},
  {"key": "qtyXa", "title": "Xả"},
  {"key": "qtyCatKhe", "title": "Cắt Khe"},
  {"key": "qtyBe", "title": "Bế"},
  {"key": "qtyDan", "title": "Dán"},
  {"key": "qtyDongGhim", "title": "Đóng Ghim"},

  //checked
  {"key": "inMatTruoc", "title": "Mặt Trước"},
  {"key": "inMatSau", "title": "Mặt Sau"},
  {"key": "dan_1_Manh", "title": "1 Mảnh"},
  {"key": "dan_2_Manh", "title": "2 Mảnh"},
  {"key": "dongGhim1Manh", "title": "1 Mảnh"},
  {"key": "dongGhim2Manh", "title": "2 Mảnh"},

  //waste
  {"key": "dmWasteLoss", "title": "Định Mức PL"},
  {"key": "wasteActually", "title": "PL Báo Cáo"},
  {"key": "shiftManager", "title": "Trưởng Máy"},

  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Ngày Hoàn Thành"},
  {
    "key": "totalPrice",
    "title": "Tổng Tiền (VNĐ)",
    "visiblePages": ["planning"],
  },

  //isRequestCheck
  {"key": "statusRequest", "title": "Kiểm Hàng"},
  {
    "key": "action",
    "title": "Kiểm Lỗi",
    "visiblePages": ["production"],
  },

  // hidden technical fields
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
  {"key": "planningBoxId", "title": "", "visible": false},
  {"key": "statusCheck", "title": "", "visible": false},
];

List<GridColumn> buildMachineBoxColumns({
  required String machine,
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
  required String page,
}) => buildGridColumns(
  headerConfig: _machineBoxColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
  page: page,
);

List<StackedHeaderRow> buildInspectBoxSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "qtyPrinted",
            "qtyCanLan",
            "qtyCanMang",
            "qtyXa",
            "qtyCatKhe",
            "qtyBe",
            "qtyDan",
            "qtyDongGhim",
          ],
          label: "Số Lượng Của Các Công Đoạn",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "qtyPaper", "needProd"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["inMatTruoc", "inMatSau"],
          label: "In Ấn",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["dan_1_Manh", "dan_2_Manh"],
          label: "Dán",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["dongGhim1Manh", "dongGhim2Manh"],
          label: "Đóng Ghim",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}


List<StackedHeaderRow> buildMachineBoxSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "qtyPrinted",
            "qtyCanLan",
            "qtyCanMang",
            "qtyXa",
            "qtyCatKhe",
            "qtyBe",
            "qtyDan",
            "qtyDongGhim",
          ],
          label: "Số Lượng Của Các Công Đoạn",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["quantityOrd", "qtyPaper", "needProd"],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["inMatTruoc", "inMatSau"],
          label: "In Ấn",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["dan_1_Manh", "dan_2_Manh"],
          label: "Dán",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: ["dongGhim1Manh", "dongGhim2Manh"],
          label: "Đóng Ghim",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
