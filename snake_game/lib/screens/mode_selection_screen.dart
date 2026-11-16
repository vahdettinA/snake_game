import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_mode.dart';
import '../widgets/game_button.dart';
import '../widgets/icon_action_button.dart';
import '../theme/game_theme.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) => GameScreen(mode: mode),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 400;
    final cardWidth = isCompact ? 190.0 : 235.0;
    final cardHeight = isCompact ? 210.0 : 260.0;
    final cardSpacing = isCompact ? 24.0 : 44.0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Orijinal Arka Plan (background.jpg)
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Sol Üst: Geri Butonu (back.png)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconActionButton(
                  iconAsset: 'assets/icons/back.png',
                  size: 48,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // 3. Üst Orta: "OYUN MODU SEÇ" Başlığı
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text(
                  'OYUN MODU SEC',
                  style: GoogleFonts.fredoka(
                    fontSize: isCompact ? 28 : 36,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFCC00),
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(
                        color: GameTheme.shadow(0.95),
                        offset: const Offset(0, 4),
                        blurRadius: 5,
                      ),
                      const Shadow(
                        color: Color(0xFF8B4513),
                        offset: Offset(2, 3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Merkez: Kullanıcının Verdiği card_classic ve card_trivia Görselleri
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: isCompact ? 36.0 : 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sol Kart: KLASIK MOD (assets/images/card_classic.png)
                  _buildDirectImageCard(
                    title: 'KLASIK MOD',
                    imageAsset: 'assets/images/card_classic.png',
                    borderColor: const Color(0xFF2ECC71),
                    ribbonColor: const Color(0xFF1E8449),
                    isGreen: true,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: () => _startGame(context, GameMode.classic),
                  ),

                  SizedBox(width: cardSpacing),

                  // Sağ Kart: BILGI AVCISI (assets/images/card_trivia.png)
                  _buildDirectImageCard(
                    title: 'BILGI AVCISI',
                    imageAsset: 'assets/images/card_trivia.png',
                    borderColor: const Color(0xFFF39C12),
                    ribbonColor: const Color(0xFF1B4F72),
                    isGreen: false,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: () => _startGame(context, GameMode.trivia),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectImageCard({
    required String title,
    required String imageAsset,
    required Color borderColor,
    required Color ribbonColor,
    required bool isGreen,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kartın Ana Gövdesi (Tıklanabilir)
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: height * 0.78,
            decoration: BoxDecoration(
              color: GameTheme.panelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Kullanıcının Doğrudan card_classic / card_trivia Görseli
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),

                  // Alt Kurdele Şeridi
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: ribbonColor,
                        border: Border(
                          top: BorderSide(color: borderColor, width: 2.0),
                        ),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: GameTheme.shadow(0.9),
                              offset: const Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Buton Metni: "OYNA" (Türkçe özel karakter sorunu olmayan evrensel O-Y-N-A)
        GameButton(
          text: 'OYNA',
          width: width * 0.88,
          height: 48,
          fontSize: 20,
          isGreen: isGreen,
          onTap: onTap,
        ),
      ],
    );
  }
}
