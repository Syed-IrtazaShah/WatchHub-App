import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Provider.of<WishlistController>(context);
    final cartController = Provider.of<CartController>(context, listen: false);

    final favoriteIds = wishlistController.favoriteIds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "My Wishlist",
          style: AppTextStyles.heading.copyWith(color: Colors.white, letterSpacing: 1.0),
        ),
        actions: [
          if (favoriteIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
              onPressed: () {
                wishlistController.clearAllFavorites();
              },
            ),
        ],
      ),
      body: favoriteIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 72, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("Your Wishlist is Empty", style: AppTextStyles.subheading),
                  const SizedBox(height: 6),
                  Text("Save watches you like here", style: AppTextStyles.body),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteIds.length,
              itemBuilder: (context, index) {
                final watchId = favoriteIds[index];
                final watch = wishlistController.getProductById(watchId);

                if (watch == null) {
                  // Trigger lazy loading
                  wishlistController.fetchAndCacheProduct(watchId);
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Watch Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          watch.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[100], width: 80, height: 80, child: const Icon(Icons.watch)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              watch.name,
                              style: AppTextStyles.subheading.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rs ${watch.price}",
                              style: AppTextStyles.price.copyWith(color: AppColors.accent),
                            ),
                            const SizedBox(height: 10),
                            
                            // Add to Cart / Stepper actions
                            if (watch.stock > 0)
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () {
                                    cartController.addToCart(CartItemModel(
                                      id: watch.id,
                                      name: watch.name,
                                      image: watch.image,
                                      price: watch.price.toDouble(),
                                      quantity: 1,
                                      stock: watch.stock,
                                    ));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Added to shopping cart!"),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    "ADD TO CART",
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Text(
                                "Out of Stock",
                                style: AppTextStyles.body.copyWith(color: AppColors.error, fontSize: 12),
                              ),
                          ],
                        ),
                      ),

                      // Remove icon
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          wishlistController.toggleFavorite(watch);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
