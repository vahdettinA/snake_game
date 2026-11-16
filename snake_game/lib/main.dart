import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';
import 'services/storage_service.dart';
import 'services/question_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yatay Mod (Landscape) ve Tam Ekran Yapılandırması
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Servislerin İlklendirilmesi
  await StorageService().init();
  await QuestionService().loadQuestions();
  await AudioService().init();

  runApp(const BilgeYilanApp());
}

class BilgeYilanApp extends StatelessWidget {
  const BilgeYilanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilge Yılan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B2631),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
