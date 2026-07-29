import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class OrderController extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool isLoading = false;
  String errorMessage = '';

  List<OrderModel> orders = [];
  List<AddressModel> addresses = [];

  // Resolves logged-in user ID, with fallback to saved session email
  Future<String?> _getEffectiveUserId() async {
    final currentId = _supabase.auth.currentUser?.id;
    if (currentId != null && currentId.isNotEmpty) {
      return currentId;
    }
    try {
      final savedEmail = await AuthService().getSavedEmail();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        final res = await _supabase
            .from('tbl_users')
            .select('user_id')
            .eq('email', savedEmail)
            .maybeSingle();
        if (res != null && res['user_id'] != null) {
          return res['user_id'].toString();
        }
      }
    } catch (e) {
      print("Error resolving user id fallback: $e");
    }
    return null;
  }

  // Returns number of total orders
  int get allOrdersCount => orders.length;

  // Returns count of active/pending/processing/shipped orders
  int get runningOrdersCount {
    return orders.where((order) {
      final normalizedStatus = order.status.toLowerCase().trim();
      return normalizedStatus == 'pending' ||
             normalizedStatus == 'confirmed' ||
             normalizedStatus == 'shipped' ||
             normalizedStatus == 'processing' ||
             normalizedStatus == 'in_transit' ||
             normalizedStatus.contains('pend') ||
             normalizedStatus.contains('confir') ||
             normalizedStatus.contains('ship');
    }).length;
  }

  // Fetches orders for the logged-in user
  Future<void> fetchUserOrders() async {
    final userId = await _getEffectiveUserId();
    if (userId == null) {
      orders = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      orders = await _orderService.fetchUserOrders(userId);
    } catch (e) {
      orders = [];
      errorMessage = "Failed to load orders history: $e";
      print("Fetch user orders error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetches all orders (Admin View)
  Future<void> fetchAllOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      orders = await _orderService.fetchAllOrders();
    } catch (e) {
      orders = [];
      errorMessage = "Failed to load admin orders registry";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Places a new checkout order and updates inventories
  Future<bool> placeOrder({
    required List<dynamic> orderItems,
    required int addressId,
    required double totalAmount,
  }) async {
    final userId = await _getEffectiveUserId();
    if (userId == null) {
      errorMessage = "Please log in to place an order";
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final success = await _orderService.placeOrder(
        userId: userId,
        orderItems: orderItems,
        addressId: addressId,
        totalAmount: totalAmount,
      );

      if (success) {
        await fetchUserOrders();
      }
      return success;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      print("Place order error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetches registered delivery addresses for the logged-in user
  Future<List<AddressModel>> fetchUserAddresses() async {
    final userId = await _getEffectiveUserId();
    if (userId == null) {
      addresses = [];
      notifyListeners();
      return [];
    }

    isLoading = true;
    notifyListeners();

    try {
      addresses = await _orderService.fetchUserAddresses(userId);
    } catch (e) {
      addresses = [];
      print("Fetch user addresses error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return addresses;
  }

  // Registers a new delivery address
  Future<bool> insertAddress(AddressModel address) async {
    errorMessage = '';
    final userId = await _getEffectiveUserId();
    if (userId == null) {
      errorMessage = "Please login first to save an address";
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _orderService.insertAddress(userId, address);
      await fetchUserAddresses();
      return true;
    } catch (e) {
      errorMessage = e.toString()
          .replaceFirst("Exception: ", "")
          .replaceFirst("PostgrestException(message: ", "")
          .replaceAll(")", "");
      print("Insert address error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Updates details of a delivery address
  Future<bool> updateAddress(int id, AddressModel address) async {
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    try {
      await _orderService.updateAddress(id, address);
      await fetchUserAddresses();
      return true;
    } catch (e) {
      errorMessage = e.toString()
          .replaceFirst("Exception: ", "")
          .replaceFirst("PostgrestException(message: ", "")
          .replaceAll(")", "");
      print("Update address error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Deletes a delivery address record
  Future<bool> deleteAddress(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _orderService.deleteAddress(id);
      await fetchUserAddresses();
      return true;
    } catch (e) {
      print("Delete address error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
