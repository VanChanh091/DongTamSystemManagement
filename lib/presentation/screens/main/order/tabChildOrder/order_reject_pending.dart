import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/sources/order_data_source.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
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
  String? selectedOrderId;
  bool isSeenOrder = false;

  final formatter = DateFormat('dd/MM/yyyy');
  final userController = Get.find<UserController>();
  final badgesController = Get.find<BadgesController>();

  @override
  void initState() {
    super.initState();
    loadOrders(false, isSeenOrder);

    columns = buildOrderColumns();
  }

  void loadOrders(bool refresh, bool ownOnly) {
    AppLogger.i("load all oder pending & reject");
    setState(() {
      futureOrdersPending = ensureMinLoading(
        OrderService().getOrderPendingAndReject(
          refresh: refresh,
          ownOnly: ownOnly,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isManager = userController.hasAnyRole(['manager', 'admin']);

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
                  const SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "ĐƠN HÀNG CHỜ DUYỆT/BỊ TỪ CHỐI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xffcfa381),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
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

                                        loadOrders(false, isSeenOrder);
                                      },
                                      label:
                                          isSeenOrder
                                              ? "Xem Tất Cả"
                                              : "Đơn Bản Thân",
                                      icon: null,
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
                                          onOrderAddOrUpdate:
                                              () =>
                                                  loadOrders(true, isSeenOrder),
                                        ),
                                  );
                                },
                                label: "Thêm mới",
                                icon: Icons.add,
                              ),
                              const SizedBox(width: 10),

                              //update
                              AnimatedButton(
                                onPressed:
                                    selectedOrderId == null
                                        ? null
                                        : () async {
                                          try {
                                            final orders =
                                                await futureOrdersPending;
                                            final selectedOrder = orders
                                                .firstWhere(
                                                  (order) =>
                                                      order.orderId ==
                                                      selectedOrderId,
                                                );

                                            if (!context.mounted) return;

                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => OrderDialog(
                                                    order: selectedOrder,
                                                    onOrderAddOrUpdate:
                                                        () => loadOrders(
                                                          true,
                                                          isSeenOrder,
                                                        ),
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
                              ),
                              const SizedBox(width: 10),

                              //delete
                              AnimatedButton(
                                onPressed:
                                    selectedOrderId == null
                                        ? null
                                        : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              bool isDeleting = false;

                                              return StatefulBuilder(
                                                builder: (
                                                  context,
                                                  setStateDialog,
                                                ) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    title: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons
                                                              .warning_amber_rounded,
                                                          color: Colors.red,
                                                          size: 30,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          "Xác nhận xoá",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content:
                                                        isDeleting
                                                            ? Row(
                                                              children: const [
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                                SizedBox(
                                                                  width: 12,
                                                                ),
                                                                Text(
                                                                  "Đang xoá...",
                                                                ),
                                                              ],
                                                            )
                                                            : const Text(
                                                              'Bạn có chắc chắn muốn xoá đơn hàng này?',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                    actions:
                                                        isDeleting
                                                            ? []
                                                            : [
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.pop(
                                                                      context,
                                                                    ),
                                                                child: const Text(
                                                                  "Huỷ",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color:
                                                                        Colors
                                                                            .black54,
                                                                  ),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                        0xffEA4346,
                                                                      ),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                ),
                                                                onPressed: () async {
                                                                  setStateDialog(
                                                                    () {
                                                                      isDeleting =
                                                                          true;
                                                                    },
                                                                  );

                                                                  await OrderService()
                                                                      .deleteOrder(
                                                                        selectedOrderId!,
                                                                      );

                                                                  badgesController
                                                                      .fetchPendingApprovals();

                                                                  await Future.delayed(
                                                                    const Duration(
                                                                      milliseconds:
                                                                          500,
                                                                    ),
                                                                  );

                                                                  if (!context
                                                                      .mounted) {
                                                                    return;
                                                                  }

                                                                  loadOrders(
                                                                    true,
                                                                    isSeenOrder,
                                                                  );

                                                                  Navigator.pop(
                                                                    context,
                                                                  );

                                                                  // Optional: Show success toast
                                                                  showSnackBarSuccess(
                                                                    context,
                                                                    'Xoá thành công',
                                                                  );
                                                                },
                                                                child: const Text(
                                                                  "Xoá",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
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
                        child: buildShimmerSkeletonTable(
                          context: context,
                          rowCount: 10,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
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

                  orderDataSource = OrderDataSource(
                    orders: data,
                    selectedOrderId: selectedOrderId,
                  );

                  return SfDataGrid(
                    source: orderDataSource,
                    isScrollbarAlwaysShown: true,
                    selectionMode: SelectionMode.single,
                    columnWidthMode: ColumnWidthMode.auto,
                    columns: columns,
                    headerRowHeight: 40,
                    rowHeight: 45,
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
                            child: formatColumn('Công Đoạn 2'),
                          ),
                        ],
                      ),
                    ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadOrders(true, isSeenOrder),
        backgroundColor: const Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
