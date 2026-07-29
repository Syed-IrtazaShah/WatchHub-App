import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// UserController manages user account listings and retrieves purchase orders for specific users.
class UserController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  
  // Selected user detail dialog variables
  Map<String, dynamic>? selectedUser;
  List<Map<String, dynamic>> userOrders = [];
  bool isLoadingOrders = false;

  // Retrieve user rows from tbl_users table
  Future<void> fetchUsers() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase.from('tbl_users').select();
      users = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("❌ Error fetching users: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Retrieve orders history list for a chosen user
  Future<void> fetchUserOrders(String userId) async {
    try {
      isLoadingOrders = true;
      notifyListeners();

      final ordersResponse = await supabase
          .from('tbl_orders')
          .select('''
            *,
            tbl_products ( prod_name, prod_price )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      userOrders = List<Map<String, dynamic>>.from(ordersResponse);
    } catch (e) {
      debugPrint("❌ Error fetching user orders: $e");
      userOrders = [];
    } finally {
      isLoadingOrders = false;
      notifyListeners();
    }
  }

  // Select user profile to view detail dialog and fetch their associated orders
  Future<void> selectUser(Map<String, dynamic> user) async {
    selectedUser = user;
    userOrders = [];
    notifyListeners();
    
    if (user['user_id'] != null) {
      await fetchUserOrders(user['user_id']);
    }
  }

  // Clear user selection states
  void clearSelection() {
    selectedUser = null;
    userOrders = [];
    notifyListeners();
  }
}
