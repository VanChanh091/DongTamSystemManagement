import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedButton extends StatefulWidget {
  final Function()? onPressed;
  final IconData? icon;
  final String label;
  final dynamic backgroundColor;
  final Color foregroundColor;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  Color _resolveColor(dynamic color, Color defaultColor) {
    if (color == null) return defaultColor;
    if (color is Rx<Color>) return color.value;
    if (color is Color) return color;
    return defaultColor;
  }

  Widget _buildButton(Color bgColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: _isPressed ? 0.9 : 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon:
              widget.icon != null
                  ? Icon(widget.icon, color: widget.foregroundColor)
                  : const SizedBox.shrink(),
          label: Text(
            widget.label,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: widget.foregroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.backgroundColor is Rx<Color>) {
      return Obx(
        () => _buildButton(_resolveColor(widget.backgroundColor, const Color(0xff78D761))),
      );
    }

    // Nếu là Color thường thì build 1 lần thôi
    return _buildButton(_resolveColor(widget.backgroundColor, const Color(0xff78D761)));
  }
}
