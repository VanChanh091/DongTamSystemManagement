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

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: _isPressed ? 0.9 : 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
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
            backgroundColor: _resolveColor(
              widget.backgroundColor,
              const Color(0xff78D761),
            ),
            foregroundColor: widget.foregroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
