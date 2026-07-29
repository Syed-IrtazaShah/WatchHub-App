import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/address_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/app_routes.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int _selectedAddressIndex = 0;
  String _paymentMethod = 'COD'; // COD, Card, PayPal
  bool _isOrderPlaced = false;

  // Track order totals for receipt layout
  late double receiptSubtotal;
  late double receiptShipping;
  late double receiptDiscount;
  late double receiptTotal;
  List<dynamic> receiptItems = [];
  AddressModel? receiptAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please login first to place order"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.signinRoute);
        return;
      }
      context.read<OrderController>().fetchUserAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final orderController = Provider.of<OrderController>(context);

    final subtotal = cartController.totalPrice.toDouble();
    const shipping = 500.0;
    final discount = subtotal > 300000 ? 5000.0 : 0.0;
    final total = subtotal > 0 ? (subtotal + shipping - discount) : 0.0;

    final addresses = orderController.addresses;

    if (_isOrderPlaced) {
      return _buildReceiptView(context, cartController);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Checkout Summary",
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: orderController.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 1. Shipping Address Section
                      _buildSectionTitle("Select Delivery Address"),
                      const SizedBox(height: 10),
                      if (addresses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              Text("No delivery addresses found", style: AppTextStyles.body),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.shippingaddressroute);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                                child: Text("Add Address", style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )
                  else ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final addr = addresses[index];
                            final isSelected = _selectedAddressIndex == index;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.accent : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: RadioListTile<int>(
                                activeColor: AppColors.accent,
                                value: index,
                                groupValue: _selectedAddressIndex,
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedAddressIndex = val);
                                },
                                title: Text(addr.fullName, style: AppTextStyles.subheading.copyWith(fontSize: 14)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("${addr.address}, ${addr.city} (${addr.type.toUpperCase()})", style: AppTextStyles.body),
                                    const SizedBox(height: 2),
                                    Text("Phone: ${addr.phone}", style: AppTextStyles.body),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 24),

                      // 2. Payment Method Section
                      _buildSectionTitle("Select Payment Method"),
                      const SizedBox(height: 10),
                      _buildPaymentOption("COD", "Cash On Delivery", Icons.money_rounded),
                      _buildPaymentOption("Card", "Credit / Debit Card", Icons.credit_card_rounded),
                      _buildPaymentOption("PayPal", "PayPal Wallet", Icons.wallet_rounded),

                      const SizedBox(height: 24),

                      // 3. Order Items Summary
                      _buildSectionTitle("Items to Order"),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: cartController.cartItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${item.name} x${item.quantity}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text("Rs ${item.price * item.quantity}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Cart Summary panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal", style: AppTextStyles.body),
                          Text("Rs ${subtotal.toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Shipping Cost", style: AppTextStyles.body),
                          Text("Rs ${shipping.toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Discount (Promo)", style: AppTextStyles.body.copyWith(color: AppColors.success)),
                            Text("-Rs ${discount.toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Gross Total", style: AppTextStyles.subheading.copyWith(fontSize: 18)),
                          Text(
                            "Rs ${total.toStringAsFixed(2)}",
                            style: AppTextStyles.price.copyWith(color: AppColors.accent, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Place Order button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (addresses.isEmpty || cartController.cartItems.isEmpty || _selectedAddressIndex >= addresses.length)
                              ? null
                              : () async {
                                  final selectedAddr = addresses[_selectedAddressIndex];
                                  if (selectedAddr.id == null) return;

                                  // Cache details before placing the order
                                  receiptSubtotal = subtotal;
                                  receiptShipping = shipping;
                                  receiptDiscount = discount;
                                  receiptTotal = total;
                                  receiptItems = cartController.cartItems.map((e) => e.toJson()).toList();
                                  receiptAddress = selectedAddr;

                                  final success = await orderController.placeOrder(
                                    orderItems: cartController.cartItems.map((e) => e.toJson()).toList(),
                                    addressId: selectedAddr.id!,
                                    totalAmount: total,
                                  );

                                  if (success) {
                                    cartController.clearCart();
                                    setState(() {
                                      _isOrderPlaced = true;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(orderController.errorMessage.isNotEmpty
                                            ? orderController.errorMessage
                                            : "Failed to place order"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "PLACE ORDER",
                            style: AppTextStyles.subheading.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(title, style: AppTextStyles.subheading.copyWith(fontSize: 15)),
    );
  }

  Widget _buildPaymentOption(String code, String label, IconData icon) {
    final isSelected = _paymentMethod == code;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.accent : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.accent : AppColors.textSecondary),
        title: Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        trailing: Radio<String>(
          activeColor: AppColors.accent,
          value: code,
          groupValue: _paymentMethod,
          onChanged: (val) {
            if (val != null) setState(() => _paymentMethod = val);
          },
        ),
        onTap: () {
          setState(() => _paymentMethod = code);
        },
      ),
    );
  }

  // Receipt details rendering view
  Widget _buildReceiptView(BuildContext context, CartController cartController) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Order Confirmation",
          style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "Thank You for Shopping!",
                    style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your order has been placed successfully and is currently being processed.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bill receipt summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Invoice Summary", style: AppTextStyles.subheading),
                  const Divider(height: 24),
                  ...receiptItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${item['name']} x${item['quantity']}", style: AppTextStyles.body),
                          Text("Rs ${item['price'] * item['quantity']}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal", style: AppTextStyles.body),
                      Text("Rs ${receiptSubtotal.toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Shipping Cost", style: AppTextStyles.body),
                      Text("Rs ${receiptShipping.toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (receiptDiscount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Discount", style: AppTextStyles.body.copyWith(color: AppColors.success)),
                        Text("-Rs ${receiptDiscount.toStringAsFixed(2)}", style: AppTextStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount Paid", style: AppTextStyles.subheading),
                      Text("Rs ${receiptTotal.toStringAsFixed(2)}", style: AppTextStyles.price.copyWith(color: AppColors.accent)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Billing address
            if (receiptAddress != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Delivery Details", style: AppTextStyles.subheading),
                    const Divider(height: 24),
                    Text(receiptAddress!.fullName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${receiptAddress!.address}, ${receiptAddress!.city}", style: AppTextStyles.body),
                    const SizedBox(height: 2),
                    Text("ZIP: ${receiptAddress!.zipCode}", style: AppTextStyles.body),
                    const SizedBox(height: 2),
                    Text("Phone: ${receiptAddress!.phone}", style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Go to home button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  cartController.clearCart();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeroute, (route) => false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("CONTINUE SHOPPING", style: AppTextStyles.subheading.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
