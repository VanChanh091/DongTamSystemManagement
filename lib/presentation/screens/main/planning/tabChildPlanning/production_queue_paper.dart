import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_change_machine.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine_paper.dart';
import 'package:dongtam/presentation/sources/machine_paper_data_source.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProductionQueuePaper extends StatefulWidget {
  const ProductionQueuePaper({super.key});

  @override
  State<ProductionQueuePaper> createState() => _ProductionQueuePaperState();
}

class _ProductionQueuePaperState extends State<ProductionQueuePaper> {
  late Future<List<PlanningPaper>> futurePlanning;
  late MachinePaperDatasource machinePaperDatasource;
  late List<GridColumn> columns;
  final DataGridController dataGridController = DataGridController();
  final badgesController = Get.find<BadgesController>();
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');
  final Map<String, int> orderIdToPlanningId = {};
  final Map<String, String> orderIdToStatus = {};
  List<String> selectedPlanningIds = [];
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  DateTime selectedDate = DateTime.now();
  DateTime? dayStart = DateTime.now();
  bool isLoading = false;
  bool isTextFieldEnabled = false;
  bool showGroup = true;

  TextEditingController searchController = TextEditingController();
  TextEditingController dayStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController totalTimeWorkingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (userController.hasPermission("plan")) {
      loadPlanning(true);
    } else {
      futurePlanning = Future.error("NO_PERMISSION");
    }

    columns = buildMachineColumns(isShowPlanningPaper: true);
  }

  void loadPlanning(bool refresh) {
    setState(() {
      futurePlanning = ensureMinLoading(
        PlanningService().getPlanningPaperByMachine(machine, refresh).then((
          planningList,
        ) {
          orderIdToPlanningId.clear();
          selectedPlanningIds.clear();
          for (var planning in planningList) {
            orderIdToPlanningId[planning.orderId] = planning.planningId;
            orderIdToStatus[planning.orderId] = planning.status;
          }
          // print('planningId:$orderIdToPlanningId');
          // print('status:$orderIdToStatus');
          return planningList;
        }),
      );
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
      loadPlanning(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlan = userController.hasPermission("plan");

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
              child:
                  isPlan
                      ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //left button
                              Container(
                                padding: const EdgeInsets.symmetric(
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
                                            isTextFieldEnabled =
                                                searchType != 'Tất cả';

                                            searchController.clear();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // find
                                    AnimatedButton(
                                      onPressed: () => searchPlanning(),
                                      label: "Tìm kiếm",
                                      icon: Icons.search,
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),

                              //right button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    // nút lên xuống
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_upward),
                                          onPressed:
                                              selectedPlanningIds.isNotEmpty
                                                  ? () {
                                                    setState(() {
                                                      machinePaperDatasource
                                                          .moveRowUp(
                                                            selectedPlanningIds,
                                                          );
                                                    });
                                                  }
                                                  : null,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.arrow_downward,
                                          ),
                                          onPressed:
                                              selectedPlanningIds.isNotEmpty
                                                  ? () {
                                                    setState(() {
                                                      machinePaperDatasource
                                                          .moveRowDown(
                                                            selectedPlanningIds,
                                                          );
                                                    });
                                                  }
                                                  : null,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),

                                    // save
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedButton(
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
                                                      return;
                                                    }

                                                    setState(
                                                      () => isLoading = true,
                                                    );

                                                    try {
                                                      final List<DataGridRow>
                                                      visibleRows =
                                                          machinePaperDatasource
                                                              .rows;

                                                      // 1️⃣ Lấy các đơn chưa complete và gán sortPlanning
                                                      final List<
                                                        Map<String, dynamic>
                                                      >
                                                      updateIndex =
                                                          visibleRows
                                                              .asMap()
                                                              .entries
                                                              .where((entry) {
                                                                final status =
                                                                    entry.value
                                                                        .getCells()
                                                                        .firstWhere(
                                                                          (
                                                                            cell,
                                                                          ) =>
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
                                                                          (
                                                                            cell,
                                                                          ) =>
                                                                              cell.columnName ==
                                                                              "planningId",
                                                                        )
                                                                        .value;

                                                                return {
                                                                  "planningId":
                                                                      planningId,
                                                                  "sortPlanning":
                                                                      entry
                                                                          .key +
                                                                      1,
                                                                };
                                                              })
                                                              .toList();

                                                      // 2️⃣ Lấy 1 đơn complete cuối cùng (để BE tính timeRunning, không update sortPlanning)
                                                      DataGridRow?
                                                      lastCompleteRow;

                                                      for (var row
                                                          in visibleRows
                                                              .reversed) {
                                                        final status =
                                                            row
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

                                                        if (status ==
                                                            'complete') {
                                                          lastCompleteRow = row;
                                                          break;
                                                        }
                                                      }

                                                      if (lastCompleteRow !=
                                                          null) {
                                                        final planningId =
                                                            lastCompleteRow
                                                                .getCells()
                                                                .firstWhere(
                                                                  (cell) =>
                                                                      cell.columnName ==
                                                                      "planningId",
                                                                )
                                                                .value;

                                                        updateIndex.add({
                                                          "planningId":
                                                              planningId,
                                                        });
                                                      }

                                                      // 3️⃣ Parse ngày, giờ, tổng thời gian
                                                      final DateTime
                                                      parsedDayStart =
                                                          DateFormat(
                                                            'dd/MM/yyyy',
                                                          ).parse(
                                                            dayStartController
                                                                .text,
                                                          );

                                                      final List<String>
                                                      timeParts =
                                                          timeStartController
                                                              .text
                                                              .split(':');
                                                      final TimeOfDay
                                                      parsedTimeStart =
                                                          TimeOfDay(
                                                            hour: int.parse(
                                                              timeParts[0],
                                                            ),
                                                            minute: int.parse(
                                                              timeParts[1],
                                                            ),
                                                          );

                                                      final int
                                                      parsedTotalTime =
                                                          int.tryParse(
                                                            totalTimeWorkingController
                                                                .text,
                                                          ) ??
                                                          0;

                                                      // 4️⃣ Gửi xuống BE
                                                      // print(
                                                      //   "=== Các đơn sẽ gửi xuống BE ===",
                                                      // );
                                                      // for (var item
                                                      //     in updateIndex) {
                                                      //   print(item);
                                                      // }
                                                      // print(
                                                      //   "================================",
                                                      // );

                                                      final result =
                                                          await PlanningService()
                                                              .updateIndexWTimeRunning(
                                                                machine,
                                                                updateIndex,
                                                                parsedDayStart,
                                                                parsedTimeStart,
                                                                parsedTotalTime,
                                                              );

                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      if (result) {
                                                        showSnackBarSuccess(
                                                          context,
                                                          "Cập nhật thành công",
                                                        );
                                                        loadPlanning(true);
                                                      }
                                                    } catch (e, s) {
                                                      showSnackBarError(
                                                        context,
                                                        "Lỗi cập nhật",
                                                      );
                                                      AppLogger.e(
                                                        "Lỗi khi lưu",
                                                        error: e,
                                                        stackTrace: s,
                                                      );
                                                    } finally {
                                                      setState(
                                                        () => isLoading = false,
                                                      );
                                                    }
                                                  },
                                          label: "Lưu",
                                          icon: Icons.save,
                                        ),

                                        if (isLoading)
                                          const Positioned(
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
                                    AnimatedButton(
                                      onPressed: () {
                                        setState(() {
                                          showGroup = !showGroup;
                                        });
                                      },
                                      label:
                                          showGroup ? 'Tắt nhóm' : 'Bật nhóm',
                                      icon:
                                          showGroup
                                              ? Symbols.ungroup
                                              : Symbols.ad_group,
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    //popup menu
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.black,
                                      ),
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

                                          if (!context.mounted) return;

                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => ChangeMachineDialog(
                                                  planning:
                                                      planning
                                                          .where(
                                                            (p) =>
                                                                selectedPlanningIds
                                                                    .contains(
                                                                      p.orderId,
                                                                    ),
                                                          )
                                                          .toList(),
                                                  onChangeMachine:
                                                      () => loadPlanning(true),
                                                ),
                                          );
                                        } else if (value == 'pause') {
                                          await handlePlanningAction(
                                            context: context,
                                            selectedPlanningIds:
                                                selectedPlanningIds,
                                            status: "pending",
                                            title: "Xác nhận dừng sản xuất",
                                            message:
                                                "Bạn có chắc muốn dừng các kế hoạch đã chọn không?",
                                            successMessage:
                                                "Dừng sản xuất thành công",
                                            errorMessage:
                                                "Có lỗi xảy ra khi dừng sản xuất",
                                            onSuccess:
                                                () => {
                                                  loadPlanning(true),
                                                  badgesController
                                                      .fetchPendingApprovals(),
                                                },
                                          );
                                        } else if (value == 'acceptLack') {
                                          await handlePlanningAction(
                                            context: context,
                                            selectedPlanningIds:
                                                selectedPlanningIds,
                                            status: "complete",
                                            title: "Xác nhận thiếu số lượng",
                                            message:
                                                "Bạn có chắc muốn chấp nhận thiếu không?",
                                            successMessage:
                                                "Thực thi thành công",
                                            errorMessage:
                                                "Có lỗi xảy ra khi thực thi",
                                            onSuccess: () => loadPlanning(true),
                                          );
                                        }
                                      },
                                      itemBuilder:
                                          (BuildContext context) => [
                                            const PopupMenuItem<String>(
                                              value: 'change',
                                              child: ListTile(
                                                leading: Icon(
                                                  Symbols.construction,
                                                ),
                                                title: Text('Chuyển Máy'),
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'pause',
                                              child: ListTile(
                                                leading: Icon(
                                                  Symbols.pause_circle,
                                                ),
                                                title: Text('Dừng Chạy Đơn'),
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'acceptLack',
                                              child: ListTile(
                                                leading: Icon(
                                                  Icons.approval_outlined,
                                                ),
                                                title: Text(
                                                  'Chấp Nhận Thiếu SL',
                                                ),
                                              ),
                                            ),
                                          ],
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          //set day and time for time running
                          const SizedBox(height: 5),
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
                                  readOnly: true,
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
                                const SizedBox(width: 32),

                                // Giờ bắt đầu
                                _buildLabelAndUnderlineInput(
                                  label: "Giờ bắt đầu:",
                                  controller: timeStartController,
                                  width: 60,
                                ),
                                const SizedBox(width: 32),

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
                      )
                      : const SizedBox.shrink(),
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
                        child: buildShimmerSkeletonTable(
                          context: context,
                          rowCount: 10,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    if (snapshot.error.toString().contains("NO_PERMISSION")) {
                      return const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.redAccent,
                              size: 35,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Bạn không có quyền xem chức năng này",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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

                  machinePaperDatasource = MachinePaperDatasource(
                    planning: data,
                    selectedPlanningIds: selectedPlanningIds,
                    showGroup: showGroup,
                    isShowPlanningPaper: true,
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
                              'totalLoss',
                            ],
                            child: formatColumn('Định Mức Phế Liệu'),
                          ),
                          StackedHeaderCell(
                            columnNames: [
                              'inMatTruoc',
                              'inMatSau',
                              'canLanBox',
                              'canMang',
                              'xa',
                              'catKhe',
                              'be',
                              'dan_1_Manh',
                              'dan_2_Manh',
                              'dongGhimMotManh',
                              'dongGhimHaiManh',
                              'chongTham',
                              'dongGoi',
                              'maKhuon',
                            ],
                            child: formatColumn('Công Đoạn 2'),
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
      floatingActionButton:
          isPlan
              ? FloatingActionButton(
                onPressed: () => loadPlanning(true),
                backgroundColor: const Color(0xff78D761),
                child: const Icon(Icons.refresh, color: Colors.white),
              )
              : null,
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

    // final hasCompletedOrder = selectedPlanningIds.any(
    //   (orderId) => orderIdToStatus[orderId] == "complete",
    // );

    // if (hasCompletedOrder) {
    //   showSnackBarError(context, "Không thể thao tác với đơn đã hoàn thành");
    //   return;
    // }

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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
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
          planningIds,
          status,
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

  Widget _buildLabelAndUnderlineInput({
    required String label,
    required TextEditingController controller,
    required double width,
    TextInputType? inputType,
    void Function()? onTap,
    bool readOnly = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: width,
          child: TextFormField(
            controller: controller,
            keyboardType: inputType ?? TextInputType.text,
            readOnly: readOnly,
            decoration: InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              hintText: '',
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
