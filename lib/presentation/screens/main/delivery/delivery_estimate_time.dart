import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_db_planning.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_stages.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_estimate_data_source.dart';
import 'package:dongtam/presentation/sources/planning/stages_data_source.dart';
import 'package:dongtam/service/dashboard_service.dart';
import 'package:dongtam/service/delivery_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/confirm_dialog.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryEstimateTime extends StatefulWidget {
  const DeliveryEstimateTime({super.key});

  @override
  State<DeliveryEstimateTime> createState() => _DeliveryEstimateTimeState();
}

class _DeliveryEstimateTimeState extends State<DeliveryEstimateTime> {
  late Future<Map<String, dynamic>> futurePaper;
  late DeliveryEstimateDataSource deliveryDataSource;
  late List<GridColumn> columnsPaper;
  late List<GridColumn> columnsStages;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final dataGridController = DataGridController();

  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};
  List<PlanningStage> selectedStages = [];
  bool selectedAll = false;
  List<int> selectedPaperId = [];

  TextEditingController dayStartController = TextEditingController();
  TextEditingController estimateTimeController = TextEditingController();

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();

    columnsPaper = buildDbPaperColumn(themeController: themeController, page: 'delivery');
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

  void loadPlanningEstimate() {
    final dayStart = DateFormat('dd/MM/yyyy').parse(dayStartController.text);

    setState(() {
      futurePaper = ensureMinLoading(
        DeliveryService().getPlanningEstimateTime(
          page: currentPage,
          pageSize: pageSize,
          dayStart: dayStart,
          estimateTime: estimateTimeController.text,
        ),
      );

      selectedPaperId.clear();
      selectedStages = [];
    });
  }

  void searchDashboard() {
    final dayStart = DateFormat('dd/MM/yyyy').parse(dayStartController.text);
    setState(() {
      futurePaper = ensureMinLoading(
        DeliveryService().getPlanningEstimateTime(
          page: currentPage,
          pageSize: pageSize,
          dayStart: dayStart,
          estimateTime: estimateTimeController.text,
        ),
      );

      selectedPaperId.clear();
      selectedStages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 125,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "DANH SÁCH HÀNG CHỜ GIAO & DỰ KIẾN",
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
                    height: 90,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //left button
                            const SizedBox(),

                            //right button
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //filter
                                    AnimatedButton(
                                      onPressed: () => loadPlanningEstimate(),
                                      label: 'Lọc Đơn',
                                      icon: Symbols.filter_alt,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),

                                    //confirm delivery
                                    AnimatedButton(
                                      onPressed: () async {
                                        bool confirm = await showConfirmDialog(
                                          context: context,
                                          title: "Xác Nhận Kế Hoạch Giao Hàng",
                                          content:
                                              "Bạn có muốn xác nhận lên kế hoạch giao hàng cho các đơn này không?",
                                          confirmText: "Xác nhận",
                                          confirmColor: const Color(0xffEA4346),
                                        );

                                        if (confirm) {
                                          try {
                                            final success = await DeliveryService()
                                                .confirmReadyDelivery(planningIds: selectedPaperId);

                                            if (!context.mounted) return;
                                            if (success) {
                                              showSnackBarSuccess(
                                                context,
                                                "Xác nhận lên kế hoạch giao hàng thành công",
                                              );
                                              loadPlanningEstimate();
                                            }
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            showSnackBarError(
                                              context,
                                              "Có lỗi khi xác nhận lên kế hoạch giao hàng",
                                            );
                                          }
                                        }
                                      },
                                      label: 'Xác Nhận Giao',
                                      icon: Symbols.confirmation_number,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        //set day and estimate time
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Ngày giao
                              buildLabelAndUnderlineInput(
                                label: "Ngày giao:",
                                controller: dayStartController,
                                width: 120,
                                readOnly: true,
                                onTap: () async {
                                  final selected = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
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
                            ],
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
                  final dbPlanning = data['plannings'] as List<PlanningPaper>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  deliveryDataSource = DeliveryEstimateDataSource(
                    delivery: dbPlanning,
                    selectedPaperId: selectedPaperId,
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
                                controller: dataGridController,
                                source: deliveryDataSource,
                                isScrollbarAlwaysShown: true,
                                columnWidthMode: ColumnWidthMode.auto,
                                navigationMode: GridNavigationMode.row,
                                selectionMode: SelectionMode.multiple,
                                headerRowHeight: 35,
                                rowHeight: 40,
                                columns: ColumnWidthTable.applySavedWidths(
                                  columns: columnsPaper,
                                  widths: columnWidthsPlanning,
                                ),
                                stackedHeaderRows: <StackedHeaderRow>[
                                  StackedHeaderRow(
                                    cells: [
                                      StackedHeaderCell(
                                        columnNames: [
                                          "dayReceive",
                                          "dateShipping",
                                          "dayStartProduction",
                                          "dayCompletedProd",
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
                                          'quantityOrd',
                                          'qtyProduced',
                                          'runningPlanProd',
                                          "totalOutbound",
                                        ],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Số Lượng',
                                            themeController: themeController,
                                          ),
                                        ),
                                      ),
                                      StackedHeaderCell(
                                        columnNames: ['timeRunningProd', 'timeRunningOvfl'],
                                        child: Obx(
                                          () => formatColumn(
                                            label: 'Thời Gian',
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
                                      setState: setState,
                                    ),
                                onColumnResizeEnd:
                                    (details) => GridResizeHelper.onResizeEnd(
                                      details: details,
                                      tableKey: 'plannings',
                                      columnWidths: columnWidthsPlanning,
                                      setState: setState,
                                    ),

                                onSelectionChanged: (addedRows, removedRows) async {
                                  if (addedRows.isEmpty && removedRows.isEmpty) return;

                                  final selectedRows = dataGridController.selectedRows;

                                  final ids =
                                      selectedRows.map((row) {
                                        return row
                                                .getCells()
                                                .firstWhere(
                                                  (cell) => cell.columnName == 'planningId',
                                                )
                                                .value
                                            as int;
                                      }).toList();

                                  // Lấy data của list (summary)
                                  setState(() {
                                    selectedPaperId = ids;
                                  });

                                  // Nếu chọn > 1 row → KHÔNG call detail
                                  if (ids.length != 1) {
                                    setState(() {
                                      selectedStages = [];
                                    });
                                    return;
                                  }

                                  final planningId = ids.first;

                                  final stages = await DashboardService().getDbPlanningDetail(
                                    planningId: planningId,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadPlanningEstimate(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
