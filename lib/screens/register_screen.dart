import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart'; // Make sure this path is correct

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // 
      backgroundColor: const Color(0xFFF6FAF5), // Light green background
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard on tap
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.green.withOpacity(0.1),
                //     blurRadius: 12,
                //     spreadRadius: 3,
                //     offset: const Offset(0, 6),
                //   ),
                // ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, size: 64, color: Colors.green),
                    const SizedBox(height: 12),
                    Text(
                      "Create Account",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 16),

                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Username", Icons.person),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter a username" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration("Email", Icons.email),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter email" : null,
                          
                    ),
                    
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      decoration: _buildInputDecoration("Password", Icons.lock),
                      validator: (value) =>
                          value == null || value.length < 6
                              ? "Password must be at least 6 characters"
                              : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _handleRegister(context),
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
                                'Register',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.green,
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
        borderSide: BorderSide.none,
      ),
    );
  }
}