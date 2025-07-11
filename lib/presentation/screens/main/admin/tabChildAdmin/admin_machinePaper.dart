import 'package:dongtam/data/models/admin/admin_machinePaper_model.dart';
import 'package:dongtam/presentation/components/dialog/dialog_machine_paper.dart';
import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/utils/showSnackBar/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminMachinePaper extends StatefulWidget {
  const AdminMachinePaper({super.key});

  @override
  State<AdminMachinePaper> createState() => _AdminMachinePaperState();
}

class _AdminMachinePaperState extends State<AdminMachinePaper> {
  late Future<List<AdminMachinePaperModel>> futureAdminMachine;
  int? selectedMachine;

  @override
  void initState() {
    super.initState();
    loadMachine();
  }

  void loadMachine() {
    setState(() {
      futureAdminMachine = AdminService().getAllMachine();
    });
  }

  Widget buildMachineDetails(AdminMachinePaperModel m) {
    final details = <String, dynamic>{
      "Thời gian đổi khổ": "${m.timeChangeSize} phút",
      if (m.speed5Layer > 0) "Tốc độ giấy 5 lớp": "${m.speed5Layer} m/phút",
      if (m.timeChangeSameSize > 0)
        "Thời gian đổi mã hàng": "${m.timeChangeSameSize} phút",
      if (m.speed2Layer > 0) "Tốc độ giấy 2 lớp": "${m.speed2Layer} m/phút",
      if (m.speed6Layer > 0) "Tốc độ giấy 6 lớp": "${m.speed6Layer} m/phút",
      if (m.speed3Layer > 0) "Tốc độ giấy 3 lớp": "${m.speed3Layer} m/phút",
      if (m.speed7Layer > 0) "Tốc độ giấy 7 lớp": "${m.speed7Layer} m/phút",
      if (m.speed4Layer > 0) "Tốc độ giấy 4 lớp": "${m.speed4Layer} m/phút",
      "Hiệu suất": "${m.machinePerformance}%",
      if (m.paperRollSpeed > 0)
        "Tốc độ cuộn giấy": "${m.paperRollSpeed} m/phút",
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        double columnWidth = (constraints.maxWidth - 20) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 8,
          children:
              details.entries.map((entry) {
                return SizedBox(
                  width: columnWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.arrow_right,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: "${entry.key}: ",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: "${entry.value}",

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          //button
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //left button
                SizedBox(),

                //right button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // refresh
                      ElevatedButton.icon(
                        onPressed: loadMachine,
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

                      // update
                      ElevatedButton.icon(
                        onPressed: () {
                          if (selectedMachine == null) {
                            showSnackBarError(
                              context,
                              'Vui lòng chọn máy cần sửa',
                            );
                            return;
                          }

                          AdminService()
                              .getMachineById(selectedMachine!)
                              .then((machineList) {
                                if (machineList.isEmpty) {
                                  showSnackBarError(
                                    context,
                                    'Không tìm thấy máy',
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => DialogMachinePaper(
                                        machine: machineList.first,
                                        onUpdateMachine: loadMachine,
                                      ),
                                );
                              })
                              .catchError((e) {
                                showSnackBarError(
                                  context,
                                  'Lỗi khi tải dữ liệu: $e',
                                );
                              });
                        },
                        label: Text(
                          "Sửa",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: Icon(Symbols.construction, color: Colors.white),
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
                        onPressed: () async {
                          if (selectedMachine == null) {
                            showSnackBarError(
                              context,
                              'Vui lòng chọn máy cần xóa',
                            );
                            return;
                          }

                          bool isDeleting = false;

                          final confirm = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setStateDialog) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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
                                            fontWeight: FontWeight.bold,
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
                                            : const Text(
                                              "Bạn có chắc chắn muốn xóa máy này không?",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    actions:
                                        isDeleting
                                            ? []
                                            : [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
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
                                                  backgroundColor: const Color(
                                                    0xffEA4346,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  setStateDialog(
                                                    () => isDeleting = true,
                                                  );
                                                  await Future.delayed(
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                  );
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text(
                                                  "Xoá",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                  );
                                },
                              );
                            },
                          );

                          if (confirm != true) return;
                          try {
                            await AdminService().deleteMachine(
                              selectedMachine!,
                            );
                            showSnackBarSuccess(
                              context,
                              "Đã xóa máy thành công",
                            );

                            setState(() {
                              futureAdminMachine =
                                  AdminService().getAllMachine();
                              selectedMachine = null;
                            });
                          } catch (e) {
                            showSnackBarError(context, "Lỗi khi xóa: $e");
                          }
                        },
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

          //card
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: FutureBuilder<List<AdminMachinePaperModel>>(
                future: futureAdminMachine,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Không có máy nào"));
                  }

                  final machines = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 12) / 2;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              machines.map((m) {
                                final isSelected =
                                    selectedMachine == m.machineId;

                                return SizedBox(
                                  width: itemWidth,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedMachine = m.machineId;
                                      });
                                    },
                                    child: Card(
                                      color:
                                          isSelected
                                              ? Colors.lightBlue.shade100
                                              : Colors.blueGrey.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 0,
                                                horizontal: 15,
                                              ),
                                              child: Text(
                                                "${m.machineName}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            buildMachineDetails(m),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
