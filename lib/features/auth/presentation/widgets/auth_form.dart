import 'package:flutter/material.dart';

typedef OnSubmit = void Function(
    String email, String password, String? name, DateTime? dob);

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
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLogin = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_isLogin) {
        widget.onSubmit(_email.trim(), _password.trim(), '', DateTime.now());
      } else {
        widget.onSubmit(_email.trim(), _password.trim(),
            _nameController.text.trim(), _selectedDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.toggleText == 'Already have an account? Login') {
      _isLogin = false;
    }
    return Column(
      children: [
        Text(widget.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  key: const ValueKey('name'),
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Please enter a valid name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Date of Birth'
                          : 'DOB: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2005),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
              ],
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
