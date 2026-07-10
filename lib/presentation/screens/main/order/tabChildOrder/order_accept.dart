import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_order.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/order_data_source.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OrderAccept extends StatefulWidget {
  const OrderAccept({super.key});

  @override
  State<OrderAccept> createState() => _OrderAcceptAndPlanningState();
}

class _OrderAcceptAndPlanningState extends State<OrderAccept> {
  late Future<Map<String, dynamic>> futureOrdersAccept;
  late List<GridColumn> columns;

  //controllers
  final formatter = DateFormat('dd/MM/yyyy');
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Tên Sản Phẩm": "productName",
    "QC Thùng": "qcBox",
  };

  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedOrderIdNotifier = ValueNotifier<String?>(null);
  Map<String, double> columnWidths = {};

  //datasource and cache
  List<OrderModel>? _cachedOrders;
  OrderDataSource? _cachedDatasource;

  //text controller
  TextEditingController searchController = TextEditingController();

  //flag
  late bool isManager;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
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

  void loadOrders({bool ownOnly = false}) {
    setState(() {
      final String keyword = searchController.text.trim().toLowerCase();
      final String selectedField = searchFieldMap[searchType] ?? "";

      if (isSearching && searchType != "Tất cả" && keyword.isNotEmpty) {
        futureOrdersAccept = ensureMinLoading(
          OrderService().getOrderAcceptted(field: selectedField, keyword: keyword),
        );
      } else {
        futureOrdersAccept = ensureMinLoading(OrderService().getOrderAcceptted(ownOnly: ownOnly));
      }
    });
    _selectedOrderIdNotifier.value = null;
  }

  void searchOrders() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchOrder => searchType=$searchType | keyword=$keyword");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOrder => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    setState(() {
      isSearching = (searchType != "Tất cả");

      if (searchType == "Tất cả") {
        futureOrdersAccept = ensureMinLoading(OrderService().getOrderAcceptted(ownOnly: false));
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureOrdersAccept = ensureMinLoading(
          OrderService().getOrderAcceptted(field: selectedField, keyword: keyword),
        );
      }
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
                                  "ĐƠN HÀNG ĐÃ DUYỆT/CHỜ LÊN KẾ HOẠCH",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: themeController.currentColor.value,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //button
                          SizedBox(
                            height: 70,
                            width: double.infinity,
                            child: Row(
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
                                      "Tên Sản Phẩm",
                                      "QC Thùng",
                                    ],
                                    onTypeChanged: (value) {
                                      setState(() {
                                        searchType = value;
                                        isTextFieldEnabled = value != 'Tất cả';

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
                                    extraWidgets: [
                                      isManager
                                          ? AnimatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isSeenOrder = !isSeenOrder;
                                              });
                                              loadOrders(ownOnly: isSeenOrder);
                                            },
                                            label: isSeenOrder ? "Xem Tất Cả" : "Đơn Bản Thân",
                                            icon: null,
                                            backgroundColor: themeController.buttonColor,
                                          )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),

                                //right button
                                Expanded(flex: 1, child: const SizedBox()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // table
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>>(
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
                            return Center(child: Text("Lỗi: ${snapshot.error}"));
                          } else if (!snapshot.hasData || snapshot.data!['orders'].isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data!;
                          final orders = data['orders'] as List<OrderModel>;

                          if (_cachedOrders == null || _cachedOrders != orders) {
                            _cachedDatasource = OrderDataSource(
                              context: context,
                              orders: orders,
                              selectedOrderId: _selectedOrderIdNotifier.value,
                            );
                          }

                          return Column(
                            children: [
                              //table
                              Expanded(
                                child: StatefulBuilder(
                                  builder: (context, localSetState) {
                                    return SfDataGridTheme(
                                      data: SfDataGridThemeData(
                                        selectionColor: Colors.blue.withValues(alpha: 0.3),
                                      ),
                                      child: SfDataGrid(
                                        source: _cachedDatasource!,
                                        isScrollbarAlwaysShown: true,
                                        selectionMode: SelectionMode.single,
                                        columnWidthMode: ColumnWidthMode.auto,
                                        headerRowHeight: 40,
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
                                                    .firstWhere(
                                                      (cell) => cell.columnName == 'orderId',
                                                    )
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
                                ),
                              ),
                            ],
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
                  buttonColor: themeController.buttonColor.value,
                  onZoomChanged: _updateZoom,
                  initialOffset: const Offset(1780, 845),
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
}
