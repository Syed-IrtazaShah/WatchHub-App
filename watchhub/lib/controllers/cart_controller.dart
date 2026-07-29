import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/cart_item_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _cartItems = [];
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<CartItemModel> get cartItems => _cartItems;

  CartController() {
    _loadFromStorage();
  }

  // Reads cart list from local storage cache
  Future<void> _loadFromStorage() async {
    try {
      final cartJson = await _secureStorage.read(key: 'cart_items');
      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson) as List<dynamic>;
        _cartItems.clear();
        for (var itemMap in cartList) {
          _cartItems.add(CartItemModel.fromJson(itemMap as Map<String, dynamic>));
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart from storage: $e');
    }
  }

  // Saves current cart items to local storage cache
  Future<void> _saveToStorage() async {
    try {
      final cartJson = json.encode(_cartItems.map((item) => item.toJson()).toList());
      await _secureStorage.write(key: 'cart_items', value: cartJson);
    } catch (e) {
      print('Error saving cart to storage: $e');
    }
  }

  // Adds a watch item to the cart list
  void addToCart(CartItemModel item) {
    final index = _cartItems.indexWhere((e) => e.id == item.id);

    if (index >= 0) {
      if (_cartItems[index].quantity + item.quantity <= _cartItems[index].stock) {
        _cartItems[index].quantity += item.quantity;
      }
    } else {
      if (item.quantity <= item.stock) {
        _cartItems.add(item);
      }
    }
    _saveToStorage();
    notifyListeners();
  }

  // Removes a watch item from the cart list
  void removeItem(int id) {
    _cartItems.removeWhere((item) => item.id == id);
    _saveToStorage();
    notifyListeners();
  }

  // Increases quantity of an item in the cart
  void increaseQty(int id) {
    final index = _cartItems.indexWhere((e) => e.id == id);
    if (index >= 0 && _cartItems[index].quantity < _cartItems[index].stock) {
      _cartItems[index].quantity++;
      _saveToStorage();
      notifyListeners();
    }
  }

  // Decreases quantity of an item in the cart
  void decreaseQty(int id) {
    final index = _cartItems.indexWhere((e) => e.id == id);
    if (index >= 0 && _cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
      _saveToStorage();
      notifyListeners();
    }
  }

  // Empties all items in the cart
  void clearCart() {
    _cartItems.clear();
    _saveToStorage();
    notifyListeners();
  }

  // Calculates the sum of all item quantities in the cart
  int get totalItems =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Calculates the total price of all items in the cart
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);
}
