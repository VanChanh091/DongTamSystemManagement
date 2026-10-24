import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/controller/user_controller.dart";
import "package:dongtam/data/models/warehouse/debt_deduction_request_model.dart";
import "package:dongtam/presentation/components/dialog/debt/dialog_debt_deduction.dart";
import "package:dongtam/presentation/components/headerTable/debt/header_table_debt_deduction.dart";
import "package:dongtam/presentation/components/shared/animation/animated_button.dart";
import "package:dongtam/presentation/components/shared/dialog_shared.dart";
import "package:dongtam/presentation/components/shared/grid_resize_helper.dart";
import "package:dongtam/presentation/components/shared/pagination_controls.dart";
import "package:dongtam/presentation/components/shared/slider_zoom.dart";
import "package:dongtam/presentation/components/sources/debt/debt_deduction_data_source.dart";
import "package:dongtam/service/debt_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/helper/skeleton/skeleton_loading.dart";
import "package:dongtam/utils/storage/sharedPreferences/column_width_table.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:intl/intl.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:syncfusion_flutter_core/theme.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class DebtDeductionRequest extends StatefulWidget {
  const DebtDeductionRequest({super.key});

  @override
  State<DebtDeductionRequest> createState() => _DebtDeductionRequestState();
}

class _DebtDeductionRequestState extends State<DebtDeductionRequest> {
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

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedRequestIdNotifier = ValueNotifier<int?>(null);
  Map<String, double> columnWidths = {};

  //datasource and cache
  DebtDeductionRequestModel? selectedDebtDeduction;
  DebtDeductionDataSource? _cachedDatasource;
  List<DebtDeductionRequestModel>? _cachedDebtDeduction;

  //flag
  late bool isSale;
  bool isSearching = false;
  bool isTextFieldEnabled = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;

  @override
  void initState() {
    super.initState();
    isSale =
        userController.hasPermission(permission: "sale") ||
        userController.hasAnyRole(roles: ["admin", "manager"]);

    loadDebtDeduction();
    columnsDebtDeduction = buildDebtDeductionColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(
      tableKey: "debt_deduction_request",
      columns: columnsDebtDeduction,
    ).then((w) {
      if (mounted) {
        setState(() {
          columnWidths = w;
        });
      }
    });
  }

  void _fetchData() {
    final String keyword = searchController.text.trim();
    final bool shouldSearchCustomer = (searchType == "Mã Khách Hàng" && keyword.isNotEmpty);

    futureDebtDeduction = ensureMinLoading(
      DebtService().getDebtDeductionRequests(
        page: currentPage,
        pageSize: pageSize,
        status: ["pending", "rejected"],
        customerId: shouldSearchCustomer ? keyword : null,
      ),
    );
    _selectedRequestIdNotifier.value = null;
    selectedDebtDeduction = null;
  }

  void loadDebtDeduction() {
    setState(() => _fetchData());
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    searchController.dispose();
    _selectedRequestIdNotifier.dispose();
    headerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.backgroundColor.value,
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
        onPressed: () => loadDebtDeduction(),
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
          "YÊU CẦU CẤN TRỪ CÔNG NỢ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: themeController.currentColor.value,
          ),
        ),
        const SizedBox(height: 8),

        //button
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
                      const SizedBox(),
                      const SizedBox(width: 20),

                      // Cụm nút hành động
                      ValueListenableBuilder(
                        valueListenable: _selectedRequestIdNotifier,
                        builder: (context, selectedRequestId, _) {
                          final bool hasSelection =
                              selectedRequestId != null && selectedDebtDeduction != null;
                          final bool canEditOrCancel =
                              hasSelection && selectedDebtDeduction!.status != "approved";
                          final bool canVerifyOtp =
                              hasSelection && selectedDebtDeduction!.status == "pending";

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isSale) ...[
                                // Thêm mới
                                AnimatedButton(
                                  onPressed: () => _showAddOrEditDialog(debtDeduction: null),
                                  label: "Thêm Mới",
                                  icon: Icons.add,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 8),

                                // Sửa phiếu
                                AnimatedButton(
                                  onPressed:
                                      canEditOrCancel
                                          ? () => _showAddOrEditDialog(
                                            debtDeduction: selectedDebtDeduction,
                                          )
                                          : null,
                                  label: "Sửa Phiếu",
                                  icon: Symbols.construction,
                                  backgroundColor: themeController.buttonColor,
                                ),
                                const SizedBox(width: 8),

                                // Duyệt OTP khẩn cấp
                                AnimatedButton(
                                  onPressed:
                                      canVerifyOtp
                                          ? () => _showOtpDialog(selectedDebtDeduction!)
                                          : null,
                                  label: "Duyệt OTP",
                                  icon: Icons.security,
                                  backgroundColor: const Color(0xff1E88E5),
                                ),
                                const SizedBox(width: 8),

                                // Hủy phiếu
                                AnimatedButton(
                                  onPressed:
                                      canEditOrCancel
                                          ? () => _handleDelete(selectedRequestId)
                                          : null,
                                  label: "Hủy Phiếu",
                                  icon: Icons.delete,
                                  backgroundColor: const Color(0xffEA4346),
                                ),
                                const SizedBox(width: 5),
                              ],
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
                "Không có dữ liệu",
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
                      columnWidthMode: ColumnWidthMode.fill,
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
                      onColumnResizeUpdate:
                          (details) => GridResizeHelper.onResizeUpdate(
                            details: details,
                            columns: columnsDebtDeduction,
                            setState: localSetState,
                          ),
                      onColumnResizeEnd:
                          (details) => GridResizeHelper.onResizeEnd(
                            details: details,
                            tableKey: "debt_deduction_request",
                            columnWidths: columnWidths,
                            setState: setState,
                          ),
                      onSelectionChanged: (addedRows, removedRows) async {
                        if (addedRows.isNotEmpty) {
                          final selectedRow = addedRows.first;
                          final requestId =
                              selectedRow
                                      .getCells()
                                      .firstWhere((cell) => cell.columnName == "requestId")
                                      .value
                                  as int?;

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
                  loadDebtDeduction();
                });
              },
              onNext: () {
                setState(() {
                  currentPage++;
                  loadDebtDeduction();
                });
              },
              onJumpToPage: (page) {
                setState(() {
                  currentPage = page;
                  loadDebtDeduction();
                });
              },
            ),
          ],
        );
      },
    );
  }

  // ==================== ACTIONS ====================

  void _showAddOrEditDialog({DebtDeductionRequestModel? debtDeduction}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => DialogDebtDeduction(
            debtDeduction: debtDeduction,
            onSuccess: () => loadDebtDeduction(),
          ),
    );
  }

  Future<void> _handleDelete(int requestId) async {
    await showDeleteConfirmHelper(
      context: context,
      title: "⚠️ Xác nhận hủy",
      content: "Bạn có chắc chắn muốn hủy yêu cầu cấn trừ công nợ này?",
      onDelete: () async {
        await DebtService().deleteDebtDeduction(requestId: requestId);
      },
      onSuccess: () {
        _selectedRequestIdNotifier.value = null;
        selectedDebtDeduction = null;
        loadDebtDeduction();
      },
    );
  }

  void _showOtpDialog(DebtDeductionRequestModel request) {
    showOtpDialog(
      context: context,
      title: "Duyệt khẩn cấp qua OTP",
      primaryColor: const Color(0xff1E88E5),
      cancelText: "Đóng",
      infoText:
          "Khách hàng: ${request.Customer?.customerName ?? request.customerId}\n"
          "Số tiền: ${NumberFormat("#,###", "vi_VN").format(request.amountRequested)} đ\n\n"
          "Nhập mã OTP đã được gửi về Telegram để xác nhận duyệt:",
      onSendOtp: () async {
        try {
          final success = await DebtService().requestOrVerifyUrgentOtp(
            requestId: request.requestId,
          );
          if (!mounted) return;
          if (success) {
            showSnackBarSuccess(context, "Đã gửi mã OTP về Telegram của Quản lý!");
          } else {
            showSnackBarError(context, "Gửi mã OTP thất bại");
          }
        } catch (e) {
          if (!mounted) return;
          showSnackBarError(context, "Lỗi gửi mã OTP: $e");
        }
      },
      onConfirm: (otp) async {
        try {
          final success = await DebtService().requestOrVerifyUrgentOtp(
            requestId: request.requestId,
            otp: otp,
          );
          if (!mounted) return;
          if (success) {
            showSnackBarSuccess(context, "Xác nhận duyệt yêu cầu thành công!");
            loadDebtDeduction();
          } else {
            showSnackBarError(context, "Xác thực OTP không thành công hoặc sai mã");
          }
        } catch (e) {
          if (!mounted) return;
          showSnackBarError(context, "Lỗi xác thực: $e");
        }
      },
    );
  }
}
