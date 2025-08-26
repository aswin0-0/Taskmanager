import 'package:flutter/material.dart';
import 'package:to_do_task/pages/home_page.dart';
import 'package:to_do_task/pages/login_page.dart';
import 'package:to_do_task/pages/register_page.dart';
import 'package:to_do_task/pages/profile_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        useMaterial3: false,
      ),
      // Default entry point = Login
      home: const LoginPage(),  
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
        '/profile' : (context) => const ProfilePage(),
        
      },
    );
  }
}
