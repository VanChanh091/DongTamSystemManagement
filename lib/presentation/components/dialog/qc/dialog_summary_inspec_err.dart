import 'package:dongtam/data/models/qualityControl/qcInspection/qc_error_summary_model.dart';
import 'package:dongtam/presentation/components/shared/animation/animated_button.dart';
import 'package:dongtam/presentation/components/shared/resizable_dialog.dart';
import 'package:dongtam/service/report_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/helper/reponsive/reponsive_dialog.dart';
import 'package:dongtam/utils/validation/validation_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum InspectionType { paper, box }

class DialogSummaryInspecErr extends StatefulWidget {
  final InspectionType type;
  final String machine;
  final List<String> machineList;

  const DialogSummaryInspecErr({
    super.key,
    required this.machine,
    required this.type,
    required this.machineList,
  });

  @override
  State<DialogSummaryInspecErr> createState() => _DialogSummaryInspecErrState();
}

class _DialogSummaryInspecErrState extends State<DialogSummaryInspecErr> {
  final formKey = GlobalKey<FormState>();

  // Danh sách tổng hợp lỗi nhận từ BE
  final _dateController = TextEditingController();
  List<QcErrorSummaryModel> listErrorSummary = [];

  // Date range variables
  late String selectedMachine;
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedMachine = widget.machine;
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final size = MediaQuery.of(context).size;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
      initialDateRange:
          (startDate != null && endDate != null)
              ? DateTimeRange(start: startDate!, end: endDate!)
              : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.35 < 400 ? 400 : size.width * 0.35,
              maxHeight: size.height * 0.8,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      final displayStart = DateFormat('dd/MM/yyyy').format(picked.start);
      final displayEnd = DateFormat('dd/MM/yyyy').format(picked.end);

      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _dateController.text = '$displayStart - $displayEnd';
      });
    }
  }

  Future<void> _handleFilter() async {
    if (formKey.currentState?.validate() ?? false) {
      if (startDate != null && endDate != null) {
        setState(() => isLoading = true);
        try {
          final result = await ReportService().getReportQcInspectionSummary(
            isPaper: widget.type == InspectionType.paper ? "paper" : "box",
            machine: selectedMachine,
            startDate: startDate!,
            endDate: endDate!,
          );

          setState(() {
            listErrorSummary = result;
          });
        } catch (error) {
          if (mounted) {
            showSnackBarError(context, "Lỗi tải báo cáo: $error");
          }
        } finally {
          if (mounted) setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResizableDialog(
      initialWidth: ResponsiveSize.getWidth(context, ResponsiveType.medium),
      minWidth: 550,
      maxWidth: 850,
      minHeight: 500,

      title: Center(
        child: Text(
          "Tổng hợp lỗi: ${widget.machine}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),

      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Đóng",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
      ],

      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //select date range
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDateRange,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Vui lòng chọn khoảng ngày...",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.calendar_month, color: Colors.red, size: 20),
                        suffixIcon:
                            _dateController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      startDate = null;
                                      endDate = null;
                                      _dateController.clear();
                                      listErrorSummary.clear();
                                    });
                                  },
                                )
                                : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (startDate == null || endDate == null) {
                          return "Vui lòng chọn thời gian!";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  //dropdown machine
                  Expanded(
                    flex: 1,
                    child: ValidationHelper.dropdownForTypes(
                      items: widget.machineList.isNotEmpty ? widget.machineList : [selectedMachine],
                      type: selectedMachine,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedMachine = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  AnimatedButton(
                    onPressed: isLoading ? null : _handleFilter,
                    label: isLoading ? "Đang lọc..." : "Lọc đơn",
                    icon: Icons.search,
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // phân thành 2 cột
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildSummaryContent(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- RENDER BẢNG 2 CỘT
  Widget _buildSummaryContent() {
    if (listErrorSummary.isEmpty) {
      return Center(
        child: Text(
          "Vui lòng chọn khoảng ngày và bấm \"Lọc đơn\" để xem báo cáo.",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }

    // nếu tiêu chí <= 10 => 1 cột
    if (listErrorSummary.length <= 10) {
      return SingleChildScrollView(child: _buildErrorTable(listErrorSummary));
    }

    // nếu tiêu chí > 10 => 2 cột
    final half = (listErrorSummary.length / 2).ceil();
    final leftList = listErrorSummary.sublist(0, half);
    final rightList = listErrorSummary.sublist(half);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildErrorTable(leftList)),
          const SizedBox(width: 16),
          Expanded(child: _buildErrorTable(rightList)),
        ],
      ),
    );
  }

  Widget _buildErrorTable(List<QcErrorSummaryModel> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3), // Cột Tên Tiêu Chí
          1: FlexColumnWidth(1), // Cột Số Lần
        },
        children: [
          // Header Table
          const TableRow(
            decoration: BoxDecoration(color: Color.fromARGB(255, 250, 235, 148)),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Text(
                  "Tên Tiêu Chí / Lỗi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Text(
                  "Số Lần",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),

          // Các hàng tiêu chí
          ...items.map((item) {
            final hasError = item.count > 0;
            return TableRow(
              decoration: BoxDecoration(color: Colors.white),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  child: Text(
                    "${item.count}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: hasError ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
