// ignore_for_file: deprecated_member_use
import 'package:adminapp/models/brand_model.dart';
import 'package:adminapp/controllers/products/add_product_controller.dart';
import 'package:adminapp/widget/custom_input.dart';
import 'package:adminapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch brands dropdown data
      Provider.of<AddProductController>(context, listen: false).fetchBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proController = Provider.of<AddProductController>(context);

    return AlertDialog(
      backgroundColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 630,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add New Product",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              // Form fields body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Image",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: proController.pickImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: proController.proImageerror.isEmpty
                                      ? Colors.grey.shade300
                                      : Colors.red,
                                ),
                              ),
                              child: proController.selectedImageBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        proController.selectedImageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Colors.grey,
                                          size: 35,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Tap to upload",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (proController.proImageerror.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          proController.proImageerror,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            controller: proController.proNamecontroller,
                            labelText: "Product Name",
                            errorText: proController.proNameerror,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: DropdownButtonFormField<Brand>(
                            value: proController.selectedBrand,
                            decoration: InputDecoration(
                              labelText: "Brand",
                              errorText: proController.proBranderror.isEmpty
                                  ? null
                                  : proController.proBranderror,

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.secondary, // Golden
                                  width: 1.5,
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.secondary, // Golden when focused
                                  width: 2,
                                ),
                              ),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: proController.brandList
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b,
                                    child: Text(b.brandName),
                                  ),
                                )
                                .toList(),
                            onChanged: proController.setSelectedBrand,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            controller: proController.proPricecontroller,
                            labelText: "Price (Rs)",
                            errorText: proController.proPriceerror,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
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

                    const SizedBox(height: 20),

                    CustomInput(
                      controller: proController.proDescriptioncontroller,
                      labelText: "Description",
                      maxLines: 3,
                      errorText: proController.proDescriptionerror,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        onPressed: proController.isLoading
                            ? null
                            : () async {
                                if (proController.proValidateform()) {
                                  final success = await proController.addProduct();
                                  if (success && context.mounted) {
                                    proController.clearForm();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Product Added Successfully"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: proController.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "ADD PRODUCT",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
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
