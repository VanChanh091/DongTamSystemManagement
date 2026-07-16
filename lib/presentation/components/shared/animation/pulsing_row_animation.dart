import 'package:flutter/material.dart';

class PulsingRowAnimation extends StatefulWidget {
  final Widget child;
  final bool isFailed;

  const PulsingRowAnimation({super.key, required this.child, required this.isFailed});

  @override
  State<PulsingRowAnimation> createState() => _PulsingRowAnimationState();
}

class _PulsingRowAnimationState extends State<PulsingRowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _colorAnimation = ColorTween(
      begin: Colors.red.withValues(alpha: 0.15),
      end: Colors.red.withValues(alpha: 0.45),
    ).animate(_controller);

    if (widget.isFailed) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingRowAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu trạng thái thay đổi từ không Fail sang Fail thì bắt đầu chạy
    if (widget.isFailed != oldWidget.isFailed) {
      if (widget.isFailed) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFailed) return widget.child;

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(color: _colorAnimation.value, child: child);
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
