import 'package:flutter/material.dart';

class BoostButton extends StatefulWidget {
  final ValueChanged<bool> onBoostChanged;
  final double width;
  final double height;

  const BoostButton({
    super.key,
    required this.onBoostChanged,
    this.width = 72,
    this.height = 62,
  });

  @override
  State<BoostButton> createState() => _BoostButtonState();
}

class _BoostButtonState extends State<BoostButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onBoostChanged(true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onBoostChanged(false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onBoostChanged(false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Image.asset(
            'assets/controls/action-button.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
