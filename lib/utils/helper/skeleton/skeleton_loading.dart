import 'package:flutter/material.dart';

/// Simple shimmer implementation (không cần package ngoài).
class SkeletonLoading extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonLoading({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            // di chuyển gradient từ trái sang phải
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.0 - 2.0 * progress, 0.0),
              end: Alignment(1.0 - 2.0 * progress, 0.0),
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: child,
        );
      },
    );
  }
}

/// Helper: build 1 "skeleton table" (header + rows) có shimmer.
Widget buildShimmerSkeletonTable({
  required BuildContext context,
  int rowCount = 10,
  double headerHeight = 40,
  double rowHeight = 38,
  double horizontalPadding = 8,
}) {
  // custom shapes theo giao diện DataGrid của bạn (bạn có thể chỉnh).
  Widget headerFake() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 200,
            height: headerHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: headerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget rowFake() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 200,
            height: rowHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: rowHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  return SkeletonLoading(
    // bạn có thể điều chỉnh base/highlight color ở đây
    child: Column(
      children: [
        // Fake header
        headerFake(),
        const SizedBox(height: 4),
        // Fake rows
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: rowCount,
            itemBuilder: (context, index) {
              return rowFake();
            },
          ),
        ),
      ],
    ),
  );
}

Future<T> ensureMinLoading<T>(
  Future<T> future, {
  Duration minDuration = const Duration(milliseconds: 300),
}) async {
  final results = await Future.wait([future, Future.delayed(minDuration)]);
  return results.first as T;
}
