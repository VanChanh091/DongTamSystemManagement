// ignore_for_file: deprecated_member_use

import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_delivery_estimate.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_stages.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_estimate_data_source.dart';
import 'package:dongtam/presentation/sources/planning/stages_data_source.dart';
import 'package:dongtam/service/synthetic_service.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryEstimateTime extends StatefulWidget {
  const DeliveryEstimateTime({super.key});

  @override
  State<DeliveryEstimateTime> createState() => _DeliveryEstimateTimeState();
}

class _DeliveryEstimateTimeState extends State<DeliveryEstimateTime> {
  late Future<Map<String, dynamic>> futurePaper;
  late List<GridColumn> columnsPaper;
  late List<GridColumn> columnsStages;

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();

  //width column
  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};
  List<PlanningStageModel> selectedStages = [];

  //filter
  String allOrders = "false";
  final Map<String, String> filterOptions = {'false': 'Đơn Bản Thân', 'true': 'Tất Cả Đơn'};

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
  };

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedPaperIdsNotifier = ValueNotifier<List<int>>([]);

  //datasource and cache
  List<PlanningPaperModel>? _cachedPapers;
  DeliveryEstimateDataSource? _cachedDatasource;
  List<PlanningPaperModel> planningList = [];

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dayStartController = TextEditingController();
  TextEditingController estimateTimeController = TextEditingController();
  TextEditingController registeredController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  //flag
  late bool isPlan;
  bool selectedAll = false;
  bool isSearching = false;
  bool isTextFieldEnabled = false;
  bool _isSelectionChange = false;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();

    isPlan = userController.hasPermission(permission: "plan");

    columnsPaper = buildDeliveryEstimateColumn(themeController: themeController);
    columnsStages = buildStageColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'estimateTime', columns: columnsPaper).then((w) {
      setState(() {
        columnWidthsPlanning = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'stage', columns: columnsStages).then((w) {
      setState(() {
        columnWidthsStage = w;
      });
    });

    final now = DateTime.now();
    dayStartController.text =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";
    estimateTimeController.text = '17:00';

    loadPlanningEstimate();
  }

  void _fetchData() {
    final dayStart = DateFormat('dd/MM/yyyy').parse(dayStartController.text);

    final String keyword = searchController.text.trim().toLowerCase();
    final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    final bool shouldSearch = isSearching && searchType != "Tất cả";

    futurePaper = ensureMinLoading(
      DeliveryService().getPlanningEstimateTime(
        page: currentPage,
        pageSize: pageSize,
        dayStart: dayStart,
        estimateTime: estimateTimeController.text,
        all: allOrders,
        field: shouldSearch ? selectedField : null,
        keyword: shouldSearch ? keyword : null,
      ),
    );

    _selectedPaperIdsNotifier.value = [];
    dataGridController.selectedRows = [];
    selectedStages = [];
  }

  void loadPlanningEstimate() {
    setState(() => _fetchData());
  }

  void searchPlanningEstimate() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchPlanningEstimate: search bị bỏ qua vì keyword trống");
      return;
    }

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(estimateTimeController.text)) {
      showSnackBarError(context, "Giờ bắt đầu không đúng định dạng (hh:mm). Ví dụ: 08:00");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
    });
  }

  void _updateSelectedIdsFromRows(List<DataGridRow> selectedRows) async {
    final List<int> ids =
        selectedRows.map((row) {
          return row.getCells().firstWhere((cell) => cell.columnName == 'planningId').value as int;
        }).toList();

    // Cập nhật danh sách ID và tạm thời xóa chi tiết cũ
    setState(() {
      _selectedPaperIdsNotifier.value = ids;
      selectedStages = [];
    });

    if (ids.length == 1) {
      try {
        final stages = await SyntheticService().getSyntheticPlanningDetail(planningId: ids.first);
        setState(() {
          selectedStages = stages;
        });
      } catch (e) {
        AppLogger.e("Lỗi khi lấy chi tiết công đoạn: $e");
      }
    }
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    dayStartController.dispose();
    estimateTimeController.dispose();
    registeredController.dispose();
    noteController.dispose();
    _zoomNotifier.dispose();
    _selectedPaperIdsNotifier.dispose();
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
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    //title & button
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: Column(
                        children: [
                          //title
                          SizedBox(
                            height: 35,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "ĐĂNG KÝ GIAO HÀNG",
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
                            height: 105,
                            width: double.infinity,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //button
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Column(
                                          children: [
                                            Row(
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
                                                    ],
                                                    onTypeChanged: (value) {
                                                      setState(() {
                                                        searchType = value;
                                                        isTextFieldEnabled = value != 'Tất cả';

                                                        if (searchType == "Tất cả" &&
                                                            searchController.text.isNotEmpty) {
                                                          searchController.clear();
                                                          currentPage = 1;
                                                          _fetchData();
                                                        }
                                                      });
                                                    },
                                                    buttonLabel: "Lọc Đơn",
                                                    controller: searchController,
                                                    textFieldEnabled: isTextFieldEnabled,
                                                    buttonColor: themeController.buttonColor,
                                                    onSearch: () => searchPlanningEstimate(),
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
                                                    child: ValueListenableBuilder(
                                                      valueListenable: _selectedPaperIdsNotifier,
                                                      builder: (context, selectedPlanningIds, _) {
                                                        final bool hasSelection =
                                                            selectedPlanningIds.isEmpty;

                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            //register delivery
                                                            AnimatedButton(
                                                              onPressed:
                                                                  hasSelection ||
                                                                          selectedPlanningIds
                                                                                  .length >
                                                                              1
                                                                      ? null
                                                                      : () async {
                                                                        registeredController
                                                                            .clear();
                                                                        noteController.clear();

                                                                        await showInputQtyDialog(
                                                                          context: context,
                                                                          title:
                                                                              "Đăng Ký Giao Hàng",
                                                                          labelText:
                                                                              "Số lượng đăng ký",
                                                                          controller:
                                                                              registeredController,
                                                                          validator: (value) {
                                                                            final n = int.tryParse(
                                                                              value!,
                                                                            );
                                                                            if (n == null ||
                                                                                n <= 0) {
                                                                              return "Số lượng phải lớn hơn 0";
                                                                            }

                                                                            return null;
                                                                          },

                                                                          //input 2
                                                                          labelText2: "Ghi chú",
                                                                          controller2:
                                                                              noteController,

                                                                          onConfirm: () async {
                                                                            try {
                                                                              final success = await DeliveryService()
                                                                                  .handlePutDelivery(
                                                                                    action:
                                                                                        "REGISTER_QTY",
                                                                                    planningId:
                                                                                        selectedPlanningIds,
                                                                                    qtyRegistered:
                                                                                        int.parse(
                                                                                          registeredController
                                                                                              .text,
                                                                                        ),
                                                                                    note:
                                                                                        noteController
                                                                                            .text,
                                                                                  );

                                                                              if (success) {
                                                                                if (context
                                                                                    .mounted) {
                                                                                  showSnackBarSuccess(
                                                                                    context,
                                                                                    "Xác nhận lên kế hoạch giao hàng thành công",
                                                                                  );
                                                                                }

                                                                                // Cập nhật số lượng badge
                                                                                badgesController
                                                                                    .fetchDeliveryRequest();

                                                                                loadPlanningEstimate();
                                                                                return true;
                                                                              }
                                                                              return false;
                                                                            } catch (e) {
                                                                              if (context.mounted) {
                                                                                showSnackBarError(
                                                                                  context,
                                                                                  "Có lỗi khi xác nhận lên kế hoạch giao hàng",
                                                                                );
                                                                              }
                                                                              return false;
                                                                            }
                                                                          },
                                                                        );
                                                                      },
                                                              label: 'Đăng Ký Giao',
                                                              icon: Symbols.confirmation_number,
                                                              backgroundColor:
                                                                  themeController.buttonColor,
                                                            ),
                                                            const SizedBox(width: 10),

                                                            //close planning
                                                            isPlan
                                                                ? Row(
                                                                  children: [
                                                                    AnimatedButton(
                                                                      onPressed:
                                                                          hasSelection
                                                                              ? null
                                                                              : () async {
                                                                                final bool
                                                                                confirm = await showConfirmDialog(
                                                                                  context: context,
                                                                                  title:
                                                                                      "Xác Nhận Đóng Kế Hoạch Này",
                                                                                  content:
                                                                                      "Bạn có chắc chắn muốn đóng kế hoạch này?",
                                                                                  confirmText:
                                                                                      "Xác Nhận",
                                                                                  confirmColor:
                                                                                      const Color(
                                                                                        0xffEA4346,
                                                                                      ),
                                                                                );

                                                                                if (confirm) {
                                                                                  try {
                                                                                    final selectedPapers =
                                                                                        planningList
                                                                                            .where(
                                                                                              (
                                                                                                p,
                                                                                              ) => selectedPlanningIds.contains(
                                                                                                p.planningId,
                                                                                              ),
                                                                                            )
                                                                                            .toList();

                                                                                    final bool
                                                                                    isBoxType =
                                                                                        selectedPapers.any(
                                                                                          (p) =>
                                                                                              p.hasBox ==
                                                                                              true,
                                                                                        );

                                                                                    final success = await DeliveryService().handlePutDelivery(
                                                                                      action:
                                                                                          "CLOSE_PLANNING",
                                                                                      planningId:
                                                                                          selectedPlanningIds,
                                                                                      isPaper:
                                                                                          !isBoxType,
                                                                                    );

                                                                                    if (success) {
                                                                                      if (context
                                                                                          .mounted) {
                                                                                        showSnackBarSuccess(
                                                                                          context,
                                                                                          "Đóng kế hoạch thành công",
                                                                                        );
                                                                                      }
                                                                                      loadPlanningEstimate();
                                                                                    }
                                                                                  } on ApiException catch (
                                                                                    e
                                                                                  ) {
                                                                                    if (!context
                                                                                        .mounted) {
                                                                                      return;
                                                                                    }

                                                                                    final showError =
                                                                                        showSnackBarError(
                                                                                          context,
                                                                                          e.message!,
                                                                                        );

                                                                                    switch (e
                                                                                        .errorCode) {
                                                                                      case "CANNOT_CLOSE_EMPTY_PAPER":
                                                                                        showError;
                                                                                        break;
                                                                                      case "NO_STAGES_FOUND":
                                                                                        showError;
                                                                                        break;
                                                                                      case "STAGE_NOT_PRODUCED":
                                                                                        showError;
                                                                                        break;
                                                                                      case "NO_INBOUND_HISTORY":
                                                                                        showError;
                                                                                        break;
                                                                                      default:
                                                                                        showSnackBarError(
                                                                                          context,
                                                                                          e.message ??
                                                                                              "Có lỗi khi đóng kế hoạch",
                                                                                        );
                                                                                    }
                                                                                  } catch (e) {
                                                                                    if (context
                                                                                        .mounted) {
                                                                                      showSnackBarError(
                                                                                        context,
                                                                                        "Có lỗi khi đóng kế hoạch",
                                                                                      );
                                                                                    }
                                                                                  }
                                                                                }
                                                                              },
                                                                      label: "Hoàn Thành",
                                                                      icon: Symbols.check,
                                                                      backgroundColor:
                                                                          themeController
                                                                              .buttonColor,
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                  ],
                                                                )
                                                                : const SizedBox.shrink(),

                                                            //filter
                                                            buildDropdownItems(
                                                              value: allOrders,
                                                              items: const ['false', 'true'],
                                                              onChanged:
                                                                  (value) => {
                                                                    setState(() {
                                                                      allOrders = value!;
                                                                      selectedPlanningIds.clear();
                                                                      loadPlanningEstimate();
                                                                    }),
                                                                  },
                                                              itemLabelBuilder:
                                                                  (value) =>
                                                                      filterOptions[value] ?? value,
                                                            ),
                                                            const SizedBox(width: 10),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),

                                            //set day and time
                                            Padding(
                                              padding: const EdgeInsets.only(left: 12),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // Ngày giao
                                                  buildLabelAndUnderlineInput(
                                                    label: "Ngày dự kiến:",
                                                    controller: dayStartController,
                                                    width: 120,
                                                    readOnly: true,
                                                    onTap: () async {
                                                      final selected = await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime(2026),
                                                        lastDate: DateTime(2100),
                                                        builder: (
                                                          BuildContext context,
                                                          Widget? child,
                                                        ) {
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
                                                      if (selected != null) {
                                                        dayStartController.text =
                                                            "${selected.day.toString().padLeft(2, '0')}/"
                                                            "${selected.month.toString().padLeft(2, '0')}/"
                                                            "${selected.year}";
                                                      }
                                                    },
                                                  ),
                                                  const SizedBox(width: 32),

                                                  // Giờ dự kiến
                                                  buildLabelAndUnderlineInput(
                                                    label: "Giờ dự kiến:",
                                                    controller: estimateTimeController,
                                                    width: 60,
                                                  ),
                                                  const SizedBox(width: 32),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                        future: futurePaper,
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
                          } else if (!snapshot.hasData || snapshot.data!['plannings'].isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final data = snapshot.data!;

                          final dbPlanning = data['plannings'] as List<PlanningPaperModel>;
                          planningList = dbPlanning;

                          final currentPg = data['currentPage'];
                          final totalPgs = data['totalPages'];

                          if (_cachedPapers == null || _cachedPapers != dbPlanning) {
                            _cachedPapers = dbPlanning;
                            _cachedDatasource = DeliveryEstimateDataSource(
                              delivery: dbPlanning,
                              selectedPaperIds: _selectedPaperIdsNotifier.value,
                              currentPage: currentPage,
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
                                      data: SfDataGridThemeData(
                                        selectionColor: Colors.blue.withValues(alpha: 0.3),
                                        currentCellStyle: const DataGridCurrentCellStyle(
                                          borderColor: Colors.transparent,
                                          borderWidth: 0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SfDataGrid(
                                              controller: dataGridController,
                                              source: _cachedDatasource!,
                                              isScrollbarAlwaysShown: true,
                                              columnWidthMode: ColumnWidthMode.auto,
                                              selectionMode: SelectionMode.multiple,
                                              headerRowHeight: 35,
                                              rowHeight: 38,
                                              columns: ColumnWidthTable.applySavedWidths(
                                                columns: columnsPaper,
                                                widths: columnWidthsPlanning,
                                              ),
                                              stackedHeaderRows: <StackedHeaderRow>[
                                                StackedHeaderRow(
                                                  cells: [
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        'quantityOrd',
                                                        'qtyProduced',
                                                        'qtyOutbound',
                                                        "qtyInventory",
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
                                                    columns: columnsPaper,
                                                    setState: localSetState,
                                                  ),
                                              onColumnResizeEnd:
                                                  (details) => GridResizeHelper.onResizeEnd(
                                                    details: details,
                                                    tableKey: 'estimateTime',
                                                    columnWidths: columnWidthsPlanning,
                                                    setState: setState,
                                                  ),

                                              onSelectionChanging: (addedRows, removedRows) {
                                                if (_isSelectionChange) return true;

                                                // Kiểm tra trạng thái bấm phím từ bàn phím
                                                final keys =
                                                    HardwareKeyboard.instance.logicalKeysPressed;
                                                final isShiftPressed =
                                                    keys.contains(LogicalKeyboardKey.shiftLeft) ||
                                                    keys.contains(LogicalKeyboardKey.shiftRight);
                                                final isCtrlPressed =
                                                    keys.contains(LogicalKeyboardKey.controlLeft) ||
                                                    keys.contains(LogicalKeyboardKey.controlRight);

                                                // TH 1: Click bình thường (Không nhấn Shift & Ctrl)
                                                if (!isShiftPressed && !isCtrlPressed) {
                                                  if (addedRows.isNotEmpty) {
                                                    final latestRow = addedRows.last;

                                                    _isSelectionChange = true;
                                                    dataGridController.selectedRows = [latestRow];
                                                    _isSelectionChange = false;

                                                    _updateSelectedIdsFromRows(
                                                      dataGridController.selectedRows,
                                                    );
                                                    return false;
                                                  } else if (removedRows.isNotEmpty &&
                                                      dataGridController.selectedRows.length > 1) {
                                                    // Nếu đang chọn nhiều dòng, click vào 1 dòng bất kỳ không giữ phím -> Reset về duy nhất dòng đó
                                                    final clickedRow = removedRows.first;

                                                    _isSelectionChange = true;
                                                    dataGridController.selectedRows = [clickedRow];
                                                    _isSelectionChange = false;

                                                    _updateSelectedIdsFromRows(
                                                      dataGridController.selectedRows,
                                                    );
                                                    return false;
                                                  }
                                                }

                                                // TH 2: Giữ phím Shift (Chọn một dải dòng liên tiếp)
                                                if (isShiftPressed &&
                                                    dataGridController.selectedRows.isNotEmpty &&
                                                    addedRows.isNotEmpty) {
                                                  final lastSelected =
                                                      dataGridController.selectedRows.last;
                                                  final newlyClicked = addedRows.last;

                                                  final allRows = _cachedDatasource!.rows;
                                                  final startIdx = allRows.indexOf(lastSelected);
                                                  final endIdx = allRows.indexOf(newlyClicked);

                                                  if (startIdx != -1 && endIdx != -1) {
                                                    final min =
                                                        startIdx < endIdx ? startIdx : endIdx;
                                                    final max =
                                                        startIdx > endIdx ? startIdx : endIdx;

                                                    final List<DataGridRow> rangeSelection = [];
                                                    for (int i = min; i <= max; i++) {
                                                      rangeSelection.add(allRows[i]);
                                                    }

                                                    _isSelectionChange = true;
                                                    dataGridController.selectedRows = List.from(
                                                      rangeSelection,
                                                    );
                                                    _isSelectionChange = false;

                                                    _updateSelectedIdsFromRows(rangeSelection);
                                                    return false;
                                                  }
                                                }

                                                // TH 3: Giữ phím Ctrl
                                                return true;
                                              },

                                              onSelectionChanged: (addedRows, removedRows) async {
                                                if (_isSelectionChange) return;
                                                _updateSelectedIdsFromRows(
                                                  dataGridController.selectedRows,
                                                );
                                              },
                                            ),
                                          ),

                                          selectedStages.isNotEmpty
                                              ? Expanded(
                                                flex: 1,
                                                child: AnimatedSize(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  child: SfDataGrid(
                                                    source: StagesDataSource(
                                                      stages: selectedStages,
                                                    ),
                                                    isScrollbarAlwaysShown: true,
                                                    headerRowHeight: 30,
                                                    rowHeight: 35,
                                                    columnWidthMode: ColumnWidthMode.fill,
                                                    selectionMode: SelectionMode.single,
                                                    columns: ColumnWidthTable.applySavedWidths(
                                                      columns: columnsStages,
                                                      widths: columnWidthsStage,
                                                    ),
                                                    stackedHeaderRows: <StackedHeaderRow>[
                                                      StackedHeaderRow(
                                                        cells: [
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "dayStart",
                                                              "dayCompleted",
                                                              "dayCompletedOvfl",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Ngày',
                                                                themeController: themeController,
                                                              ),
                                                            ),
                                                          ),
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "timeRunning",
                                                              "timeRunningOvfl",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Thời Gian',
                                                                themeController: themeController,
                                                              ),
                                                            ),
                                                          ),
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "runningPlan",
                                                              "qtyProduced",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Số Lượng',
                                                                themeController: themeController,
                                                              ),
                                                            ),
                                                          ),
                                                          StackedHeaderCell(
                                                            columnNames: [
                                                              "wasteBox",
                                                              "rpWasteLoss",
                                                            ],
                                                            child: Obx(
                                                              () => formatColumn(
                                                                label: 'Phế Liệu',
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

                                                    onColumnResizeStart:
                                                        GridResizeHelper.onResizeStart,
                                                    onColumnResizeUpdate:
                                                        (details) =>
                                                            GridResizeHelper.onResizeUpdate(
                                                              details: details,
                                                              columns: columnsStages,
                                                              setState: setState,
                                                            ),
                                                    onColumnResizeEnd:
                                                        (details) => GridResizeHelper.onResizeEnd(
                                                          details: details,
                                                          tableKey: 'stage',
                                                          columnWidths: columnWidthsStage,
                                                          setState: setState,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              : const SizedBox.shrink(),
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
                                    loadPlanningEstimate();
                                  });
                                },
                                onNext: () {
                                  setState(() {
                                    currentPage++;
                                    loadPlanningEstimate();
                                  });
                                },
                                onJumpToPage: (page) {
                                  setState(() {
                                    currentPage = page;
                                    loadPlanningEstimate();
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

            //slider zoom
            ValueListenableBuilder<double>(
              valueListenable: _zoomNotifier,
              builder: (context, zoom, _) {
                return SliderZoom(
                  zoomLevel: zoom,
                  onZoomChanged: _updateZoom,
                  initialMargin: Offset(73, 125),
                  buttonColor: themeController.buttonColor.value,
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => loadPlanningEstimate(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
