// ignore_for_file: deprecated_member_use
import 'package:adminapp/utils/app_colors.dart';
import 'package:adminapp/widget/info_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/controllers/orders/order_view_controller.dart';

class OrderDetailDailog extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailDailog({super.key, required this.order});

  @override
  State<OrderDetailDailog> createState() => _OrderDetailDailogState();
}

class _OrderDetailDailogState extends State<OrderDetailDailog> {
  late String selectedStatus;

  // Database status options mapped to user-facing labels
  final Map<String, String> orderStatusMap = const {
    'pending': 'Pending',
    'progressing': 'Progressing',
    'shipping': 'Shipping',
    'delivered': 'Delivered',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    String currentStatus = widget.order['status']?.toString().toLowerCase() ?? 'pending';
    selectedStatus = currentStatus;
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.order['tbl_users'];
    final address = widget.order['tbl_address'];
    final product = widget.order['tbl_products'];
    final orderController = context.watch<OrderViewController>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Order Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 650,
        child: orderController.isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInfoCard(
                      "Order Summary",
                      Icons.shopping_cart_outlined,
                      [
                        InfoRow(
                          label: "Order ID",
                          value: "#ORD-${widget.order['id']}",
                        ),
                        InfoRow(
                          label: "Product",
                          value: product?['prod_name'] ?? 'N/A',
                        ),
                        InfoRow(
                          label: "Quantity",
                          value: "${widget.order['total_item'] ?? 0}",
                        ),
                        InfoRow(
                          label: "Total Amount",
                          value: "Rs${widget.order['total_amount'] ?? 0}",
                        ),
                      ],
                    ),

                    _buildInfoCard("Customer Details", Icons.person_outline, [
                      InfoRow(label: "Name", value: user?['name'] ?? 'N/A'),
                      InfoRow(label: "Email", value: user?['email'] ?? 'N/A'),
                      InfoRow(
                        label: "Phone",
                        value: address?['phone_number'] ?? 'N/A',
                      ),
                    ]),

                    _buildInfoCard(
                      "Shipping Address",
                      Icons.location_on_outlined,
                      [
                        Text(
                          address?['full_name'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address != null
                              ? "${address['address_details'] ?? ''}, ${address['city'] ?? ''} - ${address['zip_code'] ?? ''}"
                              : "No address available",
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "  Update Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: orderStatusMap.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedStatus = v!),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: orderController.isLoading
                  ? null
                  : () async {
                      final success = await orderController.updateStatus(
                        widget.order['id'],
                        selectedStatus,
                      );
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✅ Order status updated successfully!',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Failed to update status'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              child: orderController.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Update Order",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
