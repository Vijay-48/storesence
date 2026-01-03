import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

/// Store Provider with real GPS-based store discovery
class StoreProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();

  List<StoreModel> _nearbyStores = [];
  StoreModel? _currentStore;
  Position? _userLocation;
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionDenied = false;

  // Getters
  List<StoreModel> get nearbyStores => _nearbyStores;
  StoreModel? get currentStore => _currentStore;
  Position? get userLocation => _userLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStores => _nearbyStores.isNotEmpty;
  bool get locationPermissionDenied => _locationPermissionDenied;

  StreamSubscription<Position>? _positionStreamSubscription;

  /// Initialize store service and start location stream
  Future<void> init() async {
    await _storeService.init();
    _startLocationStream(); // Start listening to location updates
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _startLocationStream() async {
    // Check permission first
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // Stream location settings
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Update every 100 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null) {
              _userLocation = position;
              _locationPermissionDenied = false;
              // Auto-refresh stores on significant move
              _storeService
                  .getNearbyStores(
                    latitude: position.latitude,
                    longitude: position.longitude,
                  )
                  .then((stores) {
                    _nearbyStores = stores;
                    notifyListeners();
                  });
            }
          },
        );
  }

  /// Get user's current location and load nearby stores
  Future<void> loadNearbyStores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current GPS location
      _userLocation = await _storeService.getCurrentLocation();

      if (_userLocation == null) {
        _locationPermissionDenied = true;
        // Load stores without location filtering
        _nearbyStores = await _storeService.getNearbyStores();

        // Try starting stream later if permission granted now?
        // _startLocationStream();
      } else {
        _locationPermissionDenied = false;
        // Load stores based on GPS
        _nearbyStores = await _storeService.getNearbyStores(
          latitude: _userLocation!.latitude,
          longitude: _userLocation!.longitude,
        );

        // Ensure stream is active
        if (_positionStreamSubscription == null) {
          _startLocationStream();
        }
      }
    } catch (e) {
      _error = e.toString();
      _nearbyStores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search stores by query
  Future<void> searchStores(String query) async {
    if (query.isEmpty) {
      await loadNearbyStores();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _nearbyStores = await _storeService.searchStores(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a store to shop in
  void selectStore(StoreModel store) {
    _currentStore = store;
    notifyListeners();
  }

  /// Exit current store
  void exitStore() {
    _currentStore = null;
    notifyListeners();
  }

  /// Register a new store (Store Manager)
  Future<StoreModel?> registerStore({
    required String name,
    required String address,
    required String category,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use current location for the store
      final position = await _storeService.getCurrentLocation();

      final store = await _storeService.registerStore(
        name: name,
        address: address,
        category: category,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
      );

      // Refresh stores list
      await loadNearbyStores();

      return store;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update carry bag settings
  Future<void> updateCarryBagSettings({
    required bool enabled,
    required double price,
  }) async {
    if (_currentStore == null) return;

    final updatedStore = _currentStore!.copyWith(
      carryBagEnabled: enabled,
      carryBagPrice: price,
    );

    await _storeService.updateStore(updatedStore);
    _currentStore = updatedStore;
    notifyListeners();
  }

  /// Refresh location
  Future<void> refreshLocation() async {
    _userLocation = await _storeService.getCurrentLocation();
    if (_userLocation != null) {
      _locationPermissionDenied = false;
      await loadNearbyStores();
    }
    notifyListeners();
  }
}
