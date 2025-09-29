import 'dart:convert';
import 'dart:io';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

//config to get prod or dev ip
Future<Map<String, dynamic>> loadConfig() async {
  try {
    if (kReleaseMode) {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final configPath = p.join(exeDir, 'config.prod.json');

      File configFile = File(configPath);

      // Fallback sang %APPDATA% nếu không có
      if (!await configFile.exists()) {
        AppLogger.w("Config not found at exeDir, trying APPDATA...");

        final appDataDir = p.join(
          Platform.environment['APPDATA'] ?? exeDir,
          'MyApp',
        );

        final appConfig = File(p.join(appDataDir, 'config.prod.json'));
        if (await appConfig.exists()) configFile = appConfig;
      }

      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        AppLogger.i("Config loaded successfully from: ${configFile.path}");
        return jsonDecode(content);
      } else {
        AppLogger.e("Không tìm thấy file config.prod.json");
        throw Exception("Không tìm thấy file config.prod.json");
      }
    } else {
      final content = await rootBundle.loadString(
        'assets/config/config.dev.json',
      );

      AppLogger.i(
        "Config loaded successfully from assets/config/config.dev.json",
      );
      return jsonDecode(content);
    }
  } catch (e, s) {
    AppLogger.e("Failed to load config", error: e, stackTrace: s);
    throw Exception("Failed to load config: $e");
  }
}
