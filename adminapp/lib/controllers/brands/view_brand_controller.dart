import 'package:adminapp/models/brand_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ViewBrandController retrieves the list of brands and handles deletion requests.
class ViewBrandController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Brand> brands = [];
  bool isLoading = false;
  String errorMessage = '';

  // Fetches brand rows sorted alphabetically
  Future<void> fetchBrands() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final data = await supabase
          .from('tbl_brand')
          .select('id, brand_name, brand_img_url')
          .order('brand_name', ascending: true);

      // Map dynamic lists into typed list
      brands = (data as List).map((item) => Brand.fromJson(item)).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load brands';
      notifyListeners();
      debugPrint('Error fetching brands: $e');
    }
  }

  // Deletes a brand after validating that it is not attached to any watches
  Future<bool> deleteBrand(int brandId) async {
    try {
      // 1. Verify if the brand is currently selected by any product catalog item
      final productCheck = await supabase
          .from('tbl_products')
          .select('id')
          .eq('prod_brand', brandId)
          .limit(1);

      // If matches are found, reject deletion to prevent database foreign key constraint errors
      if (productCheck.isNotEmpty) {
        errorMessage = 'Cannot delete brand. It is being used by products.';
        notifyListeners();
        return false;
      }

      // 2. Perform deletion in database
      await supabase.from('tbl_brand').delete().eq('id', brandId);

      // Remove item locally from cached list and update screen
      brands.removeWhere((brand) => brand.id == brandId);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error deleting brand: $e');
      errorMessage = 'Failed to delete brand';
      notifyListeners();
      return false;
    }
  }

  // Reloads brand list
  Future<void> refreshBrands() async {
    await fetchBrands();
  }
}
