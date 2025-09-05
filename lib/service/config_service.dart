import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

Future<Map<String, dynamic>> loadConfig() async {
  if (kReleaseMode) {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final configPath = p.join(exeDir, 'config.prod.json');

    File configFile = File(configPath);

    // Fallback sang %APPDATA% nếu không có
    if (!await configFile.exists()) {
      final appDataDir = p.join(
        Platform.environment['APPDATA'] ?? exeDir,
        'MyApp',
      );
      final appConfig = File(p.join(appDataDir, 'config.prod.json'));
      if (await appConfig.exists()) configFile = appConfig;
    }

    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      return jsonDecode(content);
    } else {
      throw Exception("Không tìm thấy file config.prod.json");
    }
  } else {
    final content = await rootBundle.loadString(
      'assets/config/config.dev.json',
    );
    return jsonDecode(content);
  }
}
