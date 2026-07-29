import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/order_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().fetchUserOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Provider.of<OrderController>(context);
    final orders = orderController.orders;

    // Filter list
    final filteredOrders = _selectedFilter == 'All'
        ? orders
        : orders.where((o) => o.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();

    final filters = ['All', 'Pending', 'Processing', 'Delivered', 'Cancelled'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "My Orders",
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Horizontal list
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = _selectedFilter == filter;

                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders Listing body
          Expanded(
            child: orderController.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text("No orders history found", style: AppTextStyles.subheading),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];

                          // Resolve status color
                          Color statusColor = Colors.orange;
                          if (order.status.toLowerCase() == 'delivered') {
                            statusColor = AppColors.success;
                          } else if (order.status.toLowerCase() == 'cancelled') {
                            statusColor = AppColors.error;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Product Image representation
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: order.productImage != null
                                      ? Image.network(
                                          order.productImage!,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(color: Colors.grey[100], width: 70, height: 70, child: const Icon(Icons.watch)),
                                        )
                                      : Container(
                                          color: Colors.grey[100],
                                          width: 70,
                                          height: 70,
                                          child: const Icon(Icons.watch, color: Colors.grey),
                                        ),
                                ),
                                const SizedBox(width: 16),

                                // Order parameters details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.productName ?? "Luxury Watch Order",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.subheading.copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Order ID: #${order.id}", style: AppTextStyles.body.copyWith(fontSize: 12)),
                                      Text(
                                        "Date: ${order.orderDate.split('T').first}",
                                        style: AppTextStyles.body.copyWith(fontSize: 11),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Rs ${order.totalAmount.toStringAsFixed(0)}",
                                        style: AppTextStyles.price.copyWith(color: AppColors.accent, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),

                                // Status indicator badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
