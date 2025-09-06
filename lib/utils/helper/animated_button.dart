import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedButton extends StatefulWidget {
  final Function()? onPressed;
  final IconData? icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.backgroundColor = const Color(0xff78D761),
    this.foregroundColor = Colors.white,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

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
            backgroundColor: widget.backgroundColor,
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
