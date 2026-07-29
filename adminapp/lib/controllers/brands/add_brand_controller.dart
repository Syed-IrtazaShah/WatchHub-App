import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AddBrandController manages the fields, validation, picture selection,
// and database uploads when creating or editing a brand.
class AddBrandController extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = false;

  // Controller for brand name input field
  final TextEditingController nameController = TextEditingController();
  
  // Selected image helper variables
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? imageUrl; // Existing image URL if editing

  // Simple validation messages
  String nameError = "";
  String imageError = "";

  // Validates user input fields before submitting
  bool validateBrandForm() {
    bool isValid = true;
    nameError = "";
    imageError = "";

    if (nameController.text.trim().isEmpty) {
      nameError = "Brand Name is required";
      isValid = false;
    }

    if (selectedImage == null && imageUrl == null) {
      imageError = "Brand Image is required";
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  // Opens gallery to pick an image for the brand logo
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = image;
      imageError = "";
      notifyListeners();
    }
  }

  // Inserts a new brand into Supabase tbl_brand table
  Future<bool> addBrand() async {
    try {
      isLoading = true;
      notifyListeners();

      String newImageUrl = '';

      // Upload binary image if selected
      if (selectedImage != null) {
        final fileName = 'brand_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await selectedImage!.readAsBytes();

        await supabase.storage.from('brand_images').uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        newImageUrl = supabase.storage.from('brand_images').getPublicUrl(fileName);
      }

      // Save brand details to DB
      await supabase.from('tbl_brand').insert({
        'brand_name': nameController.text.trim(),
        'brand_img_url': newImageUrl,
      });

      clearForm();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error adding brand: $e');
      return false;
    }
  }

  // Pre-fills controller inputs when starting an edit brand dialog
  void setEditData(int id, String name, String imgUrl) {
    nameController.text = name;
    imageUrl = imgUrl;
    notifyListeners();
  }

  // Updates an existing brand row in Supabase tbl_brand table
  Future<bool> updateBrand(int brandId) async {
    try {
      isLoading = true;
      notifyListeners();

      String newImageUrl = imageUrl ?? '';

      // If a new image was chosen, upload it and retrieve new URL
      if (selectedImage != null) {
        final fileName = 'brand_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await selectedImage!.readAsBytes();

        await supabase.storage.from('brand_images').uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        newImageUrl = supabase.storage.from('brand_images').getPublicUrl(fileName);
      }

      // Send update request
      await supabase.from('tbl_brand').update({
        'brand_name': nameController.text.trim(),
        'brand_img_url': newImageUrl,
      }).eq('id', brandId);

      clearForm();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error updating brand: $e');
      return false;
    }
  }

  // Resets the inputs and error texts
  void clearForm() {
    nameController.clear();
    selectedImage = null;
    imageUrl = null;
    nameError = "";
    imageError = "";
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
