import 'package:dongtam/data/models/report/report_production_model.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_report.dart';
import 'package:dongtam/presentation/sources/report_dataSource.dart';
import 'package:dongtam/service/report_production_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportProduction extends StatefulWidget {
  const ReportProduction({super.key});

  @override
  State<ReportProduction> createState() => _ReportProductionState();
}

class _ReportProductionState extends State<ReportProduction> {
  late Future<Map<String, dynamic>> futureReportProduction;
  late ReportDatasource reportDatasource;
  TextEditingController searchController = TextEditingController();
  String? selectedReport;
  bool isTextFieldEnabled = false;
  bool showGroup = true;
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  DateTime? fromDate;
  DateTime? toDate;

  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadReportProduction();
  }

  void loadReportProduction() {
    setState(() {
      futureReportProduction = ReportProductionService().getReportProdByMachine(
        machine,
        currentPage,
        45,
      );
    });
  }

  void changeMachine(String selectedMachine) {
    setState(() {
      machine = selectedMachine;
      loadReportProduction();
    });
  }

  void searchReport() {
    String keyword = searchController.text.trim().toLowerCase();

    if (searchType == "Tất cả") {
      setState(() {
        futureReportProduction = ReportProductionService()
            .getReportProdByMachine(machine, currentPage, 45);
      });
    } else if (searchType == "Theo Quản Ca") {
      if (keyword.isEmpty) return;
      // setState(() {
      //   futureReportProduction = ReportProductionService()
      //       .getReportByShiftManagement(keyword, machine);
      // });
    } else if (searchType == "Theo Ngày") {
      if (fromDate == null || toDate == null) {
        showSnackBarError(context, "Vui lòng chọn khoảng thời gian.");
        return;
      }
      // setState(() {
      //   futureReportProduction = ReportProductionService()
      //       .getReportByDayCompleted(fromDate!, toDate!, machine);
      // });
    }
  }

  Future<void> pickDateRange() async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        final defaultRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now(),
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
            child: Material(
              elevation: 12,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: DateRangePickerDialog(
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange:
                    (fromDate != null && toDate != null)
                        ? DateTimeRange(start: fromDate!, end: toDate!)
                        : defaultRange,
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
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
              height: 80,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //left button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        // Dropdown
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            value: searchType,
                            items:
                                ['Tất cả', "Theo Quản Ca", "Theo Ngày"].map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                searchType = value!;
                                isTextFieldEnabled =
                                    searchType == 'Theo Quản Ca';

                                if (searchType != 'Theo Quản Ca') {
                                  searchController.clear();
                                }

                                if (searchType != 'Theo Ngày') {
                                  fromDate = null;
                                  toDate = null;
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

                        // Input hoặc Button chọn ngày tùy theo searchType
                        if (searchType == 'Theo Quản Ca' ||
                            searchType == 'Tất cả')
                          SizedBox(
                            width: 220,
                            height: 50,
                            child: TextField(
                              controller: searchController,
                              enabled: searchType == 'Theo Quản Ca',
                              onSubmitted: (_) => searchReport(),
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
                          )
                        else if (searchType == 'Theo Ngày')
                          SizedBox(
                            width: 220,
                            child: ElevatedButton.icon(
                              onPressed: pickDateRange,
                              icon: Icon(Icons.date_range, color: Colors.white),
                              label: Text(
                                fromDate != null && toDate != null
                                    ? "${DateFormat('dd/MM/yyyy').format(fromDate!)} - ${DateFormat('dd/MM/yyyy').format(toDate!)}"
                                    : "Ngày hoàn thành",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                          ),

                        SizedBox(width: 10),

                        // Nút tìm kiếm
                        ElevatedButton.icon(
                          onPressed: searchReport,
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
                      ],
                    ),
                  ),

                  //right button
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
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
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: futureReportProduction,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['reports'].isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  final data = snapshot.data!;
                  final report = data['reports'] as List<ReportProductionModel>;
                  final currentPg = data['currentPage'];
                  final totalPgs = data['totalPages'];

                  reportDatasource = ReportDatasource(
                    report: report,
                    selectedReportId: selectedReport,
                    showGroup: showGroup,
                  );

                  return Column(
                    children: [
                      //table
                      Expanded(
                        child: SfDataGrid(
                          source: reportDatasource,
                          columns: buildReportColumn(),
                          allowExpandCollapseGroup: true, // Bật grouping
                          autoExpandGroups: true,
                          isScrollbarAlwaysShown: true,
                          columnWidthMode: ColumnWidthMode.auto,
                        ),
                      ),

                      //paging
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  currentPage > 1
                                      ? () {
                                        setState(() {
                                          currentPage--;
                                          loadReportProduction();
                                        });
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shadowColor: Colors.black.withOpacity(0.2),
                                elevation: 5,
                              ),
                              child: Text(
                                "Trang trước",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Trang: $currentPg / $totalPgs',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed:
                                  currentPage < totalPgs
                                      ? () {
                                        setState(() {
                                          currentPage++;
                                          loadReportProduction();
                                        });
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff78D761),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                shadowColor: Colors.black.withOpacity(0.2),
                                elevation: 5,
                              ),
                              child: Text(
                                "Trang sau",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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
        onPressed: loadReportProduction,
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
