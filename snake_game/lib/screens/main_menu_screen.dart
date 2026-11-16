import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../theme/game_theme.dart';
import '../widgets/game_button.dart';
import '../widgets/profile_coin_badge.dart';
import '../widgets/icon_action_button.dart';
import 'mode_selection_screen.dart';
import 'settings_dialog.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  int _coins = 300;
  late AnimationController _animController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    AudioService().playBgm();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    final coins = StorageService().getTotalCoins();
    if (mounted) setState(() => _coins = coins);
  }

  void _openSettings() {
    showDialog(
      context: context,
      barrierColor: GameTheme.shadow(0.55),
      builder: (context) => const SettingsDialog(),
    ).then((_) => _loadCoins());
  }

  void _navigateToModeSelection() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) => const ModeSelectionScreen(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
      ),
    ).then((_) => _loadCoins());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 400;

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

          // 2. Sol Üst: Profil ve Altın Rozeti
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: ProfileCoinBadge(coins: _coins, level: 1),
              ),
            ),
          ),

          // 3. Sağ Üst: Ayarlar Butonu (Mavi 3D buton)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconActionButton(
                  iconAsset: 'assets/icons/settings.png',
                  size: 50,
                  onTap: _openSettings,
                ),
              ),
            ),
          ),

          // 4. Merkez İçerik: Yan Yana "BİLGE YILAN" Başlığı, Maskot ve "OYNA" Butonu
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isCompact ? 8 : 12),

                // Yan Yana 3D Sarı Başlık: "BİLGE YILAN"
                Text(
                  'BİLGE YILAN',
                  style: GoogleFonts.fredoka(
                    fontSize: isCompact ? 34 : 46,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFCC00),
                    letterSpacing: 4.0,
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

                const SizedBox(height: 8),

                // Bilge Yılan & Altın Elma Maskotu (Nefes alma animasyonlu)
                AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnim.value),
                      child: child,
                    );
                  },
                  child: Container(
                    height: isCompact ? 150 : 190,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/source-crops/hero-snake.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: isCompact ? 10 : 18),

                // Parlak Yeşil 3D "OYNA" Butonu
                GameButton(
                  text: 'OYNA',
                  width: isCompact ? 190 : 220,
                  height: isCompact ? 52 : 60,
                  fontSize: isCompact ? 22 : 26,
                  isGreen: true,
                  onTap: _navigateToModeSelection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
