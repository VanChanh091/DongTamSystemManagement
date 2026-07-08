import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_cus_or_prod.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_customer.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/customer_data_source.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Future<Map<String, dynamic>> futureCustomer;
  late CustomerDatasource customerDatasource;
  late List<GridColumn> columns;

  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Khách Hàng": "customerId",
    "Tên Khách Hàng": "customerName",
    "Theo CSKH": "cskh",
    "Theo SDT": "phone",
    "Ngày Tạo": "createdAt",
  };

  String? selectedCustomerId;
  Map<String, double> columnWidths = {}; //map header table

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

  double _zoomLevel = 1.0;

  void _updateZoom(double newZoom) {
    setState(() {
      _zoomLevel = newZoom.clamp(0.5, 1.5);
    });
  }

  @override
  void initState() {
    super.initState();
    loadCustomer();

    columns = buildCustomerColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'customer', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = (searchType != "Tất cả");
    final bool isDateSearch = searchType == "Ngày Tạo";

    futureCustomer = ensureMinLoading(
      CustomerService().getCustomers(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedCustomerId = null;
  }

  void loadCustomer() {
    setState(() => _fetchData());
  }

  void searchCustomer() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchCustomer: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchCustomer: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSale = userController.hasPermission(permission: "sale");

    return Scaffold(
      body: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            final keys = HardwareKeyboard.instance.logicalKeysPressed;
            final isCtrlPressed =
                keys.contains(LogicalKeyboardKey.controlLeft) ||
                keys.contains(LogicalKeyboardKey.controlRight);

            if (isCtrlPressed) {
              if (pointerSignal.scrollDelta.dy > 0) {
                _updateZoom(_zoomLevel - 0.05);
              } else if (pointerSignal.scrollDelta.dy < 0) {
                _updateZoom(_zoomLevel + 0.05);
              }
            }
          }
        },
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: OverflowBox(
                    minWidth: constraints.maxWidth / _zoomLevel,
                    maxWidth: constraints.maxWidth / _zoomLevel,
                    minHeight: constraints.maxHeight / _zoomLevel,
                    maxHeight: constraints.maxHeight / _zoomLevel,
                    alignment: Alignment.topLeft,
                    child: Transform.scale(
                      scale: _zoomLevel,
                      alignment: Alignment.topLeft,
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
                                        "DANH SÁCH KHÁCH HÀNG",
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
                                              "Mã Khách Hàng",
                                              "Tên Khách Hàng",
                                              "Theo CSKH",
                                              "Theo SDT",
                                              "Ngày Tạo",
                                            ],
                                            onTypeChanged: (value) {
                                              setState(() {
                                                searchType = value;
                                                isTextFieldEnabled = searchType != 'Tất cả';

                                                startDate = null;
                                                endDate = null;

                                                if (searchType == "Tất cả" &&
                                                    searchController.text.isNotEmpty) {
                                                  searchController.clear();
                                                  currentPage = 1;
                                                  _fetchData();
                                                }
                                              });
                                            },
                                            controller: searchController,
                                            textFieldEnabled: isTextFieldEnabled,
                                            buttonColor: themeController.buttonColor,
                                            onSearch: () => searchCustomer(),
                                            customInputBuilder: (inputWidth) {
                                              if (searchType != 'Ngày Tạo') return null;

                                              return SizedBox(
                                                width: inputWidth,
                                                height: 50,
                                                child: InkWell(
                                                  onTap: () async {
                                                    final now = DateTime.now();
                                                    final size = MediaQuery.of(context).size;

                                                    final DateTimeRange? picked =
                                                        await showDateRangePicker(
                                                          context: context,
                                                          firstDate: DateTime(2025),
                                                          lastDate: DateTime(2100),
                                                          initialDateRange:
                                                              (startDate != null && endDate != null)
                                                                  ? DateTimeRange(
                                                                    start: startDate!,
                                                                    end: endDate!,
                                                                  )
                                                                  : DateTimeRange(
                                                                    start: now.subtract(
                                                                      const Duration(days: 7),
                                                                    ),
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
                                                                  borderRadius:
                                                                      BorderRadius.circular(16),
                                                                  clipBehavior: Clip.antiAlias,
                                                                  child: child!,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );

                                                    if (picked != null) {
                                                      final displayStart = DateFormat(
                                                        "dd/MM/yyyy",
                                                      ).format(picked.start);
                                                      final displayEnd = DateFormat(
                                                        "dd/MM/yyyy",
                                                      ).format(picked.end);

                                                      setState(() {
                                                        startDate = picked.start;
                                                        endDate = picked.end;
                                                        searchController.text =
                                                            "$displayStart - $displayEnd";
                                                      });
                                                    }
                                                  },
                                                  child: IgnorePointer(
                                                    child: TextField(
                                                      controller: searchController,
                                                      decoration: InputDecoration(
                                                        hintText: "Chọn khoảng thời gian...",
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        suffixIcon: const Icon(
                                                          Icons.calendar_today,
                                                        ),
                                                        contentPadding: const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                        ),
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
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 10,
                                            ),
                                            child:
                                                isSale
                                                    ? Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        //export excel
                                                        AnimatedButton(
                                                          onPressed: () async {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (_) => DialogExportCusOrProd(),
                                                            );
                                                          },
                                                          label: "Xuất Excel",
                                                          icon: Symbols.export_notes,
                                                          backgroundColor:
                                                              themeController.buttonColor,
                                                        ),
                                                        const SizedBox(width: 10),

                                                        //add
                                                        AnimatedButton(
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (_) => CustomerDialog(
                                                                    customer: null,
                                                                    onCustomerAddOrUpdate:
                                                                        () => loadCustomer(),
                                                                  ),
                                                            );
                                                          },
                                                          label: "Thêm mới",
                                                          icon: Icons.add,
                                                          backgroundColor:
                                                              themeController.buttonColor,
                                                        ),
                                                        const SizedBox(width: 10),

                                                        // update
                                                        AnimatedButton(
                                                          onPressed:
                                                              isSale &&
                                                                      selectedCustomerId != null &&
                                                                      selectedCustomerId!.isNotEmpty
                                                                  ? () async {
                                                                    try {
                                                                      final customersData =
                                                                          await futureCustomer;
                                                                      final List<Customer>
                                                                      customerList =
                                                                          (customersData['customers']
                                                                                      as List? ??
                                                                                  [])
                                                                              .cast<Customer>();
                                                                      final selectedCustomer =
                                                                          customerList.firstWhere(
                                                                            (customer) =>
                                                                                customer
                                                                                    .customerId ==
                                                                                selectedCustomerId,
                                                                            orElse:
                                                                                () =>
                                                                                    throw Exception(
                                                                                      "Không tìm thấy khách hàng",
                                                                                    ),
                                                                          );

                                                                      if (context.mounted) {
                                                                        showDialog(
                                                                          context: context,
                                                                          builder:
                                                                              (_) => CustomerDialog(
                                                                                customer:
                                                                                    selectedCustomer,
                                                                                onCustomerAddOrUpdate:
                                                                                    () =>
                                                                                        loadCustomer(),
                                                                              ),
                                                                        );
                                                                      }
                                                                    } catch (e, s) {
                                                                      AppLogger.e(
                                                                        "Error in getCustomerById: $e",
                                                                        stackTrace: s,
                                                                      );

                                                                      if (!context.mounted) return;
                                                                      showSnackBarError(
                                                                        context,
                                                                        'Có lỗi xảy ra, vui lòng thử lại sau',
                                                                      );
                                                                    }
                                                                  }
                                                                  : null,
                                                          label: "Sửa",
                                                          icon: Symbols.construction,
                                                          backgroundColor:
                                                              themeController.buttonColor,
                                                        ),
                                                        const SizedBox(width: 10),

                                                        //delete customers
                                                        AnimatedButton(
                                                          onPressed:
                                                              isSale &&
                                                                      selectedCustomerId != null &&
                                                                      selectedCustomerId!.isNotEmpty
                                                                  ? () async {
                                                                    await showDeleteConfirmHelper(
                                                                      context: context,
                                                                      title: "⚠️ Xác nhận xoá",
                                                                      content:
                                                                          "Bạn có chắc chắn muốn xoá khách hàng này?",
                                                                      onDelete: () async {
                                                                        await CustomerService()
                                                                            .deleteCustomer(
                                                                              customerId:
                                                                                  selectedCustomerId!,
                                                                            );
                                                                      },
                                                                      onSuccess: () {
                                                                        setState(
                                                                          () =>
                                                                              selectedCustomerId =
                                                                                  null,
                                                                        );
                                                                        loadCustomer();
                                                                      },
                                                                    );
                                                                  }
                                                                  : null,
                                                          label: "Xóa",
                                                          icon: Icons.delete,
                                                          backgroundColor: const Color(0xffEA4346),
                                                        ),
                                                      ],
                                                    )
                                                    : const SizedBox.shrink(),
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
                                future: futureCustomer,
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
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!['customers'].isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "Không có khách hàng nào",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                      ),
                                    );
                                  }

                                  final data = snapshot.data!;
                                  final customers = data['customers'] as List<Customer>;
                                  final currentPg = data['currentPage'];
                                  final totalPgs = data['totalPages'];

                                  customerDatasource = CustomerDatasource(
                                    customer: customers,
                                    selectedCustomerId: selectedCustomerId,
                                    currentPage: currentPage,
                                    pageSize: pageSize,
                                  );

                                  return Column(
                                    children: [
                                      //table
                                      Expanded(
                                        child: SfDataGrid(
                                          source: customerDatasource,
                                          isScrollbarAlwaysShown: true,
                                          columnWidthMode: ColumnWidthMode.auto,
                                          selectionMode: SelectionMode.single,
                                          headerRowHeight: 45,
                                          rowHeight: 40,
                                          columns: ColumnWidthTable.applySavedWidths(
                                            columns: columns,
                                            widths: columnWidths,
                                          ),

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
                                                tableKey: 'customer',
                                                columnWidths: columnWidths,
                                                setState: setState,
                                              ),

                                          onSelectionChanged: (addedRows, removedRows) {
                                            if (addedRows.isNotEmpty) {
                                              final selectedRow = addedRows.first;
                                              final customerId =
                                                  selectedRow
                                                      .getCells()
                                                      .firstWhere(
                                                        (cell) => cell.columnName == 'customerId',
                                                      )
                                                      .value
                                                      .toString();

                                              final selectedCustomer = customers.firstWhere(
                                                (customer) => customer.customerId == customerId,
                                              );

                                              setState(() {
                                                selectedCustomerId = selectedCustomer.customerId;
                                              });
                                            } else {
                                              setState(() {
                                                selectedCustomerId = null;
                                              });
                                            }
                                          },
                                        ),
                                      ),

                                      // Nút chuyển trang
                                      PaginationControls(
                                        currentPage: currentPg,
                                        totalPages: totalPgs,
                                        onPrevious: () {
                                          setState(() {
                                            currentPage--;
                                            loadCustomer();
                                          });
                                        },
                                        onNext: () {
                                          setState(() {
                                            currentPage++;
                                            loadCustomer();
                                          });
                                        },
                                        onJumpToPage: (page) {
                                          setState(() {
                                            currentPage = page;
                                            loadCustomer();
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
                    ),
                  ),
                );
              },
            ),

            //slider zoom
            SliderZoom(
              zoomLevel: _zoomLevel,
              buttonColor: themeController.buttonColor.value,
              onZoomChanged: _updateZoom,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadCustomer(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
