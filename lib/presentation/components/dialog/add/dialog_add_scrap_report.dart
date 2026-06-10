import 'package:dongtam/data/controller/badges_controller.dart';
import 'package:dongtam/data/models/employee/employee_basic_info.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/presentation/components/shared/cardForm/building_card_form.dart';
import 'package:dongtam/presentation/components/shared/cardForm/format_key_value_card.dart';
import 'package:dongtam/presentation/components/shared/dialog_shared.dart';
import 'package:dongtam/service/employee_service.dart';
import 'package:dongtam/service/manufacture_service.dart';
import 'package:dongtam/service/scrap_report_service.dart';
import 'package:dongtam/utils/extension/extension_helper.dart';
import 'package:dongtam/utils/handleError/api_exception.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/validation/validation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class ScrapReportDialog extends StatefulWidget {
  final ScrapReportModel? scrapReport;
  final dynamic initialData;
  final VoidCallback onSubmit;

  const ScrapReportDialog({super.key, this.scrapReport, this.initialData, required this.onSubmit});

  @override
  State<ScrapReportDialog> createState() => _ScrapReportDialogState();
}

class _ScrapReportDialogState extends State<ScrapReportDialog> {
  late Future<List<EmployeeBasicInfo>> futureEmployee;
  final formKey = GlobalKey<FormState>();

  final badgesController = Get.find<BadgesController>();

  late String shiftProduction = "Ca 1";
  final List<String> itemShiftProduction = ["Ca 1", "Ca 2", "Ca 3"];

  late String machine = "Máy 1350";
  final List<String> itemsMachine = ['Máy 1350', 'Máy 1900', 'Máy 2 Lớp', 'Máy Quấn Cuồn'];

  DateTime? dayCompleted;
  final _dayCompletedController = TextEditingController();

  String? shiftManagementSelected;
  final _shiftManagementController = TextEditingController();

  final _shiftProductionController = TextEditingController();

  final _qtyWasteNormController = TextEditingController();
  final _qtyForkliftController = TextEditingController();
  final _qtyInventoryController = TextEditingController();
  final _qtyCoreTubeController = TextEditingController();
  final _qtyOtherController = TextEditingController();

  List<PlanningPaper> listPlanningPaper = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureEmployee = EmployeeService().getEmployeeByPosition();

    if (widget.scrapReport != null) {
      scrapReportInitState();
    } else if (widget.initialData != null) {
      String? shiftManagementStr = widget.initialData["shiftManagement"];
      String? lastReporter;

      if (shiftManagementStr != null && shiftManagementStr.isNotEmpty) {
        lastReporter = shiftManagementStr.split(',').last.trim();
      }

      machine = widget.initialData["machine"] ?? machine;
      shiftManagementSelected = lastReporter ?? shiftManagementSelected;
      shiftProduction = widget.initialData["shiftProduction"] ?? shiftProduction;
      dayCompleted = widget.initialData["dayCompleted"] ?? dayCompleted;

      _dayCompletedController.text =
          dayCompleted != null ? DateFormat('dd/MM/yyyy').format(dayCompleted!) : "";
    }
  }

  void scrapReportInitState() {
    AppLogger.i("Khởi tạo form với scrapId=${widget.scrapReport!.scrapId}");

    _shiftProductionController.text = widget.scrapReport!.shiftProduction;
    _qtyForkliftController.text = widget.scrapReport!.qtyForklift.toString();
    _qtyInventoryController.text = widget.scrapReport!.qtyInventory.toString();
    _qtyCoreTubeController.text = widget.scrapReport!.qtyCoreTube.toString();
    _qtyWasteNormController.text = widget.scrapReport!.qtyProduction.toString();
    _qtyOtherController.text = widget.scrapReport!.qtyOther.toString();

    //dropdown
    machine = widget.scrapReport!.machine;
    shiftProduction = widget.scrapReport!.shiftProduction;
    shiftManagementSelected = widget.scrapReport!.reportedBy;
    dayCompleted = widget.scrapReport!.dayCompleted;
    _dayCompletedController.text = DateFormat('dd/MM/yyyy').format(dayCompleted!);
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Show loading
    showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));

    try {
      final bool isAdd = widget.scrapReport == null;
      AppLogger.i(
        isAdd
            ? "Thêm báo cáo phế liệu mới: ${widget.scrapReport?.scrapId}"
            : "Cập nhật báo cáo phế liệu: ${widget.scrapReport?.scrapId}",
      );

      final scrapData = {
        "qtyForklift": double.tryParse(_qtyForkliftController.trimmed) ?? 0,
        "qtyInventory": double.tryParse(_qtyInventoryController.trimmed) ?? 0,
        "qtyCoreTube": double.tryParse(_qtyCoreTubeController.trimmed) ?? 0,
        "qtyProduction": double.tryParse(_qtyWasteNormController.trimmed) ?? 0,
        "qtyOther": double.tryParse(_qtyOtherController.trimmed) ?? 0,
      };

      final bool success;
      if (isAdd) {
        success = await ScrapReportService().addScrapReport(
          scrapData: scrapData,
          machine: machine,
          shiftManagement: shiftManagementSelected ?? "",
          shiftProduction: shiftProduction,
          dayCompleted: dayCompleted!,
        );
      } else {
        success = await ScrapReportService().updateScrapReport(
          scrapId: widget.scrapReport!.scrapId,
          updateScrapData: scrapData,
          machine: machine,
          shiftProduction: shiftProduction,
          shiftManagement: shiftManagementSelected ?? "",
          dayCompleted: dayCompleted!,
        );
      }

      if (success) {
        if (!mounted) return;
        Navigator.pop(context); // đóng dialog loading

        badgesController.fetchScrapReportWaitingCheck();

        // Thông báo thành công
        if (!mounted) return;
        showSnackBarSuccess(context, isAdd ? "Thêm thành công" : "Cập nhật thành công");

        widget.onSubmit();
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      final errorText = switch (e.errorCode) {
        'EMPLOYEE_NOT_FOUND' => e.message!,
        _ => 'Có lỗi xảy ra, vui lòng thử lại',
      };

      if (mounted) {
        showSnackBarError(context, errorText);
        Navigator.pop(context); // đóng dialog loading
      }
    } catch (e, s) {
      AppLogger.e("Lỗi khi báo cáo sản xuất", error: e, stackTrace: s);
      if (mounted) {
        showSnackBarError(context, 'Lỗi: Không thể lưu dữ liệu');
        Navigator.pop(context); // đóng dialog loading
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _dayCompletedController.dispose();
    _shiftProductionController.dispose();
    _qtyForkliftController.dispose();
    _qtyInventoryController.dispose();
    _qtyCoreTubeController.dispose();
    _qtyOtherController.dispose();
    _shiftManagementController.dispose();
    _qtyWasteNormController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.scrapReport != null;

    final List<Map<String, dynamic>> inputQtyScrapRows = [
      {
        "leftKey": "Sản Xuất",
        "leftValue": ValidationHelper.scrapReport(
          label: "Phế Liệu Sản Xuất",
          controller: _qtyWasteNormController,
          icon: Icons.numbers,
        ),
        "rightKey": "Xe Nâng",
        "rightValue": ValidationHelper.scrapReport(
          label: "Phế Liệu Xe Nâng",
          controller: _qtyForkliftController,
          icon: Icons.numbers,
        ),
      },

      {
        "leftKey": "Ống Nòng",
        "leftValue": ValidationHelper.scrapReport(
          label: "Phế Liệu Ống Nòng",
          controller: _qtyCoreTubeController,
          icon: Icons.numbers,
        ),
        "rightKey": "Lưu Kho",
        "rightValue": ValidationHelper.scrapReport(
          label: "Phế Liệu Lưu Kho",
          controller: _qtyInventoryController,
          icon: Icons.numbers,
        ),
      },

      {
        "leftKey": "Khác",
        "leftValue": ValidationHelper.scrapReport(
          label: "Phế Liệu Khác",
          controller: _qtyOtherController,
          icon: Icons.numbers,
        ),
        "rightKey": "Trưởng Máy",
        "rightValue": FormField<String>(
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
                        employees.map((e) => e.fullName.toUpperCase()).whereType<String>().toList();

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

                    return ValidationHelper.dropdownForTypes(
                      items: items,
                      type: shiftManagementSelected!,
                      onChanged: (value) {
                        setState(() {
                          shiftManagementSelected = value;
                        });
                      },
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
      },
    ];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          isEdit ? "Cập nhật báo cáo phế liệu" : "Thêm báo cáo phế liệu",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SizedBox(
        width: ResponsiveSize.getWidth(context, ResponsiveType.xLarge),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                //show info manufacture
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ValidationHelper.scrapReport(
                                label: "Ngày Sản Xuất",
                                controller: _dayCompletedController,
                                icon: Symbols.calendar_month,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2100),
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Colors.blue,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          dialogTheme: const DialogThemeData(
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      dayCompleted = pickedDate;
                                      _dayCompletedController.text = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(pickedDate);
                                    });
                                  }
                                },
                              ),
                            ),
                            buildLineVertical(),

                            Expanded(
                              flex: 3,
                              child: ValidationHelper.dropdownForTypes(
                                items: itemsMachine,
                                type: machine,
                                onChanged: (value) {
                                  setState(() {
                                    machine = value!;
                                  });
                                },
                              ),
                            ),
                            buildLineVertical(),

                            Expanded(
                              flex: 2,
                              child: ValidationHelper.dropdownForTypes(
                                items: itemShiftProduction,
                                type: shiftProduction,
                                onChanged: (value) {
                                  setState(() {
                                    shiftProduction = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),
                    AnimatedButton(
                      onPressed: () async {
                        if (dayCompleted == null) {
                          showSnackBarError(
                            context,
                            "Vui lòng chọn ngày sản xuất trước khi lọc đơn!",
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final result = await ManufactureService().getPlanningPaper(
                            machine: machine,
                            dayCompleted: dayCompleted,
                            shiftProduction: shiftProduction,
                          );

                          setState(() {
                            listPlanningPaper = result;
                          });
                        } catch (e) {
                          if (context.mounted) {
                            showSnackBarError(context, 'Lỗi xảy ra không mong muốn');
                          }
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      label: "Lọc đơn",
                      icon: Icons.search,
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowHeight: 44,
                                dataRowMinHeight: 42,
                                columnSpacing: 24,
                                horizontalMargin: 16,
                                dividerThickness: 0.6,
                                headingRowColor: WidgetStateProperty.all(
                                  Color.fromARGB(255, 250, 235, 148),
                                ),
                                border: TableBorder(
                                  horizontalInside: BorderSide(color: Colors.grey.shade300),
                                ),
                                columns: [
                                  buildHeader("STT", width: 40, isCenter: true),
                                  buildHeader("Mã Đơn Hàng"),
                                  buildHeader("Tên Khách Hàng"),
                                  buildHeader("Quy Cách"),
                                  buildHeader("Số lượng SX"),
                                  buildHeader("Ca SX"),
                                  buildHeader("Trưởng Máy"),
                                  buildHeader("Ngày Báo Cáo"),
                                ],
                                rows:
                                    listPlanningPaper.asMap().entries.map<DataRow>((entry) {
                                      final paper = entry.value;
                                      final order = paper.order;

                                      return DataRow(
                                        cells: [
                                          buildCell(
                                            (entry.key + 1).toString(),
                                            width: 40,
                                            isCenter: true,
                                          ),
                                          buildCell(paper.orderId),
                                          buildCell(order?.customer?.customerName ?? ""),
                                          buildCell(
                                            "${order?.flute ?? ""} - ${paper.sizePaperPLaning}x${paper.lengthPaperPlanning}",
                                          ),
                                          buildCell(paper.qtyProduced.toString()),
                                          buildCell(paper.shiftProduction ?? ""),
                                          buildCell(paper.shiftManagement ?? ""),
                                          buildCell(
                                            paper.dayCompleted is DateTime
                                                ? DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(paper.dayCompleted as DateTime)
                                                : "",
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 10),

                //input scarp report
                const SizedBox(height: 10),
                buildingCard(
                  title: "Phế Liệu Khác",
                  children: formatKeyValueRows(
                    rows: inputQtyScrapRows,
                    columnCount: 2,
                    labelWidth: 150,
                    centerAlign: true,
                  ),
                ),
                const SizedBox(height: 10),
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
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isEdit ? "Cập nhật" : "Báo Cáo",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildLineVertical() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(width: 1, height: 30, color: Colors.grey.shade300),
    );
  }

  DataColumn buildHeader(String title, {double? width, bool isCenter = false}) {
    Widget content = Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

    if (isCenter) content = Center(child: content);
    if (width != null) content = SizedBox(width: width, child: content);

    return DataColumn(label: content);
  }

  DataCell buildCell(String value, {double? width, bool isCenter = false}) {
    Widget content = Text(
      value,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );

    if (isCenter) content = Center(child: content);
    if (width != null) content = SizedBox(width: width, child: content);

    return DataCell(content);
  }
}
