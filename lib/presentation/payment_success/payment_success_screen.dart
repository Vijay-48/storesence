import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_colors.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final transaction = cart.lastTransaction;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 56, color: Colors.white),
              ),

              const SizedBox(height: 24),

              // Success Title
              const Text(
                'Payment\nSuccessful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Thank you for shopping with us',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 32),

              // Transaction Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Transaction ID',
                      value: transaction?.transactionId ?? 'TXN123456789',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Date & Time',
                      value: transaction != null
                          ? DateFormat(
                              'MMM dd, yyyy hh:mm a',
                            ).format(transaction.createdAt)
                          : DateFormat(
                              'MMM dd, yyyy hh:mm a',
                            ).format(DateTime.now()),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Payment Method',
                      value: transaction?.paymentMethod.displayName ?? 'UPI',
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      label: 'Total Paid',
                      value: transaction?.formattedTotal ?? '\$18.25',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // QR Code for Exit Verification
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data:
                          transaction?.receiptQrCode ??
                          'RECEIPT_${DateTime.now().millisecondsSinceEpoch}',
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Show this at exit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/store-discovery',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
