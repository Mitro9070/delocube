import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  await initializeDateFormatting('ru_RU', null); // Инициализация локализации
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