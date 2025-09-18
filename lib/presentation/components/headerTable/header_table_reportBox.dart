import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildReportBoxColumn() {
  return [
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'reportBoxId', label: Container(), visible: false),
    GridColumn(
      columnName: 'customerName',
      label: formatColumn("Tên Khách Hàng"),
    ),
    GridColumn(columnName: 'dateShipping', label: formatColumn("Ngày YC Giao")),
    GridColumn(
      columnName: 'dayStartProduction',
      label: formatColumn("Ngày Sản Xuất"),
    ),
    GridColumn(columnName: 'dayReported', label: formatColumn("Ngày Báo Cáo")),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'QC_box', label: formatColumn("QC Thùng")),
    GridColumn(columnName: 'length', label: formatColumn("Dài")),
    GridColumn(columnName: 'size', label: formatColumn("Khổ")),
    GridColumn(columnName: 'child', label: formatColumn("Số Con")),
    GridColumn(columnName: 'quantityOrd', label: formatColumn("SL Đơn Hàng")),
    GridColumn(columnName: 'runningPlans', label: formatColumn("SL Giấy Tấm")),
    GridColumn(
      columnName: 'timeRunnings',
      label: formatColumn("Thời Gian Chạy"),
    ),

    //quantity box
    GridColumn(columnName: 'qtyPrinted', label: formatColumn("In")),
    GridColumn(columnName: 'qtyCanLan', label: formatColumn("Cấn Lằn")),
    GridColumn(columnName: 'qtyCanMang', label: formatColumn("Cán Màng")),
    GridColumn(columnName: 'qtyXa', label: formatColumn("Xả")),
    GridColumn(columnName: 'qtyCatKhe', label: formatColumn("Cắt Khe")),
    GridColumn(columnName: 'qtyBe', label: formatColumn("Bế")),
    GridColumn(columnName: 'qtyDan', label: formatColumn("Dán")),
    GridColumn(columnName: 'qtyDongGhim', label: formatColumn("Đóng Ghim")),

    //box
    GridColumn(columnName: 'inMatTruoc', label: formatColumn("In Mặt Trước")),
    GridColumn(columnName: 'inMatSau', label: formatColumn("In Mặt Sau")),
    GridColumn(columnName: 'dan_1_Manh', label: formatColumn("Dán 1 Mảnh")),
    GridColumn(columnName: 'dan_2_Manh', label: formatColumn("Dán 2 Mảnh")),
    GridColumn(
      columnName: 'dongGhim1Manh',
      label: formatColumn("ĐGhim 1 Mảnh"),
    ),
    GridColumn(
      columnName: 'dongGhim2Manh',
      label: formatColumn("ĐGhim 2 Mảnh"),
    ),

    //waste
    GridColumn(columnName: 'dmWasteLoss', label: formatColumn("Định Mức PL")),
    GridColumn(columnName: 'wasteLossRp', label: formatColumn("PL Báo Cáo")),
    GridColumn(columnName: 'shiftManager', label: formatColumn("Trưởng Máy")),
  ];
}
