import 'package:flutter/material.dart';

// Splash / Auth
import '../views/splash/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';

// Home / Shell
import '../views/home/home_view.dart';

// Products / Lists / Details
import '../views/products/product_list_view.dart';
import '../views/products/product_details_view.dart';
import '../views/products/search_view.dart';

// Checkout / Addresses
import '../views/checkout/checkout_view.dart';
import '../views/profile/shipping_address_view.dart';

// Support / Feedback
import '../views/support/support_view.dart';
import '../views/support/feedback_view.dart';

// Orders
import '../views/orders/order_history_view.dart';

class AppRoutes {
  static const String splashRoute = "/";
  static const String signinRoute = "/signin";
  static const String signupRoute = "/signup";
  
  static const String homeroute = "/home";
  static const String categoriesroute = "/categories";
  static const String favoriteroute = "/favourite";
  static const String cartroute = "/cart";
  static const String profileroute = "/profile";

  static const String productviewallroute = "/productview";
  static const String browseproductsroute = "/browseproducts";
  static const String searchroute = "/search";

  static const String shippingaddressroute = "/shippingaddress";
  static const String checkoutsummaryscreenroute = "/checkoutsummary";
  static const String orderhistoryroute = "/orderhistory";
  static const String contactSupportRoute = "/contactsupport";
  static const String feedbackreviewroute = "/feedbackreview";

  static Map<String, WidgetBuilder> routes = {
    splashRoute: (context) => const SplashView(),
    signinRoute: (context) => const LoginView(),
    signupRoute: (context) => const SignupView(),
    
    // Core shell container mapping tabs
    homeroute: (context) => const HomeView(initialTab: 0),
    categoriesroute: (context) => const HomeView(initialTab: 1),
    favoriteroute: (context) => const HomeView(initialTab: 2),
    cartroute: (context) => const HomeView(initialTab: 3),
    profileroute: (context) => const HomeView(initialTab: 4),

    // Catalogs & Search views
    browseproductsroute: (context) => const ProductListView(),
    searchroute: (context) => const SearchView(),
    productviewallroute: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final int id = args is int ? args : 0;
      return ProductDetailsView(productId: id);
    },

    // Orders, checkout, addresses views
    shippingaddressroute: (context) => const ShippingAddressView(),
    checkoutsummaryscreenroute: (context) => const CheckoutView(),
    orderhistoryroute: (context) => const OrderHistoryView(),

    // Support and app feedbacks views
    contactSupportRoute: (context) => const SupportView(),
    feedbackreviewroute: (context) => const FeedbackView(),
  };
}
