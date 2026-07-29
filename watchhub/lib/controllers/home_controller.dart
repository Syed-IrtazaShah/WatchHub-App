import 'package:flutter/material.dart';
import '../models/brand_model.dart';
import '../models/watch_model.dart';
import '../services/product_service.dart';

class HomeController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  int bottomNavIndex = 0;
  bool isLoading = false;
  String errorMessage = '';

  List<BrandModel> brands = [];
  List<WatchModel> allProducts = [];

  // Home slider hero banner image links
  final List<String> carouselImages = [
    "https://watchclubpakistan.pk/cdn/shop/files/SLA055_a.jpg?v=1670256099&width=3840",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfS7GexzseEV3cXdOlpnngCayZj8dPGN8Cd-a0WRquK_yGsdseJGRjjp4&s=10",
    "https://hodinkee.imgix.net/uploads/images/bda387bc-9223-43c8-b9f5-77971f865e34/sports-watches-2023-hodinkee.jpg?ixlib=rails-1.1.0&fm=jpg&q=55&auto=format&usm=12",
    "https://goldammer.me/cdn/shop/collections/vintage-watches.jpg?v=1747812557",
    "https://watchesandcrystals.com/cdn/shop/articles/get-the-latest-fashion-watches-for-men-and-women-424845.jpg?v=1667085325",
    "https://limitedwatches.pk/cdn/shop/files/file_00000000b16c71faaab7ccb0749847bb.png?v=1784054840&width=1500",
  ];

  // Updates the active bottom navigation tab selection index
  void changeTab(int index) {
    bottomNavIndex = index;
    notifyListeners();
  }

  // Loads homepage database requirements (brands and catalog list)
  Future<void> fetchHomeData() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final fetchedBrands = await _productService.fetchBrands();
      final fetchedProducts = await _productService.fetchProducts();

      brands = fetchedBrands;
      allProducts = fetchedProducts;
    } catch (e) {
      errorMessage = "Failed to load watch dashboard details.";
      print("Home data fetch error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
