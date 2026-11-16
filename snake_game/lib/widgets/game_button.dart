import 'package:flutter/material.dart';

import '../theme/game_theme.dart';
import '../services/audio_service.dart';

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isGreen;
  final Color? primaryColor;
  final Color? shadowColor;
  final double width;
  final double height;
  final double fontSize;
  final IconData? icon;

  const GameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isGreen = true,
    this.primaryColor,
    this.shadowColor,
    this.width = 180,
    this.height = 56,
    this.fontSize = 22,
    this.icon,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Eğer primaryColor verildiyse ve kırmızı/mavi tonundaysa ona göre buton asseti seç
    final bool useGreen = widget.primaryColor != null
        ? (widget.primaryColor == GameTheme.primaryGreen)
        : widget.isGreen;

    final assetPath = useGreen
        ? 'assets/buttons/button-green.png'
        : 'assets/buttons/button-blue.png';

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
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Şeffaf PNG Buton Arka Planı (game-assets/buttons/)
              Positioned.fill(child: Image.asset(assetPath, fit: BoxFit.fill)),

              // Buton İçi Metin ve İkon
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: GameTheme.textLight,
                        size: widget.fontSize + 2,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GameTheme.buttonTextStyle.copyWith(
                        fontSize: widget.fontSize,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: GameTheme.shadow(0.7),
                            offset: const Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
