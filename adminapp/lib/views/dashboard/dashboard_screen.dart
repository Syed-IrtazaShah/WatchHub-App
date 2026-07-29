import 'package:adminapp/controllers/dashboard_controller.dart';
import 'package:adminapp/views/dashboard/products/add_product.dart';
import 'package:adminapp/widget/dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch dashboard data
      context.read<DashboardController>().fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, dashboardController, _) {
        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Watches Hub",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          "Luxury Watch Inventory & Sales Overview",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Add New Product Dialog Trigger
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const AddProduct(),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add New Watch"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        // Refresh Button
                        ElevatedButton.icon(
                          onPressed: dashboardController.isLoading
                              ? null
                              : () {
                                  context
                                      .read<DashboardController>()
                                      .fetchDashboardStats();
                                },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Refresh Stats"),
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
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Dashboard Cards Section
                if (dashboardController.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, cardConstraints) {
                      final double width = cardConstraints.maxWidth;
                      if (width < 750) {
                        // Narrow width: Stack cards vertically
                        return Column(
                          children: [
                            DashboardCard(
                              title: "Total Revenue",
                              value: dashboardController.formatCurrency(
                                dashboardController.totalRevenue,
                              ),
                              trend: "From ${dashboardController.completedOrders} completed",
                              icon: Icons.account_balance_wallet_outlined,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            DashboardCard(
                              title: "Total Orders",
                              value: dashboardController.totalOrders.toString(),
                              trend: "${dashboardController.completedOrders} completed",
                              icon: Icons.shopping_cart_outlined,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            DashboardCard(
                              title: "Active Customers",
                              value: dashboardController.totalUsers.toString(),
                              trend: "Total registered",
                              icon: Icons.people_outline,
                              color: Colors.orange,
                            ),
                          ],
                        );
                      } else {
                        // Wide width: Horizontal row of cards
                        return Row(
                          children: [
                            Expanded(
                              child: DashboardCard(
                                title: "Total Revenue",
                                value: dashboardController.formatCurrency(
                                  dashboardController.totalRevenue,
                                ),
                                trend: "From ${dashboardController.completedOrders} completed",
                                icon: Icons.account_balance_wallet_outlined,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: DashboardCard(
                                title: "Total Orders",
                                value: dashboardController.totalOrders.toString(),
                                trend: "${dashboardController.completedOrders} completed",
                                icon: Icons.shopping_cart_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: DashboardCard(
                                title: "Active Customers",
                                value: dashboardController.totalUsers.toString(),
                                trend: "Total registered",
                                icon: Icons.people_outline,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
