import 'package:dongtam/utils/helper/style_table.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildReportColumn() {
  return [
    GridColumn(columnName: "orderId", label: formatColumn('Mã Đơn Hàng')),
    GridColumn(
      columnName: "customerName",
      label: formatColumn('Tên Khách Hàng'),
    ),
    GridColumn(
      columnName: "structure",
      label: formatColumn('Kết Cấu Đơn Hàng'),
    ),
    GridColumn(columnName: "flute", label: formatColumn('Sóng')),
    GridColumn(columnName: "qc_box", label: formatColumn('Quy cách')),
    GridColumn(
      columnName: "dateToShipping",
      label: formatColumn('Ngày Giao Hàng'),
    ),
    GridColumn(
      columnName: "dayCompletedOrd",
      label: formatColumn('Ngày hoàn thành'),
    ),
    GridColumn(
      columnName: "instructSpecial",
      label: formatColumn('HD Đặc Biệt'),
    ),
    GridColumn(columnName: "daoXa", label: formatColumn('Dao Xả')),
    GridColumn(columnName: "length", label: formatColumn('Dài')),
    GridColumn(columnName: "size", label: formatColumn('Khổ')),
    GridColumn(
      columnName: "runningForPlan",
      label: formatColumn('Kế Hoạch Chạy'),
    ),
    GridColumn(columnName: "qtyActually", label: formatColumn('SL Thực Tế')),
    GridColumn(columnName: "totalPrice", label: formatColumn('Doanh Thu')),

    GridColumn(
      columnName: "totalLossWaste",
      label: formatColumn('Tổng Phế Liệu'),
    ),
    GridColumn(columnName: "wasteActually", label: formatColumn('PL Thực Tế')),
    GridColumn(columnName: "shiftManager", label: formatColumn('Quản Ca')),
    GridColumn(
      columnName: "shiftProduction",
      label: formatColumn('Ca Sản Xuất'),
    ),
    GridColumn(columnName: "note", label: formatColumn('Ghi Chú')),
  ];
}
