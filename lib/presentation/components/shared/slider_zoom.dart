import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';

class SliderZoom extends StatefulWidget {
  final double zoomLevel;
  final ValueChanged<double> onZoomChanged;
  final Color buttonColor;
  final double min;
  final double max;
  final int divisions;
  final Offset initialOffset;

  const SliderZoom({
    super.key,
    required this.zoomLevel,
    required this.onZoomChanged,
    required this.buttonColor,
    this.min = 0.5, // 50%
    this.max = 1.5, // 150%
    this.divisions = 10,
    this.initialOffset = const Offset(1713, 961),
  });

  @override
  State<SliderZoom> createState() => _SliderZoomState();
}

class _SliderZoomState extends State<SliderZoom> {
  late Offset _position;
  bool _isExpanded = false;
  bool _isDragging = false;
  bool _isFirstFrame = true;

  @override
  void initState() {
    super.initState();
    _position = widget.initialOffset;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isFirstFrame = false);
      }
    });
  }

  Offset _clampPosition(
    Offset targetPosition,
    double screenWidth,
    double screenHeight,
    double sizeDiff,
  ) {
    double minX = 0.0;
    double maxX = screenWidth - 65.0;

    if (targetPosition.dx > screenWidth / 2) {
      minX = sizeDiff;
    }

    return Offset(
      targetPosition.dx.clamp(minX, maxX),
      targetPosition.dy.clamp(0.0, screenHeight - 48.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    const double collapsedWidth = 65.0;
    const double expandedWidth = 240.0;
    const double sizeDifference = expandedWidth - collapsedWidth;

    final bool isOnRightHalf = _position.dx > (screenSize.width / 2);
    final double currentWidth = _isExpanded ? expandedWidth : collapsedWidth;

    final Duration dynamicDuration =
        (_isFirstFrame || _isDragging) ? Duration.zero : const Duration(milliseconds: 200);

    double renderLeft = _position.dx;
    if (isOnRightHalf && _isExpanded) {
      renderLeft = _position.dx - sizeDifference;
    }

    // PHẦN TEXT Ô SỐ %
    final Widget textPart = Positioned(
      top: 0,
      bottom: 0,
      left: isOnRightHalf ? null : 0,
      right: isOnRightHalf ? 0 : null,
      width: collapsedWidth,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded), // Click để đảo trạng thái
        borderRadius: BorderRadius.circular(23),
        child: Center(
          child: Text(
            '${(widget.zoomLevel * 100).round()}%',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: widget.buttonColor),
          ),
        ),
      ),
    );

    // PHẦN THANH SLIDER TĂNG GIẢM
    final Widget sliderPart = Positioned(
      top: 0,
      bottom: 0,
      left: isOnRightHalf ? null : collapsedWidth,
      right: isOnRightHalf ? collapsedWidth : null,
      width: sizeDifference,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isExpanded ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: !_isExpanded, // Khóa tương tác bấm nút khi đang thu gọn
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nút giảm
              InkWell(
                onTap:
                    () => widget.onZoomChanged(
                      (widget.zoomLevel - 0.1).clamp(widget.min, widget.max),
                    ),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, size: 16, color: Colors.black87),
                ),
              ),

              // Thanh trượt Slider
              SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: widget.buttonColor,
                    inactiveTrackColor: widget.buttonColor.withValues(alpha: 0.2),
                    thumbColor: widget.buttonColor,
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                  ),
                  child: Slider(
                    value: widget.zoomLevel,
                    min: widget.min,
                    max: widget.max,
                    divisions: widget.divisions,
                    onChanged: widget.onZoomChanged,
                  ),
                ),
              ),

              // Nút tăng
              InkWell(
                onTap:
                    () => widget.onZoomChanged(
                      (widget.zoomLevel + 0.1).clamp(widget.min, widget.max),
                    ),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedPositioned(
      duration: dynamicDuration,
      curve: Curves.easeInOut,
      left: renderLeft,
      top: _position.dy,
      width: currentWidth,
      height: 48,
      child: RepaintBoundary(
        child: TapRegion(
          onTapOutside: (event) {
            if (_isExpanded) {
              setState(() => _isExpanded = false);
            }
          },
          child: GestureDetector(
            onPanStart: (_) => setState(() => _isDragging = true),
            onPanUpdate: (details) {
              setState(() {
                _position = _clampPosition(
                  _position + details.delta,
                  screenSize.width,
                  screenSize.height,
                  sizeDifference,
                );
              });
            },
            onPanEnd: (_) {
              setState(() => _isDragging = false);
              AppLogger.i(
                "SliderZoom đã dừng tại -> X: ${_position.dx.toStringAsFixed(1)}, Y: ${_position.dy.toStringAsFixed(1)}",
              );
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              alignment: isOnRightHalf ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color:
                      _isDragging ? widget.buttonColor : widget.buttonColor.withValues(alpha: 0.3),
                  width: _isDragging ? 2 : 1,
                ),
              ),
              child: SizedBox(
                width: expandedWidth,
                height: 48,
                child: Stack(clipBehavior: Clip.none, children: [sliderPart, textPart]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
