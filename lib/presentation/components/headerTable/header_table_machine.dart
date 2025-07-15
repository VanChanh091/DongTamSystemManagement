import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildMachineColumns() {
  return [
    //planning
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'planningId', label: Container(), visible: false),
    GridColumn(columnName: 'customerName', label: formatColumn("Tên KH")),
    GridColumn(columnName: 'dateShipping', label: formatColumn("Ngày YC Giao")),
    GridColumn(
      columnName: 'dayStartProduction',
      label: formatColumn("Ngày Sản Xuất"),
    ),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'QC_box', label: formatColumn("Quy cách")),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
    GridColumn(columnName: 'daoXa', label: formatColumn("Dao Xả")),
    GridColumn(columnName: 'length', label: formatColumn("Dài")),
    GridColumn(columnName: 'size', label: formatColumn("Khổ")),
    GridColumn(columnName: 'khoCapGiay', label: formatColumn("Khổ Cấp Giấy")),
    GridColumn(columnName: 'quantity', label: formatColumn("Số Lượng")),
    GridColumn(
      columnName: 'runningPlanProd',
      label: formatColumn("Kế Hoạch Chạy"),
    ),
    GridColumn(
      columnName: 'timeRunningProd',
      label: formatColumn("Thời Gian Chạy"),
    ),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh thu")),
    GridColumn(columnName: 'bottom', label: formatColumn("Đáy")),
    GridColumn(columnName: 'fluteE', label: formatColumn("Sóng E")),
    GridColumn(columnName: 'fluteB', label: formatColumn("Sóng B")),
    GridColumn(columnName: 'fluteC', label: formatColumn("Sóng C")),
    GridColumn(columnName: 'knife', label: formatColumn("Dao")),
    GridColumn(
      columnName: 'totalWasteLoss',
      label: formatColumn("Tổng Hao Phí"),
    ),
    GridColumn(columnName: 'index', label: formatColumn("Index")),
  ];
}
