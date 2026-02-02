import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dongtam/constant/app_info.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as p;

class UpdateService {
  static final String xmlUrl = "${AppInfo.BASE_URL}/updates/appcast.xml";
  static final String baseUrl = "${AppInfo.BASE_URL}/updates/"; // Để nối vào file .exe

  // 1. Kiểm tra version
  static Future<void> checkUpdate(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // 2. Tải file XML về và parse
    final response = await Dio().get(xmlUrl);

    final document = XmlDocument.parse(response.data);

    // Tìm item đầu tiên trong channel
    final item = document.findAllElements('item').first;

    final latestVersion = item.findElements('sparkle:version').first.innerText;
    final description = item.findElements('description').first.innerText;
    final fileName = item.findElements('enclosure').first.getAttribute('url');
    final downloadUrl = "$baseUrl$fileName";

    print(downloadUrl);

    if (latestVersion != currentVersion) {
      if (!context.mounted) return;
      _showUpdateDialog(context, downloadUrl, latestVersion, description);
    }
  }

  // 2. Hiện thông báo hỏi ý kiến
  static void _showUpdateDialog(BuildContext context, String url, String version, String note) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header: Icon & Title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(
                      Icons.system_update_alt_rounded,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Phiên bản mới v$version",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Release Notes Box
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Có gì mới trong bản cập nhật này?",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            note
                                .split('\n') // Tách theo dấu xuống dòng
                                .map((line) => line.trim()) // Xóa khoảng trắng thừa 2 đầu
                                .where((line) => line.isNotEmpty) // Bỏ dòng trống
                                .map(
                                  (cleanLine) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: Colors.blue.shade400,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            cleanLine.trim(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade800,
                                              height: 1.4,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Để sau", style: TextStyle(color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _downloadAndInstall(context, url);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Cập nhật ngay",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static Future<void> _downloadAndInstall(BuildContext context, String url) async {
    final ValueNotifier<double> downloadProgress = ValueNotifier(0);

    try {
      //progess dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => ValueListenableBuilder<double>(
              valueListenable: downloadProgress,
              builder: (context, value, child) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    color: Colors.white,
                    width: 400,
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_download_rounded, size: 50, color: Colors.blue),
                        const SizedBox(height: 20),
                        const Text(
                          "Đang tải bản cập nhật...",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Vui lòng không tắt ứng dụng",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 25),
                        // Thanh progress bo góc hiện đại
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: Colors.blue.shade50,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "${(value * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      );

      String fileName = p.basename(url);
      Directory tempDir = await getTemporaryDirectory();
      String savePath = p.join(tempDir.path, fileName);

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      // Đảm bảo progress nhảy lên 100% trước khi đóng
      downloadProgress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 500));

      final result = await OpenFile.open(savePath);

      // Nếu mở thành công thì mới thoát app
      if (result.type == ResultType.done) {
        await Future.delayed(const Duration(seconds: 1)); // Cho trình cài đặt kịp khởi động
        exit(0);
      } else {
        throw Exception("Không thể mở file cài đặt: ${result.message}");
      }
    } catch (e, s) {
      if (!context.mounted) return;
      Navigator.pop(context);
      AppLogger.e("Lỗi tải/cài đặt:", error: e, stackTrace: s);
    }
  }
}
