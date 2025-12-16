import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register with email and password
  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': DateTime.now(),
        'role': 'user', // Default role
      });

      await userCredential.user!.updateDisplayName(fullName);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Login with email and password
  Future<String?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Login as demo user (for testing)
  Future<String?> loginAsDemo() async {
    try {
      // First, try to sign in with existing account
      try {
        await _auth.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: '123456',
        );
        return null; // Success
      } on FirebaseAuthException catch (loginError) {
        // If login fails for any reason, try to create the account
        if (loginError.code == 'user-not-found' ||
            loginError.code == 'wrong-password' ||
            loginError.code == 'invalid-email') {
          // Try to create the demo user
          try {
            await _auth.createUserWithEmailAndPassword(
              email: 'test@test.com',
              password: '123456',
            );
            
            // Store user info in Firestore
            User? newUser = _auth.currentUser;
            if (newUser != null) {
              await _firestore.collection('users').doc(newUser.uid).set({
                'uid': newUser.uid,
                'email': 'test@test.com',
                'fullName': 'Demo User',
                'createdAt': DateTime.now(),
                'role': 'user',
              });
              await newUser.updateDisplayName('Demo User');
            }
            
            return null; // Success - account created
          } on FirebaseAuthException catch (createError) {
            // If account already exists (collision), try login again
            if (createError.code == 'email-already-in-use') {
              try {
                await _auth.signInWithEmailAndPassword(
                  email: 'test@test.com',
                  password: '123456',
                );
                return null; // Success on second attempt
              } catch (e) {
                return 'Demo account exists but password is incorrect. Try email login: test@test.com / 123456';
              }
            }
            return createError.message ?? 'Failed to create demo account';
          }
        }
        return loginError.message ?? 'Demo login failed';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  /// Password reset
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Password reset failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<String?> updateUserProfile({
    required String fullName,
    String? photoUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return 'User not found';

      await user.updateDisplayName(fullName);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': DateTime.now(),
      });

      return null; // Success
    } on FirebaseException catch (e) {
      return e.message ?? 'Update failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }
}
