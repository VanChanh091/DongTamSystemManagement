import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildColumnPlanning() {
  return [
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'customerName', label: formatColumn("Tên Công Ty")),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'qc_box', label: formatColumn("Quy cách")),
    GridColumn(
      columnName: 'instructSpecial',
      label: formatColumn("Hướng dẫn đặc biệt"),
    ),
    GridColumn(columnName: 'daoXa', label: formatColumn("Dao xả")),
    GridColumn(
      columnName: 'structurePaper',
      label: formatColumn("Kết cấu đặt hàng"),
    ),
    GridColumn(columnName: 'lengthPaper', label: formatColumn("Dài")),
    GridColumn(columnName: 'sizePaper', label: formatColumn("Khổ")),
    GridColumn(columnName: 'qtyOrder', label: formatColumn("SL đặt hàng")),
    GridColumn(
      columnName: 'qtyHasProduced',
      label: formatColumn("SL đã sản xuất"),
    ),
    GridColumn(
      columnName: 'qtyNeedProduced',
      label: formatColumn("SL cần sản xuất"),
    ),
    GridColumn(
      columnName: 'dateRequestShipping',
      label: formatColumn("Ngày yêu cầu giao"),
    ),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh số")),
  ];
}
