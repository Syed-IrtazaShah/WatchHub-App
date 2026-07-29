import 'package:adminapp/views/dashboard/brands/view_brand_screen.dart';
import 'package:adminapp/views/dashboard/chats/chat_support_screen.dart';
import 'package:adminapp/views/dashboard/orders/order_table_view.dart';
import 'package:adminapp/views/dashboard/products/product_table_view.dart';
import 'package:adminapp/views/dashboard/reviews/review_table_view.dart';
import 'package:adminapp/views/dashboard/users/users_table_view.dart';
import 'package:adminapp/views/dashboard/dashboard_screen.dart';
import 'package:adminapp/controllers/home_controller.dart';
import 'package:adminapp/utils/app_colors.dart';
import 'package:adminapp/widget/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool isCollapsed = false; // Collapsed sidebar state for desktop

  // View pages mapped to sidebar indexes
  final List<Widget> screens = const [
    DashboardScreen(),
    ProductsTableView(),
    ViewBrandScreen(),
    OrdersTableView(),
    ReviewsTableView(),
    UsersTableView(),
    ChatSupportTableView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Detect mobile or narrow browser width
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: AppColors.bgcolor,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        // Show hamburger button automatically on mobile/narrow screens
        automaticallyImplyLeading: isMobile,
        leading: !isMobile
            ? IconButton(
                tooltip: isCollapsed ? "Expand Sidebar" : "Collapse Sidebar",
                icon: Icon(
                  isCollapsed ? Icons.menu : Icons.menu_open,
                  color: AppColors.secondary,
                ),
                onPressed: () => setState(() => isCollapsed = !isCollapsed),
              )
            : null,
        titleSpacing: isMobile ? 8 : 8,
        title: Row(
          children: [
            const Icon(Icons.watch, color: AppColors.secondary),
            const SizedBox(width: 10),
            Text(
              isMobile ? "Watches Hub" : "Watches Hub Admin",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () {
              // Call the controller's logout function
              Provider.of<HomeController>(context, listen: false).logout(context);
            },
            icon: const Icon(Icons.logout, color: AppColors.secondary),
          ),
          const SizedBox(width: 20),
        ],
      ),

      // ================= DRAWERS (MOBILE ONLY) =================
      drawer: isMobile
          ? Drawer(
              child: Container(
                color: AppColors.primary,
                child: SafeArea(
                  child: _buildSidebarContent(context, isDrawer: true, isCollapsed: false),
                ),
              ),
            )
          : null,

      // ================= BODY =================
      body: isMobile
          ? Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: screens[selectedIndex],
              ),
            )
          : Row(
              children: [
                // Sidebar menu panel (Desktop layout with transition animation)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isCollapsed ? 70 : 250,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 10,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: _buildSidebarContent(context, isDrawer: false, isCollapsed: isCollapsed),
                ),

                // Main view panel showing the selected screen (Desktop layout)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: screens[selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper widget to construct the sidebar content
  Widget _buildSidebarContent(
    BuildContext context, {
    required bool isDrawer,
    required bool isCollapsed,
  }) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCollapsed) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    "MAIN MENU",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 0.5),
              ] else
                const SizedBox(height: 20),

              Sidebar(
                icon: Icons.dashboard_outlined,
                title: "Dashboard",
                isActive: selectedIndex == 0,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 0);
                  if (isDrawer) Navigator.pop(context);
                },
              ),

              // Products Section Header
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    "PRODUCTS",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Sidebar(
                icon: Icons.inventory_2_outlined,
                title: "Products",
                isActive: selectedIndex == 1,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 1);
                  if (isDrawer) Navigator.pop(context);
                },
              ),

              // Brands Section Header
              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    "BRANDS",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Sidebar(
                icon: Icons.label_outline,
                title: "Brands",
                isActive: selectedIndex == 2,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 2);
                  if (isDrawer) Navigator.pop(context);
                },
              ),

              if (!isCollapsed)
                const Divider(color: Colors.white24, thickness: 0.5),

              Sidebar(
                icon: Icons.shopping_cart_outlined,
                title: "Orders",
                isActive: selectedIndex == 3,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 3);
                  if (isDrawer) Navigator.pop(context);
                },
              ),
              Sidebar(
                icon: Icons.rate_review_outlined,
                title: "Reviews",
                isActive: selectedIndex == 4,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 4);
                  if (isDrawer) Navigator.pop(context);
                },
              ),
              Sidebar(
                icon: Icons.group_outlined,
                title: "Manage Users",
                isActive: selectedIndex == 5,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 5);
                  if (isDrawer) Navigator.pop(context);
                },
              ),
              Sidebar(
                icon: Icons.chat_bubble_outline,
                title: "In Chats App",
                isActive: selectedIndex == 6,
                isCollapsed: isCollapsed,
                onTap: () {
                  setState(() => selectedIndex = 6);
                  if (isDrawer) Navigator.pop(context);
                },
              ),

              const Spacer(),

              if (!isCollapsed)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Watches Hub • v1.0.0",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "v1.0",
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
