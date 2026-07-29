import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/brand_model.dart';
import '../models/watch_model.dart';
import '../models/review_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all brands
  Future<List<BrandModel>> fetchBrands() async {
    final response = await _supabase
        .from('tbl_brand')
        .select('id, brand_name, brand_img_url')
        .order('created_at', ascending: false);

    return (response as List).map((e) => BrandModel.fromJson(e)).toList();
  }

  // Fetch all products
  Future<List<WatchModel>> fetchProducts() async {
    final response = await _supabase
        .from('tbl_products')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((e) => WatchModel.fromJson(e)).toList();
  }

  // Fetch products by brand
  Future<List<WatchModel>> fetchBrandProducts(int brandId) async {
    final response = await _supabase
        .from('tbl_products')
        .select('id, prod_img, prod_name, prod_price, prod_stock, prod_description, prod_brand, prod_type, prod_category, prod_color, prod_material, prod_gender')
        .eq('prod_brand', brandId);

    return (response as List).map((e) => WatchModel.fromJson(e)).toList();
  }

  // Fetch reviews for a product
  Future<List<ReviewModel>> fetchReviews(int productId) async {
    final response = await _supabase
        .from('tbl_reviews')
        .select('*')
        .eq('product_id', productId);

    return (response as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  // Submit a review
  Future<ReviewModel> submitReview({
    required int productId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    bool isVerifiedPurchase = false,
  }) async {
    // 1. Resolve actual user name from tbl_users if possible
    String resolvedName = userName;
    try {
      final userResponse = await _supabase
          .from('tbl_users')
          .select('name')
          .eq('user_id', userId)
          .maybeSingle();

      if (userResponse != null) {
        resolvedName = userResponse['name'] ?? userName;
      }
    } catch (e) {
      print('Error resolving username for review: $e');
    }

    // 2. Insert review
    final newReview = {
      'product_id': productId,
      'user_id': userId,
      'user_name': resolvedName,
      'rating': rating,
      'comment': comment,
      'is_verified_purchase': isVerifiedPurchase,
      'helpful_count': 0,
    };

    final response = await _supabase
        .from('tbl_reviews')
        .insert(newReview)
        .select()
        .single();

    return ReviewModel.fromJson(response);
  }

  // Check user purchases
  Future<bool> hasUserPurchasedProduct(String userId, int productId) async {
    final response = await _supabase
        .from('tbl_orders')
        .select('id')
        .eq('user_id', userId)
        .eq('prod_id', productId)
        .limit(1);

    return response.isNotEmpty;
  }

  // Update review helpfulness
  Future<void> updateReviewHelpfulness(int reviewId, int newCount) async {
    await _supabase
        .from('tbl_reviews')
        .update({'helpful_count': newCount})
        .eq('id', reviewId);
  }
}
