import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadConfig() async {
  if (kReleaseMode) {
    // 🔹 Khi build .exe
    final exePath = File(Platform.resolvedExecutable).parent.path;
    final configFile = File('$exePath/config.prod.json');

    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      return jsonDecode(content);
    } else {
      throw Exception("Không tìm thấy file config.json");
    }
  } else {
    // 🔹 Khi đang chạy flutter run (dev)
    final content = await rootBundle.loadString(
      'assets/config/config.dev.json',
    );
    return jsonDecode(content);
  }
}
