import 'package:adminapp/views/dashboard/products/add_product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adminapp/controllers/products/view_product_controller.dart';
import 'package:adminapp/utils/app_colors.dart';
import 'package:adminapp/widget/custom_table.dart';
import 'package:adminapp/views/dashboard/products/product_edit_dailog.dart';

class ProductsTableView extends StatefulWidget {
  const ProductsTableView({super.key});

  @override
  State<ProductsTableView> createState() => _ProductsTableViewState();
}

class _ProductsTableViewState extends State<ProductsTableView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch product items list on startup
      Provider.of<ViewProductController>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ViewProductController>(context);

    // Show error message if delete fails
    if (productController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productController.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        productController.errorMessage = '';
      });
    }

    if (productController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Map list of watches to display inside table
    final productsData = productController.products
        .map(
          (product) => {
            'id': product.id,
            'name': product.prodName,
            'image': product.prodImg,
            'brand': product.prodBrandName,
            'price': 'Rs${product.prodPrice.toStringAsFixed(2)}',
            'stock': product.prodStock,
            'product_obj': product,
          },
        )
        .toList();

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ResponsiveTableView(
            title: 'Product Inventory',
            data: productsData,
            headers: const [
              'Image',
              'Name',
              'Brand',
              'Price',
              'Stock',
              'Actions',
            ],
            headerActions: [
              // Add watch button
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddProduct(),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add New Watch"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Refresh button
              ElevatedButton.icon(
                onPressed: () => productController.refreshProducts(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  side: const BorderSide(color: Colors.black12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
            rowBuilder: (context, header, value, item) {
              switch (header) {
                case 'Image':
                  return _buildImage(item['image']);
                case 'Name':
                  return Text(
                    item['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                case 'Brand':
                  return Text(item['brand'] ?? 'N/A');
                case 'Price':
                  return Text(
                    value.toString(),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                case 'Stock':
                  return _buildStock(value);
                case 'Actions':
                  return _buildActions(context, item, productController);
                default:
                  return Text(value.toString());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: (url != null && url.isNotEmpty)
            ? Image.network(url, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 20),
      ),
    );
  }

  Widget _buildStock(dynamic value) {
    final int stock = value is int ? value : 0;
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 8,
          color: stock < 5 ? Colors.red : Colors.green,
        ),
        const SizedBox(width: 5),
        Text("$stock"),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    Map item,
    ViewProductController controller,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => ProductEditDialog(product: item['product_obj']),
            );
            if (result == true && context.mounted) {
              controller.refreshProducts();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Product'),
                content: const Text(
                  'Are you sure you want to delete this watch item?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFef4444),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await controller.deleteProduct(item['id']);
            }
          },
        ),
      ],
    );
  }
}
