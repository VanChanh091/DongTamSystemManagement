import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PlanningDatasource extends DataGridSource {
  final formatter = DateFormat('dd/MM/yyyy');
  List<Order> orders;
  bool selectedAll = false;
  String? selectedOrderId;

  PlanningDatasource({required this.orders, this.selectedOrderId}) {
    buildPlanningCells();
  }

  late List<DataGridRow> planningDataGridRows;

  List<DataGridCell> buildPlanningCells(Order order) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(
        columnName: 'dateRequestShipping',
        value: formatter.format(order.dateRequestShipping),
      ),
      DataGridCell<String>(
        columnName: 'companyName',
        value: order.customer?.companyName ?? '',
      ),
      DataGridCell<String>(columnName: 'flute', value: order.QC_box ?? ''),
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(
        columnName: 'instructSpecial',
        value: planning.instructSpecial,
      ),
      DataGridCell<String>(columnName: 'daoXa', value: planning.daoXa),
      DataGridCell<String>(
        columnName: 'structurePaper',
        value: planning.structurePaper,
      ),
      DataGridCell<String>(
        columnName: 'lengthPaper',
        value: planning.lengthPaper,
      ),
      DataGridCell<String>(columnName: 'sizePaper', value: planning.sizePaper),
      DataGridCell<int>(columnName: 'qtyOrder', value: planning.qtyOrder),
      DataGridCell<int>(
        columnName: 'qtyHasProduced',
        value: planning.qtyHasProduced,
      ),
      DataGridCell<int>(
        columnName: 'qtyNeedProduced',
        value: planning.qtyNeedProduced,
      ),
      DataGridCell<String>(
        columnName: 'dateRequestShipping',
        value: formatter.format(planning.dateRequestShipping),
      ),
      DataGridCell<double>(
        columnName: 'totalPrice',
        value: planning.totalPrice,
      ),
    ];
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    throw UnimplementedError();
  }
}
