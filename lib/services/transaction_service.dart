import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/cart_item_model.dart';

/// Transaction service for handling transactions (Supabase Backed)
class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final _supabase = Supabase.instance.client;

  /// Create a new transaction
  Future<TransactionModel> createTransaction({
    required String storeId,
    required String storeName,
    required List<CartItemModel> items,
    required double subtotal,
    required double tax,
    required double carryBagCharge,
    required double total,
    required PaymentMethod paymentMethod,
    String? userId,
  }) async {
    final user = _supabase.auth.currentUser;
    final buyerId = userId ?? user?.id;

    if (buyerId == null) {
      throw Exception('User must be logged in to create a transaction');
    }

    try {
      // 1. Insert Transaction Record
      final transactionData = {
        'store_id': storeId,
        'user_id': buyerId,
        'subtotal': subtotal,
        'tax': tax,
        'carry_bag_charge': carryBagCharge,
        'total': total,
        'payment_method': paymentMethod.name, // Enum to string
        'status': 'completed',
      };

      final transactionResponse = await _supabase
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();

      final transactionId = transactionResponse['id'];
      final createdAt = DateTime.parse(transactionResponse['created_at']);

      // 2. Insert Transaction Items
      if (items.isNotEmpty) {
        final itemsData = items.map((item) {
          return {
            'transaction_id': transactionId,
            'product_id': item.product.id,
            'product_name': item.product.name,
            'quantity': item.quantity,
            'price_at_purchase': item.product.price,
            'total_price': item.totalPrice,
          };
        }).toList();

        await _supabase.from('transaction_items').insert(itemsData);
      }

      // 3. Return constructed model
      return TransactionModel(
        id: transactionId,
        storeId: storeId,
        storeName:
            storeName, // Note: Not storing storeName in DB to normalize, but keeping in Model for UI
        userId: buyerId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        carryBagCharge: carryBagCharge,
        total: total,
        paymentMethod: paymentMethod,
        status: TransactionStatus.completed,
        receiptQrCode: 'RECEIPT_$transactionId',
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error creating transaction: $e');
      throw Exception('Failed to process transaction: $e');
    }
  }

  /// Get user's purchase history
  Future<List<TransactionModel>> getPurchaseHistory(String? userId) async {
    final uid = userId ?? _supabase.auth.currentUser?.id;
    if (uid == null) return [];

    try {
      // Fetch transactions with store details
      // Note: Relation 'stores' needs to be defined in Supabase or we query separately.
      // Assuming 'store:stores(name)' works if FK exists.
      final response = await _supabase
          .from('transactions')
          .select('*, stores(name)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        // Map store name lookup
        final storeData = json['stores'] as Map<String, dynamic>?;
        final storeName = storeData?['name'] ?? 'Unknown Store';

        return TransactionModel.fromJson({
          ...json,
          'storeName': storeName,
          // We aren't fetching items here for list view to save bandwidth
          // If needed, we can .select('*, items:transaction_items(*)')
        });
      }).toList();
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  /// Get store transactions (for manager)
  Future<List<TransactionModel>> getStoreTransactions(String storeId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return TransactionModel.fromJson({
          ...json,
          // For manager view, store name is their own store, usually context known
          // But let's just pass empty or current store name if needed
          'storeName': 'My Store',
        });
      }).toList();
    } catch (e) {
      print('Error fetching store transactions: $e');
      return [];
    }
  }

  /// Get today's sales total
  Future<double> getTodaySales(String storeId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();

      final response = await _supabase
          .from('transactions')
          .select('total')
          .eq('store_id', storeId)
          .gte('created_at', startOfDay);

      final total = (response as List).fold<double>(
        0.0,
        (sum, item) => sum + (item['total'] as num).toDouble(),
      );

      return total;
    } catch (e) {
      print('Error calculating today sales: $e');
      return 0.0;
    }
  }
}
