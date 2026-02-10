import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_data_source.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderRejectAndPending extends StatefulWidget {
  const OrderRejectAndPending({super.key});

  @override
  State<OrderRejectAndPending> createState() => _OrderRejectAndPendingState();
}

class _OrderRejectAndPendingState extends State<OrderRejectAndPending> {
  late Future<List<Order>> futureOrdersPending;
  late OrderDataSource orderDataSource;
  late List<GridColumn> columns;
  final formatter = DateFormat('dd/MM/yyyy');
  final userController = Get.find<UserController>();
  final badgesController = Get.find<BadgesController>();
  final themeController = Get.find<ThemeController>();
  final DataGridController _dataGridController = DataGridController();
  Map<String, double> columnWidths = {};
  String? selectedOrderId;
  bool isSeenOrder = false;

  @override
  void initState() {
    super.initState();
    loadOrders(ownOnly: isSeenOrder);

    columns = buildOrderColumns(themeController: themeController, userController: userController);

    ColumnWidthTable.loadWidths(tableKey: 'order', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadOrders({required bool ownOnly}) {
    setState(() {
      futureOrdersPending = ensureMinLoading(
        OrderService().getOrderPendingAndReject(ownOnly: ownOnly),
      );
    });

    selectedOrderId = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager = userController.hasAnyRole(roles: ['manager', 'admin']);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Obx(
                        () => Text(
                          "ĐƠN HÀNG CHỜ DUYỆT/BỊ TỪ CHỐI",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),

                  //button menu
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //see all/see only
                              isManager
                                  ? SizedBox(
                                    width: 150,
                                    child: AnimatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isSeenOrder = !isSeenOrder;
                                        });

                                        loadOrders(ownOnly: isSeenOrder);
                                      },
                                      label: isSeenOrder ? "Xem Tất Cả" : "Đơn Bản Thân",
                                      icon: null,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                              const SizedBox(width: 10),

                              //add
                              AnimatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => OrderDialog(
                                          order: null,
                                          onOrderAddOrUpdate: (String newOrderId) {
                                            loadOrders(ownOnly: isSeenOrder);
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              Future.delayed(const Duration(milliseconds: 300), () {
                                                _scrollToOrder(newOrderId);
                                              });
                                            });
                                          },
                                        ),
                                  );
                                },
                                label: "Thêm mới",
                                icon: Icons.add,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 10),

                              //update
                              AnimatedButton(
                                onPressed:
                                    selectedOrderId == null
                                        ? null
                                        : () async {
                                          try {
                                            final orders = await futureOrdersPending;
                                            final selectedOrder = orders.firstWhere(
                                              (order) => order.orderId == selectedOrderId,
                                            );

                                            if (!context.mounted) return;

                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => OrderDialog(
                                                    order: selectedOrder,
                                                    onOrderAddOrUpdate:
                                                        (String? newOrderId) =>
                                                            loadOrders(ownOnly: isSeenOrder),
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
                                label: "Sửa",
                                icon: Symbols.construction,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 10),

                              //delete
                              AnimatedButton(
                                onPressed:
                                    selectedOrderId != null && selectedOrderId!.isNotEmpty
                                        ? () async {
                                          await showDeleteConfirmHelper(
                                            context: context,
                                            title: "⚠️ Xác nhận xoá",
                                            content: "Bạn có chắc chắn muốn xoá đơn hàng này?",
                                            onDelete: () async {
                                              await OrderService().deleteOrder(
                                                orderId: selectedOrderId!,
                                              );
                                            },
                                            onSuccess: () {
                                              setState(() => selectedOrderId = null);
                                              badgesController.fetchPendingApprovals();
                                              loadOrders(ownOnly: isSeenOrder);
                                            },
                                          );
                                        }
                                        : null,
                                label: "Xóa",
                                icon: Icons.delete,
                                backgroundColor: const Color(0xffEA4346),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder(
                future: futureOrdersPending,
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

                  orderDataSource = OrderDataSource(orders: data, selectedOrderId: selectedOrderId);

                  return SfDataGrid(
                    controller: _dataGridController,
                    source: orderDataSource,
                    isScrollbarAlwaysShown: true,
                    selectionMode: SelectionMode.single,
                    columnWidthMode: ColumnWidthMode.auto,
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
                            columnNames: [
                              'inMatTruoc',
                              'inMatSau',
                              'canMang',
                              'canLanBox',
                              'xa',
                              'catKhe',
                              'be',
                              'dan_1_Manh',
                              'dan_2_Manh',
                              'dongGhimMotManh',
                              'dongGhimHaiManh',
                              'chongTham',
                              'dongGoi',
                              'maKhuon',
                            ],
                            child: Obx(
                              () => formatColumn(
                                label: 'Công Đoạn 2',
                                themeController: themeController,
                              ),
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
                          tableKey: 'order',
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
                          // print("Selected Order ID: $selectedOrderId");
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
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: () => loadOrders(ownOnly: isSeenOrder),
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  void _scrollToOrder(String newOrderId) {
    // Tìm index trong list
    final newIndex = orderDataSource.orders.indexWhere((p) => p.orderId == newOrderId);

    if (newIndex != -1) {
      _dataGridController.scrollToRow(newIndex.toDouble(), canAnimate: true);
      _dataGridController.selectedIndex = newIndex;
      setState(() {
        selectedOrderId = newOrderId;
      });
    } else {
      AppLogger.d("Không tìm thấy đơn hàng mới trong bảng.");
    }
  }
}
