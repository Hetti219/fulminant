import 'package:flutter/material.dart';
import '../features/courses/presentation/screens/course_list_screen.dart';
import '../features/leaderboard/screens/leaderboard_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/signup':
      return MaterialPageRoute(builder: (_) => const SignupScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case '/course':
      return MaterialPageRoute(builder: (_) => const CourseListScreen());
    case '/leaderboard':
      return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    default:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
  }
}
