import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/game_theme.dart';
import '../../widgets/game_button.dart';

class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final int applesEaten;
  final int questionsAnswered;
  final bool isTriviaMode;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.applesEaten,
    required this.questionsAnswered,
    required this.isTriviaMode,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNewRecord = score > 0 && score >= highScore;

    return Center(
      child: Container(
        width: 440,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: GameTheme.panelBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: GameTheme.primaryRed, width: 3.5),
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
            // Başlık
            Text(
              'OYUN BİTTİ!',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: GameTheme.primaryRed,
                shadows: [
                  Shadow(
                    color: GameTheme.shadow(0.9),
                    offset: const Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            if (isNewRecord) ...[
              const SizedBox(height: 4),
              Text(
                '🎉 YENİ REKOR! 🎉',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GameTheme.brightYellow,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Skor Kartları
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: GameTheme.panelCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameTheme.panelBorder, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'SKOR',
                    score.toString(),
                    GameTheme.brightYellow,
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    'EN YÜKSEK',
                    highScore.toString(),
                    GameTheme.textLight,
                  ),
                  if (isTriviaMode) ...[
                    _buildDivider(),
                    _buildStatItem(
                      'DOĞRU',
                      questionsAnswered.toString(),
                      GameTheme.primaryGreen,
                    ),
                  ] else ...[
                    _buildDivider(),
                    _buildStatItem(
                      'ELMA',
                      applesEaten.toString(),
                      GameTheme.primaryGold,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameButton(
                  text: 'TEKRAR',
                  width: 160,
                  height: 48,
                  fontSize: 18,
                  primaryColor: GameTheme.primaryGreen,
                  shadowColor: GameTheme.darkGreen,
                  icon: Icons.refresh,
                  onTap: onRestart,
                ),
                const SizedBox(width: 16),
                GameButton(
                  text: 'MENÜ',
                  width: 160,
                  height: 48,
                  fontSize: 18,
                  primaryColor: GameTheme.primaryBlue,
                  shadowColor: GameTheme.darkBlue,
                  icon: Icons.home,
                  onTap: onExit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1.5, height: 36, color: GameTheme.whiteAlpha(0.25));
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: GameTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
