import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildOrderColumns() {
  final userController = Get.find<UserController>();

  return [
    //order
    GridColumn(columnName: 'orderId', label: formatColumn('Mã Đơn Hàng')),
    GridColumn(columnName: 'dayReceiveOrder', label: formatColumn('Ngày Nhận')),
    GridColumn(
      columnName: 'dateRequestShipping',
      label: formatColumn("Ngày YC Giao"),
    ),
    GridColumn(
      columnName: 'customerName',
      label: formatColumn("Tên Khách Hàng"),
    ),
    GridColumn(columnName: 'companyName', label: formatColumn("Tên Công Ty")),
    GridColumn(columnName: 'typeProduct', label: formatColumn("Loại SP")),
    GridColumn(columnName: 'productName', label: formatColumn("Tên SP")),
    GridColumn(columnName: 'flute', label: formatColumn("Sóng")),
    GridColumn(columnName: 'QC_box', label: formatColumn("QC Thùng")),
    GridColumn(
      columnName: 'structure',
      label: formatColumn("Kết Cấu Đặt Hàng"),
    ),
    GridColumn(columnName: 'canLan', label: formatColumn("Cấn Lằn")),
    GridColumn(columnName: 'daoXaOrd', label: formatColumn("Dao Xả")),
    GridColumn(columnName: 'lengthCus', label: formatColumn("Dài (KH)")),
    GridColumn(columnName: 'lengthMf', label: formatColumn("Dài (SX)")),
    GridColumn(columnName: 'sizeCustomer', label: formatColumn("Khổ (KH)")),
    GridColumn(columnName: 'sizeManufacture', label: formatColumn("Khổ (SX)")),
    GridColumn(
      columnName: 'quantityCustomer',
      label: formatColumn("Số Lượng (KH)"),
    ),
    GridColumn(
      columnName: 'qtyManufacture',
      label: formatColumn("Số Lượng (SX)"),
    ),
    GridColumn(columnName: 'child', label: formatColumn("Số con")),
    GridColumn(columnName: 'dvt', label: formatColumn("DVT")),
    GridColumn(columnName: 'acreage', label: formatColumn("Diện Tích")),
    GridColumn(columnName: 'price', label: formatColumn("Đơn Giá")),
    GridColumn(columnName: 'pricePaper', label: formatColumn("Giá Tấm")),
    GridColumn(columnName: 'discounts', label: formatColumn("Chiết Khấu")),
    GridColumn(columnName: 'profitOrd', label: formatColumn("Lợi Nhuận")),
    GridColumn(columnName: 'vat', label: formatColumn("VAT")),
    GridColumn(columnName: 'HD_special', label: formatColumn("HD Đặc Biệt")),
    GridColumn(columnName: 'totalPrice', label: formatColumn("Doanh số")),

    //Box
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
    ...userController.hasAnyRole(['admin', 'manager'])
        ? [
          GridColumn(
            columnName: 'staffOrder',
            label: formatColumn("Nhân Viên"),
          ),
        ]
        : [],

    GridColumn(columnName: 'status', label: formatColumn("Trạng thái")),
    GridColumn(columnName: 'rejectReason', label: formatColumn("Lý do")),
  ];
}
