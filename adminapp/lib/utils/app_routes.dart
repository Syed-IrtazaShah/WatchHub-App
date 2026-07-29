import 'package:adminapp/views/dashboard/products/add_product.dart';
import 'package:adminapp/views/home_screen.dart';
import 'package:adminapp/views/auth/login_screen.dart';
import 'package:adminapp/views/auth/splash_screen.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static const String splashRoute = "/";
  static const String loginRoute = "/login";
  static const String homeRoute = "/home";
  static const String addProductRoute = "/addproduct";

  static Map<String, WidgetBuilder> routes = {
    splashRoute: (context) => const SplashScreen(),
    loginRoute: (context) => const LoginScreen(),
    homeRoute: (context) => const HomeScreen(),
    addProductRoute: (context) => const AddProduct(),
  };
}