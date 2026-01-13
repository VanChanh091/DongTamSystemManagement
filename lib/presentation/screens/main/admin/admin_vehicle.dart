import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdminVehicle extends StatefulWidget {
  const AdminVehicle({super.key});

  @override
  State<AdminVehicle> createState() => _AdminVehicleState();
}

class _AdminVehicleState extends State<AdminVehicle> {
  late Future<List<AdminVehicleModel>> futureVehicle;
  final userController = Get.find<UserController>();
  final themeController = Get.find<ThemeController>();

  List<AdminVehicleModel> updatedVehicle = [];
  List<AdminVehicleModel> draftVehicle = [];
  List<AdminVehicleModel> tableData = [];
  List<int> isSelected = [];
  int? selectedVehicleId;
  bool selectedAll = false;

  @override
  void initState() {
    super.initState();

    loadVehicle();
  }

  void loadVehicle() {
    setState(() {
      futureVehicle = AdminService().getAllVehicle();
    });

    isSelected.clear();
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
              height: 90,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: Center(
                      child: Obx(
                        () => Text(
                          "QUẢN LÝ XE GIAO HÀNG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //left
                        const SizedBox(),

                        //right
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: Row(
                            children: [
                              //add
                              AnimatedButton(
                                onPressed: () {
                                  setState(() {
                                    final newRow = AdminVehicleModel(
                                      vehicleId: null,
                                      vehicleName: '',
                                      licensePlate: '',
                                      maxPayload: 0,
                                      volumeCapacity: 0,
                                      isDraft: true,
                                    );

                                    tableData.insert(0, newRow);
                                    draftVehicle.add(newRow);
                                  });
                                },

                                label: "Thêm dòng",
                                icon: Icons.add,
                                backgroundColor: themeController.buttonColor,
                              ),
                              const SizedBox(width: 10),

                              // update
                              AnimatedButton(
                                onPressed: () async {
                                  // CASE ADD: row mới (draft, chưa có id)
                                  final rowsToAdd =
                                      tableData
                                          .where(
                                            (e) =>
                                                e.isDraft &&
                                                e.vehicleId == null &&
                                                e.vehicleName.trim().isNotEmpty &&
                                                e.licensePlate.trim().isNotEmpty &&
                                                e.maxPayload > 0 &&
                                                e.volumeCapacity > 0,
                                          )
                                          .toList();

                                  // CASE UPDATE: row có id + được chọn
                                  final rowsToUpdate =
                                      tableData
                                          .where(
                                            (e) =>
                                                e.vehicleId != null &&
                                                isSelected.contains(e.vehicleId),
                                          )
                                          .toList();

                                  // check tick checkbox
                                  final hasUpdateRow = tableData.any((e) => e.vehicleId != null);

                                  if (rowsToAdd.isEmpty && hasUpdateRow && rowsToUpdate.isEmpty) {
                                    showSnackBarError(context, "Chưa chọn dòng cần cập nhật");
                                    return;
                                  }

                                  // ================== ADD ==================
                                  for (final e in rowsToAdd) {
                                    await AdminService().addVehicle(
                                      vehicleData: {
                                        "vehicleName": e.vehicleName,
                                        "licensePlate": e.licensePlate,
                                        "maxPayload": e.maxPayload,
                                        "volumeCapacity": e.volumeCapacity,
                                      },
                                    );
                                  }

                                  // ================== UPDATE ==================
                                  for (final e in rowsToUpdate) {
                                    await AdminService().updateVehicle(
                                      vehicleId: e.vehicleId!,
                                      vehicleUpdate: {
                                        "vehicleName": e.vehicleName,
                                        "licensePlate": e.licensePlate,
                                        "maxPayload": e.maxPayload,
                                        "volumeCapacity": e.volumeCapacity,
                                      },
                                    );
                                  }

                                  setState(() {
                                    tableData.clear();
                                    draftVehicle.clear();
                                    isSelected.clear();
                                    selectedAll = false;
                                  });

                                  loadVehicle();

                                  if (!context.mounted) return;
                                  showSnackBarSuccess(context, "Đã lưu thay đổi thành công");
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
                                                      borderRadius: BorderRadius.circular(16),
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
                                                              style: TextStyle(fontSize: 16),
                                                            ),
                                                    actions:
                                                        isDeleting
                                                            ? []
                                                            : [
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.pop(context),
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
                                                                        BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                                onPressed: () async {
                                                                  setStateDialog(() {
                                                                    isDeleting = true;
                                                                  });

                                                                  for (int id in isSelected) {
                                                                    await AdminService()
                                                                        .deleteVehicle(
                                                                          vehicleId: id,
                                                                        );
                                                                  }

                                                                  await Future.delayed(
                                                                    const Duration(seconds: 1),
                                                                  );

                                                                  if (!context.mounted) {
                                                                    return;
                                                                  }

                                                                  setState(() {
                                                                    isSelected.clear();
                                                                    tableData.clear();
                                                                  });

                                                                  loadVehicle();

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
                    ),
                  ),
                ],
              ),
            ),

            //table
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<List<AdminVehicleModel>>(
                  future: futureVehicle,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Lỗi: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Không có đơn hàng nào",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      );
                    }

                    if (snapshot.hasData && tableData.isEmpty) {
                      tableData =
                          snapshot.data!
                              .map(
                                (e) => AdminVehicleModel(
                                  vehicleId: e.vehicleId,
                                  vehicleName: e.vehicleName,
                                  licensePlate: e.licensePlate,
                                  maxPayload: e.maxPayload,
                                  volumeCapacity: e.volumeCapacity,
                                  isDraft: false,
                                ),
                              )
                              .toList();
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 25,
                        headingRowColor: WidgetStatePropertyAll(themeController.currentColor.value),
                        columns: [
                          DataColumn(
                            label: Theme(
                              data: Theme.of(context).copyWith(
                                checkboxTheme: CheckboxThemeData(
                                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.red;
                                    }
                                    return Colors.white;
                                  }),
                                  checkColor: WidgetStateProperty.all<Color>(Colors.white),
                                  side: const BorderSide(color: Colors.black, width: 1),
                                ),
                              ),
                              child: Checkbox(
                                value: selectedAll,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAll = value!;
                                    if (selectedAll) {
                                      isSelected =
                                          tableData
                                              .map((e) => e.vehicleId)
                                              .whereType<int>()
                                              .toList();
                                    } else {
                                      isSelected.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          DataColumn(label: styleText("Tên Phương Tiện")),
                          DataColumn(label: styleText("Biển Số Xe")),
                          DataColumn(label: styleText("Tải Trọng Tối Đa (kg)")),
                          DataColumn(label: styleText("Thể Tích (m³)")),
                        ],
                        rows: List<DataRow>.generate(tableData.length, (index) {
                          final vehicle = tableData[index];
                          return DataRow(
                            key: ValueKey(vehicle.vehicleId ?? vehicle.hashCode),
                            color:
                                vehicle.vehicleId == null
                                    ? WidgetStateProperty.all(Colors.yellow.withValues(alpha: 0.2))
                                    : null,
                            cells: [
                              DataCell(
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    checkboxTheme: CheckboxThemeData(
                                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return Colors.red;
                                        }
                                        return Colors.white;
                                      }),
                                      checkColor: WidgetStateProperty.all<Color>(Colors.white),
                                      side: const BorderSide(color: Colors.black, width: 1),
                                    ),
                                  ),
                                  child: Checkbox(
                                    value:
                                        vehicle.vehicleId != null &&
                                        isSelected.contains(vehicle.vehicleId),
                                    onChanged:
                                        vehicle.vehicleId == null
                                            ? null
                                            : (val) {
                                              setState(() {
                                                if (val == true) {
                                                  isSelected.add(vehicle.vehicleId!);
                                                } else {
                                                  isSelected.remove(vehicle.vehicleId);
                                                }
                                                selectedAll =
                                                    isSelected.length == snapshot.data!.length;
                                              });
                                            },
                                  ),
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: vehicle.vehicleName.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle.vehicleName = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: vehicle.licensePlate.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle.licensePlate = value;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: vehicle.maxPayload.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle.maxPayload = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                styleCellAdmin(
                                  text: vehicle.volumeCapacity.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle.volumeCapacity = double.tryParse(value) ?? 0;
                                    });
                                  },
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
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: loadVehicle,
          backgroundColor: themeController.buttonColor.value,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }
}
