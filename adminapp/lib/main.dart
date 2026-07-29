import 'package:adminapp/controllers/brands/add_brand_controller.dart';
import 'package:adminapp/controllers/brands/view_brand_controller.dart';
import 'package:adminapp/controllers/chats/chat_support_controller.dart';
import 'package:adminapp/controllers/dashboard_controller.dart';
import 'package:adminapp/controllers/orders/order_view_controller.dart';
import 'package:adminapp/controllers/products/add_product_controller.dart';
import 'package:adminapp/controllers/home_controller.dart';
import 'package:adminapp/controllers/auth/login_controller.dart';
import 'package:adminapp/controllers/auth/splash_controller.dart';
import 'package:adminapp/controllers/products/edit_product_controller.dart';
import 'package:adminapp/controllers/products/view_product_controller.dart';
import 'package:adminapp/controllers/reviews/review_controller.dart';
import 'package:adminapp/controllers/users/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adminapp/utils/app_routes.dart';
import 'package:adminapp/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rbzhjylgliiajbqtgoyz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJiemhqeWxnbGlpYWpicXRnb3l6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM2MDc2MjMsImV4cCI6MjA5OTE4MzYyM30.j5eLXhPsN8AAh7KXZZC1SWHpXgD8Pd7dK6j735sK1hQ',
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SplashController()),
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => HomeController()),
        ChangeNotifierProvider(create: (context) => DashboardController()),
        ChangeNotifierProvider(create: (context) => AddProductController()),
        ChangeNotifierProvider(create: (context) => ViewProductController()),
        ChangeNotifierProvider(create: (context) => EditProductController()),
        ChangeNotifierProvider(create: (context) => AddBrandController()),
        ChangeNotifierProvider(create: (context) => ViewBrandController()),
        ChangeNotifierProvider(create: (context) => ReviewController()),
        ChangeNotifierProvider(create: (context) => OrderViewController()),
        ChangeNotifierProvider(create: (context) => UserController()),
        ChangeNotifierProvider(create: (context) => ChatSupportController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Watcheshub Admin',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgcolor,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.bgcolor,
        ),
        fontFamily: GoogleFonts.outfit().fontFamily,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splashRoute,
      routes: AppRoutes.routes,
    );
  }
}
