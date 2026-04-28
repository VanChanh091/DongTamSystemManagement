import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_delivery_estimate.dart';
import 'package:dongtam/presentation/components/headerTable/planning/header_table_stages.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/presentation/components/shared/left_button_search.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/delivery/delivery_estimate_data_source.dart';
import 'package:dongtam/presentation/sources/planning/stages_data_source.dart';
import 'package:dongtam/service/dashboard_service.dart';
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

  //controller
  final dataGridController = DataGridController();
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  //width column
  Map<String, double> columnWidthsPlanning = {};
  Map<String, double> columnWidthsStage = {};
  List<PlanningStage> selectedStages = [];

  bool selectedAll = false;
  List<int> selectedPaperIds = [];
  List<PlanningPaper> planningList = [];

  //filter
  String allOrders = "false";
  final Map<String, String> filterOptions = {'false': 'Đơn Bản Thân', 'true': 'Tất Cả Đơn'};

  //search
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
  };

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dayStartController = TextEditingController();
  TextEditingController estimateTimeController = TextEditingController();

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false; //dùng để phân trang cho tìm kiếm

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 25;

  @override
  void initState() {
    super.initState();

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

    selectedPaperIds.clear();
    selectedStages = [];
  }

  void loadPlanningEstimate() {
    setState(() => _fetchData());
  }

  void searchPlanningEstimate() {
    String keyword = searchController.text.trim().toLowerCase();
    AppLogger.i("searchPlanningEstimate: searchType=$searchType, keyword='$keyword'");

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w("searchPlanningEstimate: search bị bỏ qua vì keyword trống");
      return;
    }

    setState(() {
      currentPage = 1;
      isSearching = (searchType != "Tất cả");
      _fetchData();
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
                        "ĐƠN HÀNG CHỜ SẢN XUẤT VÀ GIAO HÀNG",
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
                                    //search & button
                                    Row(
                                      children: [
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
                                                searchType == 'Tất cả'
                                                    ? searchController.clear()
                                                    : null;
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
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                //register delivery
                                                AnimatedButton(
                                                  onPressed:
                                                      selectedPaperIds.isEmpty ||
                                                              selectedPaperIds.length > 1
                                                          ? null
                                                          : () async {
                                                            await showInputQtyDialog(
                                                              context: context,
                                                              title: "Đăng Ký Giao Hàng",
                                                              onConfirm: (inputQty) async {
                                                                try {
                                                                  final success =
                                                                      await DeliveryService()
                                                                          .handlePutDelivery(
                                                                            planningId:
                                                                                selectedPaperIds,
                                                                            qtyRegistered: inputQty,
                                                                          );

                                                                  if (success) {
                                                                    if (context.mounted) {
                                                                      showSnackBarSuccess(
                                                                        context,
                                                                        "Xác nhận lên kế hoạch giao hàng thành công",
                                                                      );
                                                                    }
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
                                                  backgroundColor: themeController.buttonColor,
                                                ),
                                                const SizedBox(width: 10),

                                                //close planning
                                                AnimatedButton(
                                                  onPressed:
                                                      selectedPaperIds.isEmpty
                                                          ? null
                                                          : () async {
                                                            final bool
                                                            confirm = await showConfirmDialog(
                                                              context: context,
                                                              title: "Xác Nhận Đóng Kế Hoạch Này",
                                                              content:
                                                                  "Bạn có chắc chắn muốn đóng kế hoạch này?",
                                                              confirmText: "Xác Nhận",
                                                              confirmColor: const Color(0xffEA4346),
                                                            );

                                                            if (confirm) {
                                                              try {
                                                                final selectedPapers =
                                                                    planningList
                                                                        .where(
                                                                          (p) => selectedPaperIds
                                                                              .contains(
                                                                                p.planningId,
                                                                              ),
                                                                        )
                                                                        .toList();

                                                                final bool isBoxType =
                                                                    selectedPapers.any(
                                                                      (p) => p.hasBox == true,
                                                                    );

                                                                final success =
                                                                    await DeliveryService()
                                                                        .handlePutDelivery(
                                                                          planningId:
                                                                              selectedPaperIds,
                                                                          isPaper: !isBoxType,
                                                                        );

                                                                if (success) {
                                                                  if (context.mounted) {
                                                                    showSnackBarSuccess(
                                                                      context,
                                                                      "Đóng kế hoạch thành công",
                                                                    );
                                                                  }
                                                                  loadPlanningEstimate();
                                                                }
                                                              } on ApiException catch (e) {
                                                                if (!context.mounted) return;

                                                                switch (e.errorCode) {
                                                                  case "CANNOT_CLOSE_EMPTY_PAPER":
                                                                    showSnackBarError(
                                                                      context,
                                                                      e.message!,
                                                                    );
                                                                    break;
                                                                  case "NO_INBOUND_HISTORY":
                                                                    showSnackBarError(
                                                                      context,
                                                                      e.message!,
                                                                    );
                                                                    break;
                                                                  default:
                                                                    showSnackBarError(
                                                                      context,
                                                                      "Có lỗi khi đóng đơn hàng",
                                                                    );
                                                                }
                                                              } catch (e) {
                                                                if (context.mounted) {
                                                                  showSnackBarError(
                                                                    context,
                                                                    "Có lỗi khi đóng kế hoạch",
                                                                  );
                                                                }
                                                              }
                                                            }
                                                          },
                                                  label: "Đóng Kế Hoạch",
                                                  icon: Icons.delete,
                                                  backgroundColor: const Color(0xffEA4346),
                                                ),

                                                const SizedBox(width: 10),

                                                //filter
                                                buildDropdownItems(
                                                  value: allOrders,
                                                  items: const ['false', 'true'],
                                                  onChanged:
                                                      (value) => {
                                                        setState(() {
                                                          allOrders = value!;
                                                          selectedPaperIds.clear();
                                                          loadPlanningEstimate();
                                                        }),
                                                      },
                                                  itemLabelBuilder:
                                                      (value) => filterOptions[value] ?? value,
                                                ),
                                                const SizedBox(width: 10),
                                              ],
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

                  final dbPlanning = data['plannings'] as List<PlanningPaper>;
                  planningList = dbPlanning;

                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  deliveryDataSource = DeliveryEstimateDataSource(
                    delivery: dbPlanning,
                    selectedPaperIds: selectedPaperIds,
                    currentPage: currentPage,
                    pageSize: pageSize,
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
                                          'quantityOrd',
                                          'qtyProduced',
                                          'runningPlanProd',
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

                                  final List<int> ids =
                                      dataGridController.selectedRows.map((row) {
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
                                    selectedPaperIds = ids;
                                  });

                                  if (ids.length == 1) {
                                    final int targetId = ids.first;

                                    final stages = await DashboardService().getDbPlanningDetail(
                                      planningId: targetId,
                                    );

                                    setState(() {
                                      selectedStages = stages;
                                    });
                                  } else {
                                    setState(() {
                                      selectedStages = [];
                                    });
                                  }
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

Future<bool?> showInputQtyDialog({
  required BuildContext context,
  required String title,
  required Future<bool> Function(int) onConfirm,
}) async {
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            content: SizedBox(
              width: 350,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Nhập số lượng muốn giao",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Không được để trống";
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) return "Số lượng phải lớn hơn 0";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text(
                  "Hủy",
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
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            final success = await onConfirm(int.parse(controller.text));
                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context, true);
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          }
                        },
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                        : const Text(
                          'Xác nhận',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
              ),
            ],
          );
        },
      );
    },
  );
}
