import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SavePlanning extends StatelessWidget {
  final bool isLoading;

  final String machine;
  final TextEditingController dayStartController;
  final TextEditingController timeStartController;
  final TextEditingController totalTimeWorkingController;
  final bool isBox;

  final List<DataGridRow> Function() getRows;

  final String idColumn; // "planningId" hoặc "planningBoxId"
  final Rx<Color> backgroundColor;

  final VoidCallback onSuccess;
  final VoidCallback onStartLoading;
  final VoidCallback onEndLoading;

  const SavePlanning({
    super.key,
    required this.isLoading,
    required this.dayStartController,
    required this.timeStartController,
    required this.totalTimeWorkingController,
    required this.getRows,
    required this.idColumn,
    required this.isBox,
    required this.backgroundColor,
    required this.machine,
    required this.onSuccess,
    required this.onStartLoading,
    required this.onEndLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PopupMenuButton<String>(
          color: Colors.white,
          position: PopupMenuPosition.under,
          offset: const Offset(35, 5),
          onSelected: (value) async {
            if (isLoading) return;

            if (value == 'continue') {
              await _handleSave(context, forceNewDay: false);
            } else if (value == 'new') {
              await _handleSave(context, forceNewDay: true);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem<String>(
                  value: "continue",
                  child: ListTile(
                    leading: Icon(Icons.play_arrow, color: Colors.green),
                    title: Text("Chạy tiếp tục"),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: "new",
                  child: ListTile(
                    leading: Icon(Icons.fiber_new, color: Colors.blue),
                    title: Text("Chạy ngày mới"),
                  ),
                ),
              ],
          child: ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return backgroundColor.value;
                }
                return backgroundColor.value;
              }),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              padding: WidgetStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save),
                const SizedBox(width: 6),
                Text("Lưu", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),

        if (isLoading)
          const Positioned(
            right: 10,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Future<void> _handleSave(BuildContext context, {required bool forceNewDay}) async {
    final rows = getRows();

    if (dayStartController.text.isEmpty ||
        timeStartController.text.isEmpty ||
        totalTimeWorkingController.text.isEmpty) {
      showSnackBarError(
        context,
        "Vui lòng nhập đầy đủ ngày bắt đầu, giờ bắt đầu và tổng thời gian.",
      );
      return;
    }

    onStartLoading();

    try {
      // 1) Tạo danh sách updateIndex
      final List<Map<String, dynamic>> updateIndex =
          rows
              .asMap()
              .entries
              .where((entry) {
                final status =
                    entry.value
                        .getCells()
                        .firstWhere(
                          (c) => c.columnName == "status",
                          orElse: () => DataGridCell(columnName: 'status', value: null),
                        )
                        .value;

                return status != 'complete';
              })
              .map((entry) {
                final idValue =
                    entry.value.getCells().firstWhere((c) => c.columnName == idColumn).value;
                return {idColumn: idValue, "sortPlanning": entry.key + 1};
              })
              .toList();

      // 2) Lấy đơn complete cuối cùng (để BE tính timeRunning)
      DataGridRow? lastCompleteRow;
      for (var row in rows.reversed) {
        final status =
            row
                .getCells()
                .firstWhere(
                  (c) => c.columnName == "status",
                  orElse: () => DataGridCell(columnName: 'status', value: null),
                )
                .value;

        if (status == 'complete') {
          lastCompleteRow = row;
          break;
        }
      }

      if (lastCompleteRow != null) {
        final idValue =
            lastCompleteRow.getCells().firstWhere((c) => c.columnName == idColumn).value;

        updateIndex.add({idColumn: idValue});
      }

      // 3) Parse lại ngày + giờ + tổng thời gian
      final DateTime parsedDayStart = DateFormat('dd/MM/yyyy').parse(dayStartController.text);
      final parts = timeStartController.text.split(':');
      final parsedTimeStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final totalWorking = int.tryParse(totalTimeWorkingController.text) ?? 0;

      // 4️⃣ Gửi xuống BE
      // print("=== Các đơn sẽ gửi xuống BE ===");
      // for (var item in updateIndex) {
      //   print(item);
      // }
      // print("================================");

      // 4) Gọi API
      final result = await PlanningService().updateIndexWTimeRunning(
        machine: machine,
        dayStart: parsedDayStart,
        timeStart: parsedTimeStart,
        totalTimeWorking: totalWorking,
        updateIndex: updateIndex,
        isNewDay: forceNewDay,
        isBox: isBox,
      );

      if (!context.mounted) return;

      if (result) {
        showSnackBarSuccess(context, "Cập nhật thành công");
        onSuccess();
      }
    } catch (e, s) {
      if (context.mounted) {
        showSnackBarError(context, "Lỗi cập nhật");
      }
      AppLogger.e("Lỗi khi lưu", error: e, stackTrace: s);
    } finally {
      onEndLoading();
    }
  }
}
