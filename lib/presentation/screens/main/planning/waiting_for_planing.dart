import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_planning_order.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_planning.dart';
import 'package:dongtam/presentation/sources/planning_dataSource.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingForPlanning extends StatefulWidget {
  const WaitingForPlanning({super.key});

  @override
  WaitingForPlanningState createState() => WaitingForPlanningState();
}

class WaitingForPlanningState extends State<WaitingForPlanning> {
  late Future<List<Order>> futureOrdersAccept;
  late PlanningDataSource planningDataSource;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');
  String? selectedOrderId;

  @override
  void initState() {
    super.initState();

    if (userController.hasPermission('plan')) {
      loadOrders(true);
    } else {
      futureOrdersAccept = Future.error("NO_PERMISSION");
    }

    columns = buildColumnPlanning();
  }

  void loadOrders(bool refresh) {
    setState(() {
      futureOrdersAccept = ensureMinLoading(
        PlanningService().getOrderAccept(refresh),
      );
      selectedOrderId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlan = userController.hasPermission("plan");

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
              child:
                  isPlan
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(),

                          //button
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                //planning
                                AnimatedButton(
                                  onPressed:
                                      selectedOrderId == null
                                          ? null
                                          : () async {
                                            try {
                                              final order =
                                                  await futureOrdersAccept;
                                              final selectedOrder = order
                                                  .firstWhere(
                                                    (order) =>
                                                        order.orderId ==
                                                        selectedOrderId,
                                                  );

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (_) => PLanningDialog(
                                                      order: selectedOrder,
                                                      onPlanningOrder:
                                                          () =>
                                                              loadOrders(true),
                                                    ),
                                              );
                                            } catch (e) {
                                              print(
                                                "Không tìm thấy đơn hàng: $e",
                                              );
                                            }
                                          },
                                  label: "Lên kế hoạch",
                                  icon: Icons.add,
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      )
                      : SizedBox.shrink(),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureOrdersAccept,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        height: 400,
                        child: buildShimmerSkeletonTable(
                          context: context,
                          rowCount: 10,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    if (snapshot.error.toString().contains("NO_PERMISSION")) {
                      return Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.redAccent,
                              size: 35,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Bạn không có quyền xem chức năng này",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }

                  final List<Order> data = snapshot.data!;

                  planningDataSource = PlanningDataSource(
                    orders: data,
                    selectedOrderId: selectedOrderId,
                  );

                  return SfDataGrid(
                    source: planningDataSource,
                    columns: columns,
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
      floatingActionButton:
          isPlan
              ? FloatingActionButton(
                onPressed: () => loadOrders(true),
                backgroundColor: Color(0xff78D761),
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
    );
  }
}
