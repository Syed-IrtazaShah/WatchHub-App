import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/order_controller.dart';
import '../../models/address_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class AddEditAddressView extends StatefulWidget {
  final AddressModel? address;
  const AddEditAddressView({super.key, this.address});

  @override
  State<AddEditAddressView> createState() => _AddEditAddressViewState();
}

class _AddEditAddressViewState extends State<AddEditAddressView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController zipController;
  String selectedType = 'Home';

  @override
  void initState() {
    super.initState();
    selectedType = widget.address?.type ?? 'Home';
    nameController = TextEditingController(text: widget.address?.fullName ?? '');
    phoneController = TextEditingController(text: widget.address?.phone ?? '');
    addressController = TextEditingController(text: widget.address?.address ?? '');
    cityController = TextEditingController(text: widget.address?.city ?? '');
    zipController = TextEditingController(text: widget.address?.zipCode ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Provider.of<OrderController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.address == null ? "Add Address" : "Edit Address",
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Address type toggler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Home', 'Office', 'Other'].map((type) {
                final isSelected = selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade200),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? AppColors.accent : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Form inputs
            _buildField(nameController, "Receiver Full Name", Icons.person_outline),
            const SizedBox(height: 20),
            _buildField(phoneController, "Contact Phone Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildField(addressController, "Street Address Details", Icons.location_on_outlined),
            const SizedBox(height: 20),
            _buildField(cityController, "City Name", Icons.location_city_outlined),
            const SizedBox(height: 20),
            _buildField(zipController, "Postal ZIP Code", Icons.pin_drop_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 40),

            // Save address CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: orderController.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        final addressData = AddressModel(
                          id: widget.address?.id,
                          type: selectedType,
                          fullName: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          address: addressController.text.trim(),
                          city: cityController.text.trim(),
                          zipCode: zipController.text.trim(),
                        );

                        bool success = false;
                        if (widget.address == null) {
                          success = await orderController.insertAddress(addressData);
                        } else {
                          success = await orderController.updateAddress(widget.address!.id!, addressData);
                        }

                        if (success) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(orderController.errorMessage.isNotEmpty
                                  ? orderController.errorMessage
                                  : "Failed to register address"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: orderController.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "SAVE ADDRESS",
                        style: AppTextStyles.subheading.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.trim().isEmpty ? "Required field" : null,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.accent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
