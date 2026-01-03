import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';

/// Inventory Provider for Store Manager functionality
class InventoryProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  String? _currentStoreId;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  double _todaySales = 0.0;

  // Getters
  List<ProductModel> get products => _products; // Raw list

  // Filtered products based on category
  List<ProductModel> get filteredProducts => _selectedCategory == 'All'
      ? _products
      : _products.where((p) => p.category == _selectedCategory).toList();

  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentStoreId => _currentStoreId;

  // Stats getters
  int get productCount => _products.length;
  int get totalProducts => _products.length; // Alias
  int get lowStockCount => _products.where((p) => p.stockQuantity <= 10).length;
  double get todaySales => _todaySales;

  /// Set current store for inventory management
  void setStore(String storeId) {
    _currentStoreId = storeId;
    loadProducts();
  }

  /// Load products for current store (or specified store)
  Future<void> loadProducts([String? storeId]) async {
    final targetStoreId = storeId ?? _currentStoreId;
    if (targetStoreId == null) return;

    // Update current store if different
    if (storeId != null) _currentStoreId = storeId;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProductsByStore(targetStoreId);
      _categories = await _productService.getCategories(targetStoreId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load dashboard data including sales and stats
  Future<void> loadDashboardData(String storeId) async {
    _currentStoreId = storeId;
    _isLoading = true;
    notifyListeners();

    try {
      await loadProducts(storeId);

      // Fetch sales data from TransactionService
      final transactionService = TransactionService();
      _todaySales = await transactionService.getTodaySales(storeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Add a new product
  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.addProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a product
  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.updateProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    if (_currentStoreId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _productService.deleteProduct(_currentStoreId!, productId);
      await loadProducts();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    if (_currentStoreId == null) return null;
    return await _productService.getProductByBarcode(_currentStoreId!, barcode);
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    if (_currentStoreId == null) return [];
    return await _productService.searchProducts(_currentStoreId!, query);
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    if (_currentStoreId == null) return [];
    return await _productService.getLowStockProducts(_currentStoreId!);
  }
}
