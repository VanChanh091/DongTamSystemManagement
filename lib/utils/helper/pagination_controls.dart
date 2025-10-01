import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous
          ElevatedButton(
            onPressed: currentPage > 1 ? onPrevious : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.buttonColor.value,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              elevation: 5,
            ),
            child: const Text(
              "Trang trước",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            'Trang: $currentPage / $totalPages',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),

          // Next
          ElevatedButton(
            onPressed: currentPage < totalPages ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.buttonColor.value,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              elevation: 5,
            ),
            child: const Text(
              "Trang sau",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
