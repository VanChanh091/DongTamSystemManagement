import 'package:dongtam/utils/helper/style_table.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildUserColumns() {
  return [
    GridColumn(columnName: 'fullName', label: formatColumn('Họ Tên')),
    GridColumn(columnName: 'email', label: formatColumn('Email')),
    GridColumn(columnName: 'sex', label: formatColumn('Giới Tính')),
    GridColumn(columnName: 'phone', label: formatColumn('Số Điện Thoại')),
    GridColumn(columnName: 'role', label: formatColumn('Vai Trò')),
    GridColumn(columnName: 'permission', label: formatColumn('Quyền Truy Cập')),
    GridColumn(columnName: 'avatar', label: formatColumn('Hình Đại Diện')),
  ];
}
