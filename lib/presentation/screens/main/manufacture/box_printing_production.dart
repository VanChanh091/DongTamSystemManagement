import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_report_production.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_dataSource.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class BoxPrintingProduction extends StatefulWidget {
  const BoxPrintingProduction({super.key});

  @override
  State<BoxPrintingProduction> createState() => _BoxPrintingProductionState();
}

class _BoxPrintingProductionState extends State<BoxPrintingProduction> {
  late Future<List<PlanningPaper>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  String searchType = "Tất cả";
  String machine = "Máy In";
  DateTime selectedDate = DateTime.now();
  bool isTextFieldEnabled = false;
  List<String> selectedPlanningIds = [];
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, int> orderIdToPlanningId = {};
  final DataGridController dataGridController = DataGridController();
  DateTime? dayStart = DateTime.now();
  bool isLoading = false;
  bool showGroup = true;

  TextEditingController searchController = TextEditingController();
  TextEditingController dayStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController totalTimeWorkingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPlanning(false);
  }

  void loadPlanning(bool refresh) {
    setState(() {
      futurePlanning = PlanningService()
          .getPlanningPaperByMachine(machine, refresh)
          .then((planningList) {
            orderIdToPlanningId.clear();
            for (var planning in planningList) {
              orderIdToPlanningId[planning.orderId] = planning.planningId;
            }
            print(orderIdToPlanningId);
            return planningList;
          });
    });
  }

  void searchPlanning() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) {
      return;
    }

    switch (searchType) {
      case 'Tất cả':
        loadPlanning(false);
        break;
      case 'Mã Đơn Hàng':
        setState(() {
          futurePlanning = PlanningService().getPlanningByOrderId(
            keyword,
            machine,
          );
        });
        break;
      case 'Tên KH':
        setState(() {
          futurePlanning = PlanningService().getPlanningByCustomerName(
            keyword,
            machine,
          );
        });
        break;
      case 'Sóng':
        setState(() {
          futurePlanning = PlanningService().getPlanningByFlute(
            keyword,
            machine,
          );
        });
        break;
      case 'Khổ Cấp Giấy':
        setState(() {
          try {
            futurePlanning = PlanningService().getPlanningByGhepKho(
              int.parse(keyword),
              machine,
            );
          } catch (e) {
            showSnackBarError(
              context,
              'Vui lòng nhập số hợp lệ cho khổ cấp giấy',
            );
          }
        });
        break;
      default:
    }
  }

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      selectedPlanningIds.clear();
      loadPlanning(false);
    });
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
                            ElevatedButton.icon(
                              onPressed:
                                  //turn on/off
                                  selectedPlanningIds.length == 1
                                      ? () async {
                                        try {
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
                              label: Text(
                                "Báo Cáo SX",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Icon(Icons.assignment, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            //confirm production
                            ElevatedButton.icon(
                              // onPressed:
                              //     selectedPlanningIds.length == 1
                              //         ? () async {
                              //           final selectedId =
                              //               selectedPlanningIds.first;

                              //           setState(() {
                              //             if (_producingOrderId == selectedId) {
                              //               _producingOrderId = null;
                              //             } else {
                              //               _producingOrderId = selectedId;
                              //             }

                              //             selectedPlanningIds.clear();
                              //           });

                              //           loadPlanning(false);
                              //         }
                              //         : null,
                              onPressed: () {},
                              label: Text(
                                "Xác Nhận SX",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            //choose machine
                            SizedBox(
                              width: 175,
                              child: DropdownButtonFormField<String>(
                                value: machine,
                                items:
                                    [
                                      "Máy In",
                                      "Máy Bế",
                                      "Máy Dán",
                                      "Máy Cắt Khe",
                                      "Máy Cấn Lằn",
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
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có đơn hàng nào"));
                  }

                  final List<PlanningPaper> data = snapshot.data!;

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
                    columns: buildMachineColumns(),
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
