import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_planning_order.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_planning.dart';
import 'package:dongtam/presentation/sources/planning/planning_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
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
  final themeController = Get.find<ThemeController>();
  final userController = Get.find<UserController>();
  final badgesController = Get.find<BadgesController>();
  final formatter = DateFormat('dd/MM/yyyy');

  Map<String, double> columnWidths = {};
  String? selectedOrderId;

  @override
  void initState() {
    super.initState();

    if (userController.hasPermission(permission: 'plan')) {
      loadOrders();
    } else {
      futureOrdersAccept = Future.error("NO_PERMISSION");
    }

    columns = buildColumnPlanning(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'waitingPlanning', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadOrders() {
    setState(() {
      futureOrdersAccept = ensureMinLoading(PlanningService().getOrderAccept());
      selectedOrderId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlan = userController.hasPermission(permission: "plan");

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "ĐƠN HÀNG CHỜ LÊN KẾ HOẠCH",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  //button
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child:
                        isPlan
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),

                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  child: Row(
                                    children: [
                                      //planning order
                                      AnimatedButton(
                                        onPressed:
                                            selectedOrderId == null
                                                ? null
                                                : () async {
                                                  try {
                                                    final order = await futureOrdersAccept;
                                                    final selectedOrder = order.firstWhere(
                                                      (order) => order.orderId == selectedOrderId,
                                                    );

                                                    if (!context.mounted) {
                                                      return;
                                                    }

                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (_) => PLanningDialog(
                                                            order: selectedOrder,
                                                            onPlanningOrder: () => loadOrders(),
                                                          ),
                                                    );
                                                  } catch (e, s) {
                                                    AppLogger.e(
                                                      "Lỗi không tìm thấy đơn hàng",
                                                      error: e,
                                                      stackTrace: s,
                                                    );
                                                  }
                                                },
                                        label: "Lên kế hoạch",
                                        icon: Icons.add,
                                        backgroundColor: themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        height: 400,
                        child: buildShimmerSkeletonTable(context: context, rowCount: 10),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    if (snapshot.error.toString().contains("NO_PERMISSION")) {
                      return const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, color: Colors.redAccent, size: 35),
                            SizedBox(width: 8),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.auto,
                    selectionMode: SelectionMode.single,
                    headerRowHeight: 35,
                    rowHeight: 40,
                    columns: ColumnWidthTable.applySavedWidths(
                      columns: columns,
                      widths: columnWidths,
                    ),
                    stackedHeaderRows: <StackedHeaderRow>[
                      StackedHeaderRow(
                        cells: [
                          StackedHeaderCell(
                            columnNames: ["qtyManufacture", "runningPlan", "quantityProduced"],
                            child: Obx(
                              () =>
                                  formatColumn(label: 'Số Lượng', themeController: themeController),
                            ),
                          ),
                        ],
                      ),
                    ],

                    //auto resize
                    allowColumnsResizing: true,
                    columnResizeMode: ColumnResizeMode.onResize,

                    onColumnResizeStart: GridResizeHelper.onResizeStart,
                    onColumnResizeUpdate:
                        (details) => GridResizeHelper.onResizeUpdate(
                          details: details,
                          columns: columns,
                          setState: setState,
                        ),
                    onColumnResizeEnd:
                        (details) => GridResizeHelper.onResizeEnd(
                          details: details,
                          tableKey: 'waitingPlanning',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isNotEmpty) {
                        final selectedRow = addedRows.first;
                        final orderId = selectedRow.getCells()[0].value.toString();

                        final selectedOrder = data.firstWhere((order) => order.orderId == orderId);

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
                onPressed: () => loadOrders(),
                backgroundColor: themeController.buttonColor.value,
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
    );
  }
}
