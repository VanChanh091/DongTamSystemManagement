import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_planning_order.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_planning.dart';
import 'package:dongtam/presentation/sources/planning_dataSource.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingForPlanning extends StatefulWidget {
  const WaitingForPlanning({super.key});

  @override
  WaitingForPlanningState createState() => WaitingForPlanningState();
}

class WaitingForPlanningState extends State<WaitingForPlanning> {
  late Future<List<Order>> futureOrdersAccept;
  String? selectedOrderId;
  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    loadOrders(false);
  }

  void loadOrders(bool refresh) {
    setState(() {
      futureOrdersAccept = PlanningService().getOrderAccept(refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 70,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),

                  //button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        //planning
                        ElevatedButton.icon(
                          onPressed:
                              selectedOrderId == null
                                  ? null
                                  : () async {
                                    try {
                                      final order = await futureOrdersAccept;
                                      final selectedOrder = order.firstWhere(
                                        (order) =>
                                            order.orderId == selectedOrderId,
                                      );

                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => PLanningDialog(
                                              order: selectedOrder,
                                              onPlanningOrder:
                                                  () => loadOrders(true),
                                            ),
                                      );
                                    } catch (e) {
                                      print("Không tìm thấy đơn hàng: $e");
                                    }
                                  },
                          label: Text(
                            "Lên kế hoạch",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: Icon(Icons.add, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff78D761),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureOrdersAccept,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có đơn hàng nào"));
                  }

                  final List<Order> data = snapshot.data!;

                  final planningDataSource = PlanningDataSource(
                    orders: data,
                    selectedOrderId: selectedOrderId,
                  );

                  return SfDataGrid(
                    source: planningDataSource,
                    columns: buildColumnPlanning(),
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.auto,
                    selectionMode: SelectionMode.single,
                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isNotEmpty) {
                        final selectedRow = addedRows.first;
                        final orderId =
                            selectedRow.getCells()[0].value.toString();

                        final selectedOrder = data.firstWhere(
                          (order) => order.orderId == orderId,
                        );

                        setState(() {
                          selectedOrderId = selectedOrder.orderId;
                        });
                      } else {
                        setState(() {
                          selectedOrderId = null;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadOrders(true),
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
