import 'package:PavFlix/screens/auth/logback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:PavFlix/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/netflix_app_bar.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart'; // Assuming you have the ThemeProvider in a separate file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: PavFlixApp(),
    ),
  );
}

class PavFlixApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PavFlix',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreenss(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => NetflixAppBar(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}