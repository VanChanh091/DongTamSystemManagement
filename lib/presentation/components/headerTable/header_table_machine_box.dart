import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final List<Map<String, dynamic>> machineBoxColumns = [
  {"key": "orderId", "title": "Mã Đơn Hàng"},
  {"key": "planningBoxId", "title": "", "visible": false},
  {"key": "customerName", "title": "Tên Khách Hàng"},
  {"key": "dateShipping", "title": "Ngày YC Giao"},
  {"key": "dayStartProduction", "title": "Ngày Sản Xuất"},
  {"key": "dayCompletedProd", "title": "Ngày Hoàn Thành"},
  {"key": "structure", "title": "Kết Cấu Đặt Hàng"},
  {"key": "flute", "title": "Sóng"},
  {"key": "QC_box", "title": "QC Thùng"},
  {"key": "length", "title": "Dài"},
  {"key": "size", "title": "Khổ"},
  {"key": "child", "title": "Số Con"},
  {"key": "quantityOrd", "title": "SL Đơn Hàng"},
  {"key": "runningPlans", "title": "SL Giấy Tấm"},
  {"key": "timeRunnings", "title": "Thời Gian Chạy"},
  {"key": "qtyPrinted", "title": "In"},
  {"key": "qtyCanLan", "title": "Cấn Lằn"},
  {"key": "qtyCanMang", "title": "Cán Màng"},
  {"key": "qtyXa", "title": "Xả"},
  {"key": "qtyCatKhe", "title": "Cắt Khe"},
  {"key": "qtyBe", "title": "Bế"},
  {"key": "qtyDan", "title": "Dán"},
  {"key": "qtyDongGhim", "title": "Đóng Ghim"},
  {"key": "inMatTruoc", "title": "In Mặt Trước"},
  {"key": "inMatSau", "title": "In Mặt Sau"},
  {"key": "dan_1_Manh", "title": "Dán 1 Mảnh"},
  {"key": "dan_2_Manh", "title": "Dán 2 Mảnh"},
  {"key": "dongGhim1Manh", "title": "ĐGhim 1 Mảnh"},
  {"key": "dongGhim2Manh", "title": "ĐGhim 2 Mảnh"},
  {"key": "dmWasteLoss", "title": "Định Mức PL"},
  {"key": "wasteActually", "title": "PL Thực Tế"},
  {"key": "shiftManager", "title": "Trưởng Máy"},
  {"key": "status", "title": "", "visible": false},
  {"key": "index", "title": "Index", "visible": false},
  // {"key": "wasteCanMang", "title": "Phế Liệu"},
  // {"key": "wasteNormXa", "title": "Phế Liệu"},
  // {"key": "wasteCatKhe", "title": "Phế Liệu"},
  // {"key": "wasteNormBe", "title": "Phế Liệu"},
  // {"key": "wasteDan", "title": "Phế Liệu"},
  // {"key": "wasteDGhim", "title": "Phế Liệu"},
];

List<GridColumn> buildMachineBoxColumns({
  required String machine,
  required ThemeController themeController,
}) {
  return [
    for (var item in machineBoxColumns)
      GridColumn(
        columnName: item['key']!,
        label: Obx(
          () => formatColumn(
            label: item['title']!,
            themeController: themeController,
          ),
        ),
        visible: item.containsKey("visible") ? item["visible"]! as bool : true,
      ),
  ];
}
