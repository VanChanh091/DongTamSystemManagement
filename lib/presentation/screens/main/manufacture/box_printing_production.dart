import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_box.dart';
import 'package:dongtam/presentation/sources/machine_box_data_source.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/service/planning_service.dart';
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

class BoxPrintingProduction extends StatefulWidget {
  const BoxPrintingProduction({super.key});

  @override
  State<BoxPrintingProduction> createState() => _BoxPrintingProductionState();
}

class _BoxPrintingProductionState extends State<BoxPrintingProduction> {
  late Future<List<PlanningBox>> futurePlanning;
  late MachineBoxDatasource machineBoxDatasource;
  late List<GridColumn> columns;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  final socketService = SocketService();
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, int> orderIdToPlanningId = {};
  final DataGridController dataGridController = DataGridController();
  Map<String, double> columnWidths = {};
  List<String> selectedPlanningIds = [];
  List<PlanningBox> planningList = [];
  DateTime? dayStart = DateTime.now();
  String machine = "Máy In";
  bool showGroup = true;

  @override
  void initState() {
    super.initState();

    registerSocket();
    loadPlanning();

    columns = buildMachineBoxColumns(machine: machine, themeController: themeController);

    ColumnWidthTable.loadWidths(tableKey: 'queueBox', columns: columns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void loadPlanning() {
    setState(() {
      futurePlanning = ensureMinLoading(ManufactureService().getPlanningBox(machine: machine));

      selectedPlanningIds.clear();
    });
  }

  String _machineRoomName(String machineName) =>
      'machine_${machineName.toLowerCase().replaceAll(' ', '_')}';

  void _onPlanningPaperUpdated(dynamic data) {
    if (!mounted) return;
    AppLogger.i("_onPlanningBoxUpdated: machine=$machine, data=$data");

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

            title: Center(
              child: const Row(
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

  Future<void> registerSocket() async {
    AppLogger.i("registerSocket: join room machine=$machine");
    socketService.joinMachineRoom(machine);

    socketService.off('planningPaperUpdated');
    socketService.on('planningPaperUpdated', _onPlanningPaperUpdated);
  }

  Future<void> changeMachine(String machineName) async {
    // room cũ
    final oldRoom = _machineRoomName(machine);
    AppLogger.i("changeMachine: from=$oldRoom to=$machineName");

    // cập nhật state trước (UI)
    setState(() {
      machine = machineName;
      selectedPlanningIds.clear();
    });

    // rời room cũ (server cần xử lý leave-room)
    await socketService.leaveRoom(oldRoom);

    // gỡ listener cũ
    socketService.off('planningPaperUpdated');

    // join room mới và đăng ký listener
    await socketService.joinMachineRoom(machineName);
    AppLogger.i("changeMachine: joined newRoom=$machineName");

    socketService.on('planningPaperUpdated', _onPlanningPaperUpdated);

    // load data cho máy mới
    loadPlanning();
  }

  bool canExecuteAction({
    required List<int> selectedPlanningIds,
    required List<PlanningBox> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    final int selectedPlanningBoxId = selectedPlanningIds.first;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningBoxId == selectedPlanningBoxId,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    final boxTimes = selectedPlanning.boxTimes;
    if (boxTimes == null || boxTimes.isEmpty) return false;

    final status = boxTimes.first.status;
    return status != "complete";
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
                        "DANH SÁCH CÔNG ĐOẠN 2 CHỜ SẢN XUẤT",
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
                                final dropdownWidth = (maxWidth * 0.2).clamp(120.0, 170.0);

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //report production
                                    AnimatedButton(
                                      onPressed:
                                          userController.hasPermission(
                                                    permission: "step2Production",
                                                  ) &&
                                                  canExecuteAction(
                                                    selectedPlanningIds:
                                                        selectedPlanningIds.map(int.parse).toList(),
                                                    planningList: planningList,
                                                  )
                                              ? () async {
                                                try {
                                                  final int selectedPlanningBoxId = int.parse(
                                                    selectedPlanningIds.first,
                                                  );

                                                  final selectedPlanning = planningList.firstWhere(
                                                    (p) => p.planningBoxId == selectedPlanningBoxId,
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
                                                          planningId:
                                                              selectedPlanning.planningBoxId,
                                                          qtyPaper: selectedPlanning.qtyPaper,
                                                          onReport: () => loadPlanning(),
                                                          machine: machine,
                                                          isPaper: false,
                                                        ),
                                                  );
                                                } catch (e, s) {
                                                  if (!context.mounted) return;
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
                                          userController.hasPermission(
                                                    permission: "step2Production",
                                                  ) &&
                                                  canExecuteAction(
                                                    selectedPlanningIds:
                                                        selectedPlanningIds.map(int.parse).toList(),
                                                    planningList: planningList,
                                                  )
                                              ? () async {
                                                //get planning first
                                                final int selectedPlanningBoxId = int.parse(
                                                  selectedPlanningIds.first,
                                                );

                                                // find planning by planningId
                                                final selectedPlanning = planningList.firstWhere(
                                                  (p) => p.planningBoxId == selectedPlanningBoxId,
                                                  orElse:
                                                      () =>
                                                          throw Exception(
                                                            "Không tìm thấy kế hoạch",
                                                          ),
                                                );

                                                try {
                                                  await ManufactureService().confirmProducingBox(
                                                    planningBoxId: selectedPlanning.planningBoxId,
                                                    machine: machine,
                                                  );

                                                  loadPlanning();
                                                } catch (e) {
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
                                              'Máy In',
                                              "Máy Bế",
                                              "Máy Xả",
                                              "Máy Dán",
                                              'Máy Cấn Lằn',
                                              "Máy Cắt Khe",
                                              "Máy Cán Màng",
                                              "Máy Đóng Ghim",
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

                  final List<PlanningBox> data = snapshot.data!;
                  planningList = data;

                  machineBoxDatasource = MachineBoxDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                    machine: machine,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: machineBoxDatasource,
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
                            columnNames: [
                              'qtyPrinted',
                              'qtyCanLan',
                              'qtyCanMang',
                              'qtyXa',
                              'qtyCatKhe',
                              'qtyBe',
                              'qtyDan',
                              'qtyDongGhim',
                            ],
                            child: formatColumn(
                              label: 'Số Lượng Của Các Công Đoạn',
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
                          tableKey: 'queueBox',
                          columnWidths: columnWidths,
                          setState: setState,
                        ),

                    onSelectionChanged: (addedRows, removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) return;

                      setState(() {
                        // Lấy selection thật sự từ controller
                        final selectedRows = dataGridController.selectedRows;

                        selectedPlanningIds =
                            selectedRows
                                .map((row) {
                                  final cell = row.getCells().firstWhere(
                                    (c) => c.columnName == 'planningBoxId',
                                    orElse:
                                        () => const DataGridCell(
                                          columnName: 'planningBoxId',
                                          value: '',
                                        ),
                                  );
                                  return cell.value.toString();
                                })
                                .where((id) => id.isNotEmpty)
                                .toList();

                        // cập nhật cho datasource
                        machineBoxDatasource.selectedPlanningIds = selectedPlanningIds;
                        machineBoxDatasource.notifyListeners();
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

  Future<void> handlePlanningAction({
    required BuildContext context,
    required List<String> selectedPlanningIds,
    required String status,
    required String title,
    required String message,
    required String successMessage,
    required String errorMessage,
    required VoidCallback onSuccess,
  }) async {
    if (selectedPlanningIds.isEmpty) {
      showSnackBarError(context, "Chưa chọn kế hoạch cần thực hiện");
      return;
    }

    bool confirm =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              content: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Huỷ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEA4346),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Xác nhận",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      try {
        final planningIds =
            selectedPlanningIds
                .map((orderId) => orderIdToPlanningId[orderId])
                .whereType<int>()
                .toList();

        final success = await PlanningService().pauseOrAcceptLackQty(
          ids: planningIds,
          newStatus: status,
        );
        if (!context.mounted) return;

        if (success) {
          showSnackBarSuccess(context, successMessage);
          onSuccess();
        }
      } catch (e) {
        if (!context.mounted) return;
        showSnackBarError(context, errorMessage);
      }
    }
  }
}
