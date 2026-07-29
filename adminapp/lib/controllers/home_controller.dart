// ignore_for_file: use_build_context_synchronously
import 'package:adminapp/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// HomeController handles layout actions (like logging out of the admin panel).
class HomeController extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  // Performs user sign-out from Supabase, cleans local secure storage,
  // and redirects back to the login page.
  Future<void> logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    
    // Remove locally stored user email
    await storage.delete(key: "useremail");
    
    // Log out user from Supabase session
    await supabase.auth.signOut();
    
    // Go to login page
    Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
  }
}
