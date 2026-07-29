import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Submit contact support message
  Future<void> submitSupportMessage({
    required String userId,
    required String fullName,
    required String message,
  }) async {
    await _supabase.from('tbl_chatsupport').insert({
      'user_id': userId,
      'full_name': fullName.trim(),
      'message': message.trim(),
    });
  }

  // Fetch contact support messages
  Future<List<Map<String, dynamic>>> fetchSupportMessages(String userId) async {
    final response = await _supabase
        .from('tbl_chatsupport')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Submit feedback
  Future<void> submitFeedback({
    required String userId,
    required String feedbackText,
  }) async {
    await _supabase.from('tbl_feedback').insert({
      'user_id': userId,
      'feedback_text': feedbackText.trim(),
    });
  }

  // Fetch feedbacks
  Future<List<Map<String, dynamic>>> fetchUserFeedbacks(String userId) async {
    final response = await _supabase
        .from('tbl_feedback')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
