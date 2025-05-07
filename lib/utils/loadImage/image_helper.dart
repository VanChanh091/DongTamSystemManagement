import 'package:dongtam/constant/appInfo.dart';

String getImageUrl(String fileName) {
  const baseUrl = '${AppInfo.BASE_URL}/uploads';
  return '$baseUrl/$fileName';
}
