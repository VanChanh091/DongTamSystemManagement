import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildMachineColumns() {
  return [
    //planning
    // GridColumn(columnName: 'planningId', label: formatColumn('Mã Kế Hoạch')),
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'customerName', label: formatColumn("Tên KH")),
    GridColumn(columnName: 'dateShipping', label: formatColumn("Ngày YC Giao")),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'QC_box', label: formatColumn("Quy cách")),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
    GridColumn(columnName: 'daoXa', label: formatColumn("Dao Xả")),
    GridColumn(columnName: 'length', label: formatColumn("Dài")),
    GridColumn(columnName: 'size', label: formatColumn("Khổ")),
    GridColumn(columnName: 'quantity', label: formatColumn("Số Lượng")),
    GridColumn(
      columnName: 'runningPlanProd',
      label: formatColumn("Kế Hoạch Chạy"),
    ),
    GridColumn(
      columnName: 'timeRunningProd',
      label: formatColumn("Thời Gian Chạy"),
    ),

    //paper consumption norm
    GridColumn(columnName: 'dmPheLieu', label: formatColumn("ĐM Phế Liệu")),
    GridColumn(columnName: 'plDauC', label: formatColumn("PL Đầu C")),
    GridColumn(columnName: 'plDauB', label: formatColumn("PL Đầu B")),
    GridColumn(columnName: 'plDauE', label: formatColumn("PL Đầu E")),
    GridColumn(columnName: 'plDay', label: formatColumn("PL Đáy")),
    GridColumn(columnName: 'plDao', label: formatColumn("PL Dao")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh thu")),
  ];
}
