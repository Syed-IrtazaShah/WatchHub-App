import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch orders for a user
  Future<List<OrderModel>> fetchUserOrders(String userId) async {
    final response = await _supabase
        .from('tbl_orders')
        .select('''
          id,
          created_at,
          prod_id,
          total_item,
          total_amount,
          status,
          address_id,
          user_id,
          tbl_products!tbl_orders_prod_id_fkey(
            prod_name,
            prod_img
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((orderJson) {
      final productData = orderJson['tbl_products'];
      return OrderModel(
        id: orderJson['id'],
        prodId: orderJson['prod_id'],
        totalItem: orderJson['total_item'],
        totalAmount: (orderJson['total_amount'] as num).toDouble(),
        status: orderJson['status'] ?? 'pending',
        addressId: orderJson['address_id'],
        orderDate: orderJson['created_at'],
        productName: productData?['prod_name'],
        productImage: productData?['prod_img'],
      );
    }).toList();
  }

  // Fetch all orders (admin view)
  Future<List<OrderModel>> fetchAllOrders() async {
    final response = await _supabase
        .from('tbl_orders')
        .select('''
          id,
          created_at,
          prod_id,
          total_item,
          total_amount,
          status,
          address_id,
          user_id,
          tbl_products!tbl_orders_prod_id_fkey(
            prod_name,
            prod_img
          )
        ''')
        .order('created_at', ascending: false);

    return (response as List).map((orderJson) {
      final productData = orderJson['tbl_products'];
      return OrderModel(
        id: orderJson['id'],
        prodId: orderJson['prod_id'],
        totalItem: orderJson['total_item'],
        totalAmount: (orderJson['total_amount'] as num).toDouble(),
        status: orderJson['status'] ?? 'pending',
        addressId: orderJson['address_id'],
        orderDate: orderJson['created_at'],
        productName: productData?['prod_name'],
        productImage: productData?['prod_img'],
      );
    }).toList();
  }

  // Place order
  Future<bool> placeOrder({
    required String userId,
    required List<dynamic> orderItems,
    required int addressId,
    required double totalAmount,
  }) async {
    // 1. Validate stock BEFORE any updates
    for (var item in orderItems) {
      int productId = item['id'];
      int orderedQuantity = item['quantity'];

      final response = await _supabase
          .from('tbl_products')
          .select('prod_stock')
          .eq('id', productId)
          .single();

      int currentStock = response['prod_stock'] ?? 0;
      if (currentStock < orderedQuantity) {
        String itemName = item['name'] ?? 'Unknown Product';
        throw Exception('Insufficient stock for $itemName. Available: $currentStock, Requested: $orderedQuantity');
      }
    }

    // 2. Now update stock after validation
    for (var item in orderItems) {
      int productId = item['id'];
      int orderedQuantity = item['quantity'];

      final response = await _supabase
          .from('tbl_products')
          .select('prod_stock')
          .eq('id', productId)
          .single();

      int currentStock = response['prod_stock'] ?? 0;
      int newStock = currentStock - orderedQuantity;

      await _supabase
          .from('tbl_products')
          .update({'prod_stock': newStock})
          .eq('id', productId);
    }

    // 3. Insert order record per cart item to ensure all purchased products are saved
    for (var item in orderItems) {
      int itemProdId = item['id'] ?? 0;
      int itemQty = (item['quantity'] as num?)?.toInt() ?? 1;
      double itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
      double itemTotal = itemPrice * itemQty;

      await _supabase.from('tbl_orders').insert({
        'prod_id': itemProdId,
        'total_item': itemQty,
        'total_amount': itemTotal > 0 ? itemTotal : totalAmount,
        'status': 'pending',
        'address_id': addressId,
        'user_id': userId,
      });
    }

    return true;
  }

  // Fetch user addresses
  Future<List<AddressModel>> fetchUserAddresses(String userId) async {
    final response = await _supabase
        .from('tbl_address')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    return (response as List).map<AddressModel>((e) {
      return AddressModel.fromJson(e as Map<String, dynamic>);
    }).toList();
  }

  // Insert address
  Future<void> insertAddress(String userId, AddressModel address) async {
    await _supabase.from('tbl_address').insert({
      'user_id': userId,
      'address_type': address.type,
      'full_name': address.fullName,
      'phone_number': address.phone,
      'address_details': address.address,
      'city': address.city,
      'zip_code': address.zipCode,
    });
  }

  // Update address
  Future<void> updateAddress(int id, AddressModel address) async {
    await _supabase.from('tbl_address').update({
      'address_type': address.type,
      'full_name': address.fullName,
      'phone_number': address.phone,
      'address_details': address.address,
      'city': address.city,
      'zip_code': address.zipCode,
    }).eq('id', id);
  }

  // Delete address
  Future<void> deleteAddress(int id) async {
    await _supabase.from('tbl_address').delete().eq('id', id);
  }
}
