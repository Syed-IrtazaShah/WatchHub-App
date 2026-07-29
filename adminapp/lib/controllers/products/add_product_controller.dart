import 'dart:typed_data';
import 'package:adminapp/models/brand_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AddProductController handles input logic, validations, image uploads,
// and database operations when adding a new watch to the catalog.
class AddProductController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  
  bool isLoading = false;
  bool isFetchingBrands = false;

  // Form input controllers
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
  String proImageerror = "";

  // Chosen image variables
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Brands list for dropdown
  List<Brand> brandList = [];
  Brand? selectedBrand;

  // Retrieve brands from Supabase to show in dropdown
  Future<void> fetchBrands() async {
    try {
      isFetchingBrands = true;
      notifyListeners();
      
      final data = await supabase
          .from('tbl_brand')
          .select('id, brand_name, brand_img_url')
          .order('brand_name', ascending: true);
          
      brandList = (data as List).map((item) => Brand.fromJson(item)).toList();
      isFetchingBrands = false;
      notifyListeners();
    } catch (e) {
      isFetchingBrands = false;
      notifyListeners();
    }
  }

  // Update chosen brand
  void setSelectedBrand(Brand? brand) {
    selectedBrand = brand;
    proBranderror = "";
    notifyListeners();
  }

  // Validates product details form before submission
  bool proValidateform() {
    bool isvalid = true;

    // Reset error strings
    proNameerror = "";
    proBranderror = "";
    proPriceerror = "";
    proStockerror = "";
    proDescriptionerror = "";
    proImageerror = "";

    // 1. Image check
    if (selectedImage == null) {
      proImageerror = "Product image is required";
      isvalid = false;
    }

    // 2. Name check
    final nameRegExp = RegExp(r'^[a-zA-Z0-9\s\-\.\#/]+$');
    if (proNamecontroller.text.trim().isEmpty) {
      proNameerror = "Product Name is required";
      isvalid = false;
    } else if (!nameRegExp.hasMatch(proNamecontroller.text.trim())) {
      proNameerror = "Invalid characters in product name";
      isvalid = false;
    }

    // 3. Brand check
    if (selectedBrand == null) {
      proBranderror = "Please select a brand";
      isvalid = false;
    }

    // 4. Price check
    double? price = double.tryParse(proPricecontroller.text.trim());
    if (proPricecontroller.text.isEmpty) {
      proPriceerror = "Price is required";
      isvalid = false;
    } else if (price == null || price <= 0) {
      proPriceerror = "Price must be greater than 0";
      isvalid = false;
    }

    // 5. Stock check
    int? stock = int.tryParse(proStockcontroller.text.trim());
    if (proStockcontroller.text.isEmpty) {
      proStockerror = "Stock is required";
      isvalid = false;
    } else if (stock == null || stock < 0) {
      proStockerror = "Stock cannot be negative";
      isvalid = false;
    }

    // 6. Description check
    if (proDescriptioncontroller.text.trim().isEmpty) {
      proDescriptionerror = "Description is required";
      isvalid = false;
    }

    notifyListeners();
    return isvalid;
  }

  // Picks product picture from storage
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = image;
      selectedImageBytes = await image.readAsBytes();
      proImageerror = ""; 
      notifyListeners();
    }
  }

  // Uploads image to storage and adds watch details to tbl_products
  Future<bool> addProduct() async {
    try {
      isLoading = true;
      notifyListeners();
      String imageUrl = '';
      
      // Upload image
      if (selectedImage != null) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('product_images').uploadBinary(
              fileName,
              selectedImageBytes!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
        imageUrl = supabase.storage.from('product_images').getPublicUrl(fileName);
      }
      
      // Insert watch row
      await supabase.from('tbl_products').insert({
        'prod_name': proNamecontroller.text.trim(),
        'prod_img': imageUrl,
        'prod_brand': selectedBrand!.id,
        'prod_price': double.tryParse(proPricecontroller.text) ?? 0.0,
        'prod_stock': int.tryParse(proStockcontroller.text) ?? 0,
        'prod_description': proDescriptioncontroller.text.trim(),
      });
      return true;
    } catch (e) {
      debugPrint('Error inserting product: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Resets the inputs
  void clearForm() {
    proNamecontroller.clear();
    proPricecontroller.clear();
    proStockcontroller.clear();
    proDescriptioncontroller.clear();
    selectedImage = null;
    selectedImageBytes = null;
    selectedBrand = null;
    proNameerror = proBranderror = proPriceerror = proStockerror = proDescriptionerror = proImageerror = "";
    notifyListeners();
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
