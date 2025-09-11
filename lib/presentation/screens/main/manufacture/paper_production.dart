import 'package:dongtam/data/controller/userController.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_dataSource.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/service/socket/socket_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
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
  final socketService = SocketService();
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, int> orderIdToPlanningId = {};
  final DataGridController dataGridController = DataGridController();
  String machine = "Máy 1350";
  List<String> selectedPlanningIds = [];
  List<PlanningPaper> planningList = [];
  DateTime? dayStart = DateTime.now();
  bool showGroup = true;

  @override
  void initState() {
    super.initState();

    registerSocket();
    loadPlanning(true);

    columns = buildMachineColumns();
  }

  Future<void> registerSocket() async {
    await SocketService().connectToSocket(machine);

    SocketService().on('planningPaperUpdated', (data) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(20),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              actionsPadding: const EdgeInsets.only(right: 20, bottom: 16),

              title: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thông báo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),

              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    loadPlanning(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('OK', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
      );
    });
  }

  void loadPlanning(bool refresh) {
    setState(() {
      futurePlanning = ManufactureService()
          .getPlanningPaper(machine, refresh)
          .then((planningList) {
            orderIdToPlanningId.clear();
            selectedPlanningIds.clear();
            for (var planning in planningList) {
              orderIdToPlanningId[planning.orderId] = planning.planningId;
            }
            print('manufacture_paper:$orderIdToPlanningId');
            return planningList;
          });
    });
  }

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      selectedPlanningIds.clear();

      SocketService().disconnectSocket();
      registerSocket();
      loadPlanning(true);
    });
  }

  bool canExecuteAction({
    required List<String> selectedPlanningIds,
    required Map<String, int?> orderIdToPlanningId,
    required List<PlanningPaper> planningList,
  }) {
    if (selectedPlanningIds.length != 1) return false;

    final String selectedOrderId = selectedPlanningIds.first;
    final planningId = orderIdToPlanningId[selectedOrderId];
    if (planningId == null) return false;

    final selectedPlanning = planningList.firstWhere(
      (p) => p.planningId == planningId,
      orElse: () => throw Exception("Không tìm thấy kế hoạch"),
    );

    // disable nếu đã complete
    return selectedPlanning.status != "complete";
  }

  @override
  void dispose() {
    SocketService().disconnectSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            //button
            SizedBox(
              height: 70,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      SizedBox(),

                      //right button
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            //report production
                            AnimatedButton(
                              onPressed:
                                  userController.hasAnyPermission([
                                            "machine1350",
                                            "machine1900",
                                            "machine2Layer",
                                            "MachineRollPaper",
                                          ]) &&
                                          canExecuteAction(
                                            selectedPlanningIds:
                                                selectedPlanningIds,
                                            orderIdToPlanningId:
                                                orderIdToPlanningId,
                                            planningList: planningList,
                                          )
                                      ? () async {
                                        try {
                                          final String selectedOrderId =
                                              selectedPlanningIds.first;

                                          final planningId =
                                              orderIdToPlanningId[selectedOrderId];
                                          if (planningId == null) {
                                            showSnackBarError(
                                              context,
                                              "Không tìm thấy planningId cho orderId: $selectedOrderId",
                                            );
                                            return;
                                          }

                                          final selectedPlanning = planningList
                                              .firstWhere(
                                                (p) =>
                                                    p.planningId == planningId,
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
                                                      selectedPlanning
                                                          .planningId,
                                                  onReport:
                                                      () => loadPlanning(true),
                                                ),
                                          );
                                        } catch (e) {
                                          print("Lỗi khi mở Dialog: $e");
                                          showSnackBarError(
                                            context,
                                            "Đã xảy ra lỗi khi mở báo cáo.",
                                          );
                                        }
                                      }
                                      : null,
                              label: "Báo Cáo SX",
                              icon: Icons.assignment,
                            ),
                            const SizedBox(width: 10),

                            //confirm production
                            AnimatedButton(
                              onPressed:
                                  userController.hasAnyPermission([
                                            "machine1350",
                                            "machine1900",
                                            "machine2Layer",
                                            "MachineRollPaper",
                                          ]) &&
                                          canExecuteAction(
                                            selectedPlanningIds:
                                                selectedPlanningIds,
                                            orderIdToPlanningId:
                                                orderIdToPlanningId,
                                            planningList: planningList,
                                          )
                                      ? () async {
                                        //get planning first
                                        final String selectedOrderId =
                                            selectedPlanningIds.first;

                                        //get all planning
                                        final planningList =
                                            await futurePlanning;

                                        // get planningId from orderId
                                        final planningId =
                                            orderIdToPlanningId[selectedOrderId];
                                        if (planningId == null) {
                                          showSnackBarError(
                                            context,
                                            "Không tìm thấy planningId cho orderId: $selectedOrderId",
                                          );
                                          return;
                                        }

                                        // find planning by planningId
                                        final selectedPlanning = planningList
                                            .firstWhere(
                                              (p) => p.planningId == planningId,
                                              orElse:
                                                  () =>
                                                      throw Exception(
                                                        "Không tìm thấy kế hoạch",
                                                      ),
                                            );

                                        try {
                                          await ManufactureService()
                                              .confirmProducingPaper(
                                                selectedPlanning.planningId,
                                              );

                                          loadPlanning(true);
                                        } catch (e) {
                                          showSnackBarError(
                                            context,
                                            "Có lỗi khi xác nhận SX: $e",
                                          );
                                        }
                                      }
                                      : null,
                              label: "Xác Nhận SX",
                              icon: null,
                            ),
                            const SizedBox(width: 10),

                            //choose machine
                            SizedBox(
                              width: 175,
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
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có đơn hàng nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }

                  final List<PlanningPaper> data = snapshot.data!;
                  planningList = data;

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
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
                    columns: columns,
                    headerRowHeight: 40,
                    rowHeight: 45,
                    stackedHeaderRows: <StackedHeaderRow>[
                      StackedHeaderRow(
                        cells: [
                          StackedHeaderCell(
                            columnNames: [
                              'quantityOrd',
                              'runningPlanProd',
                              'qtyProduced',
                            ],
                            child: formatColumn('Số Lượng'),
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
                            child: formatColumn('Định Mức Phế Liệu'),
                          ),
                        ],
                      ),
                    ],
                    onSelectionChanged: (addedRows, removedRows) {
                      setState(() {
                        for (var row in addedRows) {
                          final orderId = row.getCells()[0].value.toString();
                          if (selectedPlanningIds.contains(orderId)) {
                            selectedPlanningIds.remove(orderId);
                          } else {
                            selectedPlanningIds.add(orderId);
                          }
                        }

                        machinePaperDatasource.selectedPlanningIds =
                            selectedPlanningIds;
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
        onPressed: () => loadPlanning(true),
        backgroundColor: Color(0xff78D761),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
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
          planningIds,
          status,
        );

        if (success) {
          showSnackBarSuccess(context, successMessage);
          onSuccess();
        }
      } catch (e) {
        showSnackBarError(context, errorMessage);
      }
    }
  }
}
