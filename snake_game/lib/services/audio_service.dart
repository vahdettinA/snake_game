import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  Future<void> init() async {
    await _sfxPlayer.setVolume(1.0);
    await _bgmPlayer.setVolume(0.5);
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void playEat() async {
    if (!StorageService().isSoundEnabled()) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/eat.mp3'));
    } catch (_) {}
  }

  void playCorrect() async {
    if (!StorageService().isSoundEnabled()) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/correct.mp3'));
    } catch (_) {}
  }

  void playWrong() async {
    if (!StorageService().isSoundEnabled()) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/wrong.mp3'));
    } catch (_) {}
  }

  void playHit() async {
    if (!StorageService().isSoundEnabled()) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/hit.mp3'));
    } catch (_) {}
  }

  void playButton() async {
    if (!StorageService().isSoundEnabled()) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/click.mp3'));
    } catch (_) {}
  }

  void playBgm() async {
    if (!StorageService().isMusicEnabled()) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (_) {}
  }

  void stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }
}

