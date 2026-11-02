import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResizableDialog extends StatefulWidget {
  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double? maxHeight;

  final Widget child;
  final Widget? title;
  final List<Widget>? actions;

  final Color backgroundColor;
  final double borderRadius;
  final double handleSize;

  const ResizableDialog({
    super.key,
    required this.initialWidth,
    this.minWidth = 300,
    this.maxWidth = 1800,
    this.minHeight = 300,
    this.maxHeight,
    required this.child,
    this.title,
    this.actions,
    this.backgroundColor = Colors.white,
    this.borderRadius = 20,
    this.handleSize = 14.0,
  });

  @override
  State<ResizableDialog> createState() => _ResizableDialogState();
}

class _ResizableDialogState extends State<ResizableDialog> {
  late double _width;
  double? _height;

  // Tạo GlobalKey để đo kích thước thực tế của Dialog
  final GlobalKey _dialogKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  // Clamp width within [minWidth, maxWidth] and screen bounds
  double _clampWidth(double w, double screenWidth) {
    final maxW = (screenWidth * 0.95).clamp(widget.minWidth, widget.maxWidth);
    return w.clamp(widget.minWidth, maxW);
  }

  // Clamp height within [minHeight, maxHeight] and screen bounds
  double _clampHeight(double h, double screenHeight) {
    final maxH = widget.maxHeight ?? screenHeight * 0.9;
    return h.clamp(widget.minHeight, maxH);
  }

  // Hàm tính toán chiều cao thực tế
  double _getActualHeight(BuildContext context) {
    if (_height != null) return _height!;

    // Đo kích thước thật đang hiển thị trên màn hình thông qua RenderBox
    final renderBox = _dialogKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.size.height;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    return (widget.maxHeight ?? screenHeight * 0.9) * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final handle = widget.handleSize;

    final double currentWidth = _clampWidth(_width, screenSize.width);
    final double effectiveMaxHeight = widget.maxHeight ?? screenSize.height * 0.9;
    final double? currentHeight =
        _height != null ? _clampHeight(_height!, screenSize.height) : null;

    // AppLogger.i(
    //   "📐 KÍCH THƯỚC DIALOG -> Width: ${currentWidth.toStringAsFixed(0)}px "
    //   "| Height: ${currentHeight?.toStringAsFixed(0) ?? 'Auto (Co giãn theo Form)'}",
    // );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: currentWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: _dialogKey,
                width: currentWidth,
                height: currentHeight,
                constraints: BoxConstraints(
                  minHeight: widget.minHeight,
                  maxHeight: effectiveMaxHeight,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Column(
                    mainAxisSize: currentHeight != null ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      // Title
                      if (widget.title != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                            child: widget.title!,
                          ),
                        ),

                      // Content
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: widget.child,
                        ),
                      ),

                      // Actions
                      if (widget.actions != null && widget.actions!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:
                                widget.actions!
                                    .map(
                                      (action) => Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: action,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ─── Resize handles ───
              ..._buildAllHandles(context: context, handle: handle, screenSize: screenSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHandle({
    required SystemMouseCursor cursor,
    required void Function(double dx, double dy) onDrag,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) {
            onDrag(details.delta.dx, details.delta.dy);
          },
          child: SizedBox(width: width, height: height),
        ),
      ),
    );
  }

  List<Widget> _buildAllHandles({
    required BuildContext context,
    required double handle,
    required Size screenSize,
  }) {
    return [
      // ─── Left edge ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeLeft,
        onDrag:
            (dx, _) => setState(() {
              _width = _clampWidth(_width - dx, screenSize.width);
            }),
        left: -handle / 2,
        top: handle,
        bottom: handle,
        width: handle,
      ),

      // ─── Right edge ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeRight,
        onDrag:
            (dx, _) => setState(() {
              _width = _clampWidth(_width + dx, screenSize.width);
            }),
        right: -handle / 2,
        top: handle,
        bottom: handle,
        width: handle,
      ),

      // ─── Bottom edge ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeDown,
        onDrag: (_, dy) {
          setState(() {
            _height = _getActualHeight(context) + dy;
          });
        },
        bottom: -handle / 2,
        left: handle,
        right: handle,
        height: handle,
      ),

      // ─── Top edge ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeUp,
        onDrag: (_, dy) {
          setState(() {
            _height = _getActualHeight(context) - dy;
          });
        },
        top: -handle / 2,
        left: handle,
        right: handle,
        height: handle,
      ),

      // ─── Top-left corner ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeUpLeft,
        onDrag: (dx, dy) {
          setState(() {
            _width = _clampWidth(_width - dx, screenSize.width);
            _height = _getActualHeight(context) - dy;
          });
        },
        left: -handle,
        top: -handle,
        width: handle * 2,
        height: handle * 2,
      ),

      // ─── Top-right corner ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeUpRight,
        onDrag: (dx, dy) {
          setState(() {
            _width = _clampWidth(_width + dx, screenSize.width);
            _height = _getActualHeight(context) - dy;
          });
        },
        right: -handle,
        top: -handle,
        width: handle * 2,
        height: handle * 2,
      ),

      // ─── Bottom-left corner ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeDownLeft,
        onDrag: (dx, dy) {
          setState(() {
            _width = _clampWidth(_width - dx, screenSize.width);
            _height = _getActualHeight(context) + dy;
          });
        },
        left: -handle,
        bottom: -handle,
        width: handle * 2,
        height: handle * 2,
      ),

      // ─── Bottom-right corner ───
      _buildEdgeHandle(
        cursor: SystemMouseCursors.resizeDownRight,
        onDrag: (dx, dy) {
          setState(() {
            _width = _clampWidth(_width + dx, screenSize.width);
            _height = _getActualHeight(context) + dy;
          });
        },
        right: -handle,
        bottom: -handle,
        width: handle * 2,
        height: handle * 2,
      ),
    ];
  }
}
