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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  DateTime? _selectedDate;
  bool _isLogin = true;

  // Validation states
  bool _emailValid = false;
  bool _passwordHasMinLength = false;
  bool _passwordHasUppercase = false;
  bool _passwordHasLowercase = false;
  bool _passwordHasNumber = false;
  bool _passwordHasSpecialChar = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    setState(() {
      _email = email;
      if (email.isEmpty) {
        _emailValid = false;
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailValid = false;
        _emailError = 'Please enter a valid email address';
      } else {
        _emailValid = true;
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _password = password;
      _passwordHasMinLength = password.length >= 8;
      _passwordHasUppercase = password.contains(RegExp(r'[A-Z]'));
      _passwordHasLowercase = password.contains(RegExp(r'[a-z]'));
      _passwordHasNumber = password.contains(RegExp(r'[0-9]'));
      _passwordHasSpecialChar =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid {
    return _passwordHasMinLength &&
        _passwordHasUppercase &&
        _passwordHasLowercase &&
        _passwordHasNumber &&
        _passwordHasSpecialChar;
  }

  Widget _buildValidationItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green : Colors.red,
                fontWeight: isValid ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  key: const ValueKey('name'),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Please enter your full name (at least 2 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select Date of Birth'
                            : 'DOB: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
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
                ),
                const SizedBox(height: 16),
              ],

              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      errorText: _emailError,
                      suffixIcon: _email.isNotEmpty
                          ? Icon(
                              _emailValid ? Icons.check_circle : Icons.error,
                              color: _emailValid ? Colors.green : Colors.red,
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!_emailValid) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_password.isNotEmpty && !_isLogin)
                            Icon(
                              _isPasswordValid
                                  ? Icons.check_circle
                                  : Icons.error,
                              color:
                                  _isPasswordValid ? Colors.green : Colors.red,
                            ),
                          IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ],
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (_isLogin) {
                        return null; // Less strict validation for login
                      }
                      if (!_isPasswordValid) {
                        return 'Password must meet all requirements below';
                      }
                      return null;
                    },
                  ),

                  // Password requirements (only show for signup)
                  if (!_isLogin && _password.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildValidationItem(
                              'At least 8 characters', _passwordHasMinLength),
                          _buildValidationItem('Contains uppercase letter',
                              _passwordHasUppercase),
                          _buildValidationItem('Contains lowercase letter',
                              _passwordHasLowercase),
                          _buildValidationItem(
                              'Contains number', _passwordHasNumber),
                          _buildValidationItem(
                              'Contains special character (!@#\$%^&*)',
                              _passwordHasSpecialChar),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Date validation for signup
              if (!_isLogin && _selectedDate == null) ...[
                const SizedBox(height: 8),
                Text(
                  'Please select your date of birth',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLogin ||
                    (_emailValid && _isPasswordValid && _selectedDate != null))
                ? _submit
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.actionButtonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onToggle,
          child: Text(widget.toggleText),
        ),
      ],
    );
  }
}
