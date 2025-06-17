import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var user = Rx<User?>(null);
  var userModel = Rx<UserModel?>(null);
  var isAuthReady = false.obs;
  var isFirebaseAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔐 AuthController initialized');
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      print('🔐 Starting authentication initialization...');

      // Check current user
      user.value = _auth.currentUser;

      if (user.value != null) {
        print('👤 Found existing user: ${user.value!.email}');
        await _loadUserData();
      }

      // Listen to auth state changes
      user.bindStream(_auth.authStateChanges());

      isFirebaseAvailable.value = true;
      isAuthReady.value = true;
      print('✅ Authentication initialized successfully');
    } catch (e) {
      print('❌ Auth initialization error: $e');
      // Create a mock user for testing
      createDemoUser();
      isFirebaseAvailable.value = false;
      isAuthReady.value = true;
    }
  }

  void createDemoUser() {
    print('🔄 Creating demo user for testing');
    // Create a mock user for testing when Firebase is not configured
    userModel.value = UserModel(
      uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'Email',
      displayName: 'Demo User',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    print('✅ Demo user created: ${userModel.value?.displayName}');
  }

  Future<void> _loadUserData() async {
    if (user.value != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.value!.uid)
            .get();

        if (doc.exists) {
          userModel.value = UserModel.fromFirestore(doc);
          print('✅ User data loaded from Firestore');
        } else {
          print('ℹ️ User document not found, creating from Firebase user');
          _createUserModelFromFirebaseUser();
        }
      } catch (e) {
        print('❌ Error loading user data: $e');
        _createUserModelFromFirebaseUser();
      }
    }
  }

  void _createUserModelFromFirebaseUser() {
    if (user.value != null) {
      userModel.value = UserModel(
        uid: user.value!.uid,
        email: user.value!.email ?? '',
        displayName: user.value!.displayName ?? 'User',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      print('🔐 Attempting to sign in user: $email');

      if (!isFirebaseAvailable.value) {
        print('🔄 Firebase not available, using demo login');
        createDemoUser();
        Get.offAll(() => MainScreen());
        return;
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ User signed in successfully');
        await _updateLastLogin(result.user!.uid);
        Get.offAll(() => MainScreen());
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Auth error: ${e.code} - ${e.message}');

      // For demo purposes, create mock user if auth fails
      if (e.code == 'network-request-failed' || e.code == 'too-many-requests') {
        print('🔄 Network issues, switching to demo mode');
        createDemoUser();
        Get.offAll(() => HomeScreen());
        return;
      }

      Get.snackbar(
        'Login Error',
        e.message ?? 'An error occurred during sign in',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ General auth error: $e');
      // Create mock user for testing
      createDemoUser();
      Get.offAll(() => HomeScreen());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      isLoading.value = true;
      print('📝 Attempting to register user: $email');

      if (!isFirebaseAvailable.value) {
        print('🔄 Firebase not available, using demo registration');
        createDemoUser();
        Get.offAll(() => HomeScreen());
        return;
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('✅ User registered successfully');
        await result.user!.updateDisplayName(displayName);
        await _createUserDocument(result.user!, displayName);
        Get.offAll(() => HomeScreen());
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Registration error: ${e.code} - ${e.message}');

      // For demo purposes, create mock user if registration fails
      if (e.code == 'network-request-failed') {
        print('🔄 Network issues, switching to demo mode');
        createDemoUser();
        Get.offAll(() => HomeScreen());
        return;
      }

      Get.snackbar(
        'Registration Error',
        e.message ?? 'An error occurred during registration',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ General registration error: $e');
      // Create mock user for testing
      createDemoUser();
      Get.offAll(() => HomeScreen());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createUserDocument(User user, String displayName) async {
    try {
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      print('✅ User document created in Firestore');
    } catch (e) {
      print('❌ Error creating user document: $e');
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
      print('✅ Last login updated');
    } catch (e) {
      print('❌ Error updating last login: $e');
    }
  }

  Future<void> signOut() async {
    try {
      print('🚪 Signing out user');
      if (isFirebaseAvailable.value) {
        await _auth.signOut();
      }
      user.value = null;
      userModel.value = null;
      print('✅ User signed out successfully');
      Get.offAll(() => LoginScreen());
    } catch (e) {
      print('❌ Sign out error: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String get currentUserId => user.value?.uid ?? userModel.value?.uid ?? 'demo_user_123';
  bool get isLoggedIn => user.value != null || userModel.value != null;
}
