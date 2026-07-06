import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_box_model.dart';
import 'package:dongtam/presentation/components/headerTable/report/header_table_inspection_box.dart';
import 'package:dongtam/presentation/components/shared/pagination_controls.dart';
import 'package:dongtam/presentation/components/shared/planning/widgets_planning.dart';
import 'package:dongtam/presentation/sources/report/inspection_box_data_source.dart';
import 'package:dongtam/service/quality_control_service.dart';
import 'package:dongtam/utils/helper/grid_resize_helper.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/storage/sharedPreferences/column_width_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportInspectionBox extends StatefulWidget {
  const ReportInspectionBox({super.key});

  @override
  State<ReportInspectionBox> createState() => _ReportInspectionBoxState();
}

class _ReportInspectionBoxState extends State<ReportInspectionBox> {
  late Future<Map<String, dynamic>> futureReportBox;
  late InspectionBoxDataSource inspectionBoxDatasource;

  //controller
  final dataGridController = DataGridController();
  final themeController = Get.find<ThemeController>();

  String machine = "Máy In";
  String searchType = "Tất cả";
  final Map<String, String> searchFieldMap = {
    "Mã Đơn Hàng": "orderId",
    "Tên Khách Hàng": "customerName",
    "Ngày Báo Cáo": "dayReported",
    "Trưởng Máy": "shiftManagement",
  };

  //text controller
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  List<int> selectedBoxIds = [];
  Map<String, double> columnWidths = {}; //map header table

  //flag
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  //date range
  DateTime? startDate;
  DateTime? endDate;

  //paging
  int currentPage = 1;
  int pageSize = 35;
  int pageSizeSearch = 30;

  @override
  void initState() {
    super.initState();
    loadInspectionBox();

    final initialColumns = buildInspectionBoxColumn(
      themeController: themeController,
      machine: machine,
    );

    ColumnWidthTable.loadWidths(tableKey: 'inspectionBox', columns: initialColumns).then((w) {
      setState(() {
        columnWidths = w;
      });
    });
  }

  void _fetchData() {
    // final String keyword = searchController.text.trim().toLowerCase();
    // final String selectedField = searchFieldMap[searchType] ?? "";

    // Điều kiện để xác định có thực hiện search hay load mặc định
    // final bool shouldSearch = isSearching && searchType != "Tất cả";
    // final bool isDateSearch = searchType == "Ngày Báo Cáo";

    futureReportBox = ensureMinLoading(
      QualityControlService().getQcInspection(
        isPaper: 'box',
        page: currentPage,
        pageSize: pageSize,
        machine: machine,
        fromJson: (json) => QcInspectionBoxModel.fromJson(json),
      ),
    );

    selectedBoxIds.clear();
  }

  void loadInspectionBox() {
    setState(() => _fetchData());
  }

  // void searchReportBox() {
  //   String keyword = searchController.text.trim().toLowerCase();
  //   final bool isDateSearch = searchType == "Ngày Báo Cáo";

  //   if (isDateSearch) {
  //     if (startDate == null || endDate == null) {
  //       AppLogger.w("searchOrders => chưa chọn khoảng thời gian");
  //       return;
  //     }
  //   } else if (isTextFieldEnabled && keyword.isEmpty) {
  //     AppLogger.w("searchReportPaper => searchType=$searchType nhưng keyword rỗng");
  //     return;
  //   }

  //   setState(() {
  //     currentPage = 1;
  //     isSearching = (searchType != "Tất cả");
  //     _fetchData();
  //   });
  // }

  void changeMachine(String newMachine) {
    setState(() {
      machine = newMachine;
      selectedBoxIds.clear();
      loadInspectionBox();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    dateController.dispose();
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
                      child: Obx(
                        () => Text(
                          "LỊCH SỬ KIỂM TRA CHẤT LƯỢNG LÀM THÙNG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
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
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //export excel
                                // AnimatedButton(
                                //   onPressed: () async {
                                //     showDialog(
                                //       context: context,
                                //       builder:
                                //           (_) => DialogSelectExportExcel(
                                //             onPlanningIdsOrRangeDate: () => loadReportPaper(),
                                //             machine: machine,
                                //           ),
                                //     );
                                //   },
                                //   label: "Xuất Excel",
                                //   icon: Symbols.export_notes,
                                //   backgroundColor: themeController.buttonColor,
                                // ),
                                const SizedBox(width: 10),

                                //choose machine
                                buildDropdownItems(
                                  value: machine,
                                  items: const [
                                    'Máy In',
                                    "Máy Bế",
                                    "Máy Xả",
                                    "Máy Dán",
                                    'Máy Cấn Lằn',
                                    "Máy Cắt Khe",
                                    "Máy Cán Màng",
                                    "Máy Đóng Ghim",
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      changeMachine(value);
                                    }
                                  },
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

            //table
            Expanded(
              child: FutureBuilder(
                future: futureReportBox,
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
                  } else if (!snapshot.hasData || snapshot.data!['inspectionBoxes'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final inspectionBoxes = data['inspectionBoxes'] as List<QcInspectionBoxModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  inspectionBoxDatasource = InspectionBoxDataSource(
                    inspectionBoxes: inspectionBoxes,
                    selectedBoxIds: selectedBoxIds,
                    machine: machine,
                    currentPage: currentPage,
                    pageSize: pageSize,
                  );

                  final dynamicColumns = buildInspectionBoxColumn(
                    themeController: themeController,
                    machine: machine,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          key: ValueKey(machine), // Thêm key để rebuild khi máy thay đổi
                          controller: dataGridController,
                          source: inspectionBoxDatasource,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          navigationMode: GridNavigationMode.row,
                          selectionMode: SelectionMode.multiple,
                          headerRowHeight: 35,
                          rowHeight: 38,
                          columns: ColumnWidthTable.applySavedWidths(
                            columns: dynamicColumns,
                            widths: columnWidths,
                          ),
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: [
                                    "orderId",
                                    "customerName",
                                    "productName",
                                    "structure",
                                    "sizePaper",
                                    "lengthPaper",
                                    "runningPlan",
                                    "qcBox",
                                  ],
                                  child: Obx(
                                    () => formatColumn(
                                      label: "Thông Tin Đơn Hàng",
                                      themeController: themeController,
                                    ),
                                  ),
                                ),
                                StackedHeaderCell(
                                  columnNames: [
                                    "boxDimension",
                                    "colorCount",
                                    "colorMatch",
                                    "colorRegistration",
                                    "fluteCrushing",
                                    "glueAdhesion",
                                    "glueViscosity",
                                    "imagePosition",
                                    "jointGap",
                                    "jointMisalignment",
                                    "paperSurface",
                                    "printContent",
                                    "printSharpness",
                                    "scoringLine",
                                    "stitchCount",
                                    "stitchHolding",
                                    "stitchPitch",
                                    "stitchPosition",
                                    "tabOverlap",
                                    "trimLineBurr",
                                  ],
                                  child: formatColumn(
                                    label: "Lỗi",
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
                                columns: dynamicColumns,
                                setState: setState,
                              ),
                          onColumnResizeEnd:
                              (details) => GridResizeHelper.onResizeEnd(
                                details: details,
                                tableKey: 'inspectionBox',
                                columnWidths: columnWidths,
                                setState: setState,
                              ),

                          onSelectionChanged: (addedRows, removedRows) {
                            if (addedRows.isEmpty && removedRows.isEmpty) return;

                            setState(() {
                              // Lấy selection thật sự từ controller
                              final selectedRows = dataGridController.selectedRows;

                              selectedBoxIds =
                                  selectedRows
                                      .map((row) {
                                        final cell = row.getCells().firstWhere(
                                          (c) => c.columnName == 'inspecBoxId',
                                          orElse:
                                              () => const DataGridCell(
                                                columnName: 'inspecBoxId',
                                                value: '',
                                              ),
                                        );
                                        return int.tryParse(cell.value.toString()) ?? 0;
                                      })
                                      .where((id) => id != 0)
                                      .toList();

                              // cập nhật cho datasource
                              inspectionBoxDatasource.selectedBoxIds = selectedBoxIds;
                              inspectionBoxDatasource.notifyListeners();
                            });
                          },
                        ),
                      ),

                      // Nút chuyển trang
                      PaginationControls(
                        currentPage: currentPg,
                        totalPages: totalPgs,
                        onPrevious: () {
                          setState(() {
                            currentPage--;
                            loadInspectionBox();
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadInspectionBox();
                          });
                        },
                        onJumpToPage: (page) {
                          setState(() {
                            currentPage = page;
                            loadInspectionBox();
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
        onPressed: () => loadInspectionBox(),
        backgroundColor: themeController.buttonColor.value,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
