import 'package:dongtam/data/models/admin/admin_machineBox_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminMachineBox extends StatefulWidget {
  const AdminMachineBox({super.key});

  @override
  State<AdminMachineBox> createState() => _AdminMachineBoxState();
}

class _AdminMachineBoxState extends State<AdminMachineBox> {
  late Future<List<AdminMachineBoxModel>> futureAdminMachine;
  int? selectedMachine;
  List<int> isSelected = [];
  List<AdminMachineBoxModel> updatedMachine = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();
    loadMachine();
  }

  void loadMachine() {
    setState(() {
      futureAdminMachine = AdminService().getAllMachineBox();
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
              height: 65,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(
                      children: [
                        // update
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (isSelected.isEmpty) {
                              showSnackBarError(
                                context,
                                "Chưa chọn thông tin cần cập nhật",
                              );
                              return;
                            }

                            final dataToUpdate =
                                updatedMachine
                                    .where(
                                      (item) =>
                                          isSelected.contains(item.machineId),
                                    )
                                    .toList();

                            for (final item in dataToUpdate) {
                              print('⏫ Updating machineId: ${item.machineId}');

                              await AdminService()
                                  .updateMachineBox(item.machineId, {
                                    "timeToProduct": item.timeToProduct,
                                    "speedOfMachine": item.speedOfMachine,
                                    "machineName": item.machineName,
                                  });
                            }

                            loadMachine();

                            showSnackBarSuccess(
                              context,
                              'Đã cập nhật thành công',
                            );
                          },
                          label: Text(
                            "Lưu Thay Đổi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: Icon(Symbols.save, color: Colors.white),
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

                        //delete customers
                        ElevatedButton.icon(
                          onPressed:
                              isSelected.isNotEmpty
                                  ? () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        bool isDeleting = false;

                                        return StatefulBuilder(
                                          builder: (context, setStateDialog) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.red,
                                                    size: 30,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Xác nhận xoá",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content:
                                                  isDeleting
                                                      ? Row(
                                                        children: const [
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                          SizedBox(width: 12),
                                                          Text("Đang xoá..."),
                                                        ],
                                                      )
                                                      : Text(
                                                        'Bạn có chắc chắn muốn xoá?',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                              actions:
                                                  isDeleting
                                                      ? []
                                                      : [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: const Text(
                                                            "Huỷ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .black54,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xffEA4346,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            setStateDialog(() {
                                                              isDeleting = true;
                                                            });

                                                            for (int id
                                                                in isSelected) {
                                                              await AdminService()
                                                                  .deleteMachineBox(
                                                                    id,
                                                                  );
                                                            }

                                                            await Future.delayed(
                                                              const Duration(
                                                                seconds: 1,
                                                              ),
                                                            );

                                                            setState(() {
                                                              isSelected
                                                                  .clear();
                                                              futureAdminMachine =
                                                                  AdminService()
                                                                      .getAllMachineBox();
                                                            });

                                                            Navigator.pop(
                                                              context,
                                                            );

                                                            // Optional: Show success toast
                                                            showSnackBarSuccess(
                                                              context,
                                                              'Xoá thành công',
                                                            );
                                                          },
                                                          child: const Text(
                                                            "Xoá",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                  : null,
                          label: Text(
                            "Xóa",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: Icon(Icons.delete, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffEA4346),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<AdminMachineBoxModel>>(
                  future: futureAdminMachine,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có dữ liệu'));
                    }

                    final data = snapshot.data!;
                    updatedMachine = data;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 25,
                        headingRowColor: WidgetStatePropertyAll(
                          Color(0xffcfa381),
                        ),
                        columns: [
                          DataColumn(
                            label: Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  fillColor:
                                      MaterialStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
                                        )) {
                                          return Colors.red;
                                        }
                                        return Colors.white;
                                      }),
                                  checkColor: MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Checkbox(
                                value: selectedAll,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAll = value!;
                                    if (selectedAll) {
                                      isSelected =
                                          data.map((e) => e.machineId).toList();
                                    } else {
                                      isSelected.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          DataColumn(label: styleText("Thời Gian Lên Bài")),
                          DataColumn(label: styleText("Tốc Độ Máy")),
                          DataColumn(label: styleText("Loại Máy")),
                        ],
                        rows: List<DataRow>.generate(data.length, (index) {
                          final machine = data[index];
                          return DataRow(
                            cells: [
                              DataCell(
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    checkboxTheme: CheckboxThemeData(
                                      fillColor:
                                          MaterialStateProperty.resolveWith<
                                            Color
                                          >((states) {
                                            if (states.contains(
                                              MaterialState.selected,
                                            )) {
                                              return Colors.red;
                                            }
                                            return Colors.white;
                                          }),
                                      checkColor:
                                          MaterialStateProperty.all<Color>(
                                            Colors.white,
                                          ),
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Checkbox(
                                    value: isSelected.contains(
                                      machine.machineId,
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          isSelected.add(machine.machineId);
                                        } else {
                                          isSelected.remove(machine.machineId);
                                        }

                                        selectedAll =
                                            isSelected.length == data.length;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  '${machine.timeToProduct.toString()} phút',
                                  (value) {
                                    setState(() {
                                      machine.timeToProduct =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  machine.speedOfMachine == 0
                                      ? "0"
                                      : '${machine.speedOfMachine.toString()} tờ/giờ',
                                  (value) {
                                    setState(() {
                                      machine.speedOfMachine =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  machine.machineName.toString(),
                                  null,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadMachine,
        backgroundColor: Color(0xff78D761),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  String showText(dynamic text) {
    return text == 0 ? "0" : '$text m/phút';
  }
}
