import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store_model.dart';
import '../../providers/store_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';

/// Store Discovery Screen with GPS-based store finding
class StoreDiscoveryScreen extends StatefulWidget {
  const StoreDiscoveryScreen({super.key});

  @override
  State<StoreDiscoveryScreen> createState() => _StoreDiscoveryScreenState();
}

class _StoreDiscoveryScreenState extends State<StoreDiscoveryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  void _loadStores() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().loadNearbyStores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Find Stores',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                context.read<StoreProvider>().searchStores(value);
              },
            ),
          ),

          // Location Status
          Consumer<StoreProvider>(
            builder: (context, store, child) {
              if (store.locationPermissionDenied) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: AppColors.warning.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_off,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Location access denied. Showing all stores.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => store.refreshLocation(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Enable'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Stores List
          Expanded(
            child: Consumer<StoreProvider>(
              builder: (context, storeProvider, child) {
                if (storeProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Finding nearby stores...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                if (!storeProvider.hasStores) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => storeProvider.loadNearbyStores(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: storeProvider.nearbyStores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final store = storeProvider.nearbyStores[index];
                      return _StoreCard(
                        store: store,
                        onTap: () => _enterStore(store),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Stores Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no stores registered in your area yet.\nBe the first store to join!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadStores,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _enterStore(StoreModel store) {
    final storeProvider = context.read<StoreProvider>();
    final cartProvider = context.read<CartProvider>();

    storeProvider.selectStore(store);
    cartProvider.setStore(store);

    Navigator.pushNamed(context, '/store-home');
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;
  final VoidCallback onTap;

  const _StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Store Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (store.distance > 0) ...[
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          store.formattedDistance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: store.isOpen
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          store.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: store.isOpen
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
