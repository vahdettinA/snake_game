import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class IconActionButton extends StatefulWidget {
  final String? iconAsset;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isGold;
  final double size;

  const IconActionButton({
    super.key,
    this.iconAsset,
    this.icon,
    required this.onTap,
    this.isGold = false,
    this.size = 48,
  });

  @override
  State<IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<IconActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgAsset = widget.isGold
        ? 'assets/buttons/icon-button-gold.png'
        : 'assets/buttons/icon-button-blue.png';

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        AudioService().playButton();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Şeffaf PNG Buton Çerçevesi
              Positioned.fill(
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.contain,
                ),
              ),

              // İkon (PNG veya IconData)
              if (widget.iconAsset != null)
                Padding(
                  padding: EdgeInsets.all(widget.size * 0.22),
                  child: Image.asset(
                    widget.iconAsset!,
                    fit: BoxFit.contain,
                  ),
                )
              else if (widget.icon != null)
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.size * 0.52,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
