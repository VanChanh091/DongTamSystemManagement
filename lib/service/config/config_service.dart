import 'dart:convert';
import 'dart:io';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

// Thử kết nối socket nhanh để xác định server đang hoạt động ở IP nào
Future<String> _resolveServerIp(Map<String, dynamic> config) async {
  final int port =
      config['serverPort'] is int
          ? config['serverPort'] as int
          : int.tryParse(config['serverPort']?.toString() ?? '5000') ?? 5000;

  final candidateIps = <String>[
    if (config['serverIp'] != null && config['serverIp'].toString().isNotEmpty)
      config['serverIp'].toString(),
    if (config['serverIpPm2'] != null && config['serverIpPm2'].toString().isNotEmpty)
      config['serverIpPm2'].toString(),
  ];

  for (final ip in candidateIps) {
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 500));
      socket.destroy();
      AppLogger.i("Đã kết nối thành công tới server tại $ip:$port");
      return ip;
    } catch (e) {
      AppLogger.w("Không thể kết nối tới server tại $ip:$port");
    }
  }

  final fallbackIp = candidateIps.isNotEmpty ? candidateIps.first : 'localhost';
  return fallbackIp;
}

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

        final appDataDir = p.join(Platform.environment['APPDATA'] ?? exeDir, 'MyApp');

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
      final content = await rootBundle.loadString('assets/config/config.dev.json');

      AppLogger.i("Config loaded successfully from config.dev.json");
      final Map<String, dynamic> config = jsonDecode(content);

      // Tự động kiểm tra và chọn server IP khả dụng (localhost hoặc serverIpPm2)
      final resolvedIp = await _resolveServerIp(config);
      config['serverIp'] = resolvedIp;
      AppLogger.i("Server IP được sử dụng: $resolvedIp");

      return config;
    }
  } catch (e, s) {
    AppLogger.e("Failed to load config", error: e, stackTrace: s);
    throw Exception("Failed to load config: $e");
  }
}
