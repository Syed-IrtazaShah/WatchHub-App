// ignore_for_file: use_build_context_synchronously
import 'package:adminapp/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SplashController handles the startup animation delay and routes the user
// based on whether they are already logged in or not.
class SplashController extends ChangeNotifier {
  
  // This function checks the saved session in the local storage
  // and directs the user to either the Home screen or the Login screen.
  void checkUserSession(BuildContext context) async {
    // Standard Flutter secure storage helper to read stored variables
    const storage = FlutterSecureStorage();

    // Check if the user email exists in storage
    String? email = await storage.read(key: "useremail");

    // Wait for 3 seconds (animation/splash delay) before navigating
    Future.delayed(const Duration(seconds: 3), () {
      if (email != null && email.isNotEmpty) {
        // If logged in, go to Dashboard/Home screen
        Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);
      } else {
        // If not logged in, go to Login screen
        Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
      }
    });
  }
}
