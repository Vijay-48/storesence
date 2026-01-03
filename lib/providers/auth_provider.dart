import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication Provider with JWT support
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isStoreManager = false;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isStoreManager => _isStoreManager;
  UserRole get userRole => _user?.role ?? UserRole.customer;
  bool get isInitialized => _isInitialized;

  /// Initialize auth state from storage
  Future<void> init() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = _authService.currentUser;
        _isStoreManager = _user?.role == UserRole.storeManager;
      }

      // Listen for auth changes (Deep links)
      Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          await _authService.isAuthenticated();
          _user = _authService.currentUser;
          _isStoreManager = _user?.role == UserRole.storeManager;
          notifyListeners();
        } else if (event == AuthChangeEvent.signedOut) {
          _user = null;
          _isStoreManager = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.sendOtp(phoneNumber);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with phone and OTP
  Future<bool> loginWithPhone(String phoneNumber, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.verifyOtpAndLogin(phoneNumber, otp);
      return _user != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.loginWithEmail(email, password);
      return _user != null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign Up with email and password
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUpWithEmail(email, password, name, role);
      // Ensure local state matches selected role
      if (_user != null) {
        _isStoreManager = role == UserRole.storeManager;
        notifyListeners();
      }
      return _user != null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set store manager mode
  void setStoreManagerMode(bool value) {
    _isStoreManager = value;
    notifyListeners();
  }

  /// Set user role after login
  Future<void> setUserRole(UserRole role) async {
    if (_user != null) {
      _user = _user!.copyWith(role: role);
      _isStoreManager = role == UserRole.storeManager;
      await _authService.setUserRole(role);
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isStoreManager = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
