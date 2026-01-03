import 'cart_item_model.dart';

/// Transaction model for purchase history
class TransactionModel {
  final String id;
  final String storeId;
  final String storeName;
  final String? userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double carryBagCharge;
  final double total;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? receiptQrCode;

  TransactionModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    this.carryBagCharge = 0.0,
    required this.total,
    required this.paymentMethod,
    this.status = TransactionStatus.completed,
    DateTime? createdAt,
    this.receiptQrCode,
  }) : createdAt = createdAt ?? DateTime.now();

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  String get formattedTax => '\$${tax.toStringAsFixed(2)}';

  String get formattedCarryBag => '\$${carryBagCharge.toStringAsFixed(2)}';

  String get transactionId => 'TXN${id.substring(0, 10).toUpperCase()}';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      storeId: (json['storeId'] ?? json['store_id']) as String,
      storeName: (json['storeName'] ?? json['store_name']) as String,
      userId: (json['userId'] ?? json['user_id']) as String?,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [], // Handle missing items gracefully
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      carryBagCharge:
          (json['carryBagCharge'] ?? json['carry_bag_charge'] as num?)
              ?.toDouble() ??
          0.0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['paymentMethod'] ?? json['payment_method']),
        orElse: () => PaymentMethod.upi,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (json['status']),
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      receiptQrCode:
          (json['receiptQrCode'] ?? json['receipt_qr_code']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'carryBagCharge': carryBagCharge,
      'total': total,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'receiptQrCode': receiptQrCode,
    };
  }
}

enum PaymentMethod { upi, creditCard, debitCard, cash }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI Payment';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.cash:
        return 'Cash at Counter';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.upi:
        return 'GPay, PhonePe, Paytm & more';
      case PaymentMethod.creditCard:
        return 'Visa, Mastercard, Amex';
      case PaymentMethod.debitCard:
        return 'All major banks accepted';
      case PaymentMethod.cash:
        return 'Pay at the exit counter';
    }
  }
}

enum TransactionStatus { pending, completed, failed, refunded }
