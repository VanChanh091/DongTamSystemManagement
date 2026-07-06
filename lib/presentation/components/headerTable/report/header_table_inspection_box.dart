import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:get/get.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

final List<Map<String, dynamic>> inspectionBoxColumns = [
  // --- THÔNG TIN CHUNG ---
  {"key": "index", "title": "STT"},
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "productName", "title": "Tên Sản Phẩm"},
  {"key": "structure", "title": "Kết Cấu Sản Xuất"},
  {"key": "sizePaper", "title": "Khổ (cm)"},
  {"key": "lengthPaper", "title": "Dài (cm)"},
  {"key": "runningPlan", "title": "Kế Hoạch Chạy"},
  {"key": "qcBox", "title": "Quy Cách"},

  // --- NHÓM CHECKLIST ---
  {"key": "boxDimension", "title": "Quy Cách Thùng", "dataKey": "BOX_DIMENSIONS"},
  {
    "key": "colorCount",
    "title": "Số Màu",
    "dataKey": "COLOR_COUNT",
    "visibleFields": ["Máy In"],
  },
  {
    "key": "colorMatch",
    "title": "Màu Sắc Theo Mẫu",
    "dataKey": "COLOR_MATCH",
    "visibleFields": ["Máy In"],
  },
  {
    "key": "colorRegistration",
    "title": "Chồng Màu",
    "dataKey": "COLOR_REGISTRATION",
    "visibleFields": ["Máy In"],
  },
  {
    "key": "fluteCrushing",
    "title": "Độ Xẹp Sóng",
    "dataKey": "FLUTE_CRUSHING",
    "visibleFields": ["Máy In", "Máy Bế", "Máy Dán", "Máy Cắt Khe"],
  },
  {
    "key": "glueAdhesion",
    "title": "Độ Bám Keo",
    "dataKey": "GLUE_ADESION",
    "visibleFields": ["Máy Dán"],
  },
  {
    "key": "glueViscosity",
    "title": "Độ Nhớt Keo Dán",
    "dataKey": "GLUE_VISCOSITY",
    "visibleFields": ["Máy Dán"],
  },
  {
    "key": "imagePosition",
    "title": "Vị Trí Hình Ảnh",
    "dataKey": "IMAGE_POSITION",
    "visibleFields": ["Máy In", "Máy Bế", "Máy Cắt Khe"],
  },
  {"key": "jointGap", "title": "Độ Hở Nắp", "dataKey": "JOINT_GAP"},
  {
    "key": "jointMisalignment",
    "title": "Độ Lệch Nắp",
    "dataKey": "JOINT_MISALIGNMENT",
    "visibleFields": ["Máy Dán"],
  },
  {
    "key": "paperSurface",
    "title": "Bề Mặt Giấy",
    "dataKey": "PAPER_SURFACE",
    "visibleFields": ["Máy In", "Máy Bế", "Máy Dán", "Máy Cắt Khe"],
  },
  {
    "key": "printContent",
    "title": "Nội Dung In Theo Mẫu",
    "dataKey": "PRINT_CONTENT",
    "visibleFields": ["Máy In"],
  },
  {
    "key": "printSharpness",
    "title": "Độ Sắc Nét",
    "dataKey": "PRINT_SHARPNESS",
    "visibleFields": ["Máy In"],
  },
  {
    "key": "scoringLine",
    "title": "Đường Lằn Cấn",
    "dataKey": "SCORING_LINE",
    "visibleFields": ["Máy In", "Máy Bế", "Máy Cắt Khe"],
  },
  {
    "key": "stitchCount",
    "title": "Số Lượng Ghim",
    "dataKey": "STITCH_COUNT",
    "visibleFields": ["Máy Đóng Ghim"],
  },
  {
    "key": "stitchHolding",
    "title": "Độ Bám Ghim",
    "dataKey": "STITCH_HOLDING",
    "visibleFields": ["Máy Đóng Ghim"],
  },
  {
    "key": "stitchPitch",
    "title": "Khoảng Cách Ghim",
    "dataKey": "STITCH_PITCH",
    "visibleFields": ["Máy Đóng Ghim"],
  },
  {
    "key": "stitchPosition",
    "title": "Vị Trí Ghim",
    "dataKey": "STITCH_POSITION",
    "visibleFields": ["Máy Đóng Ghim"],
  },
  {
    "key": "tabOverlap",
    "title": "Độ Chồng Mí Lưỡi Gà",
    "dataKey": "TAB_OVERLAP",
    "visibleFields": ["Máy Đóng Ghim", "Máy Dán"],
  },
  {
    "key": "trimLineBurr",
    "title": "Đường Dao Tề, Ba Dớ",
    "dataKey": "TRIM_LINE_BURR",
    "visibleFields": ["Máy In", "Máy Bế", "Máy Cắt Khe"],
  },

  {"key": "checkedBy", "title": "Người Kiểm"},

  // --- CÁC CỘT ẨN ---
  {"key": "inspecBoxId", "title": "", "visible": false},
  {"key": "timeInspecDate", "title": "", "visible": false},
];

bool isColumnVisibleForMachine(Map<String, dynamic> column, String machine) {
  if (!column.containsKey("visibleFields")) return true;
  return (column["visibleFields"] as List).contains(machine);
}

List<GridColumn> buildInspectionBoxColumn({
  required ThemeController themeController,
  required String machine,
}) {
  return inspectionBoxColumns
      .where((item) => isColumnVisibleForMachine(item, machine))
      .map(
        (item) => GridColumn(
          columnName: item["key"]!,
          label: Obx(() => formatColumn(label: item["title"]!, themeController: themeController)),
          visible: item["visible"] ?? true,
        ),
      )
      .toList();
}
