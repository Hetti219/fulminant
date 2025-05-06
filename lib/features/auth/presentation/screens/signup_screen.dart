import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/auth_form.dart';
import '../../logic/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToSignUp(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AuthForm(
                title: 'Login',
                actionButtonText: 'Login',
                toggleText: 'Don’t have an account? Sign up',
                onToggle: () => _navigateToSignUp(context),
                onSubmit: (email, password) {
                  context
                      .read<AuthBloc>()
                      .add(AuthLoginRequested(email, password));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
