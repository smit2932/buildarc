import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/home');
          });
          return Container(); // return an empty widget
        } else {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: "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")
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/buildarc-logo.webp'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? Text(
                        'Welcome to BuildArc, please sign in to continue.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    : Text(
                        'Welcome to BuildArc, please sign up to continue.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
              );
            },
            footerBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  "By signing in, you agree to our Terms of Service and Privacy Policy",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/buildarc-logo.webp'),
                ),
              );
            },
          );
        }
      },
    );
  }
}