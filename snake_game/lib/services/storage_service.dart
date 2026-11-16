import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyClassicHighScore = 'classic_high_score';
  static const String _keyTriviaHighScore = 'trivia_high_score';
  static const String _keyTotalCoins = 'total_coins';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyMusicEnabled = 'music_enabled';

  late SharedPreferences _prefs;
  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;
    _prefs = await SharedPreferences.getInstance();
    _isInit = true;
  }

  int getClassicHighScore() => _prefs.getInt(_keyClassicHighScore) ?? 0;
  Future<void> setClassicHighScore(int score) async {
    if (score > getClassicHighScore()) {
      await _prefs.setInt(_keyClassicHighScore, score);
    }
  }

  int getTriviaHighScore() => _prefs.getInt(_keyTriviaHighScore) ?? 0;
  Future<void> setTriviaHighScore(int score) async {
    if (score > getTriviaHighScore()) {
      await _prefs.setInt(_keyTriviaHighScore, score);
    }
  }

  int getTotalCoins() => _prefs.getInt(_keyTotalCoins) ?? 300;
  Future<void> addCoins(int amount) async {
    final current = getTotalCoins();
    await _prefs.setInt(_keyTotalCoins, current + amount);
  }

  bool isSoundEnabled() => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool enabled) async =>
      _prefs.setBool(_keySoundEnabled, enabled);

  bool isMusicEnabled() => _prefs.getBool(_keyMusicEnabled) ?? true;
  Future<void> setMusicEnabled(bool enabled) async =>
      _prefs.setBool(_keyMusicEnabled, enabled);
}

