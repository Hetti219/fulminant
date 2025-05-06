import 'package:flutter/material.dart';

typedef OnSubmit = void Function(String email, String password);

class AuthForm extends StatefulWidget {
  final String title;
  final String actionButtonText;
  final String toggleText;
  final VoidCallback onToggle;
  final OnSubmit onSubmit;

  const AuthForm({
    super.key,
    required this.title,
    required this.actionButtonText,
    required this.toggleText,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_email.trim(), _password.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value ?? '',
                validator: (value) =>
                    value!.contains('@') ? null : 'Enter a valid email',
              ),

              const SizedBox(height: 12),

              // Password Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                onSaved: (value) => _password = value ?? '',
                validator: (value) =>
                    value!.length >= 6 ? null : 'Password too short',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.actionButtonText),
        ),
        TextButton(
          onPressed: widget.onToggle,
          child: Text(widget.toggleText),
        ),
      ],
    );
  }
}
