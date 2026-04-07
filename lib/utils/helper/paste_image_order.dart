import 'package:dongtam/utils/handleError/show_snack_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';

class PasteImageOrder extends StatefulWidget {
  final Uint8List? initialImage;
  final String? initialImageUrl;
  final bool initialIsDelete;

  // hàm callback để trả dữ liệu ngược lại cho Dialog
  final Function(Uint8List? bytes, String? url, bool isDelete) onImageChanged;

  const PasteImageOrder({
    super.key,
    this.initialImage,
    this.initialImageUrl,
    required this.initialIsDelete,
    required this.onImageChanged,
  });

  @override
  State<PasteImageOrder> createState() => _PasteImageOrderState();
}

class _PasteImageOrderState extends State<PasteImageOrder> {
  late Uint8List? _currentBytes;
  late String? _currentUrl;
  late bool _currentIsDelete;

  @override
  void initState() {
    super.initState();
    _currentBytes = widget.initialImage;
    _currentUrl = widget.initialImageUrl;
    _currentIsDelete = widget.initialIsDelete;
  }

  void _updateState(Uint8List? bytes, String? url, bool isDelete) {
    setState(() {
      _currentBytes = bytes;
      _currentUrl = url;
      _currentIsDelete = isDelete;
    });
    // Gọi callback để báo cho Dialog biết giá trị đã thay đổi
    widget.onImageChanged(bytes, url, isDelete);
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      _updateState(result.files.single.bytes, null, false);
    }
  }

  Future<void> _handlePaste() async {
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      _updateState(imageBytes, null, false);
      if (!mounted) return;
      showSnackBarSuccess(context, "Đã dán ảnh từ Clipboard!");
    } else {
      if (!mounted) return;
      showSnackBarError(context, "Không tìm thấy ảnh trong Clipboard!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): _handlePaste, // Cho Windows
        const SingleActivator(LogicalKeyboardKey.keyV, meta: true): _handlePaste, // Cho máy Mac
      },
      child: Focus(
        autofocus: true, //focus phím tắt
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //select image
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text(
                      "Chọn ảnh",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  //paste image
                  ElevatedButton.icon(
                    onPressed: _handlePaste,
                    icon: const Icon(Icons.paste),
                    label: const Text(
                      "Dán ảnh",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (_currentBytes != null ||
                      (_currentUrl != null && _currentUrl!.isNotEmpty && !_currentIsDelete)) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _updateState(null, null, true),
                      icon: const Icon(Icons.delete),
                      label: const Text(
                        "Xóa ảnh",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Vùng hiển thị ảnh
              _buildImagePreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_currentBytes != null) {
      return Image.memory(
        _currentBytes!,
        height: 500,
        width: 700,
        filterQuality: FilterQuality.high,
        fit: BoxFit.contain,
      );
    } else if (_currentUrl != null && _currentUrl!.isNotEmpty && !_currentIsDelete) {
      return Image.network(
        _currentUrl!,
        height: 500,
        width: 700,
        filterQuality: FilterQuality.high,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text('Lỗi tải ảnh', style: TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            width: double.infinity,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
      );
    } else {
      return Container(
        height: 250,
        width: 450,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Chưa có ảnh\n(Nhấn Ctrl+V để dán)",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
