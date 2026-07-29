import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:adminapp/models/product_model.dart';
import 'package:adminapp/models/brand_model.dart';

// EditProductController manages existing product modifications, handles details
// pre-loading, form inputs, validation checks, and updates table records.
class EditProductController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = false;
  int? currentProductId;
  String? existingImageUrl;

  // Controllers for input forms
  final TextEditingController proNamecontroller = TextEditingController();
  final TextEditingController proPricecontroller = TextEditingController();
  final TextEditingController proStockcontroller = TextEditingController();
  final TextEditingController proDescriptioncontroller = TextEditingController();

  // Field validation error texts
  String proNameerror = "";
  String proBranderror = "";
  String proPriceerror = "";
  String proStockerror = "";
  String proDescriptionerror = "";

  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();

  List<Brand> brandList = [];
  Brand? selectedBrand;

  // Initialize fields with current watch details
  Future<void> initializeProduct(Product product) async {
    currentProductId = product.id;
    existingImageUrl = product.prodImg;

    proNamecontroller.text = product.prodName;
    proPricecontroller.text = product.prodPrice.toString();
    proStockcontroller.text = product.prodStock.toString();
    proDescriptioncontroller.text = product.prodDescription;

    await fetchBrands();
    
    // Select the watch brand from list or fallback to the first
    selectedBrand = brandList.firstWhere(
      (b) => b.id == product.prodBrandId,
      orElse: () => brandList.first,
    );

    _clearErrors();
    notifyListeners();
  }

  // Retrieve brands list
  Future<void> fetchBrands() async {
    final data = await supabase
        .from('tbl_brand')
        .select()
        .order('brand_name');

    brandList = (data as List).map((e) => Brand.fromJson(e)).toList();
  }

  // Update selected brand value
  void setSelectedBrand(Brand brand) {
    selectedBrand = brand;
    proBranderror = "";
    notifyListeners();
  }

  // Form input validation logic
  bool proValidateform() {
    bool valid = true;
    _clearErrors();

    if (proNamecontroller.text.trim().isEmpty) {
      proNameerror = "Product name required";
      valid = false;
    }

    if (selectedBrand == null) {
      proBranderror = "Select brand";
      valid = false;
    }

    final price = double.tryParse(proPricecontroller.text.trim());
    if (price == null || price <= 0) {
      proPriceerror = "Enter valid price";
      valid = false;
    }

    final stock = int.tryParse(proStockcontroller.text.trim());
    if (stock == null || stock < 0) {
      proStockerror = "Enter valid stock";
      valid = false;
    }

    if (proDescriptioncontroller.text.trim().isEmpty) {
      proDescriptionerror = "Description required";
      valid = false;
    }

    notifyListeners();
    return valid;
  }

  void _clearErrors() {
    proNameerror = "";
    proBranderror = "";
    proPriceerror = "";
    proStockerror = "";
    proDescriptionerror = "";
  }

  // Opens gallery to choose a replacement watch image
  Future<void> pickImage() async {
    selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  // Save changes to database
  Future<bool> updateProduct() async {
    try {
      isLoading = true;
      notifyListeners();

      String imageUrl = existingImageUrl ?? '';

      // Upload image if newly selected
      if (selectedImage != null) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await selectedImage!.readAsBytes();

        await supabase.storage
            .from('product_images')
            .uploadBinary(fileName, bytes);

        imageUrl = supabase.storage
            .from('product_images')
            .getPublicUrl(fileName);
      }

      // Perform update query
      await supabase.from('tbl_products').update({
        'prod_name': proNamecontroller.text.trim(),
        'prod_img': imageUrl,
        'prod_brand': selectedBrand!.id,
        'prod_price': double.parse(proPricecontroller.text),
        'prod_stock': int.parse(proStockcontroller.text),
        'prod_description': proDescriptioncontroller.text.trim(),
      }).eq('id', currentProductId!);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    proNamecontroller.dispose();
    proPricecontroller.dispose();
    proStockcontroller.dispose();
    proDescriptioncontroller.dispose();
    super.dispose();
  }
}
