import 'package:adminapp/models/brand_model.dart';
import 'package:adminapp/controllers/brands/add_brand_controller.dart';
import 'package:adminapp/utils/app_colors.dart';
import 'package:adminapp/widget/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditBrandDialog extends StatefulWidget {
  final Brand brand;
  const EditBrandDialog({super.key, required this.brand});

  @override
  State<EditBrandDialog> createState() => _EditBrandDialogState();
}

class _EditBrandDialogState extends State<EditBrandDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AddBrandController>(context, listen: false);
      controller.setEditData(
        widget.brand.id!,
        widget.brand.brandName,
        widget.brand.brandImgUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandController = Provider.of<AddBrandController>(context);

    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Text(
                "Edit Brand",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Image Preview container
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: brandController.selectedImage != null
                                ? Image.network(
                                    brandController.selectedImage!.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image);
                                    },
                                  )
                                : Image.network(
                                    brandController.imageUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image);
                                    },
                                  ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => brandController.pickImage(),
                          icon: const Icon(Icons.image),
                          label: const Text("Change Image"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name Input
                  CustomInput(
                    controller: brandController.nameController,
                    labelText: "Brand Name",
                    errorText: brandController.nameError,
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          brandController.clearForm();
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: brandController.isLoading
                            ? null
                            : () async {
                                if (brandController.validateBrandForm()) {
                                  bool success = await brandController.updateBrand(widget.brand.id!);
                                  if (context.mounted && success) {
                                    Navigator.pop(context, true);
                                  }
                                }
                              },
                        child: brandController.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Update Brand",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
