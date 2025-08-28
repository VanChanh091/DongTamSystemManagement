import 'package:get/get.dart';

class AppInfo {
  // static const String BASE_URL = "http://localhost:5000";
  // static const String BASE_URL = "http://dongtam.company.local:5000";
  static String get BASE_URL {
    final config = Get.find<Map<String, dynamic>>(tag: "AppConfig");
    final ip = config['serverIp'];
    final port = config['serverPort'];
    return "http://$ip:$port";
  }
}
