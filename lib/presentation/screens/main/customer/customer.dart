import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_cus_or_prod.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_customer.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/customer_data_source.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Future<Map<String, dynamic>> futureCustomer;
  late List<GridColumn> columns;

  // Controllers
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final TextEditingController searchController = TextEditingController();

  // Search & Filter
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Khách Hàng": "customerId",
    "Tên Khách Hàng": "customerName",
    "Theo CSKH": "cskh",
    "Theo SDT": "phone",
    "Ngày Tạo": "createdAt",
  };

  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedCustomerIdNotifier = ValueNotifier<String?>(null);

  // Datasource & Cache
  List<CustomerModel>? _cachedCustomers;
  CustomerDatasource? _cachedDatasource;

  // Date Range & Flags
  DateTime? startDate;
  DateTime? endDate;
  late bool isSale;
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  // Paging
  int currentPage = 1;
  int pageSize = 35;

  @override
  void initState() {
    super.initState();
    isSale = userController.hasPermission(permission: "sale");
    loadCustomer();

    columns = buildCustomerColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: 'customer', columns: columns).then((w) {
      if (mounted) setState(() => columnWidths = w);
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";
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

    _selectedCustomerIdNotifier.value = null;
  }

  void loadCustomer() {
    setState(() => _fetchData());
  }

  void searchCustomer() {
    String keyword = searchController.text.trim().toLowerCase();
    if (isTextFieldEnabled && keyword.isEmpty) return;

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final size = MediaQuery.of(context).size;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      initialDateRange:
          (startDate != null && endDate != null)
              ? DateTimeRange(start: startDate!, end: endDate!)
              : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder:
          (context, child) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.35,
                maxHeight: size.height * 0.8,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: child!,
              ),
            ),
          ),
    );

    if (picked != null) {
      final displayStart = DateFormat("dd/MM/yyyy").format(picked.start);
      final displayEnd = DateFormat("dd/MM/yyyy").format(picked.end);

      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        searchController.text = "$displayStart - $displayEnd";
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _zoomNotifier.dispose();
    _selectedCustomerIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value, // Nền xám nhạt giúp bảng nổi bật
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

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title & buttons
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),

                  //table & pagination
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildTableSection(),
                    ),
                  ),
                ],
              ),
            ),

            // Zoom Control Floating
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: const Offset(73, 152),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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

  Widget _buildHeaderBar() {
    return Column(
      children: [
        Text(
          "DANH SÁCH KHÁCH HÀNG",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            //search
            Expanded(
              flex: 2,
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

                    if (searchType == "Tất cả" && searchController.text.isNotEmpty) {
                      searchController.clear();
                      currentPage = 1;
                      _fetchData();
                    }
                  });
                },
                controller: searchController,
                textFieldEnabled: isTextFieldEnabled,
                buttonColor: themeController.buttonColor,
                onSearch: searchCustomer,
                customInputBuilder: (inputWidth) {
                  if (searchType != 'Ngày Tạo') return null;
                  return SizedBox(
                    width: inputWidth,
                    height: 45,
                    child: InkWell(
                      onTap: _selectDateRange,
                      child: IgnorePointer(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Chọn khoảng thời gian...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: const Icon(Icons.calendar_today, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            //buttons
            if (isSale)
              Expanded(
                flex: 3,
                child: ValueListenableBuilder(
                  valueListenable: _selectedCustomerIdNotifier,
                  builder: (context, selectedCustomerId, _) {
                    final bool hasSelection =
                        selectedCustomerId != null && selectedCustomerId.isNotEmpty;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //export
                        AnimatedButton(
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder: (_) => DialogExportCusOrProd(),
                              ),
                          label: "Xuất Excel",
                          icon: Symbols.export_notes,
                          backgroundColor: themeController.buttonColor,
                        ),
                        const SizedBox(width: 8),

                        //add
                        AnimatedButton(
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder:
                                    (_) => CustomerDialog(
                                      customer: null,
                                      onCustomerAddOrUpdate: loadCustomer,
                                    ),
                              ),
                          label: "Thêm mới",
                          icon: Icons.add,
                          backgroundColor: themeController.buttonColor,
                        ),
                        const SizedBox(width: 8),

                        //update
                        AnimatedButton(
                          onPressed:
                              hasSelection ? () => _handleEditCustomer(selectedCustomerId) : null,
                          label: "Sửa",
                          icon: Symbols.construction,
                          backgroundColor: themeController.buttonColor,
                        ),
                        const SizedBox(width: 8),

                        //delete
                        AnimatedButton(
                          onPressed:
                              hasSelection ? () => _handleDeleteCustomer(selectedCustomerId) : null,
                          label: "Xóa",
                          icon: Icons.delete,
                          backgroundColor: const Color(0xFFEA4346),
                        ),
                        const SizedBox(width: 5),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
      future: futureCustomer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerSkeletonTable(context: context, rowCount: 10);
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }
        if (!snapshot.hasData || (snapshot.data!['customers'] as List).isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có khách hàng nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final customers = data['customers'] as List<CustomerModel>;
        final currentPg = data['currentPage'] as int;
        final totalPgs = data['totalPages'] as int;

        if (_cachedCustomers != customers || _cachedDatasource == null) {
          _cachedCustomers = customers;
          _cachedDatasource = CustomerDatasource(
            customer: customers,
            selectedCustomerId: _selectedCustomerIdNotifier.value,
            currentPage: currentPage,
            pageSize: pageSize,
          );
        }

        return Column(
          children: [
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: SfDataGrid(
                      source: _cachedDatasource!,
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.auto,
                      selectionMode: SelectionMode.single,
                      headerRowHeight: 42,
                      rowHeight: 38,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columns,
                        widths: columnWidths,
                      ),
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
                            tableKey: 'customer',
                            columnWidths: columnWidths,
                            setState: setState,
                          ),
                      onSelectionChanged: (addedRows, _) {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final customerId =
                              selectedRow
                                  .getCells()
                                  .firstWhere((cell) => cell.columnName == 'customerId')
                                  .value
                                  .toString();
                          _selectedCustomerIdNotifier.value = customerId;
                        } else {
                          _selectedCustomerIdNotifier.value = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious:
                  () => setState(() {
                    currentPage--;
                    loadCustomer();
                  }),
              onNext:
                  () => setState(() {
                    currentPage++;
                    loadCustomer();
                  }),
              onJumpToPage:
                  (page) => setState(() {
                    currentPage = page;
                    loadCustomer();
                  }),
            ),
          ],
        );
      },
    );
  }

  // ==================== ACTION HANDLERS ====================

  Future<void> _handleEditCustomer(String customerId) async {
    try {
      final customersData = await futureCustomer;
      final customerList = (customersData['customers'] as List? ?? []).cast<CustomerModel>();
      final selectedCustomer = customerList.firstWhere(
        (c) => c.customerId == customerId,
        orElse: () => throw Exception("Không tìm thấy khách hàng"),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => CustomerDialog(customer: selectedCustomer, onCustomerAddOrUpdate: loadCustomer),
      );
    } catch (e, s) {
      AppLogger.e("Error in _handleEditCustomer: $e", stackTrace: s);
      if (mounted) {
        showSnackBarError(context, 'Có lỗi xảy ra, vui lòng thử lại sau');
      }
    }
  }

  Future<void> _handleDeleteCustomer(String customerId) async {
    await showDeleteConfirmHelper(
      context: context,
      title: "⚠️ Xác nhận xoá",
      content: "Bạn có chắc chắn muốn xoá khách hàng này?",
      onDelete: () async {
        await CustomerService().deleteCustomer(customerId: customerId);
      },
      onSuccess: () {
        _selectedCustomerIdNotifier.value = null;
        loadCustomer();
      },
    );
  }
}
