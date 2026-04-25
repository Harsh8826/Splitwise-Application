import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMessage = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF5),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color:Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Login to your account to continue',
                        style: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Email
                      TextFormField(
                        key: const Key('emailField'),
                        controller: _emailController,
                       
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: _buildInputDecoration('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        key: const Key('passwordField'),
                        controller: _passwordController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: _buildInputDecoration('Password', Icons.lock),
                        obscureText: true,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 24),

                      isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        key: const Key('loginButton'),
                        onPressed: isLoading ? null : () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                            ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color:Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:BorderSide.none,
      ),
    );
  }
}