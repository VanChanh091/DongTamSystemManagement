import 'package:dongtam/data/models/order/order_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class OrderDataSource extends DataGridSource {
  final formatter = DateFormat('dd/MM/yyyy');
  List<Order> orders;

  bool selectedAll = false;
  String? selectedOrderId;

  OrderDataSource({required this.orders, this.selectedOrderId}) {
    orders = orders;
    buildDataCell();
  }

  late List<DataGridRow> orderDataGridRows;

  void buildDataCell() {
    orders.sort((a, b) => a.orderId.compareTo(b.orderId));
    orderDataGridRows =
        orders.map<DataGridRow>((order) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'orderId', value: order.orderId),
              DataGridCell<String>(
                columnName: 'dayReceiveOrder',
                value: formatter.format(order.dayReceiveOrder),
              ),
              DataGridCell<String>(
                columnName: 'customerName',
                value: order.customer?.customerName,
              ),
              DataGridCell<String>(
                columnName: 'companyName',
                value: order.customer?.companyName,
              ),
              DataGridCell<String>(columnName: 'song', value: order.song),
              DataGridCell<String>(
                columnName: 'typeProduct',
                value: order.typeProduct,
              ),
              DataGridCell<String>(
                columnName: 'productName',
                value: order.productName,
              ),
              DataGridCell<String>(columnName: 'QC_box', value: order.QC_box),
              DataGridCell<String>(
                columnName: 'structure',
                value: order.formatterStructureOrder,
              ),
              DataGridCell<String>(
                columnName: 'structureReplace',
                value: order.infoProduction?.formatterStructureInfo,
              ),
              DataGridCell<double>(
                columnName: 'lengthPaper',
                value: order.lengthPaper,
              ),
              DataGridCell<double>(
                columnName: 'paperSize',
                value: order.paperSize,
              ),
              DataGridCell<int>(columnName: 'quantity', value: order.quantity),
              DataGridCell<double>(
                columnName: 'acreage',
                value: Order.acreagePaper(
                  order.lengthPaper,
                  order.paperSize,
                  order.quantity,
                ),
              ),
              DataGridCell<String>(columnName: 'dvt', value: order.dvt),
              DataGridCell<double>(columnName: 'price', value: order.price),
              DataGridCell<double>(
                columnName: 'pricePaper',
                value: order.pricePaper,
              ),
              DataGridCell<String>(
                columnName: 'dateRequestShipping',
                value: formatter.format(order.dateRequestShipping),
              ),

              //InfoProduction
              DataGridCell<double>(
                columnName: 'paperSizeInfo',
                value: order.infoProduction?.sizePaper,
              ),
              DataGridCell<int>(
                columnName: 'quantityInfo',
                value: order.infoProduction?.quantity,
              ),
              DataGridCell<String>(
                columnName: 'HD_special',
                value: order.infoProduction?.instructSpecial,
              ),
              DataGridCell<int>(
                columnName: 'numChild',
                value: order.infoProduction?.numberChild,
              ),
              DataGridCell<String>(
                columnName: 'teBien',
                value: order.infoProduction?.teBien,
              ),
              DataGridCell<String>(
                columnName: 'CD_Sau',
                value: order.infoProduction?.nextStep,
              ),
              DataGridCell<String>(
                columnName: 'totalPrice',
                value: Order.totalPricePaper(
                  order.dvt,
                  order.price,
                  order.lengthPaper,
                  order.paperSize,
                ),
              ),

              //Box
              DataGridCell<int>(
                columnName: 'inMatTruoc',
                value: order.box?.inMatTruoc,
              ),
              DataGridCell<int>(
                columnName: 'inMatSau',
                value: order.box?.inMatSau,
              ),
              DataGridCell<bool>(
                columnName: 'canMang',
                value: order.box?.canMang,
              ),
              DataGridCell<bool>(columnName: 'xa', value: order.box?.xa),
              DataGridCell<bool>(
                columnName: 'catKhe',
                value: order.box?.catKhe,
              ),
              DataGridCell<bool>(columnName: 'be', value: order.box?.be),
              DataGridCell<bool>(
                columnName: 'dan_1_Manh',
                value: order.box?.dan_1_Manh,
              ),
              DataGridCell<bool>(
                columnName: 'dan_2_Manh',
                value: order.box?.dan_2_Manh,
              ),
              DataGridCell<bool>(
                columnName: 'dongGhim',
                value: order.box?.dongGhim,
              ),
              DataGridCell<String>(
                columnName: 'khac_1',
                value: order.box?.khac_1,
              ),
              DataGridCell<String>(
                columnName: 'khac_2',
                value: order.box?.khac_2,
              ),
              DataGridCell<String>(columnName: '#', value: order.box?.khac_2),
            ],
          );
        }).toList();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  void removeItemById(String orderId) {
    orders.removeWhere((order) => order.orderId == orderId);
  }

  void removeAll() {
    orders.clear();
    buildDataCell();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();

    return DataGridRowAdapter(
      color:
          selectedOrderId == orderId
              ? Colors.blue.withOpacity(0.3)
              : Colors.transparent,
      cells:
          row.getCells().map<Widget>((dataCell) {
            return Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                '${dataCell.value}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            );
          }).toList(),
    );
  }
}
