import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../theme/game_theme.dart';
import '../widgets/game_button.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _sound;
  late bool _music;

  @override
  void initState() {
    super.initState();
    _sound = StorageService().isSoundEnabled();
    _music = StorageService().isMusicEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GameTheme.panelCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: GameTheme.primaryGold, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: GameTheme.shadow(0.6),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Text(
              'AYARLAR',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: GameTheme.brightYellow,
                shadows: [
                  Shadow(
                    color: GameTheme.shadow(0.8),
                    offset: const Offset(0, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ses Efektleri Toggle
            _buildSettingRow(
              icon: Icons.volume_up,
              title: 'Ses Efektleri',
              value: _sound,
              onChanged: (val) async {
                setState(() => _sound = val);
                await StorageService().setSoundEnabled(val);
                if (val) AudioService().playEat();
              },
            ),
            const SizedBox(height: 12),

            // Müzik Toggle
            _buildSettingRow(
              icon: Icons.music_note,
              title: 'Müzik',
              value: _music,
              onChanged: (val) async {
                setState(() => _music = val);
                await StorageService().setMusicEnabled(val);
                if (val) {
                  AudioService().playBgm();
                } else {
                  AudioService().stopBgm();
                }
              },
            ),
            const SizedBox(height: 24),

            // Kapat Butonu
            GameButton(
              text: 'KAPAT',
              width: 140,
              height: 48,
              fontSize: 18,
              primaryColor: GameTheme.primaryGreen,
              shadowColor: GameTheme.darkGreen,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameTheme.panelCardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameTheme.panelBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: GameTheme.brightYellow, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GameTheme.textLight,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            activeThumbColor: GameTheme.primaryGreen,
            activeTrackColor: GameTheme.greenAlpha(0.5),
            inactiveThumbColor: GameTheme.textMuted,
            inactiveTrackColor: GameTheme.shadow(0.25),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
