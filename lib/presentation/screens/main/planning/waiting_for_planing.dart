import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_planning_order.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_planning.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/planning/planning_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
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

class WaitingForPlanning extends StatefulWidget {
  const WaitingForPlanning({super.key});

  @override
  WaitingForPlanningState createState() => WaitingForPlanningState();
}

class WaitingForPlanningState extends State<WaitingForPlanning> {
  late Future<List<OrderModel>> futureOrdersAccept;
  late List<GridColumn> columns;

  //controllers
  final formatter = DateFormat('dd/MM/yyyy');
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();

  String type = 'unplanned';
  final Map<String, String> filterOptions = {
    'unplanned': 'Chưa xếp',
    'partial': "Xếp 1 phần",
    'planned': 'Đã xếp',
  };

  //search
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Theo Quy Cách": "QC_box",
  };

  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedOrderIdNotifier = ValueNotifier<String?>(null);

  //datasource and cache
  List<OrderModel>? _cachedPapers;
  PlanningDataSource? _cachedDatasource;

  //flag
  late bool isPlan;
  bool isTextFieldEnabled = false;

  @override
  void initState() {
    super.initState();
    loadOrders();

    isPlan = userController.hasPermission(permission: "plan");

    columns = buildColumnPlanning(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'waitingPlanning', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadOrders() {
    setState(() {
      futureOrdersAccept = ensureMinLoading(PlanningService().getOrderAccept(type: type));
      _selectedOrderIdNotifier.value = null;
    });
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchOrder => searchType=$searchType | keyword=$keyword");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOrder => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      if (searchType == "Tất cả") {
        futureOrdersAccept = ensureMinLoading(PlanningService().getOrderAccept(type: type));
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureOrdersAccept = ensureMinLoading(
          PlanningService().getOrderAccept(type: type, field: selectedField, keyword: keyword),
        );
      }
    });
  }

  void changeFilter(String newFilter) {
    setState(() {
      type = newFilter;
      _selectedOrderIdNotifier.value = null;
      loadOrders();
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
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
              child: Container(
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
                                        //left button
                                        Expanded(
                                          flex: 1,
                                          child: LeftButtonSearch(
                                            selectedType: searchType,
                                            types: const [
                                              'Tất cả',
                                              "Mã Đơn Hàng",
                                              "Tên Khách Hàng",
                                              "Theo Quy Cách",
                                            ],
                                            onTypeChanged: (value) {
                                              setState(() {
                                                searchType = value;
                                                isTextFieldEnabled = searchType != 'Tất cả';

                                                if (searchType == "Tất cả" &&
                                                    searchController.text.isNotEmpty) {
                                                  searchController.clear();
                                                  loadOrders();
                                                }
                                              });
                                            },
                                            controller: searchController,
                                            textFieldEnabled: isTextFieldEnabled,
                                            buttonColor: themeController.buttonColor,

                                            onSearch: () => searchOrders(),
                                          ),
                                        ),

                                        //right button
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 10,
                                          ),
                                          child: ValueListenableBuilder(
                                            valueListenable: _selectedOrderIdNotifier,
                                            builder: (context, selectedOrderId, _) {
                                              final bool hasSelection =
                                                  selectedOrderId != null &&
                                                  selectedOrderId.isNotEmpty;

                                              return Row(
                                                children: [
                                                  //planning order
                                                  AnimatedButton(
                                                    onPressed:
                                                        hasSelection
                                                            ? () async {
                                                              try {
                                                                final order =
                                                                    await futureOrdersAccept;
                                                                final selectedOrder = order
                                                                    .firstWhere(
                                                                      (order) =>
                                                                          order.orderId ==
                                                                          selectedOrderId,
                                                                    );

                                                                if (context.mounted) {
                                                                  showDialog(
                                                                    barrierDismissible: false,
                                                                    context: context,
                                                                    builder:
                                                                        (_) => PLanningDialog(
                                                                          order: selectedOrder,
                                                                          onPlanningOrder:
                                                                              () => loadOrders(),
                                                                        ),
                                                                  );
                                                                }
                                                              } catch (e, s) {
                                                                AppLogger.e(
                                                                  "Lỗi không tìm thấy đơn hàng",
                                                                  error: e,
                                                                  stackTrace: s,
                                                                );
                                                              }
                                                            }
                                                            : null,
                                                    label: "Lên kế hoạch",
                                                    icon: Icons.add,
                                                    backgroundColor: themeController.buttonColor,
                                                  ),
                                                  const SizedBox(width: 10),

                                                  //back order
                                                  AnimatedButton(
                                                    onPressed:
                                                        hasSelection
                                                            ? () async {
                                                              await handleBackOrder(
                                                                context: context,
                                                                orderId: selectedOrderId!,
                                                                badgesController: badgesController,
                                                                onSuccess: () {
                                                                  setState(
                                                                    () => selectedOrderId = null,
                                                                  );
                                                                  loadOrders();
                                                                },
                                                              );
                                                            }
                                                            : null,
                                                    label: "Hoàn Đơn",
                                                    icon: Symbols.keyboard_return,
                                                    backgroundColor: const Color(0xffEA4346),
                                                  ),
                                                  const SizedBox(width: 10),

                                                  //filter
                                                  buildDropdownItems(
                                                    value: type,
                                                    items: const [
                                                      'unplanned',
                                                      'partial',
                                                      'planned',
                                                    ],
                                                    onChanged: (value) => changeFilter(value!),
                                                    itemLabelBuilder:
                                                        (value) => filterOptions[value] ?? value,
                                                  ),
                                                ],
                                              );
                                            },
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

                          final List<OrderModel> data = snapshot.data!;

                          if (_cachedPapers == null || _cachedPapers != data) {
                            _cachedPapers = data;
                            _cachedDatasource = PlanningDataSource(
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
                                  source: _cachedDatasource!,
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
                                          columnNames: [
                                            "qtyManufacture",
                                            "runningPlan",
                                            "quantityProduced",
                                          ],
                                          child: Obx(
                                            () => formatColumn(
                                              label: 'Số Lượng',
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
                                        tableKey: 'waitingPlanning',
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
                  initialMargin: Offset(73, 125),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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

Future<void> handleBackOrder({
  required BuildContext context,
  required String orderId,
  required BadgesController badgesController,
  VoidCallback? onSuccess,
}) async {
  await showDeleteConfirmHelper(
    context: context,
    title: "Xác nhận trả đơn về",
    content: "Bạn có chắc chắn muốn trả đơn không?",
    confirmText: "Xác nhận",
    onDelete: () async {
      try {
        await PlanningService().backOrderToReject(orderId: orderId);
      } on ApiException catch (e) {
        String messageErr = "Trả đơn thất bại";
        switch (e.errorCode) {
          case "ORDER_HAS_PRODUCED_ITEMS":
            messageErr = e.message!;
            break;
          case "INVENTORY_VALUE_NOT_ZERO":
            messageErr = e.message!;
            break;
        }

        if (!context.mounted) return;
        showSnackBarError(context, messageErr);
      } catch (e) {
        if (context.mounted) {
          showSnackBarError(context, "Trả đơn thất bạis");
        }
      }
    },
    onSuccess: () {
      badgesController.fetchOrderPendingPlanning();
      badgesController.fetchOrderReject();

      if (onSuccess != null) {
        onSuccess();
      }
    },
  );
}
