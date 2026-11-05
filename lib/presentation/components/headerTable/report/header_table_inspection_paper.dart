import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _inspectionPaperColumns = [
  {"key": "index", "title": "STT"},
  {"key": "timeInspection", "title": "Ngày kiểm tra"},
  {"key": "checkedBy", "title": "Người Kiểm"},
  {"key": "result", "title": "Kết Quả"},

  //checking
  {"key": "moisture", "title": "Độ Ẩm (°C)"},
  {"key": "steamPressure", "title": "Áp Suất Hơi (kpa)"},
  {"key": "preheaterTemp", "title": "Nhiệt Độ Đầu Sóng (°C)"},
  {"key": "fctValue", "title": "FCT Nén Ngang (kpa)"},
  {"key": "patValue", "title": "PAT Bám Keo (N/m)"},

  //err
  {"key": "blishter", "title": "Dộp"},
  {"key": "wrongWidth", "title": "Sai Khổ"},
  {"key": "wrongLength", "title": "Sai Chiều Dài"},
  {"key": "wrongScoringSpec", "title": "Sai QC Cấn Lằn"},
  {"key": "poorScoring", "title": "Cấn Lằn Không Đạt"},
  {"key": "drityLiner", "title": "Mặt/lưng giấy không sạch"},
  {"key": "losseLiner", "title": "Mặt/lưng giấy không căng"},
  {"key": "earDefect", "title": "Hở Tai"},
  {"key": "skewedFlute", "title": "Xéo Sóng"},
  {"key": "warppage", "title": "Cong Mo"},
  {"key": "wrongStructure", "title": "Sai Kết Cấu"},
  {"key": "waveHeight", "title": "Độ Cao Sóng"},
  {"key": "poorTrim", "title": "Dao Tề Không Sạch"},
  {"key": "misalignment", "title": "Sàng"},
  {"key": "glueDripping", "title": "Nhiễu Keo"},
  {"key": "trimScrap", "title": "Rác Ba Dớ"},
  {"key": "poorBundling", "title": "Cột Không Đạt"},
  {"key": "totalWidthErr", "title": "Tổng Sai Khổ"},
  {"key": "wrongProductInfo", "title": "TTSP"},

  //info order
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "canLan", "title": "Cấn Lằn"},
  {"key": "sizePaper", "title": "Khổ (cm)"},
  {"key": "lengthPaper", "title": "Dài (cm)"},
  {"key": "runningPlan", "title": "Kế Hoạch Chạy"},
  {"key": "isFSC", "title": "Đơn FSC"},

  {"key": "note", "title": "Ghi Chú"},
  {"key": "imgError", "title": "Ảnh Lỗi"},

  //hidden fields
  {"key": "inspecPaperId", "title": "", "visible": false},
  {"key": "timeInspecDate", "title": "", "visible": false},
];

List<GridColumn> buildInspectionPaperColumn({
  required ThemeController themeController,
  required ValueNotifier<double> zoomNotifier,
}) => buildGridColumns(
  headerConfig: _inspectionPaperColumns,
  themeController: themeController,
  zoomNotifier: zoomNotifier,
);


List<StackedHeaderRow> buildInspectionPaperSHR({
  required ThemeController themeController,
  required double zoom,
}) {
  return [
    StackedHeaderRow(
      cells: [
        buildStackedHeaderCell(
          columnNames: [
            "orderId",
            "customerName",
            "productName",
            "structure",
            "flute",
            "sizePaper",
            "lengthPaper",
            "runningPlan",
            "canLan",
            "isFSC",
          ],
          label: "Thông Tin Đơn Hàng",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: [
            "moisture",
            "steamPressure",
            "preheaterTemp",
            "fctValue",
            "patValue",
          ],
          label: "Thông Tin Kiểm Tra",
          themeController: themeController,
          zoom: zoom,
        ),
        buildStackedHeaderCell(
          columnNames: [
            "blishter",
            "wrongWidth",
            "wrongLength",
            "wrongScoringSpec",
            "poorScoring",
            "drityLiner",
            "losseLiner",
            "earDefect",
            "skewedFlute",
            "warppage",
            "wrongStructure",
            "waveHeight",
            "poorTrim",
            "misalignment",
            "glueDripping",
            "trimScrap",
            "poorBundling",
            "totalWidthErr",
            "wrongProductInfo",
          ],
          label: "Lỗi",
          themeController: themeController,
          zoom: zoom,
        ),
      ],
    ),
  ];
}
