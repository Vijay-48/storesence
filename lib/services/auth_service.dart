import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Supabase Authentication Service
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;
  static const String _roleKey = 'user_role';

  UserModel? _currentUser;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserFromSession();
      return true;
    }
    return false;
  }

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Send OTP to phone number (Supabase)
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  /// Verify OTP and login (Supabase)
  Future<UserModel?> verifyOtpAndLogin(String phoneNumber, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phoneNumber,
      );

      if (response.user != null) {
        await _loadUserFromSession();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Error verifying OTP: $e');
      throw Exception('Invalid OTP or login failed');
    }
  }

  /// Login with email and password (Supabase)
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserFromSession();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Sign Up with email and password (Supabase)
  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'role': role == UserRole.storeManager ? 'manager' : 'customer',
        },
        emailRedirectTo: 'io.supabase.flutterdemo://login-callback',
      );

      if (response.user != null) {
        await _loadUserFromSession();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Set user role (Locally for now, usually DB update)
  Future<void> setUserRole(UserRole role) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role.toString());

      // Update metadata in Supabase
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'role': role == UserRole.storeManager ? 'manager' : 'customer',
          },
        ),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
  }

  /// Load user details from current session
  Future<void> _loadUserFromSession() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final metadata = user.userMetadata ?? {};
    final prefs = await SharedPreferences.getInstance();

    // Determine role: Check metadata first, fallback to local storage
    UserRole role = UserRole.customer;
    if (metadata['role'] == 'manager') {
      role = UserRole.storeManager;
    } else {
      final storedRole = prefs.getString(_roleKey);
      if (storedRole == UserRole.storeManager.toString()) {
        role = UserRole.storeManager;
      }
    }

    _currentUser = UserModel(
      id: user.id,
      name: metadata['full_name'] ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      phone: user.phone ?? '',
      role: role,
    );
  }
}
