import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/watch_card.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  String activeCategory = 'All';
  int? brandIdFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productController = context.read<ProductController>();

      if (productController.allProducts.isEmpty) {
        productController.initializeCatalog();
      }

      // Check if we navigated with a brandId argument
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        brandIdFilter = args;
        productController.clearFilters();
        productController.setFilters(brandId: args);
      } else {
        // If we have an active category set from categories page, use it
        if (productController.filterCategory != null) {
          activeCategory = productController.filterCategory!;
        } else {
          productController.clearFilters();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);

    // Dynamic title based on brand filter
    String title = "Explore Watches";
    if (brandIdFilter != null && productController.allBrands.isNotEmpty) {
      final brandMatch = productController.allBrands.where((b) => b.id == brandIdFilter);
      if (brandMatch.isNotEmpty) {
        title = brandMatch.first.name;
      }
    }

    final categoryTabs = ['All', 'Luxury', 'Smart', 'Sports', 'Classic'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          title,
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: AppColors.accent),
            onPressed: () => _showSortSheet(context, productController),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.accent),
            onPressed: () => _showFilterSheet(context, productController),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  productController.searchProducts(val);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search watch name or model...",
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            productController.searchProducts('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Categories Tabs Bar (Only show if not filtering by brand)
          if (brandIdFilter == null)
            Container(
              height: 48,
              color: Colors.black,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categoryTabs.length,
                itemBuilder: (context, index) {
                  final cat = categoryTabs[index];
                  final isSelected = activeCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeCategory = cat;
                      });
                      if (cat == 'All') {
                        productController.clearFilters();
                      } else {
                        productController.setFilters(category: cat);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // List details
          Expanded(
            child: productController.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : productController.filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text("No watches match your criteria", style: AppTextStyles.subheading),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: productController.filteredProducts.length,
                        itemBuilder: (context, index) {
                          final watch = productController.filteredProducts[index];
                          // Resolve brand name
                          final brandMatch = productController.allBrands.where((b) => b.id == watch.brandId);
                          final brandName = brandMatch.isNotEmpty ? brandMatch.first.name : null;

                          return WatchCard(watch: watch, brandName: brandName);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Bottom sheet to select sorting options
  void _showSortSheet(BuildContext context, ProductController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort By", style: AppTextStyles.heading.copyWith(fontSize: 18)),
              const Divider(height: 24),
              _sortTile(context, controller, "Price: Low to High", SortOption.priceLowToHigh),
              _sortTile(context, controller, "Price: High to Low", SortOption.priceHighToLow),
              _sortTile(context, controller, "Brand Name: A-Z", SortOption.brandAZ),
              _sortTile(context, controller, "Brand Name: Z-A", SortOption.brandZA),
              _sortTile(context, controller, "None", SortOption.none),
            ],
          ),
        );
      },
    );
  }

  Widget _sortTile(BuildContext context, ProductController controller, String label, SortOption opt) {
    final isSelected = controller.currentSort == opt;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.accent : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.accent) : null,
      onTap: () {
        controller.changeSortOption(opt);
        Navigator.pop(context);
      },
    );
  }

  // Filter selection sheet
  void _showFilterSheet(BuildContext context, ProductController controller) {
    String? selectedType = controller.filterType;
    String? selectedGender = controller.filterGender;

    // get highest price from products for slider
    double priceMax = 5000000;
    if (controller.allProducts.isNotEmpty) {
      priceMax = controller.allProducts
          .map((p) => p.price.toDouble())
          .reduce((a, b) => a > b ? a : b);
    }

    double minPrice = controller.filterMinPrice ?? 0.0;
    double maxPrice = controller.filterMaxPrice ?? priceMax;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter Products",
                        style: AppTextStyles.heading.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Reset All",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Colors.black12),
                  const SizedBox(height: 12),
                  
                  // Watch Type Chips Selection
                  if (controller.uniqueTypes.isNotEmpty) ...[
                    Text(
                      "Watch Type",
                      style: AppTextStyles.subheading.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.uniqueTypes.map((t) {
                        final isSelected = selectedType == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: Colors.grey[50],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          elevation: 0,
                          pressElevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.accent : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            setSheetState(() {
                              selectedType = selected ? t : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Target Gender Chips Selection
                  if (controller.uniqueGenders.isNotEmpty) ...[
                    Text(
                      "Gender",
                      style: AppTextStyles.subheading.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.uniqueGenders.map((g) {
                        final isSelected = selectedGender == g;
                        return ChoiceChip(
                          label: Text(g),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: Colors.grey[50],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          elevation: 0,
                          pressElevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.accent : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            setSheetState(() {
                              selectedGender = selected ? g : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Price range dynamic slider selection
                  Text(
                    "Price Range",
                    style: AppTextStyles.subheading.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs ${minPrice.toInt()}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      Text(
                        "Rs ${maxPrice.toInt()}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(minPrice, maxPrice),
                    min: 0.0,
                    max: priceMax,
                    divisions: 20,
                    activeColor: AppColors.accent,
                    inactiveColor: Colors.grey[200],
                    labels: RangeLabels(
                      "Rs ${minPrice.toInt()}",
                      "Rs ${maxPrice.toInt()}",
                    ),
                    onChanged: (RangeValues values) {
                      setSheetState(() {
                        minPrice = values.start;
                        maxPrice = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.setFilters(
                          type: selectedType,
                          gender: selectedGender,
                          minPrice: minPrice,
                          maxPrice: maxPrice,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "APPLY FILTERS",
                        style: AppTextStyles.subheading.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
