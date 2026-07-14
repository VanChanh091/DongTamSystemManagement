import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_orders.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/order_data_source.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderRejectAndPending extends StatefulWidget {
  const OrderRejectAndPending({super.key});

  @override
  State<OrderRejectAndPending> createState() => _OrderRejectAndPendingState();
}

class _OrderRejectAndPendingState extends State<OrderRejectAndPending> {
  late Future<List<OrderModel>> futureOrdersPending;
  late List<GridColumn> columns;

  //controllers
  final formatter = DateFormat('dd/MM/yyyy');
  final _dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();

  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedOrderIdNotifier = ValueNotifier<String?>(null);

  //datasource and cache
  List<OrderModel>? _cachedOrders;
  OrderDataSource? _cachedDatasource;

  //flag
  late bool isManager;
  bool isSeenOrder = false;

  @override
  void initState() {
    super.initState();
    loadOrders(ownOnly: isSeenOrder);

    isManager = userController.hasAnyRole(roles: ['manager', 'admin']);

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
    _selectedOrderIdNotifier.value = null;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    _selectedOrderIdNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerSignal:
            (pointerSignal) => handleScrollZoom(
              pointerSignal: pointerSignal,
              currentZoom: _zoomNotifier.value,
              onZoomChanged: _updateZoom,
            ),

        child: Stack(
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, cachedChild) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: OverflowBox(
                        minWidth: constraints.maxWidth / zoom,
                        maxWidth: constraints.maxWidth / zoom,
                        minHeight: constraints.maxHeight / zoom,
                        maxHeight: constraints.maxHeight / zoom,
                        alignment: Alignment.topLeft,
                        child: Transform.scale(
                          scale: zoom,
                          alignment: Alignment.topLeft,
                          child: cachedChild,
                        ),
                      ),
                    );
                  },
                );
              },
              //container contain button and table
              child: Container(
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
                                const Expanded(flex: 1, child: SizedBox()),

                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedOrderIdNotifier,
                                      builder: (context, selectedOrderId, _) {
                                        final bool hasSelection =
                                            selectedOrderId != null && selectedOrderId.isNotEmpty;

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
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
                                                    label:
                                                        isSeenOrder ? "Xem Tất Cả" : "Đơn Bản Thân",
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
                                                  barrierDismissible: false,
                                                  builder:
                                                      (_) => OrderDialog(
                                                        order: null,
                                                        onOrderAddOrUpdate: (String newOrderId) {
                                                          loadOrders(ownOnly: isSeenOrder);
                                                          WidgetsBinding.instance
                                                              .addPostFrameCallback((_) {
                                                                Future.delayed(
                                                                  const Duration(milliseconds: 300),
                                                                  () {
                                                                    _scrollToOrder(newOrderId);
                                                                  },
                                                                );
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
                                                  hasSelection
                                                      ? () async {
                                                        try {
                                                          final orders = await futureOrdersPending;
                                                          final selectedOrder = orders.firstWhere(
                                                            (order) =>
                                                                order.orderId == selectedOrderId,
                                                          );

                                                          if (!context.mounted) return;

                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (_) => OrderDialog(
                                                                  order: selectedOrder,
                                                                  onOrderAddOrUpdate:
                                                                      (String? newOrderId) =>
                                                                          loadOrders(
                                                                            ownOnly: isSeenOrder,
                                                                          ),
                                                                ),
                                                          );
                                                        } catch (e, s) {
                                                          AppLogger.e(
                                                            "Lỗi không tìm thấy đơn hàng",
                                                            error: e,
                                                            stackTrace: s,
                                                          );
                                                          showSnackBarError(
                                                            context,
                                                            'Có lỗi xảy ra, vui lòng thử lại sau',
                                                          );
                                                        }
                                                      }
                                                      : null,
                                              label: "Sửa",
                                              icon: Symbols.construction,
                                              backgroundColor: themeController.buttonColor,
                                            ),
                                            const SizedBox(width: 10),

                                            //delete
                                            AnimatedButton(
                                              onPressed:
                                                  hasSelection
                                                      ? () async {
                                                        await showDeleteConfirmHelper(
                                                          context: context,
                                                          title: "⚠️ Xác nhận xoá",
                                                          content:
                                                              "Bạn có chắc chắn muốn xoá đơn hàng này?",
                                                          onDelete: () async {
                                                            await OrderService().deleteOrder(
                                                              orderId: selectedOrderId!,
                                                            );
                                                          },
                                                          onSuccess: () {
                                                            setState(() => selectedOrderId = null);
                                                            badgesController
                                                                .fetchPendingApprovals();
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
                                        );
                                      },
                                    ),
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

                          final List<OrderModel> data = snapshot.data!;

                          if (_cachedOrders == null || _cachedOrders != data) {
                            _cachedOrders = data;
                            _cachedDatasource = OrderDataSource(
                              context: context,
                              orders: data,
                              selectedOrderId: _selectedOrderIdNotifier.value,
                            );
                          }

                          return StatefulBuilder(
                            builder: (context, localSetState) {
                              return SfDataGridTheme(
                                data: SfDataGridThemeData(
                                  selectionColor: Colors.blue.withValues(alpha: 0.3),
                                ),
                                child: SfDataGrid(
                                  controller: _dataGridController,
                                  source: _cachedDatasource!,
                                  isScrollbarAlwaysShown: true,
                                  selectionMode: SelectionMode.single,
                                  columnWidthMode: ColumnWidthMode.auto,
                                  headerRowHeight: 30,
                                  rowHeight: 38,
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
                                        setState: localSetState,
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
                                      final orderId =
                                          selectedRow
                                              .getCells()
                                              .firstWhere((cell) => cell.columnName == 'orderId')
                                              .value
                                              .toString();

                                      _selectedOrderIdNotifier.value = orderId;
                                    } else {
                                      _selectedOrderIdNotifier.value = null;
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: Offset(73, 173),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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
    final newIndex = _cachedDatasource!.orders.indexWhere((p) => p.orderId == newOrderId);

    if (newIndex != -1) {
      _dataGridController.scrollToRow(newIndex.toDouble(), canAnimate: true);
      _dataGridController.selectedIndex = newIndex;
      setState(() {
        _selectedOrderIdNotifier.value = newOrderId;
      });
    } else {
      AppLogger.d("Không tìm thấy đơn hàng mới trong bảng.");
    }
  }
}
