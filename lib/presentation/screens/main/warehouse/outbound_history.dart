import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/presentation/components/dialog/add/dialog_add_outbound.dart';
import 'package:dongtam/presentation/components/dialog/export/dialog_export_outbound.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/outbound/header_table_ob_detail.dart';
import 'package:dongtam/presentation/components/headerTable/warehouse/outbound/header_table_ob_history.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/sources/warehouse/outbound/ob_detail_data_source.dart';
import 'package:dongtam/presentation/sources/warehouse/outbound/ob_history_data_source.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OutboundHistory extends StatefulWidget {
  const OutboundHistory({super.key});

  @override
  State<OutboundHistory> createState() => _OutboundHistoryState();
}

class _OutboundHistoryState extends State<OutboundHistory> {
  late Future<Map<String, dynamic>> futureOutbound;
  late ObHistoryDataSource obHistoryDataSource;
  late List<GridColumn> columnsOutbound;
  late List<GridColumn> columnsObDetail;

  //controller
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //width column
  Map<String, double> columnWidthsOutbound = {};
  Map<String, double> columnWidthsObDetail = {};
  List<OutboundDetailModel> selectedObDetail = [];

  int? selectedOutboundId;
  OutboundHistoryModel? selectOutbound;

  //field search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Tên Khách Hàng": "customerName",
    "Ngày Xuất Kho": "dateOutbound",
  };

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //flag
  bool selectedAll = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  bool isTextFieldEnabled = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadOutbound();

    columnsOutbound = buildOutboundHistoryColumn(themeController: themeController);
    columnsObDetail = buildOutboundDetailColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'outbound', columns: columnsOutbound).then((w) {
      setState(() {
        columnWidthsOutbound = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'obDetail', columns: columnsObDetail).then((w) {
      setState(() {
        columnWidthsObDetail = w;
      });
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";
    final bool isDateSearch = searchType == "Ngày Xuất Kho";

    futureOutbound = ensureMinLoading(
      WarehouseService().getOutboundHistory(
        page: currentPage,
        pageSize: pageSize,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
        startDate: (shouldSearch && isDateSearch) ? startDate : null,
        endDate: (shouldSearch && isDateSearch) ? endDate : null,
      ),
    );

    selectedOutboundId = null;
    selectedObDetail = [];
  }

  void loadOutbound() {
    setState(() => _fetchData());
  }

  void searchOutbound() {
    String keyword = searchController.text.trim().toLowerCase();
    final bool isDateSearch = searchType == "Ngày Xuất Kho";

    if (isDateSearch) {
      if (startDate == null || endDate == null) {
        AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
        return;
      }
    } else if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchOutbound: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  bool canExecuteAction({required int? outboundId, required OutboundHistoryModel selectOutbound}) {
    if (outboundId == null) return false;

    if (userController.role.value == 'admin' || userController.role.value == 'manager') return true;

    final dateOutbound = selectOutbound.dateOutbound;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completionDate = DateTime(dateOutbound.year, dateOutbound.month, dateOutbound.day);

    if (today.isAfter(completionDate)) return false;

    return true;
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccountant = userController.hasPermission(permission: "accountant");
    bool isEdit =
        selectedOutboundId != null &&
        canExecuteAction(outboundId: selectedOutboundId, selectOutbound: selectOutbound!);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
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
                        "XUẤT KHO",
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
                            types: const ['Tất cả', "Tên Khách Hàng", "Ngày Xuất Kho"],
                            onTypeChanged: (value) {
                              setState(() {
                                searchType = value;
                                isTextFieldEnabled = searchType != 'Tất cả';

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
                            onSearch: () => searchOutbound(),
                            customInputBuilder: (inputWidth) {
                              if (searchType != 'Ngày Xuất Kho') return null;

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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export pdf
                                handleExportFile(),
                                const SizedBox(width: 10),

                                //export excel
                                isAccountant
                                    ? Row(
                                      children: [
                                        AnimatedButton(
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => DialogExportOutbound(
                                                    onLoading: () => loadOutbound(),
                                                  ),
                                            );
                                          },
                                          label: "Xuất Excel",
                                          icon: Symbols.file_download,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //update
                                        AnimatedButton(
                                          onPressed:
                                              isEdit
                                                  ? () async {
                                                    try {
                                                      final data = await futureOutbound;
                                                      final orders =
                                                          data['outbounds']
                                                              as List<OutboundHistoryModel>;
                                                      final selectedOutbound = orders.firstWhere(
                                                        (order) =>
                                                            order.outboundId == selectedOutboundId,
                                                      );

                                                      if (!context.mounted) return;

                                                      showDialog(
                                                        barrierDismissible: false,
                                                        context: context,
                                                        builder:
                                                            (_) => OutBoundDialog(
                                                              outbound: selectedOutbound,
                                                              onOutboundHistory:
                                                                  () => loadOutbound(),
                                                            ),
                                                      );
                                                    } catch (e, s) {
                                                      AppLogger.e(
                                                        "Lỗi không tìm thấy phiếu xuất kho",
                                                        error: e,
                                                        stackTrace: s,
                                                      );
                                                    }
                                                  }
                                                  : null,
                                          label: "Sửa Phiếu",
                                          icon: Symbols.construction,
                                          backgroundColor: themeController.buttonColor,
                                        ),
                                        const SizedBox(width: 10),

                                        //delete
                                        AnimatedButton(
                                          onPressed:
                                              isEdit
                                                  ? () async {
                                                    await showDeleteConfirmHelper(
                                                      context: context,
                                                      title: "⚠️ Xác nhận xoá",
                                                      content:
                                                          "Bạn có chắc chắn muốn hủy phiếu xuất kho này?",
                                                      onDelete: () async {
                                                        await WarehouseService().deleteOutbound(
                                                          outboundId: selectedOutboundId!,
                                                        );
                                                      },
                                                      onSuccess: () {
                                                        setState(() => selectedOutboundId = null);
                                                        loadOutbound();
                                                      },
                                                    );
                                                  }
                                                  : null,
                                          label: "Hủy Phiếu",
                                          icon: Icons.delete,
                                          backgroundColor: const Color(0xffEA4346),
                                        ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),
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
                future: futureOutbound,
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
                  } else if (!snapshot.hasData || snapshot.data!['outbounds'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final outbounds = data['outbounds'] as List<OutboundHistoryModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  final totalPriceByDate = data['totalPriceByDate'] as Map<String, dynamic>;
                  final grandTotal = data['grandTotal'] as Map<String, dynamic>;

                  obHistoryDataSource = ObHistoryDataSource(
                    outbounds: outbounds,
                    selectedOutboundId: selectedOutboundId,
                    currentPage: currentPage,
                    pageSize: pageSize,
                    totalPriceByDate: totalPriceByDate,
                  );

                  return Column(
                    children: [
                      //grand total price
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Tổng tiền hàng
                            const Text(
                              "Tiền hàng: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              Order.formatCurrency(grandTotal['totalPriceOrder']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.green.shade600,
                              ),
                            ),

                            const Text(
                              " – ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),

                            // Tiền VAT
                            const Text(
                              "VAT: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              Order.formatCurrency(grandTotal['totalPriceVAT']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.amber.shade800,
                              ),
                            ),

                            const Text(
                              " – ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),

                            // Tổng thanh toán
                            const Text(
                              "Tổng: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              Order.formatCurrency(grandTotal['totalPricePayment']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      //table
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SfDataGrid(
                                source: obHistoryDataSource,
                                isScrollbarAlwaysShown: true,
                                columnWidthMode: ColumnWidthMode.auto,
                                selectionMode: SelectionMode.single,
                                headerRowHeight: 30,
                                rowHeight: 40,
                                columns: ColumnWidthTable.applySavedWidths(
                                  columns: columnsOutbound,
                                  widths: columnWidthsOutbound,
                                ),
                                stackedHeaderRows: <StackedHeaderRow>[
                                  StackedHeaderRow(
                                    cells: [
                                      StackedHeaderCell(
                                        columnNames: [
                                          "totalPriceOrder",
                                          "totalPriceVAT",
                                          "totalPricePayment",
                                          "paidAmount",
                                          "remainingAmount",
                                        ],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Tổng Tiền (VNĐ)',
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
                                      columns: columnsOutbound,
                                      setState: setState,
                                    ),
                                onColumnResizeEnd:
                                    (details) => GridResizeHelper.onResizeEnd(
                                      details: details,
                                      tableKey: 'outbound',
                                      columnWidths: columnWidthsOutbound,
                                      setState: setState,
                                    ),

                                onSelectionChanged: (addedRows, removedRows) async {
                                  if (addedRows.isEmpty) {
                                    setState(() {
                                      selectedOutboundId = null;
                                    });
                                    return;
                                  }

                                  final selectedRow = addedRows.first;

                                  final outboundId =
                                      selectedRow
                                          .getCells()
                                          .firstWhere((cell) => cell.columnName == 'outboundId')
                                          .value;

                                  // Lấy data của list (summary)
                                  final selectedOutbound = outbounds.firstWhere(
                                    (ob) => ob.outboundId == outboundId,
                                  );

                                  setState(() {
                                    selectedOutboundId = selectedOutbound.outboundId;
                                    selectOutbound = selectedOutbound;
                                  });

                                  final detail = await WarehouseService().getOutboundDetail(
                                    outboundId: selectedOutbound.outboundId,
                                  );

                                  setState(() {
                                    selectedObDetail = detail;
                                  });
                                },
                              ),
                            ),

                            selectedObDetail.isNotEmpty
                                ? Expanded(
                                  flex: 1,
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: SfDataGrid(
                                      source: ObDetailDataSource(detail: selectedObDetail),
                                      isScrollbarAlwaysShown: true,
                                      headerRowHeight: 30,
                                      rowHeight: 35,
                                      columnWidthMode: ColumnWidthMode.fill,
                                      selectionMode: SelectionMode.single,
                                      columns: ColumnWidthTable.applySavedWidths(
                                        columns: columnsObDetail,
                                        widths: columnWidthsObDetail,
                                      ),

                                      //auto resize
                                      allowColumnsResizing: true,
                                      columnResizeMode: ColumnResizeMode.onResize,

                                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                                      onColumnResizeUpdate:
                                          (details) => GridResizeHelper.onResizeUpdate(
                                            details: details,
                                            columns: columnsObDetail,
                                            setState: setState,
                                          ),
                                      onColumnResizeEnd:
                                          (details) => GridResizeHelper.onResizeEnd(
                                            details: details,
                                            tableKey: 'obDetail',
                                            columnWidths: columnWidthsObDetail,
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
                            loadOutbound();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadOutbound();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadOutbound();
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
        onPressed: () => loadOutbound(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget handleExportFile() {
    final bool canAction = userController.hasAnyPermission(permission: ["accountant", "sale"]);
    bool isButtonDisabled = selectedOutboundId == null;

    return Stack(
      alignment: Alignment.center,
      children: [
        PopupMenuButton<String>(
          color: Colors.white,
          position: PopupMenuPosition.under,
          enabled: !isButtonDisabled,
          offset: const Offset(35, 5),
          onSelected: (value) async {
            bool hasMoney = (value == "hasMoney");

            final confirm = await showConfirmDialog(
              context: context,
              title: "Lập phiếu xuất kho",
              content: "Bạn muốn lập phiếu xuất kho cho đơn này?",
              confirmText: "Xác Nhận",
              confirmColor: const Color(0xffEA4346),
            );

            if (confirm == true && context.mounted) {
              final file = await WarehouseService().exportFilePDFOutbound(
                outboundId: selectedOutboundId!,
                hasMoney: hasMoney,
              );

              // 4. Xử lý kết quả trả về
              if (mounted) {
                if (file != null) {
                  showSnackBarSuccess(context, "Lập phiếu xuất kho thành công");
                } else {
                  showSnackBarError(context, "Lập phiếu xuất kho thất bại");
                }
              }
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: "hasMoney",
                  enabled: canAction,
                  child: ListTile(
                    leading: Icon(Symbols.attach_money, color: Colors.green),
                    title: Text(
                      "Có Tiền",
                      style: TextStyle(color: canAction ? Colors.black87 : Colors.grey),
                    ),
                    subtitle:
                        !canAction
                            ? const Text("Chỉ dành cho kế toán", style: TextStyle(fontSize: 10))
                            : null,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "noMoney",
                  child: ListTile(
                    leading: Icon(Symbols.do_not_disturb, color: Colors.blue),
                    title: Text("Không có tiền"),
                  ),
                ),
              ],
          child: ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (isButtonDisabled) {
                  return Colors.grey.shade300;
                }
                return themeController.buttonColor.value;
              }),
              foregroundColor: WidgetStateProperty.all<Color>(
                isButtonDisabled ? Colors.white70 : Colors.white,
              ),
              padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save),
                const SizedBox(width: 4),
                Text(
                  "Xuất Phiếu",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isButtonDisabled ? Colors.grey.shade500 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
