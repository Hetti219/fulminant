import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/router.dart';
import 'features/auth/logic/auth_bloc.dart';
import 'features/auth/data/auth_repo.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(AuthRepository()),
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        onGenerateRoute: generateRoute,
        home: const AuthWrapper(),
      ),
    ),
  );
}
