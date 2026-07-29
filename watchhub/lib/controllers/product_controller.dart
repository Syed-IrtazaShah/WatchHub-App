import 'package:flutter/material.dart';
import '../models/watch_model.dart';
import '../models/brand_model.dart';
import '../models/review_model.dart';
import '../services/product_service.dart';

enum SortOption { none, priceLowToHigh, priceHighToLow, brandAZ, brandZA }

class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  bool isLoading = false;
  String errorMessage = '';

  List<WatchModel> allProducts = [];
  List<WatchModel> filteredProducts = [];
  List<BrandModel> allBrands = [];
  
  // Brand-wise products list
  List<WatchModel> brandProducts = [];

  // Active details model
  WatchModel? selectedProduct;

  // Active reviews by product map
  final Map<int, List<ReviewModel>> reviewsMap = {};
  final Map<String, bool> userHelpfulVotes = {};

  // Filters state variables
  SortOption currentSort = SortOption.none;
  int? filterBrandId;
  String? filterType;
  String? filterCategory;
  String? filterColor;
  String? filterMaterial;
  String? filterGender;
  double? filterMinPrice;
  double? filterMaxPrice;

  // Unique attribute filters extracted from database items
  List<String> uniqueTypes = [];
  List<String> uniqueCategories = [];
  List<String> uniqueColors = [];
  List<String> uniqueMaterials = [];
  List<String> uniqueGenders = [];

  // Initialized products catalog, brand parameters, and extracts filter options
  Future<void> initializeCatalog() async {
    isLoading = true;
    notifyListeners();

    try {
      allProducts = await _productService.fetchProducts();
      allBrands = await _productService.fetchBrands();
      filteredProducts = [...allProducts];
      _extractUniqueAttributes();
    } catch (e) {
      errorMessage = "Failed to load watch catalog";
      print("Initialize catalog error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Extracts distinct attributes from catalog to construct filter menus
  void _extractUniqueAttributes() {
    uniqueTypes = allProducts
        .where((p) => p.type != null && p.type!.trim().isNotEmpty)
        .map((p) => p.type!.trim())
        .toSet()
        .toList();

    uniqueCategories = allProducts
        .where((p) => p.category != null && p.category!.trim().isNotEmpty)
        .map((p) => p.category!.trim())
        .toSet()
        .toList();

    uniqueColors = allProducts
        .where((p) => p.color != null && p.color!.trim().isNotEmpty)
        .map((p) => p.color!.trim())
        .toSet()
        .toList();

    uniqueMaterials = allProducts
        .where((p) => p.material != null && p.material!.trim().isNotEmpty)
        .map((p) => p.material!.trim())
        .toSet()
        .toList();

    uniqueGenders = allProducts
        .where((p) => p.gender != null && p.gender!.trim().isNotEmpty)
        .map((p) => p.gender!.trim())
        .toSet()
        .toList();
  }

  // Loads products filtered by brand
  Future<void> fetchBrandProducts(int brandId) async {
    isLoading = true;
    notifyListeners();
    try {
      brandProducts = await _productService.fetchBrandProducts(brandId);
    } catch (e) {
      brandProducts = [];
      errorMessage = "Failed to load brand products";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetches a single watch details entry
  Future<void> fetchProductDetail(int productId) async {
    isLoading = true;
    notifyListeners();
    try {
      final matches = allProducts.where((p) => p.id == productId);
      if (matches.isNotEmpty) {
        selectedProduct = matches.first;
      } else {
        final products = await _productService.fetchProducts();
        allProducts = products;
        final match = allProducts.where((p) => p.id == productId);
        selectedProduct = match.isNotEmpty ? match.first : null;
      }
    } catch (e) {
      selectedProduct = null;
      errorMessage = "Failed to load watch details";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Searches products by keyword matching name, category, or description
  void searchProducts(String query) {
    if (query.trim().isEmpty) {
      filteredProducts = [...allProducts];
    } else {
      final q = query.toLowerCase();
      filteredProducts = allProducts.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            (p.category?.toLowerCase().contains(q) ?? false) ||
            (p.type?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    _applySorting();
    notifyListeners();
  }

  // Configures filter requirements and rebuilds the filtered list
  void setFilters({
    int? brandId,
    String? type,
    String? category,
    String? color,
    String? material,
    String? gender,
    double? minPrice,
    double? maxPrice,
  }) {
    filterBrandId = brandId;
    filterType = type;
    filterCategory = category;
    filterColor = color;
    filterMaterial = material;
    filterGender = gender;
    filterMinPrice = minPrice;
    filterMaxPrice = maxPrice;

    applyFiltersAndSorting();
  }

  // Reset all active filters
  void clearFilters() {
    filterBrandId = null;
    filterType = null;
    filterCategory = null;
    filterColor = null;
    filterMaterial = null;
    filterGender = null;
    filterMinPrice = null;
    filterMaxPrice = null;
    currentSort = SortOption.none;
    filteredProducts = [...allProducts];
    notifyListeners();
  }

  // Applies active filters and sort settings to the catalog
  void applyFiltersAndSorting() {
    filteredProducts = allProducts.where((product) {
      if (filterBrandId != null && product.brandId != filterBrandId) return false;
      if (filterType != null && product.type != filterType) return false;
      if (filterCategory != null) {
        if (product.category == null) return false;
        final c1 = product.category!.trim().toLowerCase();
        final c2 = filterCategory!.trim().toLowerCase();
        final match = c1 == c2 ||
            (c1.startsWith('sport') && c2.startsWith('sport')) ||
            (c1.startsWith('smart') && c2.startsWith('smart')) ||
            (c1.startsWith('classic') && c2.startsWith('classic')) ||
            (c1.startsWith('luxury') && c2.startsWith('luxury'));
        if (!match) return false;
      }
      if (filterColor != null && product.color != filterColor) return false;
      if (filterMaterial != null && product.material != filterMaterial) return false;
      if (filterGender != null && product.gender != filterGender) return false;
      if (filterMinPrice != null && product.price < filterMinPrice!) return false;
      if (filterMaxPrice != null && product.price > filterMaxPrice!) return false;
      return true;
    }).toList();

    _applySorting();
    notifyListeners();
  }

  // Set sorting option
  void changeSortOption(SortOption option) {
    currentSort = option;
    _applySorting();
    notifyListeners();
  }

  // Sorts the current filtered items list
  void _applySorting() {
    switch (currentSort) {
      case SortOption.priceLowToHigh:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.brandAZ:
        filteredProducts.sort((a, b) {
          final bNameA = _getBrandName(a.brandId);
          final bNameB = _getBrandName(b.brandId);
          return bNameA.compareTo(bNameB);
        });
        break;
      case SortOption.brandZA:
        filteredProducts.sort((a, b) {
          final bNameA = _getBrandName(a.brandId);
          final bNameB = _getBrandName(b.brandId);
          return bNameB.compareTo(bNameA);
        });
        break;
      default:
        break;
    }
  }

  // Private helper to resolve brand name from its ID
  String _getBrandName(int? id) {
    if (id == null) return '';
    final match = allBrands.where((b) => b.id == id);
    return match.isNotEmpty ? match.first.name : '';
  }

  // Loads reviews list for a specific watch product
  Future<void> fetchReviews(int productId) async {
    try {
      final reviews = await _productService.fetchReviews(productId);
      reviewsMap[productId] = reviews;
      notifyListeners();
    } catch (e) {
      print("Fetch reviews error: $e");
    }
  }

  // Checks if the user has purchased the item in order to allow review submissions
  Future<bool> verifyUserPurchase(String userId, int productId) async {
    try {
      return await _productService.hasUserPurchasedProduct(userId, productId);
    } catch (e) {
      return false;
    }
  }

  // Submits a new watch review to the database
  Future<bool> addReview({
    required int productId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    bool isVerified = false,
  }) async {
    try {
      errorMessage = '';
      final review = await _productService.submitReview(
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        isVerifiedPurchase: isVerified,
      );

      if (!reviewsMap.containsKey(productId)) {
        reviewsMap[productId] = [];
      }
      reviewsMap[productId]!.add(review);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      print("Add review error: $e");
      notifyListeners();
      return false;
    }
  }

  // Increments review helpful count or toggles user helpful state
  Future<void> toggleHelpfulVote(int reviewId, String userId, int productId) async {
    final voteKey = "${userId}_$reviewId";
    final isVoted = userHelpfulVotes[voteKey] ?? false;

    final reviews = reviewsMap[productId] ?? [];
    final match = reviews.where((r) => r.id == reviewId);
    if (match.isEmpty) return;

    final review = match.first;
    int newCount = review.helpfulCount;

    if (isVoted) {
      userHelpfulVotes.remove(voteKey);
      newCount = (newCount - 1).clamp(0, 99999);
    } else {
      userHelpfulVotes[voteKey] = true;
      newCount += 1;
    }

    // Optimistic update
    final index = reviews.indexOf(review);
    reviews[index] = review.copyWith(helpfulCount: newCount);
    notifyListeners();

    try {
      await _productService.updateReviewHelpfulness(reviewId, newCount);
    } catch (e) {
      // Revert if API call fails
      reviews[index] = review;
      userHelpfulVotes[voteKey] = isVoted;
      notifyListeners();
    }
  }
}
