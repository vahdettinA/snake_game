import 'dart:math';
import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class GameJoystick extends StatefulWidget {
  final ValueChanged<Direction> onDirectionChanged;
  final double size;

  const GameJoystick({
    super.key,
    required this.onDirectionChanged,
    this.size = 144,
  });

  @override
  State<GameJoystick> createState() => _GameJoystickState();
}

class _GameJoystickState extends State<GameJoystick> {
  Offset _knobPosition = Offset.zero;
  Direction? _lastDispatchedDirection;

  void _updateKnobPosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = localPosition - center;
    final maxRadius = widget.size * 0.32;

    final distance = delta.distance;
    final angle = delta.direction; // -pi ile +pi arası

    // Mavi top sınırlandırması
    final clampedDistance = min(distance, maxRadius);
    final newKnob = Offset(
      clampedDistance * cos(angle),
      clampedDistance * sin(angle),
    );

    setState(() {
      _knobPosition = newKnob;
    });

    // Net 4 Yön Tespiti (Ölü bölge: 18 piksel)
    // Ara yönler tamamen elendi; sadece 4 ana yön (90 derecelik dilimler)
    if (distance > 18) {
      Direction dir;
      // angle: 0 = sağ, pi/2 = aşağı, pi / -pi = sol, -pi/2 = yukarı
      if (angle >= -pi / 4 && angle < pi / 4) {
        dir = Direction.right;
      } else if (angle >= pi / 4 && angle < 3 * pi / 4) {
        dir = Direction.down;
      } else if (angle >= -3 * pi / 4 && angle < -pi / 4) {
        dir = Direction.up;
      } else {
        dir = Direction.left;
      }

      if (dir != _lastDispatchedDirection) {
        _lastDispatchedDirection = dir;
        widget.onDirectionChanged(dir);
      }
    }
  }

  void _resetKnob() {
    setState(() {
      _knobPosition = Offset.zero;
      _lastDispatchedDirection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final knobSize = widget.size * 0.46;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) => _updateKnobPosition(details.localPosition),
      onPanUpdate: (details) => _updateKnobPosition(details.localPosition),
      onPanEnd: (_) => _resetKnob(),
      onPanCancel: () => _resetKnob(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Joystick Tabanı (4 oklu şeffaf görsel)
            Positioned.fill(
              child: Image.asset(
                'assets/controls/joystick-base.png',
                fit: BoxFit.contain,
              ),
            ),

            // 2. 4 Ana Yön Tıklama Alanları (D-Pad dokunma desteği)
            Positioned(
              top: 0,
              child: _buildHitArea(Direction.up, width: widget.size * 0.5, height: widget.size * 0.32),
            ),
            Positioned(
              bottom: 0,
              child: _buildHitArea(Direction.down, width: widget.size * 0.5, height: widget.size * 0.32),
            ),
            Positioned(
              left: 0,
              child: _buildHitArea(Direction.left, width: widget.size * 0.32, height: widget.size * 0.5),
            ),
            Positioned(
              right: 0,
              child: _buildHitArea(Direction.right, width: widget.size * 0.32, height: widget.size * 0.5),
            ),

            // 3. Mavi Joystick Topu
            Transform.translate(
              offset: _knobPosition,
              child: SizedBox(
                width: knobSize,
                height: knobSize,
                child: Image.asset(
                  'assets/controls/joystick-knob.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHitArea(Direction dir, {required double width, required double height}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        _lastDispatchedDirection = dir;
        widget.onDirectionChanged(dir);
      },
      child: SizedBox(width: width, height: height),
    );
  }
}
