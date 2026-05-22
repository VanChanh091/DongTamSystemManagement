import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_orders.dart';
import 'package:dongtam/presentation/components/headerTable/synthetic/orders/header_synthetic_order_detail.dart';
import 'package:dongtam/presentation/components/headerTable/synthetic/orders/header_synthetic_orders.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/synthetic/order/synthetic_box_detail_data_source.dart';
import 'package:dongtam/presentation/sources/synthetic/order/synthetic_orders_data_source.dart';
import 'package:dongtam/service/synthetic_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticOrder extends StatefulWidget {
  const SyntheticOrder({super.key});

  @override
  State<SyntheticOrder> createState() => _SyntheticOrderState();
}

class _SyntheticOrderState extends State<SyntheticOrder> {
  late Future<Map<String, dynamic>> futureOrders;
  late SyntheticOrdersDataSource syntheticOrders;
  late List<GridColumn> columnsOrders;
  late List<GridColumn> columnsBoxes;

  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //width column
  Map<String, double> columnWidthOrders = {}; //map header table
  Map<String, double> columnWidthBoxes = {};
  List<PlanningBox> selectedBoxesDetail = [];

  String? selectedOrderId;

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "orderId": "Mã Đơn Hàng",
    "customerName": "Tên Khách Hàng",
    "dayReceiveOrder": "Ngày Nhận Đơn",
  };

  //filter by machine & runningPlan
  String filterType = "all";
  final Map<String, String> filterOptions = {
    'all': 'Tất cả',
    'accept': "Đã Duyệt",
    'planning': 'Lên Kế Hoạch',
    'completed': 'Hoàn Thành',
  };

  //text controller
  TextEditingController searchController = TextEditingController();

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadOrders();

    columnsOrders = buildSyntheticOrderColumn(themeController: themeController);
    columnsBoxes = buildSyntheticBoxesColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'syntheticOrders', columns: columnsOrders).then((w) {
      setState(() {
        columnWidthOrders = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'syntheticBoxes', columns: columnsBoxes).then((w) {
      setState(() {
        columnWidthBoxes = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField =
        searchFieldMap.entries
            .firstWhere((e) => e.value == searchType, orElse: () => const MapEntry('', ''))
            .key;

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = (searchType != "Tất cả");
    final bool isDateSearch = searchType == "Ngày Nhận Đơn";

    futureOrders = ensureMinLoading(
      SyntheticService().getAllSyntheticOrders(
        page: currentPage,
        pageSize: pageSize,
        status: filterType,
        allOrders: filterType,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedOrderId = null;
    selectedBoxesDetail = [];
  }

  void loadOrders() {
    setState(() => _fetchData());
  }

  void searchOrders() {
    final bool isDateSearch = searchType == "Ngày Nhận Đơn";
    final String keyword = searchController.text.trim().toLowerCase();

    if (isDateSearch) {
      if (startDate == null || endDate == null) {
        AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
        return;
      }
    } else if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOrders => searchType=$searchType nhưng keyword rỗng");
      return;
    }

    currentPage = 1;
    setState(() => _fetchData());
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccountant = userController.hasPermission(permission: "accountant");

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
                        "TỔNG HỢP ĐƠN HÀNG",
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left button
                        Expanded(
                          flex: 1,
                          child: LeftButtonSearch(
                            selectedType: searchType,
                            types: const [
                              'Tất cả',
                              'Mã Đơn Hàng',
                              'Tên Khách Hàng',
                              'Ngày Nhận Đơn',
                            ],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = value != 'Tất cả';

                                searchType == 'Tất cả' ? searchController.clear() : null;

                                startDate = null;
                                endDate = null;

                                if (value == 'Tất cả') {
                                  currentPage = 1;
                                  _fetchData();
                                }
                              });
                            },
                            controller: searchController,
                            textFieldEnabled: isTextFieldEnabled,
                            buttonColor: themeController.buttonColor,
                            onSearch: () => searchOrders(),
                            customInputBuilder: (inputWidth) {
                              if (searchType != 'Ngày Nhận Đơn') return null;

                              return SizedBox(
                                width: inputWidth,
                                height: 50,
                                child: InkWell(
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final size = MediaQuery.of(context).size;

                                    final DateTimeRange? picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2100),
                                      initialDateRange:
                                          (startDate != null && endDate != null)
                                              ? DateTimeRange(start: startDate!, end: endDate!)
                                              : DateTimeRange(
                                                start: now.subtract(const Duration(days: 7)),
                                                end: now,
                                              ),
                                      builder: (context, child) {
                                        return Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: size.width * 0.3,
                                              maxHeight: size.height * 0.8,
                                            ),
                                            child: Material(
                                              borderRadius: BorderRadius.circular(16),
                                              clipBehavior: Clip.antiAlias,
                                              child: child!,
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    if (picked != null) {
                                      final displayStart = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(picked.start);
                                      final displayEnd = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(picked.end);

                                      setState(() {
                                        startDate = picked.start;
                                        endDate = picked.end;
                                        searchController.text = '$displayStart - $displayEnd';
                                      });
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Chọn khoảng thời gian...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        suffixIcon: const Icon(Icons.date_range),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export excel
                                isAccountant
                                    ? AnimatedButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (_) => DialogExportOrders(),
                                        );
                                      },
                                      label: "Xuất Excel",
                                      icon: Symbols.export_notes,
                                      backgroundColor: themeController.buttonColor,
                                    )
                                    : const SizedBox.shrink(),
                                const SizedBox(width: 10),

                                //filter
                                buildDropdownItems(
                                  value: filterType,
                                  items: const ['all', 'accept', 'planning', 'completed'],
                                  onChanged:
                                      (value) => {
                                        setState(() {
                                          filterType = value!;
                                          selectedOrderId = null;
                                          selectedBoxesDetail = [];
                                          loadOrders();
                                        }),
                                      },
                                  itemLabelBuilder: (value) => filterOptions[value] ?? value,
                                ),
                                const SizedBox(width: 10),
                              ],
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
                future: futureOrders,
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
                  final orders = data['orders'] as List<Order>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  syntheticOrders = SyntheticOrdersDataSource(
                    orders: orders,
                    selectedOrderId: selectedOrderId,
                    currentPage: currentPg,
                    pageSize: pageSize,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SfDataGrid(
                                source: syntheticOrders,
                                isScrollbarAlwaysShown: true,
                                columnWidthMode: ColumnWidthMode.auto,
                                selectionMode: SelectionMode.single,
                                headerRowHeight: 35,
                                rowHeight: 40,
                                columns: ColumnWidthTable.applySavedWidths(
                                  columns: columnsOrders,
                                  widths: columnWidthOrders,
                                ),
                                stackedHeaderRows: <StackedHeaderRow>[
                                  StackedHeaderRow(
                                    cells: [
                                      StackedHeaderCell(
                                        columnNames: [
                                          "sizeCust",
                                          "lengthCust",
                                          "sizeManu",
                                          "lengthManu",
                                        ],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Quy Cách',
                                            themeController: themeController,
                                          ),
                                        ),
                                      ),
                                      StackedHeaderCell(
                                        columnNames: [
                                          "quantityCustomer",
                                          'qtyOutbound',
                                          "qtyProduced",
                                          "qtyInventory",
                                          'qtyWasteNorm',
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
                                      columns: columnsOrders,
                                      setState: setState,
                                    ),
                                onColumnResizeEnd:
                                    (details) => GridResizeHelper.onResizeEnd(
                                      details: details,
                                      tableKey: 'syntheticOrders',
                                      columnWidths: columnWidthOrders,
                                      setState: setState,
                                    ),

                                onSelectionChanged: (addedRows, removedRows) async {
                                  if (addedRows.isEmpty) {
                                    setState(() {
                                      selectedOrderId = null;
                                      selectedBoxesDetail = [];
                                    });
                                    return;
                                  }

                                  final selectedRow = addedRows.first;

                                  final orderId =
                                      selectedRow
                                          .getCells()
                                          .firstWhere((cell) => cell.columnName == 'orderId')
                                          .value
                                          .toString();

                                  // Lấy data của list (summary)
                                  final selectedOrder = orders.firstWhere(
                                    (order) => order.orderId == orderId,
                                  );

                                  setState(() {
                                    selectedOrderId = selectedOrder.orderId;
                                    selectedBoxesDetail = [];
                                  });

                                  if (selectedOrder.isBox == true) {
                                    final detail = await SyntheticService().getSyntheticBoxDetail(
                                      orderId: selectedOrder.orderId,
                                    );

                                    setState(() {
                                      if (detail != null) {
                                        selectedBoxesDetail = [detail];
                                      }
                                    });
                                  }
                                },
                              ),
                            ),

                            selectedBoxesDetail.isNotEmpty
                                ? Expanded(
                                  flex: 1,
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: SfDataGrid(
                                      source: SyntheticBoxDetail(boxes: selectedBoxesDetail),
                                      isScrollbarAlwaysShown: true,
                                      headerRowHeight: 30,
                                      rowHeight: 35,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      selectionMode: SelectionMode.single,
                                      columns: ColumnWidthTable.applySavedWidths(
                                        columns: columnsBoxes,
                                        widths: columnWidthBoxes,
                                      ),

                                      //auto resize
                                      allowColumnsResizing: true,
                                      columnResizeMode: ColumnResizeMode.onResize,

                                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                                      onColumnResizeUpdate:
                                          (details) => GridResizeHelper.onResizeUpdate(
                                            details: details,
                                            columns: columnsBoxes,
                                            setState: setState,
                                          ),
                                      onColumnResizeEnd:
                                          (details) => GridResizeHelper.onResizeEnd(
                                            details: details,
                                            tableKey: 'boxesDetail',
                                            columnWidths: columnWidthBoxes,
                                            setState: setState,
                                          ),
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),

                      // Nút chuyển trang
                      PaginationControls(
                        currentPage: currentPg,
                        totalPages: totalPgs,
                        onPrevious: () {
                          setState(() {
                            currentPage--;
                            loadOrders();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadOrders();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadOrders();
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadOrders(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
