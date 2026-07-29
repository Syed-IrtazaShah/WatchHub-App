import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_routes.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context, listen: false);

    final List<Map<String, dynamic>> categoriesList = [
      {
        "name": "Luxury",
        "icon": Icons.workspace_premium_rounded,
        "image": "https://watchclubpakistan.pk/cdn/shop/files/SLA055_a.jpg?v=1670256099&width=3840",
      },
      {
        "name": "Smart",
        "icon": Icons.watch_rounded,
        "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfS7GexzseEV3cXdOlpnngCayZj8dPGN8Cd-a0WRquK_yGsdseJGRjjp4&s=10",
      },
      {
        "name": "Sports",
        "icon": Icons.timer_rounded,
        "image": "https://hodinkee.imgix.net/uploads/images/bda387bc-9223-43c8-b9f5-77971f865e34/sports-watches-2023-hodinkee.jpg?ixlib=rails-1.1.0&fm=jpg&q=55&auto=format&usm=12",
      },
      {
        "name": "Classic",
        "icon": Icons.schedule_rounded,
        "image": "https://goldammer.me/cdn/shop/collections/vintage-watches.jpg?v=1747812557",
      },
      {
        "name": "Fashion",
        "icon": Icons.diamond_rounded,
        "image": "https://watchesandcrystals.com/cdn/shop/articles/get-the-latest-fashion-watches-for-men-and-women-424845.jpg?v=1667085325",
      },
      {
        "name": "Limited",
        "icon": Icons.military_tech_rounded,
        "image": "https://limitedwatches.pk/cdn/shop/files/file_00000000b16c71faaab7ccb0749847bb.png?v=1784054840&width=1500",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Categories",
          style: AppTextStyles.heading.copyWith(color: Colors.white, letterSpacing: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: categoriesList.length,
          itemBuilder: (context, index) {
            final category = categoriesList[index];
            return GestureDetector(
              onTap: () {
                // Clear existing filters and apply the selected category filter
                productController.clearFilters();
                productController.setFilters(category: category['name']);
                
                // Route to the product listing catalog view
                Navigator.pushNamed(context, AppRoutes.browseproductsroute);
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[900],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        category['image']!,
                        fit: BoxFit.cover,
                        headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1A1A1A), Color(0xFF332A1E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha(210),
                              Colors.black.withAlpha(40),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(category['icon'] as IconData, color: AppColors.accent, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              category['name']!,
                              style: AppTextStyles.subheading.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
