import 'package:dongtam/data/controller/theme_controller.dart';
import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginationControls extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Function(int) onJumpToPage;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    required this.onJumpToPage,
  });

  @override
  State<PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends State<PaginationControls> {
  late TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
      text: widget.currentPage.toString(),
    );
  }

  @override
  void didUpdateWidget(PaginationControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _pageController.text = widget.currentPage.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleJump() {
    final value = int.tryParse(_pageController.text);
    if (value != null &&
        value >= 1 &&
        value <= widget.totalPages &&
        value != widget.currentPage) {
      widget.onJumpToPage(value);
    } else {
      // Feedback nhỏ nếu nhập sai
      showSnackBarError(context, 'Số trang không hợp lệ');
      _pageController.text = widget.currentPage.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút trang trước
          ElevatedButton(
            onPressed: widget.currentPage > 1 ? widget.onPrevious : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.buttonColor.value,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              elevation: 5,
            ),
            child: const Text(
              "Trang trước",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),

          // TextField nhập trang
          Row(
            children: [
              SizedBox(
                width: 40,
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _handleJump(),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${widget.totalPages}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Nút trang sau
          ElevatedButton(
            onPressed:
                widget.currentPage < widget.totalPages ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.buttonColor.value,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shadowColor: Colors.black.withValues(alpha: 0.2),
              elevation: 5,
            ),
            child: const Text(
              "Trang sau",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
