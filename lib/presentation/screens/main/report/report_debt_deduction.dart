import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/presentation/components/headerTable/debt/header_table_debt_deduction.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/left_button_search.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/components/sources/debt/debt_deduction_data_source.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class ReportDebtDeduction extends StatefulWidget {
  const ReportDebtDeduction({super.key});

  @override
  State<ReportDebtDeduction> createState() => _ReportDebtDeductionState();
}

class _ReportDebtDeductionState extends State<ReportDebtDeduction> {
  late Future<Map<String, dynamic>> futureDebtDeduction;
  late List<GridColumn> columnsDebtDeduction;
  final formatter = DateFormat("dd/MM/yyyy");

  //controller
  final headerScrollController = ScrollController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final searchController = TextEditingController();

  //field search & filter
  String searchType = "Tất cả";
  String selectedStatus = "Đã duyệt";
  final List<String> statusFilterOptions = ["Đã duyệt", "Tất cả", "Bị từ chối"];

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedRequestIdNotifier = ValueNotifier<int?>(null);
  Map<String, double> columnWidths = {};

  //datasource and cache
  DebtDeductionRequestModel? selectedDebtDeduction;
  DebtDeductionDataSource? _cachedDatasource;
  List<DebtDeductionRequestModel>? _cachedDebtDeduction;

  //flag
  bool isSearching = false;
  bool isTextFieldEnabled = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;

  @override
  void initState() {
    super.initState();
    loadReportDebtDeduction();
    columnsDebtDeduction = buildDebtDeductionColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(
      tableKey: "report_debt_deduction",
      columns: columnsDebtDeduction,
    ).then((w) {
      if (mounted) {
        setState(() {
          columnWidths = w;
        });
      }
    });
  }

  List<String> _resolveApiStatus() {
    switch (selectedStatus) {
      case "Đã duyệt":
        return ["approved"];
      case "Bị từ chối":
        return ["rejected"];
      case "Tất cả":
      default:
        return ["approved", "rejected", "pending"];
    }
  }

  void _fetchData() {
    final String keyword = searchController.text.trim();
    final bool shouldSearchCustomer = (searchType == "Mã Khách Hàng" && keyword.isNotEmpty);

    futureDebtDeduction = ensureMinLoading(
      DebtService().getDebtDeductionRequests(
        page: currentPage,
        pageSize: pageSize,
        status: _resolveApiStatus(),
        customerId: shouldSearchCustomer ? keyword : null,
      ),
    );
    _selectedRequestIdNotifier.value = null;
    selectedDebtDeduction = null;
  }

  void loadReportDebtDeduction() {
    setState(() => _fetchData());
  }

  void searchDebtDeduction() {
    final String keyword = searchController.text.trim();
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

  @override
  void dispose() {
    _zoomNotifier.dispose();
    searchController.dispose();
    _selectedRequestIdNotifier.dispose();
    headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
      body: Listener(
        onPointerSignal: (pointerSignal) => handleScrollZoom(
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
                  Container(padding: const EdgeInsets.all(12), child: _buildHeaderBar()),
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
        onPressed: () => loadReportDebtDeduction(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Column(
      children: [
        Text(
          "LỊCH SỬ CẤN TRỪ CÔNG NỢ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: headerScrollController,
              child: SingleChildScrollView(
                controller: headerScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cụm tìm kiếm + Lọc trạng thái
                      LeftButtonSearch(
                        selectedType: searchType,
                        types: const ["Tất cả", "Mã Khách Hàng"],
                        hintText: "Nhập mã khách hàng...",
                        onTypeChanged: (value) {
                          setState(() {
                            searchType = value;
                            isTextFieldEnabled = (searchType != "Tất cả");
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
                        onSearch: searchDebtDeduction,
                        extraWidgets: [
                          Container(
                            height: 45,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedStatus,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                items: statusFilterOptions.map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(
                                      status == "Tất cả" ? "Tất cả trạng thái" : status,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null && value != selectedStatus) {
                                    setState(() {
                                      selectedStatus = value;
                                      currentPage = 1;
                                      _fetchData();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Cụm nút hành động
                      ValueListenableBuilder(
                        valueListenable: _selectedRequestIdNotifier,
                        builder: (context, selectedRequestId, _) {
                          final bool hasSelection = selectedRequestId != null && selectedDebtDeduction != null;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedButton(
                                onPressed: hasSelection ? () => _showDetailDialog(selectedDebtDeduction!) : null,
                                label: "Xem Chi Tiết",
                                icon: Symbols.visibility,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 5),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
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
      future: futureDebtDeduction,
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
        } else if (!snapshot.hasData || (snapshot.data!["debtDeductions"] as List).isEmpty) {
          return Container(
            color: themeController.backgroundColor.value,
            child: const Center(
              child: Text(
                "Không có dữ liệu lịch sử",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final debtDeductions = (data["debtDeductions"] as List).cast<DebtDeductionRequestModel>();
        final currentPg = data["currentPage"] ?? 1;
        final totalPgs = data["totalPages"] ?? 1;

        if (_cachedDebtDeduction != debtDeductions || _cachedDatasource == null) {
          _cachedDebtDeduction = debtDeductions;
          _cachedDatasource = DebtDeductionDataSource(
            debtDeductions: debtDeductions,
            currentPage: currentPage,
            pageSize: pageSize,
            selectedRequestId: _selectedRequestIdNotifier.value,
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
                      headerRowHeight: 30,
                      rowHeight: 40,
                      columns: ColumnWidthTable.applySavedWidths(
                        columns: columnsDebtDeduction,
                        widths: columnWidths,
                      ),
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResize,
                      onColumnResizeStart: GridResizeHelper.onResizeStart,
                      onColumnResizeUpdate: (details) => GridResizeHelper.onResizeUpdate(
                        details: details,
                        columns: columnsDebtDeduction,
                        setState: localSetState,
                      ),
                      onColumnResizeEnd: (details) => GridResizeHelper.onResizeEnd(
                        details: details,
                        tableKey: "report_debt_deduction",
                        columnWidths: columnWidths,
                        setState: setState,
                      ),
                      onSelectionChanged: (addedRows, removedRows) async {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final requestId = selectedRow
                              .getCells()
                              .firstWhere((cell) => cell.columnName == "requestId")
                              .value as int?;

                          _selectedRequestIdNotifier.value = requestId;
                          try {
                            selectedDebtDeduction = _cachedDebtDeduction?.firstWhere(
                              (item) => item.requestId == requestId,
                            );
                          } catch (_) {
                            selectedDebtDeduction = null;
                          }
                        } else {
                          _selectedRequestIdNotifier.value = null;
                          selectedDebtDeduction = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            PaginationControls(
              currentPage: currentPg,
              totalPages: totalPgs,
              onPrevious: () {
                setState(() {
                  currentPage--;
                  loadReportDebtDeduction();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadReportDebtDeduction();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadReportDebtDeduction();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showDetailDialog(DebtDeductionRequestModel req) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const Icon(Symbols.receipt_long, color: Color(0xff1E88E5)),
              const SizedBox(width: 8),
              Text(
                "Chi Tiết Yêu Cầu #${req.requestId}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoLine("Mã khách hàng:", req.customerId),
                _buildInfoLine("Tên khách hàng:", req.Customer?.customerName ?? "-"),
                _buildInfoLine("Tên công ty:", req.Customer?.companyName ?? "-"),
                const Divider(height: 20),
                _buildInfoLine(
                  "Số tiền cấn trừ:",
                  "${NumberFormat("#,###", "vi_VN").format(req.amountRequested)} đ",
                  isBold: true,
                  valueColor: const Color(0xFF2E7D32),
                ),
                _buildInfoLine("Kiểu thanh toán:", req.paymentMethod),
                _buildInfoLine("Người yêu cầu:", req.requestedBy),
                _buildInfoLine("Người duyệt:", req.approvedBy ?? "-"),
                _buildInfoLine(
                  "Ngày tạo:",
                  req.createdAt != null ? formatter.format(req.createdAt!) : "-",
                ),
                _buildInfoLine(
                  "Khẩn cấp:",
                  req.isUrgent ? "Có (Duyệt qua OTP Telegram)" : "Không",
                  valueColor: req.isUrgent ? Colors.red : null,
                ),
                _buildInfoLine(
                  "Trạng thái:",
                  req.status == "approved"
                      ? "Đã duyệt"
                      : req.status == "rejected"
                          ? "Bị từ chối"
                          : "Chờ duyệt",
                  isBold: true,
                  valueColor: req.status == "approved"
                      ? const Color(0xFF2E7D32)
                      : req.status == "rejected"
                          ? Colors.red
                          : Colors.orange,
                ),
                if (req.rejectReason != null && req.rejectReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      "Lý do từ chối: ${req.rejectReason}",
                      style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1E88E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Đóng", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoLine(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
