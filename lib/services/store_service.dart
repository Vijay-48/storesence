import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store_model.dart';

/// Store Service with GPS-based store discovery (Supabase Backed)
class StoreService {
  static final StoreService _instance = StoreService._internal();
  factory StoreService() => _instance;
  StoreService._internal();

  final _supabase = Supabase.instance.client;
  List<StoreModel> _cachedStores = [];

  /// Initialize and load stored data (Cache warming)
  Future<void> init() async {
    // Initial load optional, can rely on on-demand fetching
    try {
      await _fetchStores();
    } catch (e) {
      print('Error initializing stores: $e');
    }
  }

  /// Get user's current GPS location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Get nearby stores based on GPS location
  /// Returns stores within specified radius (in meters)
  Future<List<StoreModel>> getNearbyStores({
    double? latitude,
    double? longitude,
    double radiusMeters = 50000, // 50km default for testing
  }) async {
    // Ideally we use PostGIS in Supabase, but for now we fetch all/subset and filter on client
    // or use a simple bounding box if needed.
    // Fetching all "open" stores for prototype scale is acceptable.
    await _fetchStores();

    if (latitude == null || longitude == null) {
      return _cachedStores;
    }

    // Calculate distance and filter
    final nearbyStores = <StoreModel>[];

    for (final store in _cachedStores) {
      // Skip invalid coordinates
      if (store.latitude == 0 && store.longitude == 0) continue;

      final distanceMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        store.latitude,
        store.longitude,
      );

      if (distanceMeters <= radiusMeters) {
        nearbyStores.add(
          store.copyWith(
            distance: distanceMeters / 1000, // Convert to km
          ),
        );
      }
    }

    // Sort by distance
    nearbyStores.sort((a, b) => a.distance.compareTo(b.distance));

    return nearbyStores;
  }

  /// Search stores by name
  Future<List<StoreModel>> searchStores(String query) async {
    // Use Supabase text search or client-side filter
    if (query.isEmpty) return _cachedStores;

    try {
      final response = await _supabase
          .from('stores')
          .select()
          .ilike('name', '%$query%')
          .eq('is_open', true);

      return (response as List)
          .map((json) => StoreModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Search error: $e');
      // Fallback to cache search
      final lowerQuery = query.toLowerCase();
      return _cachedStores.where((store) {
        return store.name.toLowerCase().contains(lowerQuery) ||
            (store.category?.toLowerCase().contains(lowerQuery) ?? false) ||
            store.address.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  /// Register a new store (Store Manager function)
  Future<StoreModel> registerStore({
    required String name,
    required String address,
    required String category,
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User must be logged in');

    try {
      final response = await _supabase
          .from('stores')
          .insert({
            'manager_id': user.id,
            'name': name,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'is_open': true,
            // category, carryBagPrice etc can be added to DB schema if needed later,
            // for now generic schema uses basic fields.
          })
          .select()
          .single();

      final newStore = StoreModel.fromJson(response);
      _cachedStores.add(newStore);
      return newStore;
    } catch (e) {
      print('Error registering store: $e');
      throw Exception('Failed to register store: $e');
    }
  }

  /// Update store settings
  Future<void> updateStore(StoreModel store) async {
    try {
      await _supabase
          .from('stores')
          .update({
            'name': store.name,
            'address': store.address,
            'is_open': store.isOpen,
            // Add other fields as per schema
          })
          .eq('id', store.id);

      // Update cache
      final index = _cachedStores.indexWhere((s) => s.id == store.id);
      if (index >= 0) {
        _cachedStores[index] = store;
      }
    } catch (e) {
      print('Error updating store: $e');
      throw Exception('Failed to update store');
    }
  }

  /// Get store by ID
  Future<StoreModel?> getStoreById(String storeId) async {
    // Check cache first
    try {
      final cached = _cachedStores.firstWhere((s) => s.id == storeId);
      return cached;
    } catch (_) {
      // Fetch from DB
      try {
        final response = await _supabase
            .from('stores')
            .select()
            .eq('id', storeId)
            .single();
        return StoreModel.fromJson(response);
      } catch (e) {
        return null;
      }
    }
  }

  /// Get store by Manager ID (for Dashboard)
  Future<StoreModel?> getStoreByManagerId(String managerId) async {
    try {
      final response = await _supabase
          .from('stores')
          .select()
          .eq('manager_id', managerId)
          .maybeSingle();

      if (response != null) {
        return StoreModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching manager store: $e');
      return null;
    }
  }

  /// Internal: Fetch all stores to cache
  Future<void> _fetchStores() async {
    try {
      final response = await _supabase
          .from('stores')
          .select()
          .eq('is_open', true);

      _cachedStores = (response as List)
          .map((json) => StoreModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching stores: $e');
      // Don't clear cache on error, keep old data
    }
  }
}
