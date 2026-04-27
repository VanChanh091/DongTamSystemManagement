import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_cus_or_prod.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_customer.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/customer_data_source.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
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
    "Ngày Tạo": "dayCreated",
  };

  String? selectedCustomerId;
  Map<String, double> columnWidths = {}; //map header table

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 25;

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
    final String date = dateController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";
    String apiKeyword = searchType == "Ngày Tạo" ? date : keyword;

    futureCustomer = ensureMinLoading(
      CustomerService().getCustomers(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? apiKeyword : null,
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
  Widget build(BuildContext context) {
    final bool isSale = userController.hasPermission(permission: "sale");

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
                                searchType == 'Tất cả' ? searchController.clear() : null;
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

                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: now,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2100),
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.blue,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                            dialogTheme: DialogThemeData(
                                              backgroundColor: Colors.white12,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (picked != null) {
                                      final displayDate = DateFormat('dd/MM/yyyy').format(picked);

                                      setState(() {
                                        dateController.text =
                                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

                                        searchController.text = displayDate;
                                      });
                                    }
                                  },
                                  child: IgnorePointer(
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Chọn ngày...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        suffixIcon: const Icon(Icons.calendar_today),
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
                                              builder: (_) => DialogExportCusOrProd(),
                                            );
                                          },
                                          label: "Xuất Excel",
                                          icon: Symbols.export_notes,
                                          backgroundColor: themeController.buttonColor,
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
                                                    onCustomerAddOrUpdate: () => loadCustomer(),
                                                  ),
                                            );
                                          },
                                          label: "Thêm mới",
                                          icon: Icons.add,
                                          backgroundColor: themeController.buttonColor,
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
                                                      final customersData = await futureCustomer;
                                                      final List<Customer> customerList =
                                                          (customersData['customers'] as List? ??
                                                                  [])
                                                              .cast<Customer>();
                                                      final selectedCustomer = customerList
                                                          .firstWhere(
                                                            (customer) =>
                                                                customer.customerId ==
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
                                                                customer: selectedCustomer,
                                                                onCustomerAddOrUpdate:
                                                                    () => loadCustomer(),
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
                                          backgroundColor: themeController.buttonColor,
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
                                                        await CustomerService().deleteCustomer(
                                                          customerId: selectedCustomerId!,
                                                        );
                                                      },
                                                      onSuccess: () {
                                                        setState(() => selectedCustomerId = null);
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
                        child: buildShimmerSkeletonTable(context: context, rowCount: 10),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!['customers'].isEmpty) {
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
                          // allowColumnsDragging: true,
                          // onColumnDragging: (DataGridColumnDragDetails details) {
                          //   if (details.action == DataGridColumnDragAction.dropping &&
                          //       details.to != null) {
                          //     setState(() {
                          //       final GridColumn dragColumn = columns[details.from];
                          //       columns[details.from] = columns[details.to!];
                          //       columns[details.to!] = dragColumn;

                          //       customerDatasource.buildDataGridRows();
                          //     });
                          //   }
                          //   return true;
                          // },
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
                                      .firstWhere((cell) => cell.columnName == 'customerId')
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadCustomer(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
