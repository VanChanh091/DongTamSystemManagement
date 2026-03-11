import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/data/controller/upload_process_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressUploadOrverlay extends StatelessWidget {
  final Widget child;
  const ProgressUploadOrverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final uploadProgressController = Get.find<UploadProcessController>();
    final themeController = Get.find<ThemeController>();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          KeyedSubtree(key: GlobalKey(), child: child),

          Obx(() {
            if (!uploadProgressController.isUploading.value) return const SizedBox.shrink();

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: 20,
              left: 30,
              right: 30,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeController.currentColor.value),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeController.currentColor.value,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uploadProgressController.statusMessage.value,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Tiến trình: ${(uploadProgressController.progress.value * 100).toInt()}%",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: uploadProgressController.progress.value,
                          minHeight: 6,
                          backgroundColor: themeController.currentColor.value.withValues(
                            alpha: 0.1,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            themeController.currentColor.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
