import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/review_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_routes.dart';

class ProductDetailsView extends StatefulWidget {
  final int productId;

  const ProductDetailsView({super.key, required this.productId});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int quantity = 1;
  final TextEditingController _reviewController = TextEditingController();
  int _userRating = 5;
  String? _effectiveUserId;

  @override
  void initState() {
    super.initState();
    _resolveUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productController = context.read<ProductController>();
      productController.fetchProductDetail(widget.productId);
      productController.fetchReviews(widget.productId);
    });
  }

  Future<void> _resolveUserId() async {
    final current = Supabase.instance.client.auth.currentUser?.id;
    if (current != null && current.isNotEmpty) {
      if (mounted) setState(() => _effectiveUserId = current);
      return;
    }
    final email = await AuthService().getSavedEmail();
    if (email != null && email.isNotEmpty) {
      try {
        final res = await Supabase.instance.client
            .from('tbl_users')
            .select('user_id')
            .eq('email', email)
            .maybeSingle();
        if (res != null && res['user_id'] != null) {
          if (mounted) setState(() => _effectiveUserId = res['user_id'].toString());
        }
      } catch (e) {
        debugPrint('Error resolving user id for review: $e');
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    final cartController = Provider.of<CartController>(context, listen: false);
    final wishlistController = Provider.of<WishlistController>(context);

    final watch = productController.selectedProduct;

    if (productController.isLoading || watch == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final isFav = wishlistController.isFavorite(watch.id);
    final reviews = productController.reviewsMap[watch.id] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          watch.name,
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : AppColors.accent,
            ),
            onPressed: () {
              wishlistController.toggleFavorite(watch);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Product Image
            Container(
              height: 280,
              width: double.infinity,
              color: Colors.white,
              child: Image.network(
                watch.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.watch, size: 100, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Stock Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          watch.name,
                          style: AppTextStyles.heading.copyWith(fontSize: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: watch.stock > 0 ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          watch.stock > 0 ? "IN STOCK (${watch.stock})" : "OUT OF STOCK",
                          style: TextStyle(
                            color: watch.stock > 0 ? AppColors.success : AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price Tag
                  Text(
                    "Rs ${watch.price}",
                    style: AppTextStyles.price.copyWith(fontSize: 22, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),

                  // Product Specs Summary Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow("Category", watch.category ?? "General"),
                        const Divider(height: 12),
                        _buildSpecRow("Movement Type", watch.type ?? "Analog"),
                        const Divider(height: 12),
                        _buildSpecRow("Band Material", watch.material ?? "Stainless Steel"),
                        const Divider(height: 12),
                        _buildSpecRow("Color", watch.color ?? "Standard"),
                        const Divider(height: 12),
                        _buildSpecRow("Gender", watch.gender ?? "Unisex"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text("Overview", style: AppTextStyles.subheading),
                  const SizedBox(height: 6),
                  Text(
                    watch.description,
                    style: AppTextStyles.body.copyWith(height: 1.5, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  if (watch.stock > 0) ...[
                    Row(
                      children: [
                        Text("Quantity:", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() => quantity--);
                                  }
                                },
                              ),
                              Text("$quantity", style: AppTextStyles.subheading),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  if (quantity < watch.stock) {
                                    setState(() => quantity++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                            label: const Text("ADD TO CART", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              final item = CartItemModel(
                                id: watch.id,
                                name: watch.name,
                                image: watch.image,
                                price: watch.price.toDouble(),
                                quantity: quantity,
                                stock: watch.stock,
                              );
                              cartController.addToCart(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Added to cart!"), backgroundColor: AppColors.success),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              final item = CartItemModel(
                                id: watch.id,
                                name: watch.name,
                                image: watch.image,
                                price: watch.price.toDouble(),
                                quantity: quantity,
                                stock: watch.stock,
                              );
                              cartController.addToCart(item);
                              Navigator.pushNamed(context, AppRoutes.cartroute);
                            },
                            child: const Text("BUY NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Reviews Section
                  _buildReviewsSection(context, productController, watch.id, reviews),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(val, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, ProductController controller, int prodId, List<ReviewModel> reviews) {
    final userId = _effectiveUserId ?? Supabase.instance.client.auth.currentUser?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Customer Reviews (${reviews.length})", style: AppTextStyles.subheading),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text("No reviews yet. Be the first to share your thoughts!", style: AppTextStyles.body),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.userName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        Row(
                          children: List.generate(5, (i) => Icon(Icons.star, color: i < review.rating ? Colors.amber : Colors.grey[200], size: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(review.comment, style: AppTextStyles.body),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (review.isVerifiedPurchase)
                          Row(
                            children: [
                              const Icon(Icons.verified, color: AppColors.success, size: 12),
                              const SizedBox(width: 4),
                              Text("Verified Purchase", style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.success)),
                            ],
                          )
                        else
                          const SizedBox(),
                        
                        GestureDetector(
                          onTap: () {
                            if (userId != null) {
                              controller.toggleHelpfulVote(review.id, userId, prodId);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.thumb_up_alt_outlined, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text("Helpful (${review.helpfulCount})", style: AppTextStyles.body.copyWith(fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        
        // Form to add review
        if (userId != null) ...[
          const SizedBox(height: 24),
          Text("Write a Review", style: AppTextStyles.subheading),
          const SizedBox(height: 10),
          Row(
            children: [
              Text("Rating: ", style: AppTextStyles.body),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: _userRating,
                items: [5, 4, 3, 2, 1]
                    .map((r) => DropdownMenuItem(value: r, child: Text("$r Stars")))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _userRating = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Share your experience with this watch model...",
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final comment = _reviewController.text.trim();
                if (comment.isEmpty) return;

                final isVerified = await controller.verifyUserPurchase(userId, prodId);
                final success = await controller.addReview(
                  productId: prodId,
                  userId: userId,
                  userName: "User",
                  rating: _userRating,
                  comment: comment,
                  isVerified: isVerified,
                );

                if (success) {
                  _reviewController.clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Review submitted!"), backgroundColor: Colors.green),
                    );
                  }
                } else {
                  if (context.mounted) {
                    final err = controller.errorMessage.isNotEmpty ? controller.errorMessage : "Failed to submit review";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: Text("SUBMIT REVIEW", style: AppTextStyles.subheading.copyWith(color: Colors.white, fontSize: 13)),
            ),
          ),
        ],
      ],
    );
  }
}
