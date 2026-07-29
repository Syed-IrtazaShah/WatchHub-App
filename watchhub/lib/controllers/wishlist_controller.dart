import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/watch_model.dart';
import '../services/product_service.dart';

class WishlistController extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final List<int> _favoriteIds = [];
  final Map<int, WatchModel> _cachedProducts = {};
  bool isLoading = false;

  List<int> get favoriteIds => _favoriteIds;
  int get favoriteCount => _favoriteIds.length;

  WishlistController() {
    _loadFromStorage();
  }

  // Load favorites list from secure storage
  Future<void> _loadFromStorage() async {
    try {
      final favoritesJson = await _secureStorage.read(key: 'favorites');
      if (favoritesJson != null) {
        final favoritesData = json.decode(favoritesJson) as Map<String, dynamic>;
        final ids = (favoritesData['ids'] as List<dynamic>).cast<int>();
        _favoriteIds.clear();
        _favoriteIds.addAll(ids);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites from storage: $e');
    }
  }

  // Save favorites list to secure storage
  Future<void> _saveToStorage() async {
    try {
      final favoritesData = {'ids': _favoriteIds};
      await _secureStorage.write(key: 'favorites', value: json.encode(favoritesData));
    } catch (e) {
      debugPrint('Error saving favorites to storage: $e');
    }
  }

  // Check if a specific watch is marked as favorite
  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  // Return a cached watch model by id
  WatchModel? getProductById(int productId) => _cachedProducts[productId];

  // Toggles the favorite status of a watch item
  Future<void> toggleFavorite(WatchModel watch) async {
    if (_favoriteIds.contains(watch.id)) {
      _favoriteIds.remove(watch.id);
      _cachedProducts.remove(watch.id);
    } else {
      _favoriteIds.add(watch.id);
      _cachedProducts[watch.id] = watch;
    }
    await _saveToStorage();
    notifyListeners();
  }

  // Toggles a favorite status by id and fetches its details automatically
  Future<void> toggleFavoriteById(int productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      _cachedProducts.remove(productId);
      await _saveToStorage();
      notifyListeners();
    } else {
      _favoriteIds.add(productId);
      await _saveToStorage();
      notifyListeners();
      await fetchAndCacheProduct(productId);
    }
  }

  // Fetches a single watch model detail from backend and caches it
  Future<WatchModel?> fetchAndCacheProduct(int productId) async {
    if (_cachedProducts.containsKey(productId)) {
      return _cachedProducts[productId];
    }

    try {
      final products = await _productService.fetchProducts();
      final matches = products.where((p) => p.id == productId);
      if (matches.isNotEmpty) {
        final product = matches.first;
        _cachedProducts[productId] = product;
        notifyListeners();
        return product;
      }
    } catch (e) {
      debugPrint('Error fetching/caching favorite product $productId: $e');
    }
    return null;
  }

  // Prefetches all favorited watches details in background
  Future<void> prefetchAllFavorites() async {
    if (_favoriteIds.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final products = await _productService.fetchProducts();
      for (var id in _favoriteIds) {
        final matches = products.where((p) => p.id == id);
        if (matches.isNotEmpty) {
          _cachedProducts[id] = matches.first;
        }
      }
    } catch (e) {
      debugPrint('Error prefetching favorites: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Clears all wishlist items
  Future<void> clearAllFavorites() async {
    _favoriteIds.clear();
    _cachedProducts.clear();
    await _saveToStorage();
    notifyListeners();
  }
}
