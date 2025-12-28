import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper function to create the Firestore profile for a NEW user
  // This ensures all login methods (Email/Google) create a profile.
  Future<void> _createFirestoreProfile(User user, String username) async {
    final docSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!docSnapshot.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'email': user.email,
        'accountType': 'Free',
        'createdAt': FieldValue.serverTimestamp(),
        'stats': {'totalGamesPlayed': 0, 'wins': 0, 'losses': 0},
      });
    }
  }

  // Upgrade user to Pro
  Future<void> upgradeToPro() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'accountType': 'Pro',
      'upgradedAt': FieldValue.serverTimestamp(),
    });
  }

  // In your auth_service.dart file, update the cancelSubscription method:

  Future<void> cancelSubscription() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'accountType': 'Free',
              'canceledAt': FieldValue.serverTimestamp(),
            });

        print('Subscription cancelled successfully for user: ${user.uid}');
      }
    } catch (e) {
      print('Error cancelling subscription: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  // Email/Password Register Function
  Future<String?> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create profile using the helper function
        await _createFirestoreProfile(user, username);
        return "Success";
      }
    } catch (e) {
      return e.toString();
    }
    return "Unknown Error";
  }

  // Email/Password Login Function
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  // Google Sign-In Function
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return "User canceled the sign-in process.";
      }

      // Obtain the auth details (token) from the Google request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential using the Google tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Use Google display name as the default username
        String username = user.displayName ?? "New Gamer";

        // Ensure a Firestore profile exists
        await _createFirestoreProfile(user, username);

        return "Success";
      }
    } catch (e) {
      return e.toString();
    }
    return "Unknown Error";
  }

  // Password Reset Function
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Logout Function - Updated to handle Google Sign-In
  Future<String?> signOut() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Also sign out from Google Sign-In if user used Google to log in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      }

      return "Success";
    } catch (e) {
      return e.toString();
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Update user profile
  Future<String?> updateProfile({String? username, String? email}) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return "No user logged in";

      Map<String, dynamic> updates = {};

      if (username != null && username.isNotEmpty) {
        updates['username'] = username;
      }

      if (email != null && email.isNotEmpty && email != user.email) {
        await user.updateEmail(email);
        updates['email'] = email;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      return "Success";
    } catch (e) {
      return e.toString();
    }
  }
}
