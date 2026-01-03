import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/store_provider.dart';
import '../../theme/app_colors.dart';

class CarryBagOptionScreen extends StatelessWidget {
  const CarryBagOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>().currentStore;
    final cart = context.watch<CartProvider>();

    // Set carry bag price from store
    if (store != null) {
      cart.setCarryBagPrice(store.carryBagPrice);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Bag Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Need a Carry Bag?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Help us reduce plastic waste',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 32),

            // Yes Option
            _BagOptionCard(
              title: 'Yes, I need a bag',
              subtitle: 'Eco-friendly paper bag',
              price: '\$${cart.carryBagPrice.toStringAsFixed(2)}',
              isSelected: cart.needsCarryBag,
              icon: Icons.check_circle,
              onTap: () => cart.setNeedsCarryBag(true),
            ),

            const SizedBox(height: 16),

            // No Option
            _BagOptionCard(
              title: 'No, I have my own',
              subtitle: 'Thanks for being eco-friendly!',
              price: null,
              isSelected: !cart.needsCarryBag,
              icon: Icons.close,
              onTap: () => cart.setNeedsCarryBag(false),
            ),

            const Spacer(),

            // Price Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Items Total',
                    value: '\$${(cart.subtotal + cart.tax).toStringAsFixed(2)}',
                  ),
                  if (cart.needsCarryBag) ...[
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: 'Carry Bag',
                      value: cart.formattedCarryBag,
                    ),
                  ],
                  const Divider(height: 24),
                  _PriceRow(
                    label: 'Total',
                    value: cart.formattedTotal,
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Payment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BagOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? price;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _BagOptionCard({
    required this.title,
    required this.subtitle,
    this.price,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (price != null)
              Text(
                price!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceRow({
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
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
