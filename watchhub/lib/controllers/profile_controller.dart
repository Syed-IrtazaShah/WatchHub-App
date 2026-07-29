import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  bool _isInitialized = false;

  // Loads current user profile and fills controller inputs
  Future<void> initializeUserData() async {
    if (_isInitialized) return;

    _isInitialized = true;
    isLoading = true;
    notifyListeners();

    try {
      var userEmail = await _authService.getSavedEmail();
      if (userEmail == null || userEmail.isEmpty) {
        userEmail = Supabase.instance.client.auth.currentUser?.email;
        if (userEmail != null && userEmail.isNotEmpty) {
          await _authService.saveEmail(userEmail);
        }
      }

      if (userEmail != null && userEmail.isNotEmpty) {
        final profile = await _authService.fetchProfile(userEmail);
        if (profile != null) {
          nameController.text = profile['name']?.toString() ?? '';
          emailController.text = profile['email']?.toString() ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _isInitialized = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Resets the profile initialization status to force data re-fetch on edit/reload
  void resetInitialization() {
    _isInitialized = false;
    notifyListeners();
  }

  // Saves profile modifications to database and updates cache details
  Future<void> saveProfile(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      _showSnackbar(context, "Name cannot be empty", Colors.red);
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackbar(context, "Invalid email format", Colors.red);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final oldEmail = await _authService.getSavedEmail();
      if (oldEmail != null && oldEmail.isNotEmpty) {
        await _authService.updateProfile(oldEmail, name, email);
        resetInitialization();
        _showSnackbar(context, "Profile updated successfully", Colors.green);
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        _showSnackbar(context, "No active login session found", Colors.red);
      }
    } catch (e) {
      _showSnackbar(context, "Failed to update profile: $e", Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to show snackbars
  void _showSnackbar(BuildContext context, String msg, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
