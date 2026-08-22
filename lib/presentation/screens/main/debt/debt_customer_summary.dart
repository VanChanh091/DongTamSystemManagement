import "dart:io";

import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/payment/customer_debt_summary_model.dart";
import "package:dongtam/presentation/components/dialog/debt/dialog_closing_debt.dart";
import "package:dongtam/presentation/components/dialog/debt/dialog_payment_debt.dart";
import "package:dongtam/presentation/components/headerTable/header_table_debt.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/planning/widgets_planning.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/sources/debt_customer_data_source.dart";
import "package:dongtam/service/customer_service.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/grid_resize_helper.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class DebtCustomerSummary extends StatefulWidget {
  const DebtCustomerSummary({super.key});

  @override
  State<DebtCustomerSummary> createState() => _DebtCustomerSummaryState();
}

class _DebtCustomerSummaryState extends State<DebtCustomerSummary> {
  late Future<Map<String, dynamic>> futureDebtSummary;
  late List<GridColumn> columnsDebt;

  //controller
  final headerScrollController = ScrollController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //field search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {};

  //sales user filter
  String selectedSalesUser = "Tất cả";
  String? selectedUserId;
  List<String> salesUserItems = ["Tất cả"];
  Map<String, String?> salesUserMap = {"Tất cả": null};

  //cached grand totals for smooth animated count transitions
  double _lastTotalDebt = 0;
  double _lastDueDebt = 0;
  double _lastNotDueDebt = 0;

  //width column
  Map<String, double> columnWidthsDebt = {};

  Map<String, double> columnWidths = {};
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedDebtNotifier = ValueNotifier<String?>(null);

  //datasource and cache
  DebtCustomerDataSource? _cachedDatasource;
  CustomerDebtSummaryModel? selectDebtCustomer;
  List<CustomerDebtItemModel>? _cachedDataSourceList;

  //text controller
  final searchController = TextEditingController();
  final slipCodeController = TextEditingController();

  //flag
  bool isSearching = false; //dùng để phân trang cho tìm kiếm
  late bool isManager;
  late bool isAccountant;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();

    isManager = userController.hasAnyRole(roles: ["admin", "manager"]);
    isAccountant = userController.hasPermission(permission: "accountant");

    _loadSalesUsers();
    loadOutbound();

    columnsDebt = buildDebtColumn(themeController: themeController);
    ColumnWidthTable.loadWidths(tableKey: "debtCustomer", columns: columnsDebt).then((w) {
      setState(() {
        columnWidthsDebt = w;
      });
    });
  }

  String _getShortName(String fullName) {
    // Tách chuỗi theo khoảng trắng
    final parts = fullName.trim().split(RegExp(r"\s+"));

    // Nếu tên chỉ có 1 hoặc 2 từ thì giữ nguyên
    if (parts.length <= 2) {
      return fullName.trim();
    }

    // Lấy 2 từ cuối cùng và ghép lại
    return parts.sublist(parts.length - 2).join(" ");
  }

  Future<void> _loadSalesUsers() async {
    try {
      final users = await CustomerService().getUserSales();

      if (mounted) {
        setState(() {
          final Map<String, String?> newMap = {"Tất cả": null};
          final List<String> newItems = ["Tất cả"];

          for (final user in users) {
            final name = user.fullName?.trim();
            if (name != null && name.isNotEmpty) {
              final shortName = _getShortName(name);

              // Nếu tên chưa có trong danh sách thì mới thêm vào
              if (!newMap.containsKey(shortName)) {
                newItems.add(shortName);
                newMap[shortName] = user.userId.toString();
              }
            }
          }

          salesUserMap = newMap;
          salesUserItems = newItems;
        });
      }
    } catch (e, s) {
      AppLogger.e("Lỗi tải danh sách nhân viên sale: $e", error: e, stackTrace: s);
    }
  }

  void _fetchData() {
    futureDebtSummary = ensureMinLoading(
      DebtService().getCustomerDebtSummary(
        page: currentPage,
        pageSize: pageSize,
        userId: selectedUserId,
      ),
    );

    _selectedDebtNotifier.value = null;
  }

  void loadOutbound() {
    setState(() => _fetchData());
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    slipCodeController.dispose();
    _zoomNotifier.dispose();
    _selectedDebtNotifier.dispose();
    headerScrollController.dispose();
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

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  // initialMargin: Offset(73, 125),
                  initialMargin: Offset(73, 152),
                  buttonColor: themeController.buttonColor.value,
                );
              },
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

  Widget _buildHeaderBar() {
    return Column(
      children: [
        //title
        Text(
          "DANH SÁCH CÔNG NỢ KHÁCH HÀNG",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 10),

        //button
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //left button
                          const SizedBox(),
                          const SizedBox(width: 20),

                          //right button
                          ValueListenableBuilder(
                            valueListenable: _selectedDebtNotifier,
                            builder: (context, selectedOutboundId, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedButton(
                                    onPressed: () async {
                                      final bool success = await showConfirmDialog(
                                        context: context,
                                        title: "Xuất file công nợ khách hàng",
                                        content:
                                            "Bạn có chắc chắn muốn xuất file công nợ khách hàng không?",
                                        confirmText: "Xác Nhận",
                                      );

                                      if (success) {
                                        final File? file = await DebtService().exportDebtCustomer();

                                        if (context.mounted) {
                                          if (file != null) {
                                            showSnackBarSuccess(
                                              context,
                                              "Xuất file công nợ khách hàng thành công",
                                            );
                                          } else {
                                            showSnackBarError(
                                              context,
                                              "Xuất file công nợ khách hàng thất bại",
                                            );
                                          }
                                        }
                                      }
                                    },
                                    label: "Xuất Excel",
                                    icon: Symbols.file_download,
                                    backgroundColor: themeController.buttonColor,
                                  ),
                                  const SizedBox(width: 8),

                                  //closing debt
                                  if (isAccountant) ...[
                                    AnimatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => DialogClosingDebt(
                                                customerId: _selectedDebtNotifier.value,
                                                onClosingSuccess: () {
                                                  loadOutbound();
                                                },
                                              ),
                                        );
                                      },
                                      label: "Chốt Công Nợ",
                                      icon: Symbols.attach_money,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 8),

                                    //payment
                                    AnimatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => DialogPaymentDebt(
                                                customerId: _selectedDebtNotifier.value,
                                                onPaymentSuccess: () {
                                                  loadOutbound();
                                                },
                                              ),
                                        );
                                      },
                                      label: "Thanh Toán",
                                      icon: Symbols.payment,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 8),
                                  ],

                                  if (isManager) ...[
                                    buildDropdownItems(
                                      value:
                                          salesUserItems.contains(selectedSalesUser)
                                              ? selectedSalesUser
                                              : salesUserItems.first,
                                      items: salesUserItems,
                                      width: 160,
                                      onChanged: (value) {
                                        if (value != null && value != selectedSalesUser) {
                                          setState(() {
                                            selectedSalesUser = value;
                                            selectedUserId = salesUserMap[value];
                                            currentPage = 1;
                                            loadOutbound();
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    //grand total price
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: futureDebtSummary,
                        builder: (context, snapshot) {
                          final isLoading = snapshot.connectionState == ConnectionState.waiting;

                          if (snapshot.hasData) {
                            final grandTotalRaw =
                                snapshot.data?["grandTotal"] as Map<String, dynamic>?;
                            final grandTotal =
                                grandTotalRaw != null
                                    ? CustomerDebtItemModel.fromJson(grandTotalRaw)
                                    : null;

                            _lastTotalDebt = grandTotal?.totalDebt ?? 0;
                            _lastDueDebt = grandTotal?.overdueDebt ?? 0;
                            _lastNotDueDebt = grandTotal?.notDueDebt ?? 0;
                          }

                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: isLoading ? 0.4 : 1.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Nợ trong hạn: ",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildAnimatedCounter(
                                  targetValue: _lastNotDueDebt,
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
                                const Text(
                                  "Nợ đến hạn: ",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildAnimatedCounter(
                                  targetValue: _lastDueDebt,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.red.shade600,
                                  ),
                                ),

                                const Text(
                                  " – ",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text(
                                  "Tổng nợ: ",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildAnimatedCounter(
                                  targetValue: _lastTotalDebt,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableSection() {
    return FutureBuilder(
      future: futureDebtSummary,
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
        } else if (!snapshot.hasData || snapshot.data!["debts"].isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: Center(
              child: Text(
                "Không có phiếu xuất kho nào",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final debts = data["debts"] as List<CustomerDebtItemModel>;
        final currentPg = data["currentPage"];
        final totalPgs = data["totalPages"];

        // totalPriceByDate = data["totalPriceByDate"] as Map<String, dynamic>;
        // grandTotal = data["grandTotal"] as Map<String, dynamic>;

        if (_cachedDataSourceList != debts || _cachedDatasource != null) {
          _cachedDataSourceList = debts;
          _cachedDatasource = DebtCustomerDataSource(
            customers: debts,
            currentPage: currentPg,
            pageSize: pageSize,
          );
        }

        return Column(
          children: [
            //table
            Expanded(
              child: StatefulBuilder(
                builder: (context, localSetState) {
                  return SfDataGridTheme(
                    data: SfDataGridThemeData(selectionColor: Colors.blue.withValues(alpha: 0.3)),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SfDataGrid(
                            source: _cachedDatasource!,
                            isScrollbarAlwaysShown: true,
                            columnWidthMode: ColumnWidthMode.auto,
                            selectionMode: SelectionMode.single,
                            headerRowHeight: 30,
                            rowHeight: 40,
                            columns: ColumnWidthTable.applySavedWidths(
                              columns: columnsDebt,
                              widths: columnWidthsDebt,
                            ),
                            stackedHeaderRows: <StackedHeaderRow>[
                              StackedHeaderRow(
                                cells: [
                                  StackedHeaderCell(
                                    columnNames: [
                                      "notDueDebt",
                                      "currentPeriodDebt",
                                      "closedDebt",
                                      "dueIn1_3",
                                    ],
                                    child: Obx(
                                      () => formatColumn(
                                        label: "Nợ Trong Hạn (VNĐ)",
                                        themeController: themeController,
                                      ),
                                    ),
                                  ),
                                  StackedHeaderCell(
                                    columnNames: [
                                      "overdue1_30",
                                      "overdue31_60",
                                      "overdue61_90",
                                      "overdue91_120",
                                      "overdueOver120",
                                      "overdueDebt",
                                    ],
                                    child: Obx(
                                      () => formatColumn(
                                        label: "Nợ Quá Hạn (VNĐ)",
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
                                  columns: columnsDebt,
                                  setState: localSetState,
                                ),
                            onColumnResizeEnd:
                                (details) => GridResizeHelper.onResizeEnd(
                                  details: details,
                                  tableKey: "debtCustomer",
                                  columnWidths: columnWidthsDebt,
                                  setState: setState,
                                ),

                            onSelectionChanged: (addedRows, removedRows) {
                              if (addedRows.isNotEmpty) {
                                final selectedRow = addedRows.first;
                                final custIdCell = selectedRow.getCells().firstWhere(
                                  (cell) => cell.columnName == "customerId",
                                );
                                _selectedDebtNotifier.value = custIdCell.value?.toString();
                              } else {
                                _selectedDebtNotifier.value = null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
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
    );
  }

  //helper animation
  Widget _buildAnimatedCounter({required num targetValue, required TextStyle style}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetValue.toDouble()),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(OrderModel.formatCurrency(value), style: style);
      },
    );
  }
}
