import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase/auth_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

/// Listens to Firebase auth state and routes the user to the correct screen:
///
///  • While the auth state is unknown  → [SplashScreen] (loading animation)
///  • Authenticated user              → [HomeScreen]
///  • Unauthenticated user            → [LoginScreen]
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // Still waiting for Firebase to resolve the auth state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // User is signed in — go directly to the home screen.
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // No authenticated user — show the login screen.
        return const LoginScreen();
      },
    );
  }
}
