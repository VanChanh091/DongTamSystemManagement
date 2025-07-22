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
  late Future<List<ReportProductionModel>> futureReportProduction;
  late ReportDatasource reportDatasource;
  TextEditingController searchController = TextEditingController();
  String? selectedReport;
  bool isTextFieldEnabled = false;
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    loadReportProduction();
  }

  void loadReportProduction() {
    setState(() {
      futureReportProduction = ReportProductionService().getReportProdByMachine(
        machine,
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
            .getReportProdByMachine(machine);
      });
    } else if (searchType == "Theo Quản Ca") {
      if (keyword.isEmpty) return;
      setState(() {
        futureReportProduction = ReportProductionService()
            .getReportByShiftManagement(keyword, machine);
      });
    } else if (searchType == "Theo Ngày") {
      if (fromDate == null || toDate == null) {
        showSnackBarError(context, "Vui lòng chọn khoảng thời gian.");
        return;
      }
      setState(() {
        futureReportProduction = ReportProductionService()
            .getReportByDayCompleted(fromDate!, toDate!, machine);
      });
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
                        //dropdown
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
                        ),
                        const SizedBox(width: 10),

                        // find
                        ElevatedButton.icon(
                          onPressed: () {
                            searchReport();
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
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        // Nút chọn ngày
                        ElevatedButton.icon(
                          onPressed: pickDateRange,
                          icon: Icon(Icons.date_range, color: Colors.white),
                          label: Text(
                            fromDate != null && toDate != null
                                ? "${DateFormat('dd/MM/yyyy').format(fromDate!)} - ${DateFormat('dd/MM/yyyy').format(toDate!)}"
                                : "Chọn ngày",
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
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<ReportProductionModel>>(
                  future: futureReportProduction,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Lỗi: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    final List<ReportProductionModel> data = snapshot.data!;

                    reportDatasource = ReportDatasource(
                      report: data,
                      selectedReportId: selectedReport,
                    );

                    return SfDataGrid(
                      source: reportDatasource,
                      columns: buildReportColumn(),
                      isScrollbarAlwaysShown: true,
                      columnWidthMode: ColumnWidthMode.auto,
                    );
                  },
                ),
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
