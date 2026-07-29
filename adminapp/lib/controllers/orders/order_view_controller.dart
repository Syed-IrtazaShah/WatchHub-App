import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// OrderViewController retrieves client orders, manages status changes, and order deletions.
class OrderViewController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = false;
  List<Map<String, dynamic>> ordersList = [];

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  // Retrieve client orders from table, joining related product, address, and profile details
  Future<void> fetchOrders() async {
    try {
      isLoading = true;
      notifyListeners();

      List<Map<String, dynamic>> orders;
      try {
        final response = await supabase.from('tbl_orders').select('''
          *,
          tbl_products ( prod_name, prod_price, prod_img ),
          tbl_address ( full_name, phone_number, address_details, city, zip_code )
        ''').order('created_at', ascending: false);
        orders = List<Map<String, dynamic>>.from(response);
      } catch (joinErr) {
        debugPrint('⚠️ Joined select failed, falling back to direct fetch: $joinErr');
        final response = await supabase.from('tbl_orders').select().order('created_at', ascending: false);
        orders = List<Map<String, dynamic>>.from(response);
      }

      if (orders.isNotEmpty) {
        // Collect product IDs, address IDs, and user IDs for bulk queries
        final prodIds = orders.map((o) => o['prod_id']).where((id) => id != null).toSet().toList();
        final addrIds = orders.map((o) => o['address_id']).where((id) => id != null).toSet().toList();
        final userIds = orders.map((o) => o['user_id']?.toString().trim()).where((id) => id != null && id.isNotEmpty).cast<String>().toSet().toList();

        // 1. Fetch products if missing from joined structure
        Map<dynamic, dynamic> productsMap = {};
        if (prodIds.isNotEmpty) {
          try {
            final pRes = await supabase.from('tbl_products').select('id, prod_name, prod_price, prod_img').inFilter('id', prodIds);
            for (var p in pRes as List) {
              productsMap[p['id']] = p;
            }
          } catch (e) {
            debugPrint("Product bulk fetch error: $e");
          }
        }

        // 2. Fetch addresses if missing from joined structure
        Map<dynamic, dynamic> addressMap = {};
        if (addrIds.isNotEmpty) {
          try {
            final aRes = await supabase.from('tbl_address').select('id, full_name, phone_number, address_details, city, zip_code').inFilter('id', addrIds);
            for (var a in aRes as List) {
              addressMap[a['id']] = a;
            }
          } catch (e) {
            debugPrint("Address bulk fetch error: $e");
          }
        }

        // 3. Fetch user profiles
        Map<String, dynamic> usersMap = {};
        if (userIds.isNotEmpty) {
          try {
            final uRes = await supabase.from('tbl_users').select('user_id, name, email').inFilter('user_id', userIds);
            for (var u in uRes as List) {
              final uId = u['user_id']?.toString().trim();
              if (uId != null && uId.isNotEmpty) {
                usersMap[uId] = u;
              }
            }
          } catch (e) {
            debugPrint("Users bulk fetch error: $e");
          }
        }

        // Merge joined or bulk data structures into order map items
        for (var order in orders) {
          if (order['tbl_products'] == null && order['prod_id'] != null) {
            order['tbl_products'] = productsMap[order['prod_id']];
          }
          if (order['tbl_address'] == null && order['address_id'] != null) {
            order['tbl_address'] = addressMap[order['address_id']];
          }
          final uId = order['user_id']?.toString().trim();
          order['tbl_users'] = uId != null ? usersMap[uId] : null;
        }
      }

      ordersList = orders;
    } catch (e) {
      debugPrint('❌ Fetch Orders Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Updates status value (e.g. pending, completed, cancelled) for an order row
  Future<bool> updateStatus(int orderId, String newStatus) async {
    try {
      isLoading = true;
      notifyListeners();

      await supabase
          .from('tbl_orders')
          .update({'status': newStatus.toLowerCase()})
          .eq('id', orderId);

      // Update cached list item to update UI instantly without full reload
      final index = ordersList.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        ordersList[index]['status'] = newStatus.toLowerCase();
      }

      return true;
    } catch (e) {
      debugPrint('❌ Update Status Error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Deletes an order from list (only allowed if order is marked as 'cancelled')
  Future<bool> deleteOrder(int orderId) async {
    try {
      final order = ordersList.firstWhere((o) => o['id'] == orderId);

      if (order['status'].toString().toLowerCase() != 'cancelled') {
        debugPrint('❌ Cannot delete non-cancelled order');
        return false;
      }

      // Perform deletion
      await supabase.from('tbl_orders').delete().eq('id', orderId);
      ordersList.removeWhere((o) => o['id'] == orderId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Delete Order Error: $e');
      return false;
    }
  }

  // Reloads order list
  Future<void> refreshOrders() => fetchOrders();
}
