import 'package:flutter/material.dart';

double toDouble(dynamic val) {
  if (val == null || val == '') return 0.0;
  if (val is int) return val.toDouble();
  if (val is double) return val;
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

TimeOfDay parseTimeOfDay(dynamic timeValue) {
  // Trường hợp đã là TimeOfDay → trả về luôn
  if (timeValue is TimeOfDay) return timeValue;

  // Trường hợp là chuỗi hợp lệ → parse
  if (timeValue is String && timeValue.isNotEmpty) {
    try {
      final parts = timeValue.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print('⚠️ Error parsing time: $e for $timeValue');
    }
  }

  // Trả về mặc định nếu không parse được
  return const TimeOfDay(hour: 0, minute: 0);
}
