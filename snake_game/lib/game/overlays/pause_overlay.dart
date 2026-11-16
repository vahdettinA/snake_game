import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../../theme/game_theme.dart';
import '../../widgets/game_button.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: GameTheme.panelCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: GameTheme.primaryGold, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: GameTheme.shadow(0.7),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OYUN DURAKLATILDI',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: GameTheme.brightYellow,
                shadows: [
                  Shadow(
                    color: GameTheme.shadow(0.8),
                    offset: const Offset(0, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GameButton(
              text: 'DEVAM ET',
              width: 200,
              height: 48,
              fontSize: 18,
              primaryColor: GameTheme.primaryGreen,
              shadowColor: GameTheme.darkGreen,
              icon: Icons.play_arrow,
              onTap: onResume,
            ),
            const SizedBox(height: 12),
            GameButton(
              text: 'TEKRAR DENE',
              width: 200,
              height: 48,
              fontSize: 18,
              primaryColor: GameTheme.primaryBlue,
              shadowColor: GameTheme.darkBlue,
              icon: Icons.refresh,
              onTap: onRestart,
            ),
            const SizedBox(height: 12),
            GameButton(
              text: 'ANA MENÜ',
              width: 200,
              height: 48,
              fontSize: 18,
              primaryColor: GameTheme.primaryRed,
              shadowColor: GameTheme.darkRed,
              icon: Icons.home,
              onTap: onExit,
            ),
          ],
        ),
      ),
    );
  }
}
