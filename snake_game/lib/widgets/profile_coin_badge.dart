import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/game_theme.dart';

class ProfileCoinBadge extends StatelessWidget {
  final int coins;
  final int level;

  const ProfileCoinBadge({
    super.key,
    required this.coins,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Sağ tarafa uzanan altın gösterge kapsülü (hud-panel.png zeminli)
          Container(
            margin: const EdgeInsets.only(left: 36),
            height: 38,
            padding: const EdgeInsets.only(left: 20, right: 16),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/panels/hud-panel.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Altın Yıldız İkonu
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [GameTheme.goldLight, GameTheme.primaryGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: GameTheme.appleLight, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.goldAlpha(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.star, size: 13, color: GameTheme.textLight),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  coins.toString(),
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.brightYellow,
                    shadows: [
                      Shadow(
                        color: GameTheme.shadow(0.9),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sol taraftaki Yılan Avatarı ve Seviye Rozeti
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF85929E),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: const Color(0xFF1ABC9C).withValues(alpha: 0.25),
                    child: const Center(
                      child: Text('🐍', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  // Seviye Rozeti
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 13,
                      color: GameTheme.primaryBlue,
                      child: Center(
                        child: Text(
                          '$level',
                          style: GoogleFonts.fredoka(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: GameTheme.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
