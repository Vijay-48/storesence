import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/transaction_model.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';

/// Cart Provider with real-time functionality and persistence
class CartProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  static const String _cartKey = 'shopping_cart';
  static const double _taxRate = 0.08; // 8% tax

  List<CartItemModel> _items = [];
  StoreModel? _currentStore;
  bool _needsCarryBag = false;
  double _carryBagPrice = 0.50;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isLoading = false;
  TransactionModel? _lastTransaction;

  // Getters
  List<CartItemModel> get items => _items;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get needsCarryBag => _needsCarryBag;
  bool get wantsCarryBag => _needsCarryBag; // Alias
  double get carryBagPrice => _carryBagPrice;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;
  TransactionModel? get lastTransaction => _lastTransaction;
  StoreModel? get currentStore => _currentStore;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * _taxRate;
  double get carryBagCharge => _needsCarryBag ? _carryBagPrice : 0.0;
  double get total => subtotal + tax + carryBagCharge;

  // Formatted getters
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedTax => '\$${tax.toStringAsFixed(2)}';
  String get formattedCarryBag => '\$${carryBagCharge.toStringAsFixed(2)}';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  /// Initialize cart from storage
  Future<void> init() async {
    await _loadCart();
  }

  /// Set current store for shopping
  void setStore(StoreModel store) {
    // Clear cart if changing stores
    if (_currentStore != null && _currentStore!.id != store.id) {
      clearCart();
    }
    _currentStore = store;
    _carryBagPrice = store.carryBagPrice;
    notifyListeners();
  }

  /// Set carry bag price
  void setCarryBagPrice(double price) {
    _carryBagPrice = price;
    notifyListeners();
  }

  /// Add product by barcode scan
  Future<ProductModel?> addProductByBarcode(String barcode) async {
    if (_currentStore == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final product = await _productService.getProductByBarcode(
        _currentStore!.id,
        barcode,
      );

      if (product != null) {
        addToCart(product);
        return product;
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add product to cart
  void addToCart(ProductModel product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      _items.add(CartItemModel(product: product, quantity: 1));
    }

    _saveCart();
    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveCart();
      notifyListeners();
    }
  }

  /// Increment item quantity
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + 1);
      _saveCart();
      notifyListeners();
    }
  }

  /// Decrement item quantity
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final current = _items[index];
      if (current.quantity <= 1) {
        removeFromCart(productId);
      } else {
        _items[index] = current.copyWith(quantity: current.quantity - 1);
        _saveCart();
        notifyListeners();
      }
    }
  }

  /// Remove item from cart
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  /// Remove product (alias)
  void removeProduct(String productId) => removeFromCart(productId);

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    _needsCarryBag = false;
    _saveCart();
    notifyListeners();
  }

  /// Set carry bag preference
  void setCarryBag(bool value) {
    _needsCarryBag = value;
    notifyListeners();
  }

  /// Set needs carry bag (alias)
  void setNeedsCarryBag(bool value) => setCarryBag(value);

  /// Set payment method
  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  /// Checkout - process payment and create transaction
  Future<TransactionModel?> checkout() async {
    if (_items.isEmpty || _currentStore == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final transaction = await _transactionService.createTransaction(
        storeId: _currentStore!.id,
        storeName: _currentStore!.name,
        items: List.from(_items),
        subtotal: subtotal,
        tax: tax,
        carryBagCharge: carryBagCharge,
        total: total,
        paymentMethod: _selectedPaymentMethod,
      );

      // Reduce stock for each product
      for (final item in _items) {
        await _productService.reduceStock(
          _currentStore!.id,
          item.product.id,
          item.quantity,
        );
      }

      _lastTransaction = transaction;
      clearCart();

      return transaction;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load cart from storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final Map<String, dynamic> data = jsonDecode(cartJson);
        final List<dynamic> itemsList = data['items'] ?? [];

        _items = itemsList.map((json) => CartItemModel.fromJson(json)).toList();
        _needsCarryBag = data['needsCarryBag'] ?? false;

        notifyListeners();
      }
    } catch (e) {
      // Cart loading failed, start with empty cart
    }
  }

  /// Save cart to storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'items': _items.map((item) => item.toJson()).toList(),
        'needsCarryBag': _needsCarryBag,
        'storeId': _currentStore?.id,
      };
      await prefs.setString(_cartKey, jsonEncode(data));
    } catch (e) {
      // Cart saving failed silently
    }
  }
}
