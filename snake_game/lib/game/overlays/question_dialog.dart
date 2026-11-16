import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../services/audio_service.dart';
import '../../theme/game_theme.dart';

class QuestionDialogOverlay extends StatefulWidget {
  final Question question;
  final ValueChanged<bool> onAnswer;

  const QuestionDialogOverlay({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<QuestionDialogOverlay> createState() => _QuestionDialogOverlayState();
}

class _QuestionDialogOverlayState extends State<QuestionDialogOverlay>
    with SingleTickerProviderStateMixin {
  late int _timeLeft;
  Timer? _timer;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = 15;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft > 1) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
    });
    AudioService().playWrong();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) widget.onAnswer(false);
    });
  }

  void _chooseOption(int index) {
    if (_isAnswered) return;
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = index;
    });

    final bool isCorrect = (index == widget.question.correctIndex);
    if (isCorrect) {
      AudioService().playCorrect();
    } else {
      AudioService().playWrong();
    }

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) widget.onAnswer(isCorrect);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double timerProgress = _timeLeft / 15.0;

    return Center(
      child: Container(
        width: 580,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.panelBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: GameTheme.primaryGold, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: GameTheme.shadow(0.85),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Kısım: Kategori ve Süre Sayacı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kategori Rozeti
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: GameTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GameTheme.lightBlue, width: 1.5),
                  ),
                  child: Text(
                    widget.question.category,
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: GameTheme.textLight,
                    ),
                  ),
                ),

                // 15 Saniyelik Sayaç
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 5
                        ? GameTheme.deepRed
                        : GameTheme.panelCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _timeLeft <= 5
                          ? GameTheme.primaryRed
                          : GameTheme.primaryGold,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 18,
                        color: _timeLeft <= 5
                            ? GameTheme.textLight
                            : GameTheme.brightYellow,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_timeLeft s',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 5
                              ? GameTheme.textLight
                              : GameTheme.brightYellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Süre İlerleme Barı
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: timerProgress,
                minHeight: 6,
                backgroundColor: GameTheme.whiteAlpha(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeLeft <= 5
                      ? GameTheme.primaryRed
                      : GameTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Soru Metni
            Container(
              constraints: const BoxConstraints(minHeight: 54),
              alignment: Alignment.center,
              child: Text(
                widget.question.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GameTheme.textLight,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4 Şık (2x2 Grid)
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: List.generate(widget.question.options.length, (index) {
                final optionText = widget.question.options[index];
                final optionLetter = String.fromCharCode(
                  65 + index,
                ); // A, B, C, D

                Color btnColor = GameTheme.panelCard;
                Color borderColor = GameTheme.panelBorderLight;

                if (_isAnswered) {
                  if (index == widget.question.correctIndex) {
                    btnColor = GameTheme.darkGreen;
                    borderColor = GameTheme.primaryGreen;
                  } else if (index == _selectedOptionIndex) {
                    btnColor = GameTheme.darkRed;
                    borderColor = GameTheme.primaryRed;
                  }
                }

                return SizedBox(
                  width: 254,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: borderColor, width: 2),
                      ),
                    ),
                    onPressed: _isAnswered ? null : () => _chooseOption(index),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: GameTheme.shadow(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              optionLetter,
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: GameTheme.brightYellow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            optionText,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GameTheme.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isAnswered &&
                            index == widget.question.correctIndex)
                          const Icon(
                            Icons.check_circle,
                            color: GameTheme.textLight,
                            size: 22,
                          )
                        else if (_isAnswered && index == _selectedOptionIndex)
                          const Icon(
                            Icons.cancel,
                            color: GameTheme.textLight,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

