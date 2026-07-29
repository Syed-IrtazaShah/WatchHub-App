import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_routes.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().initializeUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "My Profile",
          style: AppTextStyles.heading.copyWith(color: Colors.white, letterSpacing: 1.0),
        ),
      ),
      body: profileController.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User Details Profile Section
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.person, size: 56, color: AppColors.accent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profileController.nameController.text.isNotEmpty
                              ? profileController.nameController.text
                              : "Guest User",
                          style: AppTextStyles.subheading.copyWith(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profileController.emailController.text.isNotEmpty
                              ? profileController.emailController.text
                              : "guest@watchhub.com",
                          style: AppTextStyles.body.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Menu list options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.edit_outlined,
                          title: "Edit Personal Details",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditProfileView()),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: "Manage Shipping Addresses",
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.shippingaddressroute);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.history_rounded,
                          title: "My Order History",
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.orderhistoryroute);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.support_agent_outlined,
                          title: "Help & In-App Support",
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.contactSupportRoute);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.feedback_outlined,
                          title: "Submit App Feedback",
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.feedbackreviewroute);
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Logout Action
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                            title: Text(
                              "Logout Session",
                              style: AppTextStyles.subheading.copyWith(color: AppColors.error, fontSize: 15),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.error),
                            onTap: () {
                              authController.logout(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(
          title,
          style: AppTextStyles.subheading.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        onTap: onTap,
      ),
    );
  }
}
