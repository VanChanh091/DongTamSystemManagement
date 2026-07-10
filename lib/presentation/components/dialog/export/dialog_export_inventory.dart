import 'dart:io';

import 'package:dongtam/service/warehouse_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DialogExportInventory extends StatefulWidget {
  const DialogExportInventory({super.key});

  @override
  State<DialogExportInventory> createState() => _DialogExportInventoryState();
}

class _DialogExportInventoryState extends State<DialogExportInventory> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  DateTime? selectedDate;

  Future<void> pickDateTime(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    final DateTime initial = selectedDate ?? DateTime.now();
    DateTime tempDate = DateTime(initial.year, initial.month, initial.day);
    TimeOfDay tempTime = TimeOfDay(hour: initial.hour, minute: initial.minute);

    final DateTime? result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 580,
            child: StatefulBuilder(
              builder: (context, dialogSetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Chọn Ngày & Giờ",
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 280,
                            child: CalendarDatePicker(
                              initialDate: tempDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              onDateChanged: (date) {
                                dialogSetState(() {
                                  tempDate = date;
                                });
                              },
                            ),
                          ),
                        ),

                        const VerticalDivider(width: 20, thickness: 1),

                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                "Giờ chốt kho:",
                                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),

                              OutlinedButton.icon(
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: tempTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          timePickerTheme: TimePickerTheme.of(context).copyWith(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          colorScheme: Theme.of(
                                            context,
                                          ).colorScheme.copyWith(surface: Colors.white),
                                        ),
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: size.width * 0.3,
                                              maxHeight: size.height * 0.8,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(16),
                                              clipBehavior: Clip.antiAlias,
                                              child: child!,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  if (time != null) {
                                    dialogSetState(() {
                                      tempTime = time;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.access_time, size: 18),
                                label: Text(tempTime.format(context)),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              Text(
                                "Đã chọn:\n${DateFormat('dd/MM/yyyy').format(tempDate)} ${tempTime.format(context)}",
                                style: GoogleFonts.inter(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Hàng nút điều hướng dưới cùng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Hủy",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        ElevatedButton(
                          onPressed: () {
                            final finalDateTime = DateTime(
                              tempDate.year,
                              tempDate.month,
                              tempDate.day,
                              tempTime.hour,
                              tempTime.minute,
                            );
                            Navigator.pop(context, finalDateTime);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            "Xác nhận",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  void submit() async {
    try {
      if (selectedOption.value == 'closingDate') {
        if (selectedDate == null) {
          showSnackBarError(context, 'Vui lòng chọn ngày');
          return;
        }
      }

      File? file;
      file = await WarehouseService().exportExcelInventory(targetDate: selectedDate);

      if (mounted) {
        if (file != null) {
          showSnackBarSuccess(context, 'Xuất dữ liệu thành công');
        } else {
          showSnackBarError(context, "Xuất file thất bại");
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, s) {
      if (mounted) {
        AppLogger.e("Lỗi khi xuất excel", error: e, stackTrace: s);
        showSnackBarError(context, 'Lỗi: Không thể xuất dữ liệu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Xuất Danh Sách Tồn Kho",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: ValueListenableBuilder<String?>(
        valueListenable: selectedOption,
        builder: (context, value, _) {
          return RadioGroup(
            groupValue: value,
            onChanged: (val) {
              if (val != null) selectedOption.value = val;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option 1: Theo Tất Cả
                // RadioListTile<String>(
                //   title: const Text("Tồn Hiện Tại", style: TextStyle(fontSize: 16)),
                //   value: 'all',
                //   groupValue: value,
                //   onChanged: (val) => selectedOption.value = val,
                // ),
                // Option 2: Theo ngày nhập kho
                RadioListTile<String>(
                  title: const Text("Chốt Tồn Kho", style: TextStyle(fontSize: 16)),
                  value: 'closingDate',
                ),

                const SizedBox(height: 10),
                if (value == 'closingDate') ...[
                  Column(
                    children: [
                      SizedBox(
                        width: 250,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => pickDateTime(context),
                          icon: Icon(Icons.date_range, color: Colors.blue.shade400),
                          label: Text(
                            selectedDate == null
                                ? "Chọn ngày"
                                : DateFormat('dd/MM/yyyy HH:mm').format(selectedDate!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (selectedDate == null)
                        const Text(
                          "Chưa chọn ngày chốt tồn kho",
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),

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
          child: const Text(
            "Xác nhận",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
