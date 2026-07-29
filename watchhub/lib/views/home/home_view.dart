import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/product_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/watch_card.dart';

// Tab imports
import '../categories/categories_view.dart';
import '../wishlist/wishlist_view.dart';
import '../cart/cart_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  final int initialTab;
  const HomeView({super.key, this.initialTab = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Load home data on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().fetchHomeData();
      context.read<HomeController>().changeTab(widget.initialTab);
      // Load products catalog too
      context.read<ProductController>().initializeCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);

    // List of core tab pages
    final List<Widget> tabs = [
      const _HomeTabContent(),
      const CategoriesView(),
      const WishlistView(),
      const CartView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: tabs[homeController.bottomNavIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: homeController.bottomNavIndex,
        onTap: (index) {
          homeController.changeTab(index);
        },
      ),
    );
  }
}

// Actual dashboard widget
class _HomeTabContent extends StatelessWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "WatchHub",
          style: AppTextStyles.heading.copyWith(color: Colors.white, letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.accent),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.searchroute);
            },
          ),
          IconButton(
            icon: const Icon(Icons.explore_outlined, color: AppColors.accent),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.browseproductsroute);
            },
          ),
        ],
      ),
      body: homeController.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                await homeController.fetchHomeData();
                await productController.initializeCatalog();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 16),
                  
                  // Promo Carousel Slider
                  _buildCarousel(homeController),
                  const SizedBox(height: 24),

                  // Brand Slider section
                  _buildBrandSlider(context, homeController),
                  const SizedBox(height: 24),

                  // Featured/Popular list title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Popular Watches", style: AppTextStyles.heading.copyWith(fontSize: 18)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.browseproductsroute);
                          },
                          child: Text(
                            "View All",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid of Popular Watches
                  _buildPopularGrid(homeController),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildCarousel(HomeController controller) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.9,
      ),
      items: controller.carouselImages.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[900],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E1E1E), Color(0xFF3A2E1C)],
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
                            Colors.black.withAlpha(200),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Timeless Style",
                            style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            "For Every Occasion",
                            style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildBrandSlider(BuildContext context, HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Top Brands", style: AppTextStyles.heading.copyWith(fontSize: 18)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: controller.brands.length,
            itemBuilder: (context, index) {
              final brand = controller.brands[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.browseproductsroute,
                    arguments: brand.id,
                  );
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          brand.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.stars, color: AppColors.accent, size: 28),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        brand.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularGrid(HomeController controller) {
    if (controller.allProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            "No featured watches found.",
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    // Display max 6 items on home tab
    final displayItems = controller.allProducts.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final watch = displayItems[index];
          // Find brand name
          final brandMatch = controller.brands.where((b) => b.id == watch.brandId);
          final brandName = brandMatch.isNotEmpty ? brandMatch.first.name : null;

          return WatchCard(watch: watch, brandName: brandName);
        },
      ),
    );
  }
}
