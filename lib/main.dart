import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flowers_EA/pages/comunes/home.dart';
import 'package:flowers_EA/servicios/sign_user/login.dart';
import 'package:flowers_EA/pages/splash_screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: 'AIzaSyAYy5qzj7_xXCS4WLKgfglEP7HvuJ0aF_o',
    appId: '1:495211324516:android:3bc2275b42ea4405fb6b71',
    messagingSenderId: '495211324516',
    projectId: 'proyectoarmario-8b8d4',
    storageBucket: 'proyectoarmario-8b8d4.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EL ARMARIO',
      routes: { 
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}
