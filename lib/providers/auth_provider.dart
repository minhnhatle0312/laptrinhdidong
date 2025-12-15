import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser ?? _authService.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userEmail => currentUser?.email;
  String? get displayName => currentUser?.displayName;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize auth state listener
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final error = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      if (error != null) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final error = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (error != null) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login as demo user
  Future<bool> loginAsDemo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final error = await _authService.loginAsDemo();
      
      if (error != null) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final error = await _authService.resetPassword(email: email);
      
      if (error != null) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final error = await _authService.updateUserProfile(
        fullName: fullName,
        photoUrl: photoUrl,
      );
      
      if (error != null) {
        _errorMessage = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}