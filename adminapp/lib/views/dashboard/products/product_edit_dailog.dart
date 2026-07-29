// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:adminapp/models/product_model.dart';
import 'package:adminapp/controllers/products/edit_product_controller.dart';
import 'package:adminapp/widget/custom_input.dart';
import 'package:adminapp/utils/app_colors.dart';

class ProductEditDialog extends StatefulWidget {
  final Product product;
  const ProductEditDialog({super.key, required this.product});

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize controller fields with current product values
      Provider.of<EditProductController>(
        context,
        listen: false,
      ).initializeProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final proController = Provider.of<EditProductController>(context);

    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: SingleChildScrollView(
        child: Container(
          width: 630,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: const Text(
                  "Edit Product",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // IMAGE PREVIEW AND CHOOSE TRIGGER
                    Row(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: proController.selectedImage != null
                                ? (kIsWeb
                                    ? Image.network(
                                        proController.selectedImage!.path,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(proController.selectedImage!.path),
                                        fit: BoxFit.cover,
                                      ))
                                : Image.network(
                                    proController.existingImageUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(Icons.image),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: proController.pickImage,
                          child: const Text("Change Image"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // NAME + BRAND SELECTOR
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            controller: proController.proNamecontroller,
                            labelText: "Product Name",
                            errorText: proController.proNameerror,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: proController.selectedBrand?.brandName,
                            decoration: InputDecoration(
                              labelText: "Select Brand",
                              errorText: proController.proBranderror.isEmpty ? null : proController.proBranderror,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: proController.brandList
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b.brandName,
                                    child: Text(b.brandName),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              final brand = proController.brandList.firstWhere((b) => b.brandName == value);
                              proController.setSelectedBrand(brand);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // PRICE + STOCK INPUTS
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            controller: proController.proPricecontroller,
                            labelText: "Price (PKR)",
                            errorText: proController.proPriceerror,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomInput(
                            controller: proController.proStockcontroller,
                            labelText: "Stock",
                            errorText: proController.proStockerror,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // DESCRIPTION INPUT
                    CustomInput(
                      controller: proController.proDescriptioncontroller,
                      labelText: "Description",
                      maxLines: 3,
                      errorText: proController.proDescriptionerror,
                    ),

                    const SizedBox(height: 30),

                    // CANCEL AND SAVE ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: proController.isLoading
                              ? null
                              : () async {
                                  if (proController.proValidateform()) {
                                    final success = await proController.updateProduct();
                                    if (success && context.mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                },
                          child: proController.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Update Product",
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
      ),
    );
  }
}
