import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/dialog/dialog_check_qc.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_box_waiting.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_stages.dart';
import 'package:dongtam/presentation/sources/planning/stages_data_source.dart';
import 'package:dongtam/presentation/sources/waitingCheck/waiting_check_box_data_source.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/service/quality_control_service.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckBox extends StatefulWidget {
  const WaitingCheckBox({super.key});

  @override
  State<WaitingCheckBox> createState() => _WaitingCheckBoxState();
}

class _WaitingCheckBoxState extends State<WaitingCheckBox> {
  late Future<List<PlanningBox>> futureBoxWaiting;
  late WaitingCheckBoxDataSource waitingCheckBoxDS;
  late List<GridColumn> columnsBox;
  late List<GridColumn> columnsStages;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};
  int? selectedPlanningBoxIds;
  List<PlanningBox> planningList = [];
  List<PlanningStage> selectedStages = [];

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
      futureBoxWaiting = ensureMinLoading(WarehouseService().getBoxWaitingChecked());

      selectedPlanningBoxIds = null;
      selectedStages = [];
    });
  }

  bool canExecuteAction({
    required int? selectedPlanningBoxIds,
    required List<PlanningBox> planningList,
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

  @override
  Widget build(BuildContext context) {
    //QC Check
    final bool qcCheck =
        userController.hasPermission(permission: 'QC') &&
        canExecuteAction(
          selectedPlanningBoxIds: selectedPlanningBoxIds,
          planningList: planningList,
        );

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
                        SizedBox(),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //inbound warehouse
                                AnimatedButton(
                                  onPressed:
                                      qcCheck
                                          ? () async {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => DialogCheckQC(
                                                    planningBoxId: selectedPlanningBoxIds!,
                                                    onQcSessionAddOrUpdate: () => loadBoxWaiting(),
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

                                //confirm Finalized Session
                                AnimatedButton(
                                  onPressed:
                                      qcCheck
                                          ? () async {
                                            try {
                                              if (selectedPlanningBoxIds == null) return;

                                              final int selectedPlanningBoxId =
                                                  selectedPlanningBoxIds!;

                                              // Tìm planning tương ứng
                                              final selectedPlanning = planningList.firstWhere(
                                                (p) => p.planningBoxId == selectedPlanningBoxId,
                                                orElse:
                                                    () =>
                                                        throw Exception("Không tìm thấy kế hoạch"),
                                              );

                                              // Gửi yêu cầu xác nhận sản xuất
                                              await QualityControlService().confirmFinalizeSession(
                                                planningBoxId: selectedPlanning.planningBoxId,
                                                isPaper: false,
                                              );

                                              if (!context.mounted) return;

                                              loadBoxWaiting();

                                              showSnackBarSuccess(
                                                context,
                                                "Xác nhận hoàn thành phiên kiểm tra thành công",
                                              );
                                            } catch (e, s) {
                                              AppLogger.e(
                                                "Lỗi khi xác nhận SX",
                                                error: e,
                                                stackTrace: s,
                                              );
                                              if (!context.mounted) return;
                                              showSnackBarError(
                                                context,
                                                "Có lỗi khi hoàn thành phiên kiểm tra: $e",
                                              );
                                            }
                                          }
                                          : null,
                                  label: "Hoàn Thành",
                                  icon: Symbols.done_outline,
                                  backgroundColor: themeController.buttonColor,
                                ),

                                const SizedBox(width: 10),
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

                  final List<PlanningBox> data = snapshot.data!;
                  planningList = data;

                  waitingCheckBoxDS = WaitingCheckBoxDataSource(
                    planning: data,
                    selectedPlanningBoxIds: selectedPlanningBoxIds,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SfDataGrid(
                                source: waitingCheckBoxDS,
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
                                        columnNames: ["quantityOrd", "qtyPaper", "inboundQty"],
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
                                        columnNames: ["dongGhim1Manh", "dongGhim2Manh"],
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
                                      setState: setState,
                                    ),
                                onColumnResizeEnd:
                                    (details) => GridResizeHelper.onResizeEnd(
                                      details: details,
                                      tableKey: 'boxWaiting',
                                      columnWidths: columnWidthsPlanning,
                                      setState: setState,
                                    ),

                                onSelectionChanged: (addedRows, removedRows) async {
                                  if (addedRows.isEmpty) {
                                    setState(() {
                                      selectedPlanningBoxIds = null;
                                    });
                                    return;
                                  }

                                  final selectedRow = addedRows.first;

                                  final planningBoxId =
                                      selectedRow
                                          .getCells()
                                          .firstWhere((cell) => cell.columnName == 'planningBoxId')
                                          .value;

                                  // Lấy data của list (summary)
                                  final selectedDbPaper = data.firstWhere(
                                    (paper) => paper.planningBoxId == planningBoxId,
                                  );

                                  setState(() {
                                    selectedPlanningBoxIds = selectedDbPaper.planningBoxId;
                                  });

                                  final stages = await WarehouseService().getDbPlanningDetail(
                                    planningBoxId: selectedDbPaper.planningBoxId,
                                  );

                                  setState(() {
                                    selectedStages = stages;
                                  });
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
                                              columnNames: ["timeRunning", "timeRunningOvfl"],
                                              child: Obx(
                                                () => formatColumn(
                                                  label: 'Thời Gian',
                                                  themeController: themeController,
                                                ),
                                              ),
                                            ),
                                            StackedHeaderCell(
                                              columnNames: ["runningPlan", "qtyProduced"],
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

                                      onColumnResizeStart: GridResizeHelper.onResizeStart,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadBoxWaiting(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
