import "dart:typed_data";
import "package:dongtam/data/controller/theme_controller.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart";
import "package:dongtam/service/warehouse_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:printing/printing.dart";

class DialogPreviewOutboundPdf extends StatefulWidget {
  final OutboundHistoryModel outbound;
  final bool hasMoney;

  const DialogPreviewOutboundPdf({super.key, required this.outbound, required this.hasMoney});

  @override
  State<DialogPreviewOutboundPdf> createState() => _DialogPreviewOutboundPdfState();
}

class _DialogPreviewOutboundPdfState extends State<DialogPreviewOutboundPdf> {
  final themeController = Get.find<ThemeController>();

  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final bytes = await WarehouseService().getOutboundPdfBytes(
      outboundId: widget.outbound.outboundId,
      hasMoney: widget.hasMoney,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (bytes != null) {
          _pdfBytes = bytes;
        } else {
          _errorMessage = "Không thể tải nội dung phiếu xuất kho";
        }
      });
    }
  }

  // Tải file về máy
  Future<void> _downloadFile() async {
    if (_pdfBytes == null) return;

    final slipCode =
        widget.outbound.outboundSlipCode.isNotEmpty
            ? widget.outbound.outboundSlipCode
            : "PXK_${widget.outbound.outboundId}";

    setState(() => _isDownloading = true);

    try {
      final file = await WarehouseService().savePdfBytesToFile(
        bytes: _pdfBytes!,
        defaultFileName: "$slipCode.pdf",
      );

      if (mounted && file != null) {
        showSnackBarSuccess(context, "Lưu file thành công");
      }
    } catch (_) {
      if (mounted) {
        showSnackBarError(context, "Lỗi khi lưu file PDF");
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  // In tài liệu
  Future<void> _printPdf(String slipCode) async {
    if (_pdfBytes == null) return;
    await Printing.layoutPdf(onLayout: (format) => _pdfBytes!, name: "$slipCode.pdf");
  }

  // Chia sẻ tài liệu
  Future<void> _sharePdf(String slipCode) async {
    if (_pdfBytes == null) return;
    await Printing.sharePdf(bytes: _pdfBytes!, filename: "$slipCode.pdf");
  }

  @override
  Widget build(BuildContext context) {
    final slipCode =
        widget.outbound.outboundSlipCode.isNotEmpty
            ? widget.outbound.outboundSlipCode
            : "#PXK-${widget.outbound.outboundId}";

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth > 1000 ? 1000 : screenWidth * 0.9,
          maxHeight: screenHeight * 0.96,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================== HEADER ====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Symbols.preview, color: Colors.blue.shade700, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Bản Xem Trước ($slipCode)",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Nút Tải File PDF
                  IconButton(
                    onPressed: (_pdfBytes != null && !_isDownloading) ? _downloadFile : null,
                    icon:
                        _isDownloading
                            ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: themeController.currentColor.value,
                              ),
                            )
                            : const Icon(Icons.download, size: 20),
                    tooltip: _isDownloading ? "Đang lưu file..." : "Tải file",
                    splashRadius: 18,
                  ),
                  const SizedBox(width: 4),

                  // Nút In
                  IconButton(
                    onPressed: _pdfBytes != null ? () => _printPdf(slipCode) : null,
                    icon: const Icon(Icons.print_outlined, size: 20),
                    tooltip: "In",
                    splashRadius: 18,
                  ),

                  // Nút Share
                  IconButton(
                    onPressed: _pdfBytes != null ? () => _sharePdf(slipCode) : null,
                    icon: const Icon(Icons.share_outlined, size: 20),
                    tooltip: "Chia sẻ",
                    splashRadius: 18,
                  ),
                  const SizedBox(width: 7),

                  // Nút Đóng
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    splashRadius: 18,
                    tooltip: "Đóng",
                  ),
                ],
              ),
            ),

            // ==================== PDF BODY ====================
            Flexible(
              child:
                  _isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(strokeWidth: 3),
                              SizedBox(height: 16),
                              Text(
                                "Đang tải dữ liệu phiếu xuất kho...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                      : _errorMessage != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Symbols.error, color: Colors.red.shade400, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _fetchPdf,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text("Thử lại"),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Container(
                        color: const Color(0xff525659),
                        child: PdfPreview(
                          build: (format) => _pdfBytes!,
                          dpi: 200,
                          useActions: false, // ẨN HOÀN TOÀN THANH FOOTER DƯỚI CÙNG
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          maxPageWidth: 800,
                          pdfFileName: "$slipCode.pdf",
                          previewPageMargin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
