import 'package:flutter/material.dart';

class TimeAndDayPlanning extends StatelessWidget {
  final TextEditingController dayStartController;
  final TextEditingController timeStartController;
  final TextEditingController totalTimeWorkingController;

  const TimeAndDayPlanning({
    super.key,
    required this.dayStartController,
    required this.timeStartController,
    required this.totalTimeWorkingController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ngày bắt đầu
          _buildLabelAndUnderlineInput(
            label: "Ngày bắt đầu:",
            controller: dayStartController,
            width: 120,
            readOnly: true,
            onTap: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogTheme: DialogThemeData(backgroundColor: Colors.white12),
                    ),
                    child: child!,
                  );
                },
              );
              if (selected != null) {
                dayStartController.text =
                    "${selected.day.toString().padLeft(2, '0')}/"
                    "${selected.month.toString().padLeft(2, '0')}/"
                    "${selected.year}";
              }
            },
          ),
          const SizedBox(width: 32),

          // Giờ bắt đầu
          _buildLabelAndUnderlineInput(
            label: "Giờ bắt đầu:",
            controller: timeStartController,
            width: 60,
          ),
          const SizedBox(width: 32),

          // Tổng giờ làm
          _buildLabelAndUnderlineInput(
            label: "Tổng giờ làm:",
            controller: totalTimeWorkingController,
            width: 40,
            inputType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

Widget _buildLabelAndUnderlineInput({
  required String label,
  required TextEditingController controller,
  required double width,
  TextInputType? inputType,
  void Function()? onTap,
  bool readOnly = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      const SizedBox(width: 8),
      SizedBox(
        width: width,
        child: TextFormField(
          controller: controller,
          keyboardType: inputType ?? TextInputType.text,
          readOnly: readOnly,
          decoration: InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            hintText: '',
          ),
          onTap: onTap,
        ),
      ),
    ],
  );
}
