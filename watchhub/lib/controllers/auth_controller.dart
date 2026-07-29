import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../utils/app_routes.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool isLoading = false;

  // Handles onboarding timer and routes logged-in users to home, others to sign-in
  // Handles onboarding timer and routes logged-in users to home, returns true if logged in
  Future<bool> splashTimer(BuildContext context) async {
    final email = await _authService.getSavedEmail();
    if (email != null && email.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.pushReplacementNamed(context, AppRoutes.homeroute);
      });
      return true;
    }
    return false;
  }

  // Logs the user in, validates inputs, stores user email, and routes to home
  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar(context, "Email and Password are required", Colors.red);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user == null) {
        _showSnackbar(context, "Invalid email or password", Colors.red);
        return;
      }

      await _authService.ensureUserExists(user);

      await _authService.saveEmail(email);
      emailController.clear();
      passwordController.clear();

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.homeroute);
      _showSnackbar(context, "Welcome back!", Colors.green);
    } on AuthException catch (e) {
      _showSnackbar(context, e.message, Colors.red);
    } catch (e) {
      _showSnackbar(context, "Failed to login. Please try again.", Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Registers a new user, adds their row to tbl_users, and routes to login
  Future<void> signUp(BuildContext context) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');

    if (username.isEmpty || !nameRegex.hasMatch(username)) {
      _showSnackbar(context, "Name must contain only alphabets", Colors.red);
      return;
    }
    if (email.isEmpty) {
      _showSnackbar(context, "Email is required", Colors.red);
      return;
    }
    if (password.length < 6) {
      _showSnackbar(context, "Password must be at least 6 characters", Colors.red);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(username, email, password);
      _showSnackbar(context, "Account created! Please log in.", Colors.green);
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.signinRoute);
    } on AuthException catch (e) {
      _showSnackbar(context, e.message, Colors.red);
    } catch (e) {
      _showSnackbar(context, e.toString(), Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Triggers recovery email for forgotten password
  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar(context, "Please enter your email", Colors.red);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _showSnackbar(context, "Reset link sent to your email", Colors.green);
    } on AuthException catch (e) {
      _showSnackbar(context, e.message, Colors.red);
    } catch (e) {
      _showSnackbar(context, "Something went wrong", Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Updates logged-in user password
  Future<void> changePassword(BuildContext context, String newPassword) async {
    if (newPassword.isEmpty || newPassword.length < 6) {
      _showSnackbar(context, "Password must be at least 6 characters", Colors.red);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _authService.updatePassword(newPassword);
      _showSnackbar(context, "Password changed successfully!", Colors.green);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on AuthException catch (e) {
      _showSnackbar(context, e.message, Colors.red);
    } catch (e) {
      _showSnackbar(context, "Something went wrong", Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Sign out the current user session and route to sign-in page
  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.signinRoute);
  }

  // Simple snackbar helper method
  void _showSnackbar(BuildContext context, String msg, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
