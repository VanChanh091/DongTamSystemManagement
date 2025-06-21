import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_change_machine.dart';
import 'package:dongtam/presentation/components/headerTable/header_table_machine.dart';
import 'package:dongtam/presentation/sources/machine_DataSource.dart';
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
  TextEditingController searchController = TextEditingController();
  String searchType = "Tất cả";
  String machine = "Máy 1350";
  DateTime selectedDate = DateTime.now();
  bool isTextFieldEnabled = false;
  List<String> selectedPlanningIds = [];
  final formatter = DateFormat('dd/MM/yyyy');
  final DataGridController dataGridController = DataGridController();

  @override
  void initState() {
    super.initState();
    loadPlanning();
  }

  void loadPlanning() {
    setState(() {
      futurePlanning = PlanningService().getPlanningByMachine(machine);
    });
  }

  void searchPlanning() {
    String keyword = searchController.text.trim().toLowerCase();

    if (isTextFieldEnabled && keyword.isEmpty) {
      return;
    }

    switch (searchType) {
      case 'Tất cả':
        loadPlanning();
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
      loadPlanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(5),
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
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: searchType,
                          items:
                              ['Tất cả', 'Tên KH', "Sóng", 'Khổ Cấp Giấy'].map((
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

                      // refresh
                      ElevatedButton.icon(
                        // onPressed: () {
                        //   setState(() {
                        //     selectedPlanningIds.clear();
                        //     machineDatasource.selectedPlanningIds =
                        //         selectedPlanningIds;
                        //     loadPlanning();
                        //     machineDatasource.notifyListeners();
                        //   });
                        // },
                        onPressed: () {
                          setState(() {
                            selectedPlanningIds.clear();
                          });

                          loadPlanning();
                        },
                        label: Text(
                          "Tải lại",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Icons.refresh, color: Colors.white),
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
                    ],
                  ),
                ),

                //right button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // nút lên xuống
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward),
                            // Nút hoạt động khi có ít nhất 1 hàng được chọn
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
                            // Nút hoạt động khi có ít nhất 1 hàng được chọn
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
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final List<DataGridRow> visibleRows =
                                machineDatasource.rows;

                            final List<Map<String, dynamic>> updateIndex =
                                visibleRows.asMap().entries.map((entry) {
                                  final planningId =
                                      entry.value
                                          .getCells()
                                          .firstWhere(
                                            (cell) =>
                                                cell.columnName == "planningId",
                                          )
                                          .value;

                                  return {
                                    "planningId": planningId,
                                    "sortPlanning": entry.key + 1,
                                  };
                                }).toList();

                            final result = await PlanningService()
                                .updateIndexPlanning(updateIndex, machine);

                            loadPlanning();

                            if (result) {
                              showSnackBarSuccess(
                                context,
                                "Cập nhật thành công",
                              );
                            }
                          } catch (e) {
                            showSnackBarError(context, "Lỗi cập nhật");
                            print("Lỗi khi lưu: $e");
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

                      const SizedBox(width: 10),

                      //choose machine
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: machine,
                          items:
                              ['Máy 1350', "Máy 1900", "Máy 2 Lớp"].map((
                                String value,
                              ) {
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
                                    onChangeMachine: loadPlanning,
                                  ),
                            );
                          } else if (value == 'export') {
                            print("Xuất PDF");
                          }
                        },
                        itemBuilder:
                            (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'change',
                                child: ListTile(
                                  leading: Icon(Symbols.construction),
                                  title: Text('Chuyển máy'),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'export',
                                child: ListTile(
                                  leading: Icon(Symbols.print),
                                  title: Text('Xuất PDF'),
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
                );

                return SfDataGrid(
                  controller: dataGridController,
                  source: machineDatasource,
                  columns: buildMachineColumns(),
                  isScrollbarAlwaysShown: true,
                  columnResizeMode: ColumnResizeMode.onResize,
                  columnWidthMode: ColumnWidthMode.auto,
                  navigationMode: GridNavigationMode.row,
                  selectionMode: SelectionMode.multiple,
                  onSelectionChanged: (addedRows, removedRows) {
                    setState(() {
                      for (var row in addedRows) {
                        final orderId = row.getCells()[0].value.toString();
                        if (selectedPlanningIds.contains(orderId)) {
                          selectedPlanningIds.remove(orderId);
                          // print("❌ Unselected: $selectedPlanningIds");
                        } else {
                          selectedPlanningIds.add(orderId);
                          // print("✅ Selected: $selectedPlanningIds");
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
    );
  }
}

Widget styleText(String text) {
  return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
}

Widget styleCell(double? width, String text) {
  return SizedBox(width: width, child: Text(text, maxLines: 3));
}
