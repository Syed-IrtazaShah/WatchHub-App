
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get current user email from local secure storage
  Future<String?> getSavedEmail() async {
    return await _storage.read(key: "useremail");
  }

  // Save user email to local secure storage
  Future<void> saveEmail(String email) async {
    await _storage.write(key: "useremail", value: email);
  }

  // Clear user session from local secure storage
  Future<void> clearSession() async {
    await _storage.delete(key: "useremail");
  }

  // Login
  Future<User?> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  // Ensure user profile exists in custom users table (auto-creates if missing)
  Future<bool> ensureUserExists(User user) async {
    try {
      final existing = await _supabase
          .from("tbl_users")
          .select()
          .eq("user_id", user.id)
          .limit(1);

      if (existing.isNotEmpty) {
        return true;
      }

      // Check by email in case user_id is missing or updated
      if (user.email != null && user.email!.isNotEmpty) {
        final existingByEmail = await _supabase
            .from("tbl_users")
            .select()
            .eq("email", user.email!)
            .limit(1);

        if (existingByEmail.isNotEmpty) {
          await _supabase
              .from("tbl_users")
              .update({"user_id": user.id})
              .eq("email", user.email!);
          return true;
        }
      }

      // Auto-create missing profile row in tbl_users
      final defaultName = user.userMetadata?['name'] ?? (user.email != null ? user.email!.split('@').first : 'User');
      await _supabase.from("tbl_users").insert({
        "user_id": user.id,
        "name": defaultName,
        "email": user.email ?? "",
      });
      return true;
    } catch (e) {
      // Fallback: allow login if user is authenticated in Supabase Auth
      return true;
    }
  }

  // Sign Up / Register
  Future<User?> signUp(String username, String email, String password) async {
    // 1. Check if email is already registered in tbl_users
    final existing = await _supabase
        .from("tbl_users")
        .select()
        .eq("email", email)
        .limit(1);

    if (existing.isNotEmpty) {
      throw const AuthException("Email already registered");
    }

    // 2. Auth SignUp
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException("Failed to register user");
    }

    // 3. Insert user record into database
    await _supabase.from("tbl_users").insert({
      "user_id": user.id,
      "name": username,
      "email": email,
    });

    return user;
  }

  // Send Reset Password Email
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update Password for Authenticated User
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Fetch Profile Info
  Future<Map<String, dynamic>?> fetchProfile(String email) async {
    try {
      final response = await _supabase
          .from('tbl_users')
          .select('name, email')
          .eq('email', email)
          .maybeSingle();

      if (response != null && response['name'] != null && response['name'].toString().trim().isNotEmpty) {
        return response;
      }

      final authUser = _supabase.auth.currentUser;
      final defaultName = authUser?.userMetadata?['name'] ?? (email.isNotEmpty ? email.split('@').first : 'User');
      return {'name': defaultName, 'email': email};
    } catch (e) {
      final defaultName = email.isNotEmpty ? email.split('@').first : 'User';
      return {'name': defaultName, 'email': email};
    }
  }

  // Update Profile Info
  Future<void> updateProfile(String oldEmail, String newName, String newEmail) async {
    await _supabase
        .from('tbl_users')
        .update({
          'name': newName,
          'email': newEmail,
        })
        .eq('email', oldEmail);

    if (oldEmail != newEmail) {
      await saveEmail(newEmail);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await clearSession();
  }
}
