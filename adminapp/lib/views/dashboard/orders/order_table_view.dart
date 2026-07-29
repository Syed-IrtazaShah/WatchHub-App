import 'package:adminapp/controllers/orders/order_view_controller.dart';
import 'package:adminapp/views/dashboard/orders/order_detail_dailog.dart';
import 'package:adminapp/widget/custom_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersTableView extends StatefulWidget {
  const OrdersTableView({super.key});

  @override
  State<OrdersTableView> createState() => _OrdersTableViewState();
}

class _OrdersTableViewState extends State<OrdersTableView> {
  String filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch orders list on startup
      context.read<OrderViewController>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderController = context.watch<OrderViewController>();

    if (orderController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter local orders list based on status selector
    final filteredOrders = orderController.ordersList.where((order) {
      final status = order['status'].toString().toLowerCase();
      if (filterStatus == 'all') return true;
      if (filterStatus == 'delivered') {
        return status == 'delivered' || status == 'completed';
      }
      return status == filterStatus;
    }).toList();

    // Map fields for rendering table rows
    final ordersData = filteredOrders.map((order) {
      return {
        'id': order['id'],
        'order_id': '#ORD-${order['id']}',
        'product': order['tbl_products']?['prod_name'] ?? 'Unknown',
        'qty': order['total_item'] ?? 0,
        'total': 'Rs ${order['total_amount'] ?? 0}',
        'status': order['status'] ?? 'pending',
        'full_item': order,
      };
    }).toList();

    return Align(
      alignment: AlignmentGeometry.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: ResponsiveTableView(
            title: "Order Inventory",
            data: ordersData,
            headerActions: [
              DropdownButton<String>(
                value: filterStatus,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Orders')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'shipping', child: Text('Shipping')),
                  DropdownMenuItem(value: 'progressing', child: Text('Progressing')),
                  DropdownMenuItem(
                    value: 'delivered',
                    child: Text('Delivered / Completed'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (v) => setState(() => filterStatus = v!),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => orderController.refreshOrders(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  side: const BorderSide(color: Colors.black12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
            headers: const [
              'Order ID',
              'Product',
              'Qty',
              'Total',
              'Status',
              'Actions',
            ],
            rowBuilder: (context, header, value, item) {
              if (header == 'Status') {
                return _buildStatusBadge(value.toString());
              }
              if (header == 'Actions') {
                return _buildActions(context, item);
              }
              return Text(value.toString());
            },
          ),
        ),
      ),
    );
  }

  // STATUS BADGE
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'cancelled':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'delivered':
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ACTIONS BUTTONS
  Widget _buildActions(BuildContext context, Map item) {
    final status = item['status'].toString().toLowerCase();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // View Action
        IconButton(
          icon: const Icon(Icons.visibility, color: Colors.indigo),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<OrderViewController>(),
              child: OrderDetailDailog(order: item['full_item']),
            ),
          ),
        ),

        // Delete Action (only available for cancelled orders)
        if (status == 'cancelled')
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Cancelled Order',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Order'),
                  content: const Text(
                    'This cancelled order will be permanently deleted. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // ignore: use_build_context_synchronously
                await context.read<OrderViewController>().deleteOrder(item['id']);
              }
            },
          ),
      ],
    );
  }
}
