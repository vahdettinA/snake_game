import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  // Temel Renkler
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF1E824C);
  static const Color lightGreen = Color(0xFFA2DED0);

  static const Color primaryBlue = Color(0xFF2980B9);
  static const Color darkBlue = Color(0xFF1B4F72);
  static const Color lightBlue = Color(0xFF5DADE2);
  static const Color skyBlue = Color(0xFF85C1E9);

  static const Color primaryGold = Color(0xFFF39C12);
  static const Color brightYellow = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE066);
  static const Color darkYellow = Color(0xFFD4AC0D);

  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color darkRed = Color(0xFFC0392B);
  static const Color deepRed = Color(0xFF922B21);

  // Koyu & Panel / Taş Teması Renkleri
  static const Color panelBg = Color(0xFF1B2631);
  static const Color panelCard = Color(0xFF2C3E50);
  static const Color panelCardDark = Color(0xFF1A252F);
  static const Color panelBorder = Color(0xFF34495E);
  static const Color panelBorderLight = Color(0xFF5D6D7E);

  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFFBDC3C7);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color shadowBlack = Color(0xFF000000);

  // Yılan ve Meyve Renkleri
  static const Color snakeHeadLight = Color(0xFF7DCEA0);
  static const Color snakeHead = Color(0xFF2ECC71);
  static const Color snakeHeadDark = Color(0xFF239B56);

  static const Color snakeBodyLight = Color(0xFF58D68D);
  static const Color snakeBody = Color(0xFF27AE60);
  static const Color snakeBodyDark = Color(0xFF196F3D);

  static const Color appleLight = Color(0xFFFFEC99);
  static const Color appleMid = Color(0xFFFFC107);
  static const Color appleDark = Color(0xFFD68910);

  static const Color stoneBg = Color(0xFFE8D7B8);
  static const Color stoneBorder = Color(0xFF8B6B4A);

  // Şeffaflık yardımcı fonksiyonları (withValues kullanarak)
  static Color shadow(double alpha) => shadowBlack.withValues(alpha: alpha);
  static Color whiteAlpha(double alpha) => textLight.withValues(alpha: alpha);
  static Color goldAlpha(double alpha) => brightYellow.withValues(alpha: alpha);
  static Color blueAlpha(double alpha) => lightBlue.withValues(alpha: alpha);
  static Color greenAlpha(double alpha) =>
      primaryGreen.withValues(alpha: alpha);
  static Color stoneAlpha(double alpha) => stoneBorder.withValues(alpha: alpha);

  // Yazı Stilleri (Casual / Cartoon fontlar)
  static TextStyle get titleStyle => GoogleFonts.fredoka(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: goldLight,
    letterSpacing: 2.0,
    shadows: [
      Shadow(color: shadow(0.85), offset: const Offset(0, 4), blurRadius: 4),
      const Shadow(
        color: Color(0xFF8B4513),
        offset: Offset(2, 3),
        blurRadius: 2,
      ),
    ],
  );

  static TextStyle get headerStyle => GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: textLight,
    letterSpacing: 1.5,
    shadows: [
      Shadow(color: shadow(0.85), offset: const Offset(0, 3), blurRadius: 3),
    ],
  );

  static TextStyle get buttonTextStyle => GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textLight,
    letterSpacing: 1.5,
    shadows: [
      Shadow(color: shadow(0.45), offset: const Offset(0, 2), blurRadius: 2),
    ],
  );

  static TextStyle get bodyTextStyle => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textLight,
  );
}
