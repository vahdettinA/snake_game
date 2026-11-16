import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/game_joystick.dart';
import '../theme/game_theme.dart';

class GridPos {
  final int x;
  final int y;

  const GridPos(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPos && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

enum FoodType { apple, question }

class FoodItem {
  final GridPos pos;
  final FoodType type;

  FoodItem(this.pos, this.type);
}

class BilgeYilanGame extends FlameGame {
  final GameMode mode;
  final Function(int score, int coins) onScoreUpdate;
  final Function(Question question) onQuestionTriggered;
  final Function(int finalScore, int apples, int questions) onGameOver;

  BilgeYilanGame({
    required this.mode,
    required this.onScoreUpdate,
    required this.onQuestionTriggered,
    required this.onGameOver,
  });

  // Geniş Oyun Sahası (22 sütun x 11 satır)
  static const int gridCols = 22;
  static const int gridRows = 11;

  double cellWidth = 40;
  double cellHeight = 40;
  double boardLeft = 40;
  double boardTop = 70;
  double boardWidth = 880;
  double boardHeight = 440;

  // Duvar Görseli (assets/images/duvar.png)
  ui.Image? _wallImage;

  // Yılan Durumu & Akıllı Yön Kuyruğu (Input Buffer)
  List<GridPos> snake = [];
  Direction currentDirection = Direction.right;
  final List<Direction> _directionQueue = [];
  bool isBoosting = false;

  // Zamanlama
  double _stepTimer = 0.0;
  final double _normalSpeed = 0.28;
  final double _boostSpeed = 0.14;

  // Yemler
  List<FoodItem> foods = [];

  // Oyun İstatistikleri
  int score = 0;
  int applesEaten = 0;
  int questionsAnswered = 0;
  bool isGameEnded = false;
  bool isQuestionActive = false;

  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    try {
      _wallImage = await images.load('duvar.png');
    } catch (_) {}
    _initBoard();
    resetGame();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initBoard();
  }

  void _initBoard() {
    if (size.x <= 0 || size.y <= 0) return;

    final double leftRatio = 0.04;
    final double rightRatio = 0.04;
    final double topRatio = 0.13;
    final double bottomRatio = 0.05;

    boardLeft = size.x * leftRatio;
    boardTop = size.y * topRatio;
    boardWidth = size.x * (1.0 - leftRatio - rightRatio);
    boardHeight = size.y * (1.0 - topRatio - bottomRatio);

    cellWidth = boardWidth / gridCols;
    cellHeight = boardHeight / gridRows;
  }

  void resetGame() {
    isGameEnded = false;
    isQuestionActive = false;
    score = 0;
    applesEaten = 0;
    questionsAnswered = 0;
    currentDirection = Direction.right;
    _directionQueue.clear();
    isBoosting = false;
    _stepTimer = 0.0;

    final int startX = gridCols ~/ 3;
    final int startY = gridRows ~/ 2;
    snake = [
      GridPos(startX, startY),
      GridPos(startX - 1, startY),
      GridPos(startX - 2, startY),
    ];

    foods.clear();
    _spawnFood();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onScoreUpdate(score, StorageService().getTotalCoins());
    });

    resumeEngine();
  }

  // Akıcı ve Takılmayan Yön Girişi (Buffer Queue)
  void changeDirection(Direction newDir) {
    if (isGameEnded || isQuestionActive || paused) return;

    // Kuyruktaki son hedeflenen yönü baz al
    final Direction referenceDir = _directionQueue.isNotEmpty
        ? _directionQueue.last
        : currentDirection;

    // 180 derece tersine anında dönüşü engelle
    if (referenceDir == Direction.right && newDir == Direction.left) return;
    if (referenceDir == Direction.left && newDir == Direction.right) return;
    if (referenceDir == Direction.up && newDir == Direction.down) return;
    if (referenceDir == Direction.down && newDir == Direction.up) return;
    if (referenceDir == newDir) return;

    // Kuyrukta en fazla 2 girdi tut (anında tepki ve sıfır takılma)
    if (_directionQueue.length < 2) {
      _directionQueue.add(newDir);
    }
  }

  void setBoost(bool boost) {
    isBoosting = boost;
  }

  void _spawnFood() {
    foods.clear();

    if (mode == GameMode.classic) {
      for (int i = 0; i < 3; i++) {
        final pos = _getRandomEmptyPos();
        if (pos != null) {
          foods.add(FoodItem(pos, FoodType.apple));
        }
      }
    } else {
      final qPos = _getRandomEmptyPos();
      if (qPos != null) {
        foods.add(FoodItem(qPos, FoodType.question));
      }
      final applePos = _getRandomEmptyPos();
      if (applePos != null) {
        foods.add(FoodItem(applePos, FoodType.apple));
      }
    }
  }

  GridPos? _getRandomEmptyPos() {
    final occupied = {...snake, ...foods.map((f) => f.pos)};
    final List<GridPos> emptyCells = [];

    for (int x = 0; x < gridCols; x++) {
      for (int y = 0; y < gridRows; y++) {
        final pos = GridPos(x, y);
        if (!occupied.contains(pos)) {
          emptyCells.add(pos);
        }
      }
    }

    if (emptyCells.isEmpty) return null;
    return emptyCells[_random.nextInt(emptyCells.length)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameEnded || isQuestionActive || paused) return;

    _stepTimer += dt;
    final speed = isBoosting ? _boostSpeed : _normalSpeed;

    if (_stepTimer >= speed) {
      _stepTimer = 0.0;
      _moveSnake();
    }
  }

  void _moveSnake() {
    // Kuyruktan sıradaki yönü al
    if (_directionQueue.isNotEmpty) {
      currentDirection = _directionQueue.removeAt(0);
    }

    final head = snake.first;
    GridPos newHead;

    switch (currentDirection) {
      case Direction.up:
        newHead = GridPos(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = GridPos(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = GridPos(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = GridPos(head.x + 1, head.y);
        break;
    }

    // 1. Duvara Çarpma Kontrolü
    if (newHead.x < 0 ||
        newHead.x >= gridCols ||
        newHead.y < 0 ||
        newHead.y >= gridRows) {
      _handleGameOver();
      return;
    }

    // 2. Kendi Kuyruğuna Çarpma Kontrolü
    if (snake.contains(newHead)) {
      _handleGameOver();
      return;
    }

    // Baş ekle
    snake.insert(0, newHead);

    // 3. Yem Yeme Kontrolü
    FoodItem? eatenFood;
    for (final food in foods) {
      if (food.pos == newHead) {
        eatenFood = food;
        break;
      }
    }

    if (eatenFood != null) {
      foods.remove(eatenFood);

      if (eatenFood.type == FoodType.apple) {
        AudioService().playEat();
        score += 10;
        applesEaten++;
        StorageService().addCoins(5);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onScoreUpdate(score, StorageService().getTotalCoins());
        });

        final newPos = _getRandomEmptyPos();
        if (newPos != null) {
          foods.add(FoodItem(newPos, FoodType.apple));
        }
      } else if (eatenFood.type == FoodType.question) {
        isQuestionActive = true;
        pauseEngine();
        final question = QuestionService().getRandomQuestion();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onQuestionTriggered(question);
        });
        return;
      }
    } else {
      snake.removeLast();
    }
  }

  void handleQuestionAnswer(bool isCorrect) {
    isQuestionActive = false;
    _directionQueue.clear();
    if (isCorrect) {
      score += 25;
      questionsAnswered++;
      StorageService().addCoins(15);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onScoreUpdate(score, StorageService().getTotalCoins());
      });

      _spawnFood();
      resumeEngine();
    } else {
      _handleGameOver();
    }
  }

  void _handleGameOver() {
    isGameEnded = true;
    _directionQueue.clear();
    AudioService().playHit();
    pauseEngine();

    if (mode == GameMode.classic) {
      StorageService().setClassicHighScore(score);
    } else {
      StorageService().setTriviaHighScore(score);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onGameOver(score, applesEaten, questionsAnswered);
    });
  }

  // ===================== RENDER =====================
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderCastleWalls(canvas);
    _renderBoardTiles(canvas);
    _renderFoods(canvas);
    _renderSnake(canvas);
  }

  void _renderCastleWalls(Canvas canvas) {
    final boardRect = Rect.fromLTWH(boardLeft, boardTop, boardWidth, boardHeight);
    const double wallThickness = 14.0;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(boardRect.inflate(wallThickness + 2), shadowPaint);

    if (_wallImage != null) {
      final imgW = _wallImage!.width.toDouble();
      final imgH = _wallImage!.height.toDouble();
      final srcRect = Rect.fromLTWH(0, 0, imgW, imgH);
      final paint = Paint()..filterQuality = FilterQuality.medium;

      canvas.drawImageRect(
        _wallImage!,
        srcRect,
        Rect.fromLTWH(boardLeft - wallThickness, boardTop - wallThickness, boardWidth + (wallThickness * 2), wallThickness),
        paint,
      );

      canvas.drawImageRect(
        _wallImage!,
        srcRect,
        Rect.fromLTWH(boardLeft - wallThickness, boardTop + boardHeight, boardWidth + (wallThickness * 2), wallThickness),
        paint,
      );

      canvas.drawImageRect(
        _wallImage!,
        srcRect,
        Rect.fromLTWH(boardLeft - wallThickness, boardTop, wallThickness, boardHeight),
        paint,
      );

      canvas.drawImageRect(
        _wallImage!,
        srcRect,
        Rect.fromLTWH(boardLeft + boardWidth, boardTop, wallThickness, boardHeight),
        paint,
      );
    } else {
      final wallPaint = Paint()
        ..color = const Color(0xFF6E543C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = wallThickness;
      canvas.drawRRect(
        RRect.fromRectAndRadius(boardRect.inflate(wallThickness / 2), const Radius.circular(8)),
        wallPaint,
      );
    }

    final innerBorderPaint = Paint()
      ..color = const Color(0xFFD4AC0D).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(4)),
      innerBorderPaint,
    );
  }

  void _renderBoardTiles(Canvas canvas) {
    final tileBorderPaint = Paint()
      ..color = GameTheme.stoneAlpha(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int x = 0; x < gridCols; x++) {
      for (int y = 0; y < gridRows; y++) {
        final rect = Rect.fromLTWH(
          boardLeft + (x * cellWidth),
          boardTop + (y * cellHeight),
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(rect, tileBorderPaint);
      }
    }
  }

  void _renderFoods(Canvas canvas) {
    for (final food in foods) {
      final rect = Rect.fromLTWH(
        boardLeft + (food.pos.x * cellWidth) + (cellWidth * 0.1),
        boardTop + (food.pos.y * cellHeight) + (cellHeight * 0.1),
        cellWidth * 0.8,
        cellHeight * 0.8,
      );

      if (food.type == FoodType.apple) {
        _drawGoldenApple(canvas, rect);
      } else {
        _drawQuestionScroll(canvas, rect);
      }
    }
  }

  void _drawGoldenApple(Canvas canvas, Rect rect) {
    final center = rect.center;
    final radius = rect.width * 0.40;

    final applePaint = Paint()
      ..shader = const RadialGradient(
        colors: [GameTheme.appleLight, GameTheme.appleMid, GameTheme.appleDark],
        center: Alignment(-0.3, -0.3),
      ).createShader(rect);

    final glowPaint = Paint()
      ..color = GameTheme.goldAlpha(0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, radius + 2, glowPaint);
    canvas.drawCircle(center, radius, applePaint);

    final leafPaint = Paint()..color = GameTheme.primaryGreen;
    final leafPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy - radius - 7,
        center.dx + 9,
        center.dy - radius - 3,
      )
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy - radius - 1,
        center.dx,
        center.dy - radius,
      );
    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawQuestionScroll(Canvas canvas, Rect rect) {
    final glowPaint = Paint()
      ..color = GameTheme.blueAlpha(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), glowPaint);

    final boxPaint = Paint()
      ..shader = const LinearGradient(
        colors: [GameTheme.skyBlue, GameTheme.primaryBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final borderPaint = Paint()
      ..color = GameTheme.primaryGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, boxPaint);
    canvas.drawRRect(rrect, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: GameTheme.textLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: GameTheme.shadow(0.6), offset: const Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - (textPainter.width / 2),
        rect.center.dy - (textPainter.height / 2),
      ),
    );
  }

  void _renderSnake(Canvas canvas) {
    if (snake.isEmpty) return;

    // Gövde
    for (int i = snake.length - 1; i >= 1; i--) {
      final pos = snake[i];
      final double progress = i / snake.length;
      final double scale = 0.82 - (progress * 0.14);

      final rect = Rect.fromCenter(
        center: Offset(
          boardLeft + (pos.x * cellWidth) + (cellWidth / 2),
          boardTop + (pos.y * cellHeight) + (cellHeight / 2),
        ),
        width: cellWidth * scale,
        height: cellHeight * scale,
      );

      final bodyPaint = Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFF58D68D),
            Color(0xFF27AE60),
            Color(0xFF1E8449),
          ],
          center: Alignment(-0.25, -0.25),
        ).createShader(rect);

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(rect.center.translate(0, 2), rect.width * 0.48, shadowPaint);
      canvas.drawCircle(rect.center, rect.width * 0.48, bodyPaint);

      // Benek
      final spotPaint = Paint()..color = const Color(0xFFF9E79F).withValues(alpha: 0.65);
      canvas.drawCircle(rect.center.translate(-1, -2), rect.width * 0.16, spotPaint);
    }

    // Orijinal Sevimli Gözlüklü Kafa
    final headPos = snake.first;
    final headRect = Rect.fromCenter(
      center: Offset(
        boardLeft + (headPos.x * cellWidth) + (cellWidth / 2),
        boardTop + (headPos.y * cellHeight) + (cellHeight / 2),
      ),
      width: cellWidth * 1.05,
      height: cellHeight * 1.05,
    );

    _drawOriginalCuteHead(canvas, headRect, currentDirection);
  }

  void _drawOriginalCuteHead(Canvas canvas, Rect rect, Direction dir) {
    final headPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF82E0AA),
          Color(0xFF2ECC71),
          Color(0xFF196F3D),
        ],
        center: Alignment(-0.2, -0.2),
      ).createShader(rect);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(rect.center.translate(0, 2.5), rect.width * 0.48, shadowPaint);
    canvas.drawCircle(rect.center, rect.width * 0.48, headPaint);

    Offset eye1;
    Offset eye2;
    final double eyeRadius = rect.width * 0.20;

    switch (dir) {
      case Direction.right:
        eye1 = rect.center.translate(rect.width * 0.12, -rect.height * 0.20);
        eye2 = rect.center.translate(rect.width * 0.12, rect.height * 0.20);
        break;
      case Direction.left:
        eye1 = rect.center.translate(-rect.width * 0.12, -rect.height * 0.20);
        eye2 = rect.center.translate(-rect.width * 0.12, rect.height * 0.20);
        break;
      case Direction.up:
        eye1 = rect.center.translate(-rect.width * 0.20, -rect.height * 0.12);
        eye2 = rect.center.translate(rect.width * 0.20, -rect.height * 0.12);
        break;
      case Direction.down:
        eye1 = rect.center.translate(-rect.width * 0.20, rect.height * 0.12);
        eye2 = rect.center.translate(rect.width * 0.20, rect.height * 0.12);
        break;
    }

    _drawCartoonEye(canvas, eye1, eyeRadius, dir);
    _drawCartoonEye(canvas, eye2, eyeRadius, dir);
    _drawGlasses(canvas, eye1, eye2, eyeRadius);
  }

  void _drawCartoonEye(Canvas canvas, Offset center, double radius, Direction dir) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    final strokePaint = Paint()
      ..color = const Color(0xFF1E8449)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, strokePaint);

    Offset pupilCenter = center;
    switch (dir) {
      case Direction.right:
        pupilCenter = center.translate(radius * 0.25, 0);
        break;
      case Direction.left:
        pupilCenter = center.translate(-radius * 0.25, 0);
        break;
      case Direction.up:
        pupilCenter = center.translate(0, -radius * 0.25);
        break;
      case Direction.down:
        pupilCenter = center.translate(0, radius * 0.25);
        break;
    }

    final pupilPaint = Paint()..color = const Color(0xFF17202A);
    canvas.drawCircle(pupilCenter, radius * 0.55, pupilPaint);

    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pupilCenter.translate(-radius * 0.18, -radius * 0.18), radius * 0.22, highlightPaint);
    canvas.drawCircle(pupilCenter.translate(radius * 0.12, radius * 0.12), radius * 0.10, highlightPaint);
  }

  void _drawGlasses(Canvas canvas, Offset eye1, Offset eye2, double eyeRadius) {
    final framePaint = Paint()
      ..color = const Color(0xFFD4AC0D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final glassShinePaint = Paint()
      ..color = const Color(0xFF85C1E9).withValues(alpha: 0.25);

    final r = eyeRadius * 1.15;
    canvas.drawCircle(eye1, r, glassShinePaint);
    canvas.drawCircle(eye2, r, glassShinePaint);
    canvas.drawCircle(eye1, r, framePaint);
    canvas.drawCircle(eye2, r, framePaint);
    canvas.drawLine(eye1, eye2, framePaint);
  }
}
