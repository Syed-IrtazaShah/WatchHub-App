import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Controllers 
import 'controllers/auth_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/support_controller.dart';
import 'controllers/profile_controller.dart';

// Routes & Colors
import 'utils/app_routes.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase client config
  await Supabase.initialize(
    url: 'https://rbzhjylgliiajbqtgoyz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJiemhqeWxnbGlpYWpicXRnb3l6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM2MDc2MjMsImV4cCI6MjA5OTE4MzYyM30.j5eLXhPsN8AAh7KXZZC1SWHpXgD8Pd7dK6j735sK1hQ',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => SupportController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
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
      title: 'WatchHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        hintColor: AppColors.accent,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splashRoute,
      routes: AppRoutes.routes,
    );
  }
}