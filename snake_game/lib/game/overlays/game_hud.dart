import 'package:flutter/material.dart';
import '../../widgets/profile_coin_badge.dart';
import '../../widgets/icon_action_button.dart';

class GameHud extends StatelessWidget {
  final int coins;
  final int score;
  final int targetScore;
  final VoidCallback onPause;
  final VoidCallback onSettings;
  final bool isTriviaMode;

  const GameHud({
    super.key,
    required this.coins,
    required this.score,
    this.targetScore = 10,
    required this.onPause,
    required this.onSettings,
    this.isTriviaMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = ((score % targetScore) / targetScore).clamp(0.0, 1.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sol Üst: Profil ve Altın
            ProfileCoinBadge(coins: coins),

            // Üst Orta: Orijinal Progress Bar (progress-track.png ve progress-fill.png)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İlerleme Kapsülü
                SizedBox(
                  width: 150,
                  height: 28,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Arka Plan İlerleme Oluğu
                      Positioned.fill(
                        child: Image.asset(
                          'assets/panels/progress-track.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Sarı İlerleme Dolgusu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
                        child: FractionallySizedBox(
                          widthFactor: progress == 0 ? 0.06 : progress,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/panels/progress-fill.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Soru Sandığı İkonu
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    'assets/icons/question.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // Sağ Üst: Duraklat (pause.png) ve Ayarlar (settings.png) Butonları
            Row(
              children: [
                IconActionButton(
                  iconAsset: 'assets/icons/pause.png',
                  size: 44,
                  onTap: onPause,
                ),
                const SizedBox(width: 10),
                IconActionButton(
                  iconAsset: 'assets/icons/settings.png',
                  size: 44,
                  onTap: onSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
