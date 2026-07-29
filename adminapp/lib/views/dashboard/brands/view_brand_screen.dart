import 'package:adminapp/controllers/brands/view_brand_controller.dart';
import 'package:adminapp/views/dashboard/brands/add_brand_screen.dart';
import 'package:adminapp/views/dashboard/brands/edit_brand_dailog.dart';
import 'package:adminapp/widget/custom_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewBrandScreen extends StatefulWidget {
  const ViewBrandScreen({super.key});

  @override
  State<ViewBrandScreen> createState() => _ViewBrandScreenState();
}

class _ViewBrandScreenState extends State<ViewBrandScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch brands list
      Provider.of<ViewBrandController>(context, listen: false).fetchBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brandController = Provider.of<ViewBrandController>(context);

    if (brandController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (brandController.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              brandController.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => brandController.fetchBrands(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Map list of brands to display inside table
    final brandsData = brandController.brands
        .map(
          (brand) => {
            'id': brand.id,
            'name': brand.brandName,
            'image': brand.brandImgUrl,
            'brand_obj': brand,
          },
        )
        .toList();

    return Align(
      alignment: AlignmentGeometry.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ResponsiveTableView(
            title: 'Brands',
            data: brandsData,
            headerActions: [
              Row(
                children: [
                  // Trigger add dialog
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddBrandScreen(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add New Brand"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Trigger reload list
                  ElevatedButton.icon(
                    onPressed: () => brandController.refreshBrands(),
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
              ),
            ],
            headers: const ['Image', 'Name', 'Actions'],
            rowBuilder: (context, header, value, item) {
              if (header == 'Image') {
                final imageUrl = item['image'] ?? '';

                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFe5e7eb)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFf3f4f6),
                                child: const Icon(
                                  Icons.image,
                                  size: 20,
                                  color: Color(0xFF9ca3af),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                  return child;
                              }
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFf3f4f6),
                            child: const Icon(
                              Icons.image,
                              size: 20,
                              color: Color(0xFF9ca3af),
                            ),
                          ),
                  ),
                );
              }

              if (header == 'Name') {
                return Text(
                  item['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                );
              }

              if (header == 'Actions') {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () async {
                        // Trigger edit dialog
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => EditBrandDialog(brand: item['brand_obj']),
                        );
                        if (result == true && context.mounted) {
                          brandController.refreshBrands();
                        }
                      },
                      tooltip: 'Edit',
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      color: const Color(0xFFef4444),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Brand'),
                            content: const Text(
                              'Are you sure you want to delete this brand?',
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

                        if (confirm == true && context.mounted) {
                          final success = await brandController.deleteBrand(
                            item['id'],
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Brand deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  brandController.errorMessage.isEmpty
                                      ? 'Failed to delete brand'
                                      : brandController.errorMessage,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'Delete',
                      splashRadius: 20,
                    ),
                  ],
                );
              }

              return Text(value.toString());
            },
          ),
        ),
      ),
    );
  }
}
