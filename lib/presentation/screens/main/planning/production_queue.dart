import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_change_machine.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine.dart';
import 'package:dongtam/presentation/sources/machine_dataSource.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionQueue extends StatefulWidget {
  const ProductionQueue({super.key});

  @override
  State<ProductionQueue> createState() => _ProductionQueueState();
}

class _ProductionQueueState extends State<ProductionQueue> {
  late Future<List<Planning>> futurePlanning;
  late MachineDatasource machineDatasource;
  String searchType = "Tất cả";
  String machine = "Máy 1350";
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
          .getPlanningByMachine(machine, refresh)
          .then((planningList) {
            orderIdToPlanningId.clear();
            selectedPlanningIds.clear();
            for (var planning in planningList) {
              if (planning.step == 'paper') {
                orderIdToPlanningId[planning.orderId] = planning.planningId;
              }
            }
            // print(orderIdToPlanningId);
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
              height: 105,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //left button
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            //dropdown
                            SizedBox(
                              width: 160,
                              child: DropdownButtonFormField<String>(
                                value: searchType,
                                items:
                                    [
                                      'Tất cả',
                                      'Mã Đơn Hàng',
                                      'Tên KH',
                                      "Sóng",
                                      'Khổ Cấp Giấy',
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    searchType = value!;
                                    isTextFieldEnabled = searchType != 'Tất cả';

                                    if (!isTextFieldEnabled) {
                                      searchController.clear();
                                    }
                                  });
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

                            // input
                            SizedBox(
                              width: 250,
                              height: 50,
                              child: TextField(
                                controller: searchController,
                                enabled: isTextFieldEnabled,
                                onSubmitted: (_) => searchPlanning(),
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // find
                            ElevatedButton.icon(
                              onPressed: () {
                                searchPlanning();
                              },
                              label: Text(
                                "Tìm kiếm",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon: Icon(Icons.search, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),

                      //right button
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            // nút lên xuống
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_upward),
                                  onPressed:
                                      selectedPlanningIds.isNotEmpty
                                          ? () {
                                            setState(() {
                                              machineDatasource.moveRowUp(
                                                selectedPlanningIds,
                                              );
                                            });
                                          }
                                          : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed:
                                      selectedPlanningIds.isNotEmpty
                                          ? () {
                                            setState(() {
                                              machineDatasource.moveRowDown(
                                                selectedPlanningIds,
                                              );
                                            });
                                          }
                                          : null,
                                ),
                              ],
                            ),
                            SizedBox(width: 20),

                            // save
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () async {
                                            if (dayStartController
                                                    .text
                                                    .isEmpty ||
                                                timeStartController
                                                    .text
                                                    .isEmpty ||
                                                totalTimeWorkingController
                                                    .text
                                                    .isEmpty) {
                                              showSnackBarError(
                                                context,
                                                "Vui lòng nhập đầy đủ ngày bắt đầu, giờ bắt đầu và tổng thời gian.",
                                              );
                                            }
                                            setState(() => isLoading = true);

                                            try {
                                              final List<DataGridRow>
                                              visibleRows =
                                                  machineDatasource.rows;

                                              final List<Map<String, dynamic>>
                                              updateIndex =
                                                  visibleRows
                                                      .asMap()
                                                      .entries
                                                      .where((entry) {
                                                        // Lấy giá trị status từ row
                                                        final status =
                                                            entry.value
                                                                .getCells()
                                                                .firstWhere(
                                                                  (cell) =>
                                                                      cell.columnName ==
                                                                      "status",
                                                                  orElse:
                                                                      () => DataGridCell(
                                                                        columnName:
                                                                            'status',
                                                                        value:
                                                                            null,
                                                                      ),
                                                                )
                                                                .value;

                                                        return status !=
                                                            'complete';
                                                      })
                                                      .map((entry) {
                                                        final planningId =
                                                            entry.value
                                                                .getCells()
                                                                .firstWhere(
                                                                  (cell) =>
                                                                      cell.columnName ==
                                                                      "planningId",
                                                                )
                                                                .value;

                                                        return {
                                                          "planningId":
                                                              planningId,
                                                          "sortPlanning":
                                                              entry.key + 1,
                                                        };
                                                      })
                                                      .toList();

                                              final DateTime parsedDayStart =
                                                  DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).parse(
                                                    dayStartController.text,
                                                  );

                                              final List<String> timeParts =
                                                  timeStartController.text
                                                      .split(':');

                                              final TimeOfDay
                                              parsedTimeStart = TimeOfDay(
                                                hour: int.parse(timeParts[0]),
                                                minute: int.parse(timeParts[1]),
                                              );

                                              final int parsedTotalTime =
                                                  int.tryParse(
                                                    totalTimeWorkingController
                                                        .text,
                                                  ) ??
                                                  0;

                                              final result =
                                                  await PlanningService()
                                                      .updateIndexWTimeRunning(
                                                        machine,
                                                        updateIndex,
                                                        parsedDayStart,
                                                        parsedTimeStart,
                                                        parsedTotalTime,
                                                      );

                                              if (result) {
                                                showSnackBarSuccess(
                                                  context,
                                                  "Cập nhật thành công",
                                                );
                                                loadPlanning(true);
                                              }
                                            } catch (e) {
                                              showSnackBarError(
                                                context,
                                                "Lỗi cập nhật",
                                              );
                                              print("Lỗi khi lưu: $e");
                                            } finally {
                                              setState(() => isLoading = false);
                                            }
                                          },
                                  label: Text(
                                    "Lưu",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  icon: Icon(Icons.save, color: Colors.white),
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
                                if (isLoading)
                                  Positioned(
                                    right: 10,
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(width: 10),

                            //group/unGroup
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  showGroup = !showGroup;
                                });
                              },
                              label: Text(
                                showGroup ? 'Tắt nhóm' : 'Bật nhóm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              icon:
                                  showGroup
                                      ? Icon(
                                        Symbols.ungroup,
                                        color: Colors.white,
                                      )
                                      : Icon(
                                        Symbols.ad_group,
                                        color: Colors.white,
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
                            SizedBox(width: 10),

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

                            //popup menu
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.black),
                              color: Colors.white,
                              onSelected: (value) async {
                                if (value == 'change') {
                                  if (selectedPlanningIds.isEmpty) {
                                    showSnackBarError(
                                      context,
                                      "Chưa chọn kế hoạch cần chuyển máy",
                                    );
                                    return;
                                  }
                                  final planning = await futurePlanning;

                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => ChangeMachineDialog(
                                          planning:
                                              planning
                                                  .where(
                                                    (p) => selectedPlanningIds
                                                        .contains(p.orderId),
                                                  )
                                                  .toList(),
                                          onChangeMachine:
                                              () => loadPlanning(true),
                                        ),
                                  );
                                } else if (value == 'pause') {
                                  await handlePlanningAction(
                                    context: context,
                                    selectedPlanningIds: selectedPlanningIds,
                                    status: "pending",
                                    title: "Xác nhận dừng sản xuất",
                                    message:
                                        "Bạn có chắc muốn dừng các kế hoạch đã chọn không?",
                                    successMessage: "Dừng sản xuất thành công",
                                    errorMessage:
                                        "Có lỗi xảy ra khi dừng sản xuất",
                                    onSuccess: () => loadPlanning(true),
                                  );
                                } else if (value == 'acceptLack') {
                                  await handlePlanningAction(
                                    context: context,
                                    selectedPlanningIds: selectedPlanningIds,
                                    status: "complete",
                                    title: "Xác nhận thiếu số lượng",
                                    message:
                                        "Bạn có chắc muốn chấp nhận thiếu không?",
                                    successMessage: "Thực thi thành công",
                                    errorMessage: "Có lỗi xảy ra khi thực thi",
                                    onSuccess: () => loadPlanning(true),
                                  );
                                }
                              },
                              itemBuilder:
                                  (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'change',
                                      child: ListTile(
                                        leading: Icon(Symbols.construction),
                                        title: Text('Chuyển Máy'),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'pause',
                                      child: ListTile(
                                        leading: Icon(Symbols.pause_circle),
                                        title: Text('Dừng Chạy Đơn'),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'acceptLack',
                                      child: ListTile(
                                        leading: Icon(Icons.approval_outlined),
                                        title: Text('Chấp Nhận Thiếu Đơn'),
                                      ),
                                    ),
                                  ],
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //set day and time for time running
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Ngày bắt đầu
                        _buildLabelAndUnderlineInput(
                          label: "Ngày bắt đầu:",
                          controller: dayStartController,
                          width: 120,
                          onTap: () async {
                            final selected = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (selected != null) {
                              dayStartController.text =
                                  "${selected.day.toString().padLeft(2, '0')}/"
                                  "${selected.month.toString().padLeft(2, '0')}/"
                                  "${selected.year}";
                            }
                          },
                        ),
                        SizedBox(width: 32),

                        // Giờ bắt đầu
                        _buildLabelAndUnderlineInput(
                          label: "Giờ bắt đầu:",
                          controller: timeStartController,
                          width: 60,
                        ),
                        SizedBox(width: 32),

                        // Tổng giờ làm
                        _buildLabelAndUnderlineInput(
                          label: "Tổng giờ làm:",
                          controller: totalTimeWorkingController,
                          width: 40,
                          inputType: TextInputType.number,
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
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có đơn hàng nào"));
                  }

                  final List<Planning> data = snapshot.data!;

                  machineDatasource = MachineDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                  );

                  return SfDataGrid(
                    controller: dataGridController,
                    source: machineDatasource,
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

                        machineDatasource.selectedPlanningIds =
                            selectedPlanningIds;
                        machineDatasource.notifyListeners();
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

  Widget _buildLabelAndUnderlineInput({
    required String label,
    required TextEditingController controller,
    required double width,
    TextInputType? inputType,
    void Function()? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: width,
          child: TextFormField(
            controller: controller,
            keyboardType: inputType ?? TextInputType.text,
            readOnly: false,
            decoration: InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              hintText: '',
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
