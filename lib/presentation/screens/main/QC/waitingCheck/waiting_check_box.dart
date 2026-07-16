import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/dialog/other/dialog_check_qc.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_box_waiting.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_stages.dart';
import 'package:dongtam/presentation/components/shared/slider_zoom.dart';
import 'package:dongtam/presentation/sources/planning/stages_data_source.dart';
import 'package:dongtam/presentation/sources/waitingCheck/waiting_check_box_data_source.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckBox extends StatefulWidget {
  const WaitingCheckBox({super.key});

  @override
  State<WaitingCheckBox> createState() => _WaitingCheckBoxState();
}

class _WaitingCheckBoxState extends State<WaitingCheckBox> {
  late Future<List<PlanningBoxModel>> futureBoxWaiting;
  late List<GridColumn> columnsBox;
  late List<GridColumn> columnsStages;

  //controllers
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final badgesController = Get.find<BadgesController>();

  //notifiers
  final _zoomNotifier = ValueNotifier<double>(1.0);
  final _selectedPlanningBoxIdsNotifier = ValueNotifier<int?>(null);

  //datasource and cache
  List<PlanningBoxModel>? _cachedBoxes;
  WaitingCheckBoxDataSource? _cachedDatasource;

  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};

  List<PlanningBoxModel> planningList = [];
  List<PlanningStageModel> selectedStages = [];

  @override
  void initState() {
    super.initState();
    loadBoxWaiting();

    columnsBox = buildBoxWaitingColumn(themeController: themeController);
    columnsStages = buildStageColumn(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'boxWaiting', columns: columnsBox).then((w) {
      setState(() {
        columnWidthsPlanning = w;
      });
    });

    ColumnWidthTable.loadWidths(tableKey: 'stage', columns: columnsStages).then((w) {
      setState(() {
        columnWidthsStage = w;
      });
    });
  }

  void loadBoxWaiting() {
    setState(() {
      futureBoxWaiting = ensureMinLoading(
        WarehouseService().getBoxWaitingChecked(isPaper: "false"),
      );
      selectedStages = [];
      _selectedPlanningBoxIdsNotifier.value = null;
    });
  }

  bool canExecuteAction({
    required int? selectedPlanningBoxIds,
    required List<PlanningBoxModel> planningList,
  }) {
    if (selectedPlanningBoxIds == null) return false;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningBoxId == selectedPlanningBoxIds,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // disable nếu đã complete
    if (selectedPlanning.statusRequest == "finalize") return false;

    return true;
  }

  bool canFinalizePlanning({required PlanningBoxModel planning}) {
    return planning.getTotalQtyInbound > 0;
  }

  int get requestQtyProduced {
    if (selectedStages.isEmpty) return 0;

    for (var stage in selectedStages) {
      if (stage.isRequest == true) {
        return stage.qtyProduced ?? 0;
      }
    }
    return 0;
  }

  void _updateZoom(double newZoom) {
    _zoomNotifier.value = newZoom.clamp(0.5, 1.5);
  }

  @override
  void dispose() {
    super.dispose();
    _zoomNotifier.dispose();
    _selectedPlanningBoxIdsNotifier.dispose();
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

              //container contain button and table
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
                                "DANH SÁCH CÔNG ĐOẠN 2 CHỜ KIỂM",
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
                                const SizedBox(),

                                //right button
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _selectedPlanningBoxIdsNotifier,
                                      builder: (context, selectedPlanningBoxIds, _) {
                                        //QC Check
                                        final bool qcCheck =
                                            userController.hasPermission(permission: 'QC') &&
                                            canExecuteAction(
                                              selectedPlanningBoxIds:
                                                  _selectedPlanningBoxIdsNotifier.value,
                                              planningList: planningList,
                                            );

                                        final PlanningBoxModel? selectedPlanning =
                                            _selectedPlanningBoxIdsNotifier.value != null
                                                ? planningList.firstWhereOrNull(
                                                  (p) =>
                                                      p.planningBoxId ==
                                                      _selectedPlanningBoxIdsNotifier.value,
                                                )
                                                : null;

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //inbound warehouse
                                            AnimatedButton(
                                              onPressed:
                                                  qcCheck
                                                      ? () async {
                                                        final int remainQty =
                                                            requestQtyProduced -
                                                            selectedPlanning!.getTotalQtyInbound;

                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (_) => DialogCheckQC(
                                                                planningBoxId:
                                                                    selectedPlanningBoxIds!,
                                                                onQcSessionAddOrUpdate:
                                                                    () => loadBoxWaiting(),
                                                                valueInbound: remainQty,
                                                                type: 'box',
                                                              ),
                                                        );
                                                      }
                                                      : null,
                                              label: "Nhập Kho",
                                              icon: Symbols.input,
                                              backgroundColor: themeController.buttonColor,
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
                          ),
                        ],
                      ),
                    ),

                    // table
                    Expanded(
                      child: FutureBuilder(
                        future: futureBoxWaiting,
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
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Không có đơn hàng nào",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            );
                          }

                          final List<PlanningBoxModel> data = snapshot.data!;
                          planningList = data;

                          if (_cachedBoxes != data || _cachedDatasource == null) {
                            _cachedBoxes = data;
                            _cachedDatasource = WaitingCheckBoxDataSource(
                              planning: data,
                              selectedPlanningBoxIds: _selectedPlanningBoxIdsNotifier.value,
                            );
                          }

                          return Column(
                            children: [
                              //table
                              Expanded(
                                child: StatefulBuilder(
                                  builder: (context, localSetState) {
                                    return Column(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: SfDataGridTheme(
                                            data: SfDataGridThemeData(
                                              selectionColor: Colors.blue.withValues(alpha: 0.3),
                                            ),
                                            child: SfDataGrid(
                                              source: _cachedDatasource!,
                                              isScrollbarAlwaysShown: true,
                                              columnWidthMode: ColumnWidthMode.auto,
                                              selectionMode: SelectionMode.single,
                                              headerRowHeight: 35,
                                              rowHeight: 38,
                                              columns: ColumnWidthTable.applySavedWidths(
                                                columns: columnsBox,
                                                widths: columnWidthsPlanning,
                                              ),
                                              stackedHeaderRows: <StackedHeaderRow>[
                                                StackedHeaderRow(
                                                  cells: [
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        "quantityOrd",
                                                        "qtyPaper",
                                                        "inboundQty",
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'Số Lượng',
                                                          themeController: themeController,
                                                        ),
                                                      ),
                                                    ),
                                                    StackedHeaderCell(
                                                      columnNames: ["inMatTruoc", "inMatSau"],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'In Ấn',
                                                          themeController: themeController,
                                                        ),
                                                      ),
                                                    ),
                                                    StackedHeaderCell(
                                                      columnNames: ["dan_1_Manh", "dan_2_Manh"],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'Dán',
                                                          themeController: themeController,
                                                        ),
                                                      ),
                                                    ),
                                                    StackedHeaderCell(
                                                      columnNames: [
                                                        "dongGhim1Manh",
                                                        "dongGhim2Manh",
                                                      ],
                                                      child: Obx(
                                                        () => formatColumn(
                                                          label: 'Đóng Ghim',
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
                                                    columns: columnsBox,
                                                    setState: localSetState,
                                                  ),
                                              onColumnResizeEnd:
                                                  (details) => GridResizeHelper.onResizeEnd(
                                                    details: details,
                                                    tableKey: 'boxWaiting',
                                                    columnWidths: columnWidthsPlanning,
                                                    setState: setState,
                                                  ),

                                              onSelectionChanged: (addedRows, removedRows) async {
                                                if (addedRows.isNotEmpty) {
                                                  final selectedRow = addedRows.first;

                                                  final planningBoxId =
                                                      selectedRow
                                                          .getCells()
                                                          .firstWhere(
                                                            (cell) =>
                                                                cell.columnName == 'planningBoxId',
                                                          )
                                                          .value;

                                                  setState(() {
                                                    _selectedPlanningBoxIdsNotifier.value =
                                                        planningBoxId;
                                                    selectedStages = [];
                                                  });

                                                  try {
                                                    final stages = await WarehouseService()
                                                        .getBoxWaitingCheckedDetail(
                                                          planningBoxId: planningBoxId,
                                                        );

                                                    setState(() {
                                                      selectedStages = stages;
                                                      localSetState(() {});
                                                    });
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      showSnackBarError(
                                                        context,
                                                        "Lỗi khi lấy chi tiết công đoạn",
                                                      );
                                                    }
                                                  }
                                                } else {
                                                  setState(() {
                                                    _selectedPlanningBoxIdsNotifier.value = null;
                                                    selectedStages = [];
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        selectedStages.isNotEmpty
                                            ? Expanded(
                                              flex: 1,
                                              child: AnimatedSize(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                child: SfDataGrid(
                                                  source: StagesDataSource(stages: selectedStages),
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
                                                          columnNames: ["wasteBox", "rpWasteLoss"],
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
                                                      (details) => GridResizeHelper.onResizeUpdate(
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
                                    );
                                  },
                                ),
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
        onPressed: () => loadBoxWaiting(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
