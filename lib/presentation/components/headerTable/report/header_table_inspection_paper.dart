import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _inspectionPaperColumns = [
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},

  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "sizePaper", "title": "Khổ (cm)"},
  {"key": "lengthPaper", "title": "Dài (cm)"},
  {"key": "runningPlan", "title": "Kế Hoạch Chạy"},

  {"key": "timeInspection", "title": "Ngày kiểm tra"},
  {"key": "numberPallet", "title": "Số Pallet"},
  {"key": "machineSpeed", "title": "Tốc Độ Máy (m/p)"},
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

  {"key": "checkedBy", "title": "Người Kiểm"},

  //hidden fields
  {"key": "inspecPaperId", "title": "", "visible": false},
  {"key": "timeInspecDate", "title": "", "visible": false},
];

List<GridColumn> buildInspectionPaperColumn({required ThemeController themeController}) {
  return [
    for (var item in _inspectionPaperColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
