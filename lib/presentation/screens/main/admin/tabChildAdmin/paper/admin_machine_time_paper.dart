import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_machine_paper_model.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminMachinePaper extends StatefulWidget {
  const AdminMachinePaper({super.key});

  @override
  State<AdminMachinePaper> createState() => _AdminMachinePaperState();
}

class _AdminMachinePaperState extends State<AdminMachinePaper> {
  late Future<List<AdminMachinePaperModel>> futureAdminMachine;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();
  int? selectedMachine;
  List<int> isSelected = [];
  List<AdminMachinePaperModel> updatedMachine = [];
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();

    if (userController.hasAnyRole(roles: ["admin"])) {
      loadMachine();
    } else {
      futureAdminMachine = Future.error("NO_PERMISSION");
    }
  }

  void loadMachine() {
    setState(() {
      futureAdminMachine = AdminService().getMachinePapers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccept = userController.hasAnyRole(roles: ["admin"]);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            SizedBox(
              height: 90,
              width: double.infinity,
              child: Column(
                children: [
                  //title
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Obx(
                        () => Text(
                          "THỜI GIAN VÀ TỐC ĐỘ MÁY SÓNG",
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
                    height: 60,
                    width: double.infinity,
                    child:
                        isAccept
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //left
                                const SizedBox(),

                                //right
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  child: Row(
                                    children: [
                                      // update
                                      AnimatedButton(
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
                                                    (item) => isSelected.contains(item.machineId),
                                                  )
                                                  .toList();

                                          for (final item in dataToUpdate) {
                                            // print(
                                            //   '⏫ Updating machineId: ${item.machineId}',
                                            // );

                                            await AdminService().updateMachinePaper(
                                              machineId: item.machineId,
                                              machineUpdate: {
                                                "timeChangeSize": item.timeChangeSize,
                                                "timeChangeSameSize": item.timeChangeSameSize,
                                                "speed2Layer": item.speed2Layer,
                                                "speed3Layer": item.speed3Layer,
                                                "speed4Layer": item.speed4Layer,
                                                "speed5Layer": item.speed5Layer,
                                                "speed6Layer": item.speed6Layer,
                                                "speed7Layer": item.speed7Layer,
                                                "paperRollSpeed": item.paperRollSpeed,
                                                "machinePerformance": item.machinePerformance,
                                                "machineName": item.machineName,
                                                'type': item.type,
                                              },
                                            );
                                          }

                                          loadMachine();

                                          if (!context.mounted) return;
                                          showSnackBarSuccess(context, 'Đã cập nhật thành công');
                                        },
                                        label: "Lưu Thay Đổi",
                                        icon: Symbols.save,
                                        backgroundColor: themeController.buttonColor,
                                      ),
                                      const SizedBox(width: 10),

                                      //delete customers
                                      AnimatedButton(
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
                                                              borderRadius: BorderRadius.circular(
                                                                16,
                                                              ),
                                                            ),
                                                            title: const Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.warning_amber_rounded,
                                                                  color: Colors.red,
                                                                  size: 30,
                                                                ),
                                                                SizedBox(width: 8),
                                                                Text(
                                                                  "Xác nhận xoá",
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content:
                                                                isDeleting
                                                                    ? const Row(
                                                                      children: [
                                                                        CircularProgressIndicator(
                                                                          strokeWidth: 2,
                                                                        ),
                                                                        SizedBox(width: 12),
                                                                        Text("Đang xoá..."),
                                                                      ],
                                                                    )
                                                                    : const Text(
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
                                                                            () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: const Text(
                                                                          "Huỷ",
                                                                          style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black54,
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
                                                                                .deleteMachinePaper(
                                                                                  machineId: id,
                                                                                );
                                                                          }

                                                                          await Future.delayed(
                                                                            const Duration(
                                                                              seconds: 1,
                                                                            ),
                                                                          );

                                                                          if (!context.mounted) {
                                                                            return;
                                                                          }

                                                                          setState(() {
                                                                            isSelected.clear();
                                                                            futureAdminMachine =
                                                                                AdminService()
                                                                                    .getMachinePapers();
                                                                          });

                                                                          Navigator.pop(context);

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
                                                                                FontWeight.bold,
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
                                        label: "Xóa",
                                        icon: Icons.delete,
                                        backgroundColor: const Color(0xffEA4346),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<AdminMachinePaperModel>>(
                  future: futureAdminMachine,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      if (snapshot.error.toString().contains("NO_PERMISSION")) {
                        return const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, color: Colors.redAccent, size: 35),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    updatedMachine = data;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 25,
                        headingRowColor: WidgetStatePropertyAll(themeController.currentColor.value),
                        columns: _buildColumns(context, data),
                        rows: _buildRows(data, context),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () =>
            isAccept
                ? FloatingActionButton(
                  onPressed: loadMachine,
                  backgroundColor: themeController.buttonColor.value,
                  child: const Icon(Icons.refresh, color: Colors.white),
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context, List<AdminMachinePaperModel> data) {
    return [
      DataColumn(label: _buildSelectAllCheckbox(data)),
      DataColumn(label: styleText("Tgian đổi khổ")),
      DataColumn(label: styleText("Tgian đổi cùng khổ")),
      DataColumn(label: styleText("Tốc độ 2 lớp")),
      DataColumn(label: styleText("Tốc độ 3 lớp")),
      DataColumn(label: styleText("Tốc độ 4 lớp")),
      DataColumn(label: styleText("Tốc độ 5 lớp")),
      DataColumn(label: styleText("Tốc độ 6 lớp")),
      DataColumn(label: styleText("Tốc độ 7 lớp")),
      DataColumn(label: styleText("Tốc độ quấn cuộn")),
      DataColumn(label: styleText("Hiệu suất")),
      DataColumn(label: styleText("Tên Máy")),
      DataColumn(label: styleText("Loại")),
    ];
  }

  Widget _buildSelectAllCheckbox(List<AdminMachinePaperModel> data) {
    return Checkbox(
      value: selectedAll,
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.red : Colors.white,
      ),
      checkColor: Colors.white,
      side: const BorderSide(color: Colors.black),
      onChanged: (value) {
        setState(() {
          selectedAll = value!;
          isSelected = selectedAll ? data.map((e) => e.machineId).toList() : [];
        });
      },
    );
  }

  List<DataRow> _buildRows(List<AdminMachinePaperModel> data, BuildContext context) {
    return List<DataRow>.generate(data.length, (index) {
      final machine = data[index];

      return DataRow(
        cells: [
          //checkbox
          DataCell(
            Theme(
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    return states.contains(WidgetState.selected) ? Colors.red : Colors.white;
                  }),
                  checkColor: WidgetStateProperty.all<Color>(Colors.white),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: Checkbox(
                value: isSelected.contains(machine.machineId),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      isSelected.add(machine.machineId);
                    } else {
                      isSelected.remove(machine.machineId);
                    }
                    selectedAll = isSelected.length == data.length;
                  });
                },
              ),
            ),
          ),

          // 2. Tgian đổi khổ
          _buildEditableCell(
            text: '${machine.timeChangeSize} phút',
            onChanged: (value) => machine.timeChangeSize = int.tryParse(value) ?? 0,
          ),

          // 3. Tgian đổi cùng khổ
          _buildEditableCell(
            text: machine.timeChangeSameSize == 0 ? "0" : '${machine.timeChangeSameSize} phút',
            onChanged: (value) => machine.timeChangeSameSize = int.tryParse(value) ?? 0,
          ),

          // 4 -> 9. Các loại tốc độ lớp (2 - 7)
          _buildEditableCell(
            text: showText(text: machine.speed2Layer, type: ''),
            onChanged: (value) => machine.speed2Layer = int.tryParse(value) ?? 0,
          ),
          _buildEditableCell(
            text: showText(text: machine.speed3Layer, type: machine.type),
            onChanged: (value) => machine.speed3Layer = int.tryParse(value) ?? 0,
          ),
          _buildEditableCell(
            text: showText(text: machine.speed4Layer, type: machine.type),
            onChanged: (value) => machine.speed4Layer = int.tryParse(value) ?? 0,
          ),
          _buildEditableCell(
            text: showText(text: machine.speed5Layer, type: machine.type),
            onChanged: (value) => machine.speed5Layer = int.tryParse(value) ?? 0,
          ),
          _buildEditableCell(
            text: showText(text: machine.speed6Layer, type: machine.type),
            onChanged: (value) => machine.speed6Layer = int.tryParse(value) ?? 0,
          ),
          _buildEditableCell(
            text: showText(text: machine.speed7Layer, type: machine.type),
            onChanged: (value) => machine.speed7Layer = int.tryParse(value) ?? 0,
          ),

          // 10. Tốc độ quấn cuộn
          _buildEditableCell(
            text: showText(text: machine.paperRollSpeed, type: machine.type),
            onChanged: (value) => machine.paperRollSpeed = int.tryParse(value) ?? 0,
          ),

          // 11. Hiệu suất
          _buildEditableCell(
            text: '${machine.machinePerformance}%',
            onChanged: (value) => machine.machinePerformance = double.tryParse(value) ?? 0,
          ),

          // 12. Tên Máy (Chỉ xem)
          DataCell(styleCellAdmin(text: machine.machineName, onChanged: null)),

          // 13. Loại (Chỉ xem)
          DataCell(styleCellAdmin(text: machine.type, onChanged: null)),
        ],
      );
    });
  }

  // Helper
  String showText({required dynamic text, required String type}) {
    final unit = (type == 'M2') ? 'm' : 'kg';
    return text == 0 ? "0" : '$text $unit/phút';
  }

  DataCell _buildEditableCell({required String text, required Function(String) onChanged}) {
    return DataCell(
      styleCellAdmin(
        text: text,
        onChanged: (value) {
          setState(() {
            onChanged(value);
          });
        },
      ),
    );
  }
}
