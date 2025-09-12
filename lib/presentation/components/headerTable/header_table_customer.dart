import 'package:dongtam/utils/helper/style_table.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildCustomerColumn() {
  return [
    GridColumn(columnName: "stt", label: formatColumn("STT")),
    GridColumn(columnName: "customerId", label: formatColumn("Mã KH")),
    GridColumn(columnName: "maSoThue", label: formatColumn("MST")),
    GridColumn(columnName: "customerName", label: formatColumn("Tên KH")),
    GridColumn(columnName: "phone", label: formatColumn("SDT")),
    GridColumn(
      columnName: "contactPerson",
      label: formatColumn("Người Liên Hệ"),
    ),
    GridColumn(columnName: "dayCreatedCus", label: formatColumn("Ngày Tạo KH")),
    GridColumn(columnName: "companyName", label: formatColumn("Tên Công Ty")),
    GridColumn(
      columnName: "companyAddress",
      label: formatColumn("Địa chỉ công ty"),
    ),
    GridColumn(
      columnName: "shippingAddress",
      label: formatColumn("Địa chỉ Giao Hàng"),
    ),
    GridColumn(columnName: "CSKH", label: formatColumn("CSKH")),
  ];
}
