// ignore_for_file: use_build_context_synchronously
import 'package:adminapp/utils/app_colors.dart';
import 'package:adminapp/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// LoginController handles inputs, validations, and calling the login API
// for authentication on the Admin login screen.
class LoginController extends ChangeNotifier {
  // Input fields controllers to retrieve text from user input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Storage and Supabase references
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final SupabaseClient supabase = Supabase.instance.client;

  // States to manage loading status, toggle visibility, and show form errors
  String emailError = "";
  String passwordError = "";
  bool obscureText = true;
  bool isLoading = false;

  // Toggles the visibility of the password field
  void toggleObscure() {
    obscureText = !obscureText;
    notifyListeners(); // Updates the UI
  }

  // Simple validation to check that the fields are not empty
  bool validateInputs() {
    emailError = "";
    passwordError = "";
    bool isValid = true;

    if (emailController.text.trim().isEmpty) {
      emailError = "Email is required";
      isValid = false;
    }
    if (passwordController.text.trim().isEmpty) {
      passwordError = "Password is required";
      isValid = false;
    }

    notifyListeners(); // Refresh UI to show error labels
    return isValid;
  }

  // Attempts to log in using Supabase and redirects if successful
  Future<void> loginAdmin(BuildContext context) async {
    if (!validateInputs()) {
      return; // Stop if inputs are invalid
    }

    isLoading = true;
    notifyListeners(); // Show loading indicator in UI

    try {
      final emailValue = emailController.text.trim();
      final passwordValue = passwordController.text.trim();

      // Call Supabase auth login
      await supabase.auth.signInWithPassword(
        email: emailValue,
        password: passwordValue,
      );

      // Save user email locally to keep session
      await storage.write(key: "useremail", value: emailValue);

      // Reset values
      emailController.clear();
      passwordController.clear();

      isLoading = false;
      notifyListeners();

      // Go to Home screen
      Navigator.pushReplacementNamed(context, AppRoutes.homeRoute);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged in successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
    } on AuthException catch (e) {
      isLoading = false;
      notifyListeners();
      
      // Handle login error (e.g., incorrect credentials)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
        ),
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();

      // Handle unexpected system/network errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
