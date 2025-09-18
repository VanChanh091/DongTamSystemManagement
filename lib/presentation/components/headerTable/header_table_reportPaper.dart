import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildReportPaperColumn() {
  return [
    GridColumn(columnName: "orderId", label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: "reportPaperId", label: Container(), visible: false),
    GridColumn(
      columnName: "customerName",
      label: formatColumn('Tên Khách Hàng'),
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
    GridColumn(columnName: 'daoXa', label: formatColumn("Dao Xả")),
    GridColumn(columnName: 'length', label: formatColumn("Dài")),
    GridColumn(columnName: 'size', label: formatColumn("Khổ")),
    GridColumn(columnName: 'child', label: formatColumn("Số Con")),
    GridColumn(columnName: 'khoCapGiay', label: formatColumn("Khổ Cấp Giấy")),
    GridColumn(columnName: 'quantityOrd', label: formatColumn("SL Đơn Hàng")),
    GridColumn(
      columnName: 'runningPlanProd',
      label: formatColumn("Kế Hoạch Chạy"),
    ),
    GridColumn(
      columnName: 'qtyProduced',
      label: formatColumn("SL Đã Sản Xuất"),
    ),
    GridColumn(columnName: 'qtyReported', label: formatColumn("SL Báo Cáo")),
    GridColumn(
      columnName: 'timeRunningProd',
      label: formatColumn("Thời Gian Chạy"),
    ),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh thu")),

    //waste norm
    GridColumn(columnName: 'bottom', label: formatColumn("Đáy")),
    GridColumn(columnName: 'fluteE', label: formatColumn("Sóng E")),
    GridColumn(columnName: 'fluteB', label: formatColumn("Sóng B")),
    GridColumn(columnName: 'fluteC', label: formatColumn("Sóng C")),
    GridColumn(columnName: 'knife', label: formatColumn("Dao")),
    GridColumn(columnName: 'totalLoss', label: formatColumn("Tổng PL")),
    GridColumn(columnName: 'qtyWasteRp', label: formatColumn("PL Báo Cáo")),
    GridColumn(columnName: 'shiftProduct', label: formatColumn("Ca Sản Xuất")),
    GridColumn(columnName: 'shiftManager', label: formatColumn("Trưởng Máy")),

    //box
    GridColumn(columnName: 'hasMadeBox', label: formatColumn("Làm Thùng?")),
  ];
}
