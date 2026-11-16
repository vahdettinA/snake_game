import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;
  QuestionService._internal();

  List<Question> _allQuestions = [];
  List<Question> _remainingQuestions = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  int get totalCount => _allQuestions.length;

  Future<void> loadQuestions() async {
    if (_isLoaded && _allQuestions.isNotEmpty) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/questions.json');
      final List<dynamic> data = json.decode(jsonStr);
      _allQuestions = data.map((item) => Question.fromJson(item)).toList();
      _remainingQuestions = List.from(_allQuestions)..shuffle();
      _isLoaded = true;
    } catch (e) {
      // Fallback güvenlik soruları
      _allQuestions = [
        const Question(
          id: 1,
          question: "Türkiye'nin başkenti neresidir?",
          options: ["İstanbul", "Ankara", "İzmir", "Bursa"],
          correctIndex: 1,
          category: "Coğrafya",
        ),
        const Question(
          id: 2,
          question: "Güneş sisteminin en büyük gezegeni hangisidir?",
          options: ["Mars", "Satürn", "Jüpiter", "Venüs"],
          correctIndex: 2,
          category: "Bilim",
        ),
      ];
      _remainingQuestions = List.from(_allQuestions);
      _isLoaded = true;
    }
  }

  Question getRandomQuestion() {
    if (_remainingQuestions.isEmpty) {
      _remainingQuestions = List.from(_allQuestions)..shuffle();
    }
    return _remainingQuestions.removeLast();
  }

  void resetQuestions() {
    _remainingQuestions = List.from(_allQuestions)..shuffle();
  }
}

