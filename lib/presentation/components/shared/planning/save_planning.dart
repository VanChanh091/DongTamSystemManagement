import 'package:dongtam/presentation/components/shared/animated_button.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SavePlanning extends StatelessWidget {
  final bool isLoading;
  final TextEditingController dayStartController;
  final TextEditingController timeStartController;
  final TextEditingController totalTimeWorkingController;
  final List<DataGridRow> Function() getRows;

  final String idColumn; // "planningId" hoặc "planningBoxId"
  final bool isBox;
  final Rx<Color> backgroundColor;

  final String machine;
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
        AnimatedButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
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
                      // 1️⃣ Lấy các đơn chưa complete và gán sortPlanning
                      final List<Map<String, dynamic>> updateIndex =
                          rows
                              .asMap()
                              .entries
                              .where((entry) {
                                final status =
                                    entry.value
                                        .getCells()
                                        .firstWhere(
                                          (cell) => cell.columnName == "status",
                                          orElse:
                                              () => DataGridCell(columnName: 'status', value: null),
                                        )
                                        .value;

                                return status != 'complete';
                              })
                              .map((entry) {
                                final idValue =
                                    entry.value
                                        .getCells()
                                        .firstWhere((cell) => cell.columnName == idColumn)
                                        .value;

                                return {idColumn: idValue, "sortPlanning": entry.key + 1};
                              })
                              .toList();

                      // 2️⃣ Lấy 1 đơn complete cuối cùng (để BE tính timeRunning, không update sortPlanning)
                      DataGridRow? lastCompleteRow;

                      for (var row in rows.reversed) {
                        final status =
                            row
                                .getCells()
                                .firstWhere(
                                  (cell) => cell.columnName == "status",
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
                            lastCompleteRow
                                .getCells()
                                .firstWhere((c) => c.columnName == idColumn)
                                .value;

                        updateIndex.add({idColumn: idValue});
                      }

                      // 3️⃣ Parse ngày, giờ, tổng thời gian
                      final DateTime parsedDayStart = DateFormat(
                        'dd/MM/yyyy',
                      ).parse(dayStartController.text);

                      final List<String> timeParts = timeStartController.text.split(':');

                      final TimeOfDay parsedTimeStart = TimeOfDay(
                        hour: int.parse(timeParts[0]),
                        minute: int.parse(timeParts[1]),
                      );

                      final int parsedTotalTime =
                          int.tryParse(totalTimeWorkingController.text) ?? 0;

                      // 4️⃣ Gửi xuống BE
                      print("=== Các đơn sẽ gửi xuống BE ===");
                      for (var item in updateIndex) {
                        print(item);
                      }
                      print("================================");

                      final result = await PlanningService().updateIndexWTimeRunning(
                        machine: machine,
                        dayStart: parsedDayStart,
                        timeStart: parsedTimeStart,
                        totalTimeWorking: parsedTotalTime,
                        updateIndex: updateIndex,
                        isBox: isBox,
                      );

                      if (!context.mounted) {
                        return;
                      }
                      if (result) {
                        showSnackBarSuccess(context, "Cập nhật thành công");
                        onSuccess();
                      }
                    } catch (e, s) {
                      if (!context.mounted) {
                        return;
                      }
                      showSnackBarError(context, "Lỗi cập nhật");

                      AppLogger.e("Lỗi khi lưu", error: e, stackTrace: s);
                    } finally {
                      onEndLoading();
                    }
                  },
          label: "Lưu",
          icon: Icons.save,
          backgroundColor: backgroundColor,
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
}
