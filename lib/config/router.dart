import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/home/home_screen.dart'; // create later

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/signup':
      return MaterialPageRoute(builder: (_) => const SignupScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    default:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
  }
}
