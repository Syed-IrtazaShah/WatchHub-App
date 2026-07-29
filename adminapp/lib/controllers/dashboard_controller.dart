import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DashboardController manages calculations and summaries shown on the homepage dashboard.
class DashboardController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  // Loading indicator for showing spinner
  bool isLoading = false;

  // Summary figures
  int totalUsers = 0;
  int totalOrders = 0;
  int completedOrders = 0;
  double totalRevenue = 0.0;

  // Main function that triggers parallel database requests to load dashboard stats
  Future<void> fetchDashboardStats() async {
    try {
      isLoading = true;
      notifyListeners();

      // Execute both users count and order statistics in parallel to save load time
      await Future.wait([
        _fetchTotalUsers(),
        _fetchOrderStats(),
      ]);
    } catch (e) {
      debugPrint("❌ Error fetching dashboard stats: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Count rows in the users table
  Future<void> _fetchTotalUsers() async {
    try {
      final response = await supabase.from('tbl_users').select('user_id').count();
      totalUsers = response.count;
    } catch (e) {
      debugPrint("❌ Error fetching total users count: $e");
      totalUsers = 0;
    }
  }

  // Retrieve orders and calculate completed counts + sum revenue
  Future<void> _fetchOrderStats() async {
    try {
      // Get all orders count and list data
      final allOrdersResponse = await supabase
          .from('tbl_orders')
          .select('id, status, total_amount')
          .count();

      totalOrders = allOrdersResponse.count;
      final List<dynamic> orders = allOrdersResponse.data as List<dynamic>;

      // Reset statistics
      completedOrders = 0;
      totalRevenue = 0.0;

      // Loop through all orders to compile metrics
      for (var order in orders) {
        final String status = order['status']?.toString().toLowerCase() ?? '';

        // If order is finished, count it and sum revenue
        if (status == 'completed' || status == 'delivered') {
          completedOrders++;
          final double amount = (order['total_amount'] ?? 0).toDouble();
          totalRevenue += amount;
        }
      }
    } catch (e) {
      debugPrint("❌ Error calculating order statistics: $e");
      totalOrders = 0;
      completedOrders = 0;
      totalRevenue = 0.0;
    }
  }

  // Helper method to format cash output neatly (e.g. Rs125.5k instead of Rs125500)
  String formatCurrency(double amount) {
    if (amount >= 100000) {
      return "Rs${(amount / 1000).toStringAsFixed(1)}k";
    }
    return "Rs${amount.toStringAsFixed(0)}";
  }
}
