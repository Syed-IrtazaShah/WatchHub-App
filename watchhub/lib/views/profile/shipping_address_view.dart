import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/order_controller.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'add_edit_address_view.dart';

class ShippingAddressView extends StatefulWidget {
  const ShippingAddressView({super.key});

  @override
  State<ShippingAddressView> createState() => _ShippingAddressViewState();
}

class _ShippingAddressViewState extends State<ShippingAddressView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().fetchUserAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Provider.of<OrderController>(context);
    final addresses = orderController.addresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "My Addresses",
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: orderController.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_rounded, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("No Addresses Registered", style: AppTextStyles.subheading),
                      const SizedBox(height: 6),
                      Text("Add delivery location details", style: AppTextStyles.body),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              addr.type.toLowerCase() == 'home'
                                  ? Icons.home_outlined
                                  : addr.type.toLowerCase() == 'office'
                                      ? Icons.business_outlined
                                      : Icons.location_on_outlined,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(addr.fullName, style: AppTextStyles.subheading.copyWith(fontSize: 15)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        addr.type.toUpperCase(),
                                        style: AppTextStyles.body.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(addr.address, style: AppTextStyles.body),
                                Text("${addr.city}, ZIP ${addr.zipCode}", style: AppTextStyles.body),
                                const SizedBox(height: 4),
                                Text("Phone: ${addr.phone}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                                      label: const Text("Edit", style: TextStyle(color: Colors.blue, fontSize: 13)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AddEditAddressView(address: addr)),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                      label: const Text("Delete", style: TextStyle(color: Colors.red, fontSize: 13)),
                                      onPressed: () {
                                        if (addr.id != null) {
                                          orderController.deleteAddress(addr.id!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: AppColors.accent),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditAddressView()),
          );
        },
      ),
    );
  }
}
