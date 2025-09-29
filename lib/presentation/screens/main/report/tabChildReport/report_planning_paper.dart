import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:dongtam/presentation/components/dialog/dialog_option_export_excel.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_report_paper.dart';
import 'package:dongtam/presentation/sources/report_paper_data_source.dart';
import 'package:dongtam/service/report_planning_service.dart';
import 'package:dongtam/utils/helper/animated_button.dart';
import 'package:dongtam/utils/helper/pagination_controls.dart';
import 'package:dongtam/utils/helper/skeleton/skeleton_loading.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPlanningPaper extends StatefulWidget {
  const ReportPlanningPaper({super.key});

  @override
  State<ReportPlanningPaper> createState() => _ReportPlanningPaperState();
}

class _ReportPlanningPaperState extends State<ReportPlanningPaper> {
  late Future<Map<String, dynamic>> futureReportPaper;
  late ReportPaperDatasource reportPaperDatasource;
  late List<GridColumn> columns;
  List<int> selectedReportId = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  bool isTextFieldEnabled = false;
  bool isSearching = false;

  int currentPage = 1;
  int pageSize = 25;
  int pageSizeSearch = 20;

  @override
  void initState() {
    super.initState();
    loadReportPaper(true);

    columns = buildReportPaperColumn();
  }

  void loadReportPaper(bool refresh) {
    setState(() {
      if (isSearching) {
        String keyword = searchController.text.trim().toLowerCase();
        String date = dateController.text.trim().toLowerCase();

        AppLogger.d("loadReportPaper | search keyword=$keyword | date=$date");

        if (searchType == 'Tên KH') {
          futureReportPaper = ensureMinLoading(
            ReportPlanningService().getRPByCustomerName(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Theo Mã ĐH") {
          futureReportPaper = ensureMinLoading(
            ReportPlanningService().getRPByOrderId(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Ngày Báo Cáo") {
          futureReportPaper = ensureMinLoading(
            ReportPlanningService().getRPByDayReported(
              keyword: date,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "SL Báo Cáo") {
          futureReportPaper = ensureMinLoading(
            ReportPlanningService().getRPByQtyReported(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Ghép Khổ") {
          futureReportPaper = ensureMinLoading(
            ReportPlanningService().getRPByGhepKho(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        } else if (searchType == "Quản Ca") {
          futureReportPaper = ensureMinLoading(
            ReportPlanningService().getRPByShiftManagement(
              keyword: keyword,
              machine: machine,
              page: currentPage,
              pageSize: pageSizeSearch,
            ),
          );
        }
      } else {
        futureReportPaper = ensureMinLoading(
          ReportPlanningService().getReportPaper(
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

    AppLogger.i(
      "searchReportPaper => searchType=$searchType | keyword=$keyword | date=$date | machine=$machine",
    );

    if (isTextFieldEnabled && keyword.isEmpty) {
      AppLogger.w(
        "searchReportPaper => searchType=$searchType nhưng keyword rỗng",
      );
      return;
    }

    currentPage = 1;
    isSearching = (searchType != "Tất cả");

    switch (searchType) {
      case "Tất cả":
        setState(() {
          futureReportPaper = ReportPlanningService().getReportPaper(
            machine: machine,
            page: currentPage,
            pageSize: pageSize,
          );
        });
        break;
      case "Theo Mã ĐH":
        setState(() {
          futureReportPaper = ReportPlanningService().getRPByOrderId(
            keyword: keyword,
            machine: machine,
            page: currentPage,
            pageSize: pageSizeSearch,
          );
        });
        break;
      case "Tên KH":
        setState(() {
          futureReportPaper = ReportPlanningService().getRPByCustomerName(
            keyword: keyword,
            machine: machine,
            page: currentPage,
            pageSize: pageSizeSearch,
          );
        });
        break;
      case "Ngày Báo Cáo":
        setState(() {
          futureReportPaper = ReportPlanningService().getRPByDayReported(
            keyword: date,
            machine: machine,
            page: currentPage,
            pageSize: pageSizeSearch,
          );
        });
        break;
      case "SL Báo Cáo":
        setState(() {
          futureReportPaper = ReportPlanningService().getRPByQtyReported(
            keyword: keyword,
            machine: machine,
            page: currentPage,
            pageSize: pageSizeSearch,
          );
        });
        break;
      case "Ghép Khổ":
        setState(() {
          futureReportPaper = ReportPlanningService().getRPByGhepKho(
            keyword: keyword,
            machine: machine,
            page: currentPage,
            pageSize: pageSizeSearch,
          );
        });
        break;
      case "Quản Ca":
        setState(() {
          futureReportPaper = ReportPlanningService().getRPByShiftManagement(
            keyword: keyword,
            machine: machine,
            page: currentPage,
            pageSize: pageSizeSearch,
          );
        });
        break;
      default:
        break;
    }
  }

  void changeMachine(String selectedMachine) {
    AppLogger.i("changeMachine | from=$machine -> to=$selectedMachine");
    setState(() {
      machine = selectedMachine;
      selectedReportId.clear();
      loadReportPaper(true);
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
                                  "Ghép Khổ",
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
                                        () => loadReportPaper(false),
                                    machine: machine,
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
                future: futureReportPaper,
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
                      snapshot.data!['reportPapers'].isEmpty) {
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
                  final reportPapers =
                      data['reportPapers'] as List<ReportPaperModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  reportPaperDatasource = ReportPaperDatasource(
                    reportPapers: reportPapers,
                    selectedReportId: selectedReportId,
                  );

                  reportPaperDatasource.notifyListeners();

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: reportPaperDatasource,
                          columns: columns,
                          isScrollbarAlwaysShown: true,
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          columnWidthMode: ColumnWidthMode.auto,
                          navigationMode: GridNavigationMode.row,
                          selectionMode: SelectionMode.multiple,
                          headerRowHeight: 40,
                          rowHeight: 45,
                          stackedHeaderRows: <StackedHeaderRow>[
                            StackedHeaderRow(
                              cells: [
                                StackedHeaderCell(
                                  columnNames: [
                                    'quantityOrd',
                                    'runningPlanProd',
                                    'qtyReported',
                                    'LackOfQty',
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
                                final reportPaperId =
                                    row
                                        .getCells()
                                        .firstWhere(
                                          (cell) =>
                                              cell.columnName ==
                                              'reportPaperId',
                                        )
                                        .value;
                                if (selectedReportId.contains(reportPaperId)) {
                                  selectedReportId.remove(reportPaperId);
                                } else {
                                  selectedReportId.add(reportPaperId);
                                }
                              }

                              reportPaperDatasource.selectedReportId =
                                  selectedReportId;
                              reportPaperDatasource.notifyListeners();
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
                            loadReportPaper(false);
                          });
                        },
                        onNext: () {
                          setState(() {
                            currentPage++;
                            loadReportPaper(false);
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
        onPressed: () => loadReportPaper(true),
        backgroundColor: const Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
