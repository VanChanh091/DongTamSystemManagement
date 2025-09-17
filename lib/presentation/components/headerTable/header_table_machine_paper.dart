import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildMachineColumns({
  bool isShowPlanningPaper = false,
  bool hasBox = false,
}) {
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
      columnName: 'dayCompletedProd',
      label: formatColumn("Ngày Hoàn Thành"),
    ),
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
    GridColumn(columnName: 'qtyProduced', label: formatColumn("SL Sản Xuất")),
    GridColumn(
      columnName: 'timeRunningProd',
      label: formatColumn("Thời Gian Chạy"),
    ),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh thu")),
    GridColumn(columnName: 'bottom', label: formatColumn("Đáy")),
    GridColumn(columnName: 'fluteE', label: formatColumn("Sóng E")),
    GridColumn(columnName: 'fluteB', label: formatColumn("Sóng B")),
    GridColumn(columnName: 'fluteC', label: formatColumn("Sóng C")),
    GridColumn(columnName: 'knife', label: formatColumn("Dao")),
    GridColumn(columnName: 'totalLoss', label: formatColumn("Tổng PL")),
    GridColumn(columnName: 'qtyWastes', label: formatColumn("PL Thực Tế")),
    GridColumn(columnName: 'shiftProduct', label: formatColumn("Ca Sản Xuất")),
    GridColumn(columnName: 'shiftManager', label: formatColumn("Trưởng Máy")),

    //box
    if (isShowPlanningPaper == true) ...[
      GridColumn(columnName: 'inMatTruoc', label: formatColumn("In Mặt Trước")),
      GridColumn(columnName: 'inMatSau', label: formatColumn("In Mặt Sau")),
      GridColumn(columnName: 'chongTham', label: formatColumn("Chống Thấm")),
      GridColumn(columnName: 'canLanBox', label: formatColumn("Cấn Lằn")),
      GridColumn(columnName: 'canMang', label: formatColumn("Cán Màng")),
      GridColumn(columnName: 'xa', label: formatColumn("Xả")),
      GridColumn(columnName: 'catKhe', label: formatColumn("Cắt Khe")),
      GridColumn(columnName: 'be', label: formatColumn("Bế")),
      GridColumn(columnName: 'maKhuon', label: formatColumn("Mã Khuôn")),
      GridColumn(columnName: 'dan_1_Manh', label: formatColumn("Dán 1 Mảnh")),
      GridColumn(columnName: 'dan_2_Manh', label: formatColumn("Dán 2 Mảnh")),
      GridColumn(
        columnName: 'dongGhimMotManh',
        label: formatColumn("Đóng Ghim 1 Mảnh"),
      ),
      GridColumn(
        columnName: 'dongGhimHaiManh',
        label: formatColumn("Đóng Ghim 2 Mảnh"),
      ),
      GridColumn(columnName: 'dongGoi', label: formatColumn("Đóng Gói")),
    ],

    if (hasBox == true) ...[
      GridColumn(columnName: 'hasMadeBox', label: formatColumn("Làm Thùng?")),
    ],

    GridColumn(columnName: 'status', label: SizedBox(), visible: false),
    GridColumn(
      columnName: 'index',
      label: formatColumn("Index"),
      visible: false,
    ),
  ];
}
