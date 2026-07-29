import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/feedback_service.dart';

class SupportController extends ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool isLoading = false;
  String errorMessage = '';

  String userName = '';
  String userEmail = '';

  List<Map<String, dynamic>> userMessages = [];
  List<Map<String, dynamic>> userFeedbacks = [];

  // Loads current user email and name details
  Future<void> fetchUserDetails() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('tbl_users')
          .select('name, email')
          .eq('user_id', user.id)
          .single();

      userName = response['name'] ?? '';
      userEmail = response['email'] ?? '';
      notifyListeners();
    } catch (e) {
      userName = '';
      userEmail = '';
    }
  }

  // Sends a customer support message to the database
  Future<bool> submitMessage({
    required String fullName,
    required String message,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      errorMessage = "User not logged in";
      return false;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _feedbackService.submitSupportMessage(
        userId: user.id,
        fullName: fullName,
        message: message,
      );
      await fetchUserMessages();
      return true;
    } catch (e) {
      errorMessage = "Failed to send message: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetches support correspondence history
  Future<void> fetchUserMessages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      userMessages = await _feedbackService.fetchSupportMessages(user.id);
    } catch (e) {
      errorMessage = "Failed to load support records";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Submits issue report feedback
  Future<bool> submitFeedback({required String feedbackText}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      errorMessage = "User not logged in";
      return false;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _feedbackService.submitFeedback(
        userId: user.id,
        feedbackText: feedbackText,
      );
      await fetchUserFeedbacks();
      return true;
    } catch (e) {
      errorMessage = "Failed to submit feedback: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetches report feedback history
  Future<void> fetchUserFeedbacks() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      userFeedbacks = await _feedbackService.fetchUserFeedbacks(user.id);
    } catch (e) {
      errorMessage = "Failed to load feedback records";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
