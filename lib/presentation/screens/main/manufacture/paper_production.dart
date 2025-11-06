import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_data_source.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PaperProduction extends StatefulWidget {
  const PaperProduction({super.key});

  @override
  State<PaperProduction> createState() => _PaperProductionState();
}

class _PaperProductionState extends State<PaperProduction> {
  late Future<List<PlanningPaper>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final socketService = SocketService();
  final formatter = DateFormat('dd/MM/yyyy');
  final DataGridController dataGridController = DataGridController();
  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningPaper> planningList = [];
  DateTime? dayStart = DateTime.now();
  String machine = "Máy 1350";
  bool showGroup = true;

  @override
  void initState() {
    super.initState();

    registerSocket();
    loadPlanning();

    columns = buildMachineColumns(themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'queuePaper', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPlanning() {
    AppLogger.i("Loading all data manufacture paper");
    setState(() {
      futurePlanning = ensureMinLoading(ManufactureService().getPlanningPaper(machine: machine));

      selectedPlanningIds.clear();
    });
  }

  /* start socket */
  String _machineRoomName(String machineName) =>
      'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';

  Future<void> registerSocket() async {
    AppLogger.i("registerSocket: join room machine=$machine");
    socketService.joinMachineRoom(machine);

    socketService.off('planningPaperUpdated');
    socketService.on('planningPaperUpdated', _onPlanningPaperUpdated);
  }

  void _onPlanningPaperUpdated(dynamic data) {
    if (!mounted) return;
    AppLogger.i("_onPlanningPaperUpdated: machine=$machine, data=$data");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(20),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            actionsPadding: const EdgeInsets.only(right: 20, bottom: 16),

            title: const Center(
              child: Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Thông báo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Đã có kế hoạch mới cho $machine.\nNhấn OK để cập nhật dữ liệu.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),

            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  loadPlanning();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  Future<void> changeMachine(String machineName) async {
    final oldRoom = _machineRoomName(machine);
    AppLogger.i("changeMachine: from=$oldRoom to=$machineName");

    // cập nhật state trước (UI)
    setState(() {
      machine = machineName;
      selectedPlanningIds.clear();
    });

    await socketService.leaveRoom(oldRoom);

    // gỡ listener cũ
    socketService.off('planningPaperUpdated');

    // join room mới và đăng ký listener
    await socketService.joinMachineRoom(machineName);
    AppLogger.i("changeMachine: joined newRoom=$machineName");

    socketService.on('planningPaperUpdated', _onPlanningPaperUpdated);

    loadPlanning();
  }
  /* end socket */

  bool canExecuteAction({
    required List<int> selectedPlanningIds,
    required List<PlanningPaper> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    final int selectedPlanningId = selectedPlanningIds.first;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningId == selectedPlanningId,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // disable nếu đã complete
    return selectedPlanning.status != "complete";
  }

  @override
  void dispose() {
    final room = _machineRoomName(machine);
    socketService.leaveRoom(room);
    socketService.off('planningPaperUpdated');
    super.dispose();
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
                        "DANH SÁCH GIẤY TẤM CHỜ SẢN XUẤT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeController.currentColor.value,
                        ),
                      ),
                    ),
                  ),

                  //button menu
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),

                        //right button
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxWidth = constraints.maxWidth;
                                final dropdownWidth = (maxWidth * 0.2).clamp(125.0, 175.0);

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //report production
                                    AnimatedButton(
                                      onPressed:
                                          userController.hasAnyPermission(
                                                    permission: [
                                                      "machine1350",
                                                      "machine1900",
                                                      "machine2Layer",
                                                      "MachineRollPaper",
                                                    ],
                                                  ) &&
                                                  canExecuteAction(
                                                    selectedPlanningIds:
                                                        selectedPlanningIds.map(int.parse).toList(),
                                                    planningList: planningList,
                                                  )
                                              ? () async {
                                                try {
                                                  final int selectedPlanningId = int.parse(
                                                    selectedPlanningIds.first,
                                                  );

                                                  final selectedPlanning = planningList.firstWhere(
                                                    (p) => p.planningId == selectedPlanningId,
                                                    orElse:
                                                        () =>
                                                            throw Exception(
                                                              "Không tìm thấy kế hoạch",
                                                            ),
                                                  );

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (_) => DialogReportProduction(
                                                          planningId: selectedPlanning.planningId,
                                                          onReport: () => loadPlanning(),
                                                        ),
                                                  );
                                                } catch (e, s) {
                                                  AppLogger.e(
                                                    "Lỗi khi mở dialog",
                                                    error: e,
                                                    stackTrace: s,
                                                  );
                                                  showSnackBarError(
                                                    context,
                                                    "Đã xảy ra lỗi khi mở báo cáo.",
                                                  );
                                                }
                                              }
                                              : null,
                                      label: "Báo Cáo SX",
                                      icon: Icons.assignment,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),

                                    //confirm production
                                    AnimatedButton(
                                      onPressed:
                                          userController.hasAnyPermission(
                                                    permission: [
                                                      "machine1350",
                                                      "machine1900",
                                                      "machine2Layer",
                                                      "MachineRollPaper",
                                                    ],
                                                  ) &&
                                                  canExecuteAction(
                                                    selectedPlanningIds:
                                                        selectedPlanningIds.map(int.parse).toList(),
                                                    planningList: planningList,
                                                  )
                                              ? () async {
                                                try {
                                                  // Lấy planningId (đang ở dạng String → convert sang int)
                                                  final int selectedPlanningId = int.parse(
                                                    selectedPlanningIds.first,
                                                  );

                                                  // Tìm planning tương ứng
                                                  final selectedPlanning = planningList.firstWhere(
                                                    (p) => p.planningId == selectedPlanningId,
                                                    orElse:
                                                        () =>
                                                            throw Exception(
                                                              "Không tìm thấy kế hoạch",
                                                            ),
                                                  );

                                                  // Gửi yêu cầu xác nhận sản xuất
                                                  await ManufactureService().confirmProducingPaper(
                                                    planningId: selectedPlanning.planningId,
                                                  );

                                                  if (!context.mounted) return;

                                                  loadPlanning();
                                                } catch (e, s) {
                                                  AppLogger.e(
                                                    "Lỗi khi xác nhận SX",
                                                    error: e,
                                                    stackTrace: s,
                                                  );
                                                  if (!context.mounted) return;
                                                  showSnackBarError(
                                                    context,
                                                    "Có lỗi khi xác nhận SX: $e",
                                                  );
                                                }
                                              }
                                              : null,
                                      label: "Xác Nhận SX",
                                      icon: null,
                                      backgroundColor: themeController.buttonColor,
                                    ),
                                    const SizedBox(width: 10),

                                    //choose machine
                                    SizedBox(
                                      width: dropdownWidth,
                                      child: DropdownButtonFormField<String>(
                                        value: machine,
                                        items:
                                            [
                                              'Máy 1350',
                                              "Máy 1900",
                                              "Máy 2 Lớp",
                                              "Máy Quấn Cuồn",
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            changeMachine(value);
                                          }
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
                future: futurePlanning,
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

                  final data = snapshot.data as List<PlanningPaper>;
                  planningList = data;

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                    hasBox: true,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: machinePaperDatasource,
                    allowExpandCollapseGroup: true, // Bật grouping
                    autoExpandGroups: true,
                    isScrollbarAlwaysShown: true,
                    columnWidthMode: ColumnWidthMode.auto,
                    navigationMode: GridNavigationMode.row,
                    selectionMode: SelectionMode.multiple,
                    headerRowHeight: 35,
                    rowHeight: 40,
                    columns: ColumnWidthTable.applySavedWidths(
                      columns: columns,
                      widths: columnWidths,
                    ),
                    stackedHeaderRows: <StackedHeaderRow>[
                      StackedHeaderRow(
                        cells: [
                          StackedHeaderCell(
                            columnNames: ['quantityOrd', 'runningPlanProd', 'qtyProduced'],
                            child: formatColumn(
                              label: 'Số Lượng',
                              themeController: themeController,
                            ),
                          ),
                          StackedHeaderCell(
                            columnNames: [
                              'bottom',
                              'fluteE',
                              'fluteB',
                              'fluteC',
                              'knife',
                              'totalWasteLoss',
                            ],
                            child: formatColumn(
                              label: 'Định Mức Phế Liệu',
                              themeController: themeController,
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
                          columns: columns,
                          setState: setState,
                        ),
                    onColumnResizeEnd:
                        (details) => GridResizeHelper.onResizeEnd(
                          details: details,
                          tableKey: 'queuePaper',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      setState(() {
                        final selectedRows = dataGridController.selectedRows;

                        selectedPlanningIds =
                            selectedRows
                                .map((row) {
                                  final cell = row.getCells().firstWhere(
                                    (c) => c.columnName == 'planningId',
                                    orElse:
                                        () =>
                                            const DataGridCell(columnName: 'planningId', value: ''),
                                  );
                                  return cell.value.toString();
                                })
                                .where((id) => id.isNotEmpty)
                                .toList();

                        // cập nhật cho datasource
                        machinePaperDatasource.selectedPlanningIds = selectedPlanningIds;
                        machinePaperDatasource.notifyListeners();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadPlanning(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
