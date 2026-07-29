import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ReviewController manages customer product reviews, performs data joining,
// handles reviews deletion, and toggles verified purchase indicators.
class ReviewController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetches product reviews and joins related user names and product names
  Future<void> fetchReviews({bool onlyPending = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var query = _supabase.from('tbl_reviews').select('*');
      
      // Filter non-verified purchases if flag is set
      if (onlyPending) {
        query = query.eq('is_verified_purchase', false);
      }
      
      final response = await query.order('created_at', ascending: false);
      final List<Map<String, dynamic>> fetchedReviews = List<Map<String, dynamic>>.from(response);

      if (fetchedReviews.isNotEmpty) {
        // Extract distinct lists of product IDs and user IDs to fetch their names in bulk
        final productIds = fetchedReviews.map((r) => int.parse(r['product_id'].toString())).toSet().toList();
        final userIds = fetchedReviews.map((r) => r['user_id'].toString()).toSet().toList();

        // Retrieve product names and user names
        final productsData = await _supabase.from('tbl_products').select('id, prod_name').inFilter('id', productIds);
        final usersData = await _supabase.from('tbl_users').select('user_id, name').inFilter('user_id', userIds);

        // Convert lists to lookup maps
        final pMap = {for (var p in productsData) p['id'].toString(): p['prod_name']};
        final uMap = {for (var u in usersData) u['user_id'].toString(): u['name']};

        // Attach joined brand name and customer name to each review list element
        for (var review in fetchedReviews) {
          review['joined_product'] = pMap[review['product_id'].toString()] ?? 'Unknown Product';
          review['joined_customer'] = uMap[review['user_id'].toString()] ?? (review['user_name'] ?? 'Guest');
        }
      }
      _reviews = fetchedReviews;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deletes review record from database
  Future<void> deleteReview(dynamic id) async {
    try {
      await _supabase.from('tbl_reviews').delete().eq('id', id);
      _reviews.removeWhere((r) => r['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  // Toggles the verified purchase flag for a review
  Future<void> updateStatus(dynamic id, bool currentStatus) async {
    try {
      await _supabase.from('tbl_reviews').update({'is_verified_purchase': !currentStatus}).eq('id', id);
      
      final index = _reviews.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        _reviews[index]['is_verified_purchase'] = !currentStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  // Reload reviews list
  Future<void> refreshReview() async => fetchReviews();
}
