import 'package:dongtam/data/models/report/report_planning_box.dart';
import 'package:dongtam/presentation/components/dialog/dialog_option_exportExcel.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_reportBox.dart';
import 'package:dongtam/presentation/sources/report_box_datasource.dart';
import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPlanningBox extends StatefulWidget {
  const ReportPlanningBox({super.key});

  @override
  State<ReportPlanningBox> createState() => _ReportPlanningBoxState();
}

class _ReportPlanningBoxState extends State<ReportPlanningBox> {
  late Future<Map<String, dynamic>> futureReportBox;
  late ReportBoxDatasource reportBoxDatasource;
  late List<GridColumn> columns;
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String searchType = "Tất cả";
  String machine = "Máy In";
  List<int> selectedReportId = [];
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadReportBox(true);

    columns = buildReportBoxColumn();
  }

  void loadReportBox(bool refresh) {
    setState(() {
      if (isSearching) {
        String keyword = searchController.text.trim().toLowerCase();
        String date = dateController.text.trim().toLowerCase();

        if (searchType == 'Tên KH') {
          futureReportBox = ensureMinLoading(
            ReportPlanningService().getRBByCustomerName(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Theo Mã ĐH") {
          futureReportBox = ensureMinLoading(
            ReportPlanningService().getRBByOrderId(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Ngày Báo Cáo") {
          futureReportBox = ensureMinLoading(
            ReportPlanningService().getRBByDayReported(
              keyword: date,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "SL Báo Cáo") {
          futureReportBox = ensureMinLoading(
            ReportPlanningService().getRBByQtyReported(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "QC Thùng") {
          futureReportBox = ensureMinLoading(
            ReportPlanningService().getRBByQcBox(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Quản Ca") {
          futureReportBox = ensureMinLoading(
            ReportPlanningService().getRBByShiftManagement(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        }
      } else {
        futureReportBox = ensureMinLoading(
          ReportPlanningService().getReportBox(
            machine: machine,
            page: currentPage,
            pageSize: pageSize,
            refresh: refresh,
          ),
        );
      }
    });
  }

  void searchReportPaper() {
    String keyword = searchController.text.trim().toLowerCase();
    String date = dateController.text.trim().toLowerCase();
    if (isTextFieldEnabled && keyword.isEmpty) return;

    currentPage = 1;
    if (searchType == "Tất cả") {
      setState(() {
        futureReportBox = ReportPlanningService().getReportBox(
          machine: machine,
          page: currentPage,
          pageSize: pageSize,
          refresh: false,
        );
      });
    } else if (searchType == "Theo Mã ĐH") {
      isSearching = true;
      setState(() {
        futureReportBox = ReportPlanningService().getRBByOrderId(
          keyword: keyword,
          machine: machine,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == 'Tên KH') {
      isSearching = true;
      setState(() {
        futureReportBox = ReportPlanningService().getRBByCustomerName(
          keyword: keyword,
          machine: machine,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "Ngày Báo Cáo") {
      isSearching = true;
      setState(() {
        futureReportBox = ReportPlanningService().getRBByDayReported(
          keyword: date,
          machine: machine,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "SL Báo Cáo") {
      isSearching = true;
      setState(() {
        futureReportBox = ReportPlanningService().getRBByQtyReported(
          keyword: keyword,
          machine: machine,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "QC Thùng") {
      isSearching = true;
      setState(() {
        futureReportBox = ReportPlanningService().getRBByQcBox(
          keyword: keyword,
          machine: machine,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    } else if (searchType == "Quản Ca") {
      isSearching = true;
      setState(() {
        futureReportBox = ReportPlanningService().getRBByShiftManagement(
          keyword: keyword,
          machine: machine,
          page: currentPage,
          pageSize: pageSizeSearch,
        );
      });
    }
  }

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      selectedReportId.clear();
      loadReportBox(true);
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
              height: 70,
              width: double.infinity,
              child: Row(
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
                                  "Theo Mã ĐH",
                                  'Tên KH',
                                  "Ngày Báo Cáo",
                                  "SL Báo Cáo",
                                  "QC Thùng",
                                  "Quản Ca",
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

                                searchController.clear();
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        //date picker or input
                        searchType == 'Ngày Báo Cáo'
                            ? SizedBox(
                              width: 250,
                              height: 50,
                              child: InkWell(
                                onTap: () async {
                                  final now = DateTime.now();

                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: now,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );

                                  if (picked != null) {
                                    final displayDate = DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(picked);

                                    setState(() {
                                      dateController.text =
                                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

                                      searchController.text = displayDate;
                                    });
                                  }
                                },
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Chọn ngày...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : SizedBox(
                              width: 250,
                              height: 50,
                              child: TextField(
                                controller: searchController,
                                enabled: isTextFieldEnabled,
                                onSubmitted: (_) => searchReportPaper(),
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
                        AnimatedButton(
                          onPressed: () => searchReportPaper(),
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
                        //export excel
                        AnimatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => DialogSelectExportExcel(
                                    selectedReportId: selectedReportId,
                                    onPlanningIdsOrRangeDate:
                                        () => loadReportBox(true),
                                    machine: machine,
                                    isBox: true,
                                  ),
                            );
                          },
                          label: "Xuất Excel",
                          icon: Icons.search,
                        ),
                        const SizedBox(width: 10),

                        //choose machine
                        SizedBox(
                          width: 175,
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
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
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
                        child: buildShimmerSkeletonTable(
                          context: context,
                          rowCount: 10,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['reportBoxes'].isEmpty) {
                    return const Center(
                      child: Text(
                        "Không có báo cáo nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final reportBoxes =
                      data['reportBoxes'] as List<ReportBoxModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  reportBoxDatasource = ReportBoxDatasource(
                    reportPapers: reportBoxes,
                    selectedReportId: selectedReportId,
                    machine: machine,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: reportBoxDatasource,
                          columns: columns,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          selectionMode: SelectionMode.single,
                          headerRowHeight: 40,
                          rowHeight: 45,
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
                                    'Báo Cáo Số Lượng Các Công Đoạn',
                                  ),
                                ),
                              ],
                            ),
                          ],
                          onSelectionChanged: (addedRows, removedRows) {
                            setState(() {
                              for (var row in addedRows) {
                                final reportPaperId =
                                    row
                                        .getCells()
                                        .firstWhere(
                                          (cell) =>
                                              cell.columnName == 'reportBoxId',
                                        )
                                        .value;
                                if (selectedReportId.contains(reportPaperId)) {
                                  selectedReportId.remove(reportPaperId);
                                } else {
                                  selectedReportId.add(reportPaperId);
                                }
                              }

                              reportBoxDatasource.selectedReportId =
                                  selectedReportId;
                              reportBoxDatasource.notifyListeners();
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
                            loadReportBox(false);
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadReportBox(false);
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
        onPressed: () => loadReportBox(true),
        backgroundColor: const Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
