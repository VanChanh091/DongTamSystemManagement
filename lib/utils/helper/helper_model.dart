import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';

double toDouble(dynamic val) {
  if (val == null || val == "") return 0.0;
  if (val is int) return val.toDouble();
  if (val is double) return val;
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

int toInt(dynamic val) {
  if (val == null || val == "") return 0;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? 0;
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
    } catch (e, s) {
      AppLogger.e("⚠️ Error parsing time for $timeValue", error: e, stackTrace: s);
    }
  }

  // Trả về mặc định nếu không parse được
  return const TimeOfDay(hour: 0, minute: 0);
}

// Parse Map có key là String/Number sang Map<int, T>.
// Nếu `valueParser` trả về null thì phần tử đó sẽ bị bỏ qua (an toàn khi data lỗi).
Map<int, T> parseIntKeyMap<T>(dynamic raw, T? Function(dynamic value) valueParser) {
  if (raw is! Map) return {};

  final Map<int, T> result = {};
  raw.forEach((key, value) {
    final intKey = int.tryParse(key.toString());
    if (intKey != null) {
      final parsedValue = valueParser(value);
      if (parsedValue != null) {
        result[intKey] = parsedValue;
      }
    }
  });

  return result;
}

/// Helper chuyên dùng cho Model: tự check `is Map<String, dynamic>` trước khi parse
Map<int, T> parseIntModelMap<T>(dynamic raw, T Function(Map<String, dynamic> json) fromJson) {
  return parseIntKeyMap(raw, (v) => v is Map<String, dynamic> ? fromJson(v) : null);
}

// Helper viết tắt chuyên dùng cho Map<int, int>
Map<int, int> parseIntIntMap(dynamic raw) {
  return parseIntKeyMap(raw, (v) => toInt(v));
}

// Helper viết tắt chuyên dùng cho Map<int, double>
Map<int, double> parseIntDoubleMap(dynamic raw) {
  return parseIntKeyMap(raw, (v) => toDouble(v));
}
