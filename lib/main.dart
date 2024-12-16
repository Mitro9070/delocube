import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// Импортируем пакеты для локализации
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // Импорт для инициализации локализации
import 'screens/splash_screen.dart';
import 'screens/storytelling_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/profile_screen.dart';
import 'models/capsule_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.safetyNet,
  );

  // Инициализация локализации для русской локали
  await initializeDateFormatting('ru_RU', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delocube',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Поддержка локализации
      locale: const Locale('ru'), // Установка локали по умолчанию
      supportedLocales: [const Locale('ru', 'RU')], // Поддерживаемые локали
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Если используете Cupertino Widgets
      ],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/feedback') {
          final capsule = settings.arguments as Capsule;
          return MaterialPageRoute(
            builder: (context) {
              return FeedbackScreen(capsule: capsule);
            },
          );
        }
        return null;
      },
      routes: {
        '/': (context) => SplashScreen(),
        '/storytelling': (context) => StorytellingScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}