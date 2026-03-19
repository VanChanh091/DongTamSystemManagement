import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/presentation/components/shared/confirm_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/validation/validation_order.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DialogReportProduction extends StatefulWidget {
  final int planningId;
  final VoidCallback onReport;
  final String? machine;
  final bool isPaper;
  final int? qtyPaper;

  //model
  final dynamic initialData;

  const DialogReportProduction({
    super.key,
    required this.planningId,
    required this.onReport,
    this.isPaper = true,
    this.machine,
    this.qtyPaper,

    this.initialData,
  });

  @override
  State<DialogReportProduction> createState() => _DialogReportProductionState();
}

class _DialogReportProductionState extends State<DialogReportProduction> {
  late Future<List<EmployeeBasicInfo>> futureEmployee;

  final formKey = GlobalKey<FormState>();

  final qtyProducedController = TextEditingController();
  final qtyWasteNormController = TextEditingController();
  final dayCompletedController = TextEditingController();
  final employeeCodeController = TextEditingController();

  late String shiftProduction = "Ca 1";
  final List<String> itemShiftProduction = ["Ca 1", "Ca 2", "Ca 3"];
  final shiftProductionController = TextEditingController();

  String? shiftManagementSelected;
  final shiftManagementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureEmployee = EmployeeService().getEmployeeByPosition();

    qtyWasteNormController.text = "1";

    if (widget.initialData != null) {
      Map<String, dynamic> data = widget.initialData;

      //helper lấy giá trị cuối sau dấu phẩy
      String getLastValue(dynamic input) {
        if (input == null || input.toString().isEmpty) return "";
        String str = input.toString();
        return str.contains(',') ? str.split(',').last.trim() : str.trim();
      }

      shiftManagementSelected = getLastValue(data['manager']).toUpperCase();
      shiftManagementController.text = shiftManagementSelected!;

      if (widget.isPaper) {
        shiftProduction = getLastValue(data['shift']);
        shiftProductionController.text = shiftProduction;
      }
    }
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      AppLogger.w("Form không hợp lệ, dừng submit");
      return;
    }

    try {
      final int qtyProduced = int.tryParse(qtyProducedController.trimmed) ?? 0;
      final double qtyWasteNorm = double.tryParse(qtyWasteNormController.trimmed) ?? 0;

      final DateTime completedDate = DateTime.now();

      final String shiftManagement = shiftManagementSelected ?? "";

      final Map<String, dynamic> reportData = {
        "shiftManagement": shiftManagement,
        "shiftProduction": shiftProduction,
      };

      bool success;
      if (widget.isPaper == true) {
        final text = widget.initialData != null ? 'Cập nhật' : 'Báo cáo';

        AppLogger.i("$text sản xuất giấy tấm: ${widget.planningId}");
        success = await ManufactureService().createOrUpdateReportPaper(
          planningId: widget.planningId,
          qtyProduced: qtyProduced,
          qtyWasteNorm: qtyWasteNorm,
          dayCompleted: completedDate,
          reportedBy: employeeCodeController.trimmed.toUpperCase(),
          reportData: reportData,
          isUpdate: widget.initialData != null ? true : false,
        );
      } else {
        if (widget.qtyPaper == null || widget.qtyPaper == 0) {
          final confirm = await showConfirmDialog(
            context: context,
            title: "⚠️ Thiếu số lượng giấy tấm",
            content:
                "Kế hoạch này chưa có số lượng giấy tấm.\n"
                "Bạn có chắc muốn tiếp tục báo cáo không?",
            confirmText: "Tiếp tục",
            cancelText: "Hủy",
          );

          if (confirm != true) {
            return;
          }
        }

        AppLogger.i("Báo cáo sản xuất thùng: ID = ${widget.planningId}");
        success = await ManufactureService().createOrUpdateReportBox(
          planningBoxId: widget.planningId,
          machine: widget.machine ?? "",
          dayCompleted: completedDate,
          qtyProduced: qtyProduced,
          rpWasteLoss: qtyWasteNorm,
          shiftManagement: shiftManagement,
          reportedBy: employeeCodeController.trimmed.toUpperCase(),
          isUpdate: widget.initialData != null ? true : false,
        );
      }

      if (success) {
        // Show loading
        if (!mounted) return;
        showLoadingDialog(context);
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        showSnackBarSuccess(context, 'Báo cáo sản xuất thành công');
        widget.onReport();

        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      final errorText = switch (e.errorCode) {
        'ACCESS_DENIED' => 'Bạn không có quyền báo cáo máy này',
        'INVALID_MACHINE' => 'Máy không hợp lệ',
        'EMPLOYEE_NOT_FOUND' => 'Mã nhân viên không tồn tại',
        _ => 'Có lỗi xảy ra, vui lòng thử lại',
      };

      if (mounted) {
        showSnackBarError(context, errorText);
      }
    } catch (e, s) {
      AppLogger.e("Lỗi khi báo cáo sản xuất", error: e, stackTrace: s);
      if (mounted) {
        showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
      }
    }
  }

  Widget validateInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: Colors.white,
        filled: true,
      ),
      validator: (value) {
        final text = value?.trim() ?? "";

        if (text.isEmpty) return "Vui lòng nhập $label";

        if (label == "Số Lượng Đã Sản Xuất") {
          final intValue = int.tryParse(text);

          if (!RegExp(r'^\d+$').hasMatch(text)) {
            return "Chỉ được nhập số nguyên dương";
          } else if (intValue == 0 || intValue! < 0) {
            return "Số lượng không được bé hơn hoặc bằng 0";
          }
        } else if (label == "Phế Liệu Thực Tế") {
          final doubleValue = double.tryParse(text);

          if (!RegExp(r'^\d+([.]\d+)?$').hasMatch(text)) {
            return "Chỉ được nhập số thực, chỉ được dùng dấu chấm";
          } else if (doubleValue == 0 || doubleValue! < 0) {
            return "Số lượng phế liệu không được bé hơn 0";
          }
        } else if (label == "Trưởng Máy") {
          if (!RegExp(r"^[a-zA-ZÀ-ỹ\s]+$").hasMatch(text)) {
            return "Chỉ được chứa chữ cái và khoảng trắng";
          }
        }

        return null;
      },
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    super.dispose();
    qtyProducedController.dispose();
    qtyWasteNormController.dispose();
    dayCompletedController.dispose();
    shiftManagementController.dispose();
    shiftProductionController.dispose();
    employeeCodeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          widget.initialData != null ? "Cập Nhật Báo Cáo" : "Báo Cáo Sản Xuất",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 15),
                validateInput(
                  "Số Lượng Đã Sản Xuất",
                  qtyProducedController,
                  Symbols.production_quantity_limits,
                ),
                const SizedBox(height: 10),

                validateInput("Phế Liệu Thực Tế", qtyWasteNormController, Symbols.box),
                const SizedBox(height: 10),

                FormField<String>(
                  validator: (_) {
                    if ((shiftManagementSelected ?? "").trim().isEmpty) {
                      return "Vui lòng chọn Trưởng Máy";
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<List<EmployeeBasicInfo>>(
                          future: futureEmployee,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: LinearProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Text("Lỗi tải trưởng máy");
                            }

                            final employees = snapshot.data ?? [];
                            final items =
                                employees
                                    .map((e) => e.fullName.toUpperCase())
                                    .whereType<String>()
                                    .toList();

                            if (items.isEmpty) {
                              return const Text("Không có dữ liệu trưởng máy");
                            }

                            if (shiftManagementSelected != null) {
                              if (!items.contains(shiftManagementSelected)) {
                                shiftManagementSelected = items.first;
                              }
                            } else {
                              shiftManagementSelected = items.first;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Trưởng Máy",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 6),
                                ValidationOrder.dropdownForTypes(
                                  items: items,
                                  type: shiftManagementSelected!,
                                  onChanged: (value) {
                                    setState(() {
                                      shiftManagementSelected = value;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                if (widget.isPaper) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ca Sản Xuất", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      ValidationOrder.dropdownForTypes(
                        items: itemShiftProduction,
                        type: shiftProduction,
                        onChanged: (value) {
                          setState(() {
                            shiftProduction = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 10),

                validateInput("Mã nhân viên báo cáo", employeeCodeController, Symbols.code),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Hủy",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Xác nhận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
