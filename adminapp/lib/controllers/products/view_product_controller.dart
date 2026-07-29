import 'package:adminapp/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ViewProductController retrieves the products inventory list and handles row deletion.
class ViewProductController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Product> products = [];
  bool isLoading = false;
  String errorMessage = '';

  // Fetches watch catalogue items including their joined brand information
  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      // Retrieve product list joining tbl_brand details
      final data = await supabase
          .from('tbl_products')
          .select('''
            id, 
            prod_img, 
            prod_name, 
            prod_price, 
            prod_stock, 
            prod_description,
            tbl_brand ( id, brand_name)
          ''')
          .order('created_at', ascending: false);

      // Parse records
      products = (data as List).map((item) {
        final rawItem = Map<String, dynamic>.from(item);
        // Fallback in case brand details are null
        rawItem['tbl_brand'] ??= {
          'id': 0,
          'brand_name': 'No Brand',
        };
        return Product.fromJson(rawItem);
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load products';
      notifyListeners();
    }
  }

  // Deletes a product from the database
  Future<bool> deleteProduct(dynamic productId) async {
    try {
      await supabase.from('tbl_products').delete().eq('id', productId);
      // Remove deleted item from client view
      products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } on PostgrestException catch (e) {
      // Catch foreign key violations (e.g. product already exists inside placed orders)
      if (e.code == '23503') {
        errorMessage = 'Product is already in orders';
      } else {
        errorMessage = 'Failed to delete product';
      }
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong';
      notifyListeners();
      return false;
    }
  }

  // Reloads inventory
  Future<void> refreshProducts() async => fetchProducts();
}
