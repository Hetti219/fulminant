import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/auth_form.dart';
import '../../logic/auth_bloc.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
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
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AuthForm(
                title: 'Sign Up',
                actionButtonText: 'Create Account',
                toggleText: 'Already have an account? Login',
                onToggle: () => _navigateToLogin(context),
                onSubmit: (email, password) {
                  context
                      .read<AuthBloc>()
                      .add(AuthSignUpRequested(email, password));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
