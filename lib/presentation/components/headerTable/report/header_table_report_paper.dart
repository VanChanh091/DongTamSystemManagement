import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _reportPaperColumns = [
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},

  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayReported", "title": "Ngày Báo Cáo"},

  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "isFSC", "title": "Đơn FSC"},
  {"key": "daoXa", "title": "Dao Xả"},

  {"key": "size", "title": "Khổ (cm)"},
  {"key": "length", "title": "Dài (cm)"},
  {"key": "numberChild", "title": "Số Con"},
  {"key": "khoCapGiay", "title": "Khổ Cấp Giấy"},

  {"key": "runningPlanProd", "title": "Kế Hoạch Chạy"},
  {"key": "qtyReported", "title": "SL Báo Cáo"},
  {"key": "lackOfQty", "title": "Thiếu/Đủ SL"},

  {"key": "timeRunningProd", "title": "Thời Gian Chạy"},
  {"key": "averageSpeed", "title": "Hiệu Suất (m/p)"},
  {"key": "dvt", "title": "DVT"},

  {"key": "HD_special", "title": "HD Đặc Biệt"},
  {"key": "totalPrice", "title": "Tổng Tiền"},

  //waste norm
  {"key": "bottom", "title": "Đáy"},
  {"key": "fluteE", "title": "Sóng E"},
  {"key": "fluteB", "title": "Sóng B"},
  {"key": "fluteC", "title": "Sóng C"},
  {"key": "fluteA", "title": "Sóng A"},
  {"key": "knife", "title": "Dao"},
  {"key": "totalLoss", "title": "Tổng PL"},
  {"key": "qtyWasteRp", "title": "PL Báo Cáo"},

  {"key": "shiftProduction", "title": "Ca SX"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "reportedBy", "title": "Người Báo Cáo"},

  // box
  {"key": "hasMadeBox", "title": "Làm Thùng?"},

  //hidden fields
  {"key": "reportPaperId", "title": "", "visible": false},
  {"key": "dateTimeRp", "title": "", "visible": false},
];

List<GridColumn> buildReportPaperColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _reportPaperColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);


List<StackedHeaderRow> buildReportPaperSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "quantityOrd",
            "runningPlanProd",
            "qtyReported",
            "lackOfQty",
          ],
          label: "Số Lượng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: [
            "bottom",
            "fluteE",
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
