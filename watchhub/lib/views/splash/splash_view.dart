import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool showOnboarding = false;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    
    // Check if session exists
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isLoggedIn = await authController.splashTimer(context);
      
      if (!isLoggedIn) {
        // Wait a brief second to fade in the onboarding options
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              showOnboarding = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Hero Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage("assets/images/rolex.png"),
                fit: BoxFit.cover,
                opacity: 0.55,
              ),
            ),
          ),
          
          // Subtle Dark/Gold Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(50),
                  Colors.black.withAlpha(200),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title / Logo with elegant premium badge
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.watch_rounded, color: AppColors.accent, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              "WatchHub",
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Middle / Bottom Onboarding Text & Buttons
                  AnimatedOpacity(
                    opacity: showOnboarding ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.heading.copyWith(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.25,
                              letterSpacing: 0.5,
                            ),
                            children: const [
                              TextSpan(text: "Timeless "),
                              TextSpan(
                                text: "Elegance\n",
                                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
                              ),
                              TextSpan(text: "On Your Wrist"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Explore our curated selection of luxury, classic, and modern masterpieces designed to match your distinguished lifestyle.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Action Buttons
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.homeroute);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "SHOP NOW",
                              style: AppTextStyles.subheading.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signinRoute);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "LOGIN / SIGN UP",
                            style: AppTextStyles.subheading.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
