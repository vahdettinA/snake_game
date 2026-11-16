import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/question.dart';
import '../services/storage_service.dart';
import '../game/bilge_yilan_game.dart';
import '../game/overlays/game_hud.dart';
import '../game/overlays/question_dialog.dart';
import '../game/overlays/pause_overlay.dart';
import '../game/overlays/game_over_overlay.dart';
import '../widgets/game_joystick.dart';
import '../widgets/boost_button.dart';
import '../theme/game_theme.dart';
import 'settings_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;

  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BilgeYilanGame _game;
  int _score = 0;
  int _coins = 300;
  bool _isPaused = false;
  bool _isGameOver = false;

  int _finalScore = 0;
  int _highScore = 0;
  int _applesEaten = 0;
  int _questionsAnswered = 0;

  Question? _currentQuestion;

  @override
  void initState() {
    super.initState();
    _coins = StorageService().getTotalCoins();
    _highScore = widget.mode == GameMode.classic
        ? StorageService().getClassicHighScore()
        : StorageService().getTriviaHighScore();

    _game = BilgeYilanGame(
      mode: widget.mode,
      onScoreUpdate: (score, coins) {
        if (!mounted) return;
        setState(() {
          _score = score;
          _coins = coins;
        });
      },
      onQuestionTriggered: (question) {
        if (!mounted) return;
        setState(() {
          _currentQuestion = question;
        });
      },
      onGameOver: (finalScore, apples, questions) {
        if (!mounted) return;
        final currentHigh = widget.mode == GameMode.classic
            ? StorageService().getClassicHighScore()
            : StorageService().getTriviaHighScore();
        setState(() {
          _isGameOver = true;
          _finalScore = finalScore;
          _applesEaten = apples;
          _questionsAnswered = questions;
          _highScore = currentHigh;
        });
      },
    );
  }

  void _pauseGame() {
    _game.pauseEngine();
    setState(() => _isPaused = true);
  }

  void _resumeGame() {
    _game.resumeEngine();
    setState(() => _isPaused = false);
  }

  void _restartGame() {
    setState(() {
      _isPaused = false;
      _isGameOver = false;
      _currentQuestion = null;
      _score = 0;
    });
    _game.resetGame();
  }

  void _openSettings() {
    _game.pauseEngine();
    showDialog(
      context: context,
      barrierColor: GameTheme.shadow(0.55),
      builder: (context) => const SettingsDialog(),
    ).then((_) {
      if (!_isPaused && !_isGameOver && _currentQuestion == null) {
        _game.resumeEngine();
      }
      if (mounted) {
        setState(() {
          _coins = StorageService().getTotalCoins();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Temiz Tapınak Zemin & Çerçeve Görseli (clean_game_arena.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/clean_game_arena.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Flame Oyun Katmanı (Yılan ve Yemler Karolar Üzerinde)
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          // 3. Üst Bar (HUD)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GameHud(
              coins: _coins,
              score: _score,
              targetScore: widget.mode == GameMode.trivia ? 100 : 50,
              isTriviaMode: widget.mode == GameMode.trivia,
              onPause: _pauseGame,
              onSettings: _openSettings,
            ),
          ),

          // 4. Sol Alt: Sanal Joystick Kontrolörü (YALNIZCA BİR TANE!)
          Positioned(
            left: 20,
            bottom: 16,
            child: GameJoystick(
              size: 144,
              onDirectionChanged: (dir) {
                _game.changeDirection(dir);
              },
            ),
          ),

          // 5. Sağ Alt: Aksiyon / Turbo Butonu (YALNIZCA BİR TANE!)
          Positioned(
            right: 28,
            bottom: 22,
            child: BoostButton(
              width: 76,
              height: 66,
              onBoostChanged: (boost) {
                _game.setBoost(boost);
              },
            ),
          ),

          // 6. Soru Pop-up Overlay'i (Bilgi Avcısı Modunda)
          if (_currentQuestion != null)
            Positioned.fill(
              child: Container(
                color: GameTheme.shadow(0.72),
                child: QuestionDialogOverlay(
                  question: _currentQuestion!,
                  onAnswer: (isCorrect) {
                    final q = _currentQuestion;
                    setState(() => _currentQuestion = null);
                    if (q != null) {
                      _game.handleQuestionAnswer(isCorrect);
                    }
                  },
                ),
              ),
            ),

          // 7. Duraklatma (Pause) Overlay'i
          if (_isPaused)
            Positioned.fill(
              child: Container(
                color: GameTheme.shadow(0.65),
                child: PauseOverlay(
                  onResume: _resumeGame,
                  onRestart: _restartGame,
                  onExit: () => Navigator.of(context).pop(),
                ),
              ),
            ),

          // 8. Oyun Bitti (Game Over) Overlay'i
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: GameTheme.shadow(0.78),
                child: GameOverOverlay(
                  score: _finalScore,
                  highScore: _highScore,
                  applesEaten: _applesEaten,
                  questionsAnswered: _questionsAnswered,
                  isTriviaMode: widget.mode == GameMode.trivia,
                  onRestart: _restartGame,
                  onExit: () => Navigator.of(context).pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
