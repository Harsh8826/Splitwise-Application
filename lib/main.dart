import 'package:flutter_application_4/services/auth_provider.dart';
import 'package:flutter_application_4/services/group_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/log/log.dart';
// Screens
import 'package:flutter_application_4/screens/login_screen.dart';
import 'package:flutter_application_4/screens/register_screen.dart';
import 'package:flutter_application_4/screens/home_screen.dart';

// Theme colors (if using constant colors)
import 'package:flutter_application_4/constants/colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const BuddySplitApp(),
    ),
  );
}

class BuddySplitApp extends StatelessWidget {
  const BuddySplitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
  // AuthService().deleteToken();

    return MaterialApp(
      title: 'Buddy Split',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
      ),
      home: const AuthCheck(), // shows login or home based on auth status
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

// ✅ Inline AuthCheck Widget
class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {

        if (auth.isAuthenticated) {
          Logger.logDeveloper('Authentication is ${auth.isAuthenticated}');
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      
      },
    );
  }
}
