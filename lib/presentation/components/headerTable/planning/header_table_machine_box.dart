import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> _machineBoxColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày Dự Kiến"},
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Ngày Hoàn Thành"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "quantityOrd", "title": "Đơn Hàng"},
  {"key": "qtyPaper", "title": "Giấy Tấm"},
  {"key": "needProd", "title": "Cần SX"},
  {"key": "timeRunnings", "title": "Thời Gian Chạy"},

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

  //isRequestCheck
  {"key": "statusRequest", "title": "Kiểm Hàng"},

  // hidden technical fields
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
  {"key": "planningBoxId", "title": "", "visible": false},
];

List<GridColumn> buildMachineBoxColumns({
  required String machine,
  required ThemeController themeController,
}) {
  return [
    for (var item in _machineBoxColumns)
      GridColumn(
        columnName: item['key']!,
        label: Obx(() => formatColumn(label: item['title']!, themeController: themeController)),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
