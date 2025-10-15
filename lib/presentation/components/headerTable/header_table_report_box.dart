import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> reportBoxColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "reportBoxId", "title": "", "visible": false},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày YC Giao"},
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayReported", "title": "Ngày Báo Cáo"},
  {"key": "dateTimeRp", "title": "", "visible": false},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "timeRunnings", "title": "Thời Gian Chạy"},

  // quantity box
  {"key": "qtyPrinted", "title": "In"},
  {"key": "qtyCanLan", "title": "Cấn Lằn"},
  {"key": "qtyCanMang", "title": "Cán Màng"},
  {"key": "qtyXa", "title": "Xả"},
  {"key": "qtyCatKhe", "title": "Cắt Khe"},
  {"key": "qtyBe", "title": "Bế"},
  {"key": "qtyDan", "title": "Dán"},
  {"key": "qtyDongGhim", "title": "Đóng Ghim"},
  {"key": "lackOfQty", "title": "Thiếu/Đủ SL"},

  // box
  {"key": "inMatTruoc", "title": "In Mặt Trước"},
  {"key": "inMatSau", "title": "In Mặt Sau"},
  {"key": "dan_1_Manh", "title": "Dán 1 Mảnh"},
  {"key": "dan_2_Manh", "title": "Dán 2 Mảnh"},
  {"key": "dongGhim1Manh", "title": "ĐGhim 1 Mảnh"},
  {"key": "dongGhim2Manh", "title": "ĐGhim 2 Mảnh"},

  // waste
  {"key": "dmWasteLoss", "title": "Định Mức PL"},
  {"key": "wasteLossRp", "title": "PL Báo Cáo"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
];

List<GridColumn> buildReportBoxColumn({
  required ThemeController themeController,
}) {
  return [
    for (var item in reportBoxColumns)
      GridColumn(
        columnName: item["key"]!,
        label: Obx(
          () => formatColumn(
            label: item["title"]!,
            themeController: themeController,
          ),
        ),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
