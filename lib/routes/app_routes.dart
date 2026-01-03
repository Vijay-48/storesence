import 'package:flutter/material.dart';

// Customer Screens
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/role_selection/role_selection_screen.dart';
import '../presentation/store_discovery/store_discovery_screen.dart';
import '../presentation/store_home/store_home_screen.dart';
import '../presentation/barcode_scan_screen/barcode_scan_screen.dart';
import '../presentation/shopping_cart/cart_screen.dart';
import '../presentation/carry_bag_option_screen/carry_bag_option_screen.dart';
import '../presentation/payment/payment_screen.dart';
import '../presentation/payment_success/payment_success_screen.dart';
import '../presentation/purchase_history/purchase_history_screen.dart';
import '../presentation/profile/profile_screen.dart';

// Manager Screens
import '../presentation/manager/dashboard_screen.dart';
import '../presentation/manager/create_store_screen.dart';
import '../presentation/manager/add_product_screen.dart';
import '../presentation/manager/inventory_screen.dart';
import '../presentation/manager/transactions_screen.dart';

class AppRoutes {
  // Entry Flow
  static const String splash = '/';
  static const String auth = '/auth';
  static const String roleSelection = '/role-selection';

  // Customer Flow
  static const String storeDiscovery = '/store-discovery';
  static const String storeHome = '/store-home';
  static const String scan = '/scan';
  static const String cart = '/cart';
  static const String carryBag = '/carry-bag';
  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
  static const String purchaseHistory = '/purchase-history';
  static const String profile = '/profile';

  // Manager Flow
  static const String managerDashboard = '/manager/dashboard';
  static const String managerCreateStore = '/manager/create-store';
  static const String managerAddProduct = '/manager/add-product';
  static const String managerInventory = '/manager/inventory';
  static const String managerTransactions = '/manager/transactions';

  static const String initialRoute = splash;

  static Map<String, WidgetBuilder> get routes => {
    // Entry Flow
    splash: (_) => const SplashScreen(),
    auth: (_) => const AuthenticationScreen(),
    roleSelection: (_) => const RoleSelectionScreen(),

    // Customer Flow
    storeDiscovery: (_) => const StoreDiscoveryScreen(),
    storeHome: (_) => const StoreHomeScreen(),
    scan: (_) => const BarcodeScanScreen(),
    cart: (_) => const CartScreen(),
    carryBag: (_) => const CarryBagOptionScreen(),
    payment: (_) => const PaymentScreen(),
    paymentSuccess: (_) => const PaymentSuccessScreen(),
    purchaseHistory: (_) => const PurchaseHistoryScreen(),
    profile: (_) => const ProfileScreen(),

    // Manager Flow
    managerDashboard: (_) => const ManagerDashboardScreen(),
    managerCreateStore: (_) => const CreateStoreScreen(),
    managerAddProduct: (_) => const AddProductScreen(),
    managerInventory: (_) => const InventoryScreen(),
    managerTransactions: (_) => const TransactionsScreen(),
  };
}
