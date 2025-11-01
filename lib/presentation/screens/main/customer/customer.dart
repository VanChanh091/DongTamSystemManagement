import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/presentation/components/dialog/dialog_add_customer.dart';
import 'package:dongtam/presentation/components/dialog/dialog_export_cus_or_prod.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_customer.dart';
import 'package:dongtam/presentation/sources/customer_data_source.dart';
import 'package:dongtam/service/customer_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:get/get.dart';
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
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final Map<String, String> searchFieldMap = {
    "Theo Mã": "customerId",
    "Theo Tên KH": "customerName",
    "Theo CSKH": "cskh",
    "Theo SDT": "phone",
  };

  TextEditingController searchController = TextEditingController();
  Map<String, double> columnWidths = {}; //map header table
  bool selectedAll = false;
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  String searchType = "Tất cả";
  String? selectedCustomerId;

  int currentPage = 1;
  int pageSize = 30;
  int pageSizeSearch = 20;

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

  void loadCustomer() {
    setState(() {
      final String selectedField = searchFieldMap[searchType] ?? "";

      String keyword = searchController.text.trim().toLowerCase();

      if (isSearching && searchType != "Tất cả") {
        AppLogger.i("loadCustomer: isSearching=true, keyword='$keyword'");

        futureCustomer = ensureMinLoading(
          CustomerService().getCustomerByField(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      } else {
        futureCustomer = ensureMinLoading(
          CustomerService().getAllCustomers(page: currentPage, pageSize: pageSize),
        );
      }

      selectedCustomerId = null;
    });
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

      if (searchType == "Tất cả") {
        futureCustomer = ensureMinLoading(
          CustomerService().getAllCustomers(page: currentPage, pageSize: pageSize),
        );
      } else {
        final selectedField = searchFieldMap[searchType] ?? "";

        futureCustomer = ensureMinLoading(
          CustomerService().getCustomerByField(
            field: selectedField,
            keyword: keyword,
            page: currentPage,
            pageSize: pageSizeSearch,
          ),
        );
      }
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth;
                                final dropdownWidth = (maxWidth * 0.2).clamp(120.0, 170.0);
                                final textInputWidth = (maxWidth * 0.3).clamp(200.0, 250.0);

                                return Row(
                                  children: [
                                    //dropdown
                                    SizedBox(
                                      width: dropdownWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: searchType,
                                        items:
                                            [
                                              'Tất cả',
                                              "Theo Mã",
                                              "Theo Tên KH",
                                              "Theo CSKH",
                                              "Theo SDT",
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            searchType = value!;
                                            isTextFieldEnabled = searchType != 'Tất cả';

                                            searchController.clear();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    //input
                                    SizedBox(
                                      width: textInputWidth,
                                      height: 50,
                                      child: TextField(
                                        controller: searchController,
                                        enabled: isTextFieldEnabled,
                                        onSubmitted: (_) => searchCustomer(),
                                        decoration: InputDecoration(
                                          hintText: 'Tìm kiếm...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    //find
                                    AnimatedButton(
                                      onPressed: () {
                                        searchCustomer();
                                      },
                                      label: "Tìm kiếm",
                                      icon: Icons.search,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                  ],
                                );
                              },
                            ),
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
                                              builder:
                                                  (_) => DialogExportCusOrProd(
                                                    onCusOrProd: () => loadCustomer(),
                                                  ),
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
                                              isSale
                                                  ? () async {
                                                    if (selectedCustomerId == null ||
                                                        selectedCustomerId!.isEmpty) {
                                                      showSnackBarError(
                                                        context,
                                                        'Vui lòng chọn khách hàng cần sửa',
                                                      );
                                                      return;
                                                    }

                                                    try {
                                                      final result = await CustomerService()
                                                          .getCustomerByField(
                                                            field: 'customerId',
                                                            keyword: selectedCustomerId!,
                                                          );

                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      // Defensive null checks
                                                      if (result['customers'] == null) {
                                                        showSnackBarError(
                                                          context,
                                                          'Dữ liệu trả về không hợp lệ',
                                                        );
                                                        return;
                                                      }

                                                      final customers =
                                                          result['customers'] as List<Customer>? ??
                                                          [];

                                                      if (customers.isEmpty) {
                                                        showSnackBarError(
                                                          context,
                                                          'Không tìm thấy khách hàng',
                                                        );
                                                        return;
                                                      }

                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (_) => CustomerDialog(
                                                              customer: customers.first,
                                                              onCustomerAddOrUpdate:
                                                                  () => loadCustomer(),
                                                            ),
                                                      );
                                                    } catch (e, s) {
                                                      AppLogger.e(
                                                        "Error in getCustomerById: $e",
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

                                        //delete customers
                                        AnimatedButton(
                                          onPressed:
                                              isSale &&
                                                      selectedCustomerId != null &&
                                                      selectedCustomerId!.isNotEmpty
                                                  ? () => _confirmDelete(context)
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

  Future<void> _confirmDelete(BuildContext context) async {
    //show confirm dialog
    final confirm = await showConfirmDialog(
      context: context,
      title: "⚠️ Xác nhận xoá",
      content: "Bạn có chắc chắn muốn xoá khách hàng này?",
      confirmText: "Xoá",
      confirmColor: const Color(0xffEA4346),
    );

    if (!confirm) return;

    //show deleteing dialog
    if (!context.mounted) return;
    showLoadingDialog(context, message: "Đang xoá...");

    try {
      await CustomerService().deleteCustomer(customerId: selectedCustomerId!);
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        selectedCustomerId = null;
      });
      loadCustomer();

      if (!context.mounted) return;

      Navigator.pop(context);
      showSnackBarSuccess(context, "Xoá thành công");
    } catch (e, s) {
      Navigator.pop(context);
      AppLogger.e("Lỗi khi xoá khách hàng", error: e, stackTrace: s);
      showSnackBarError(context, "Không thể xoá khách hàng");
    }
  }
}
