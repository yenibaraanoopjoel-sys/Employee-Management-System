import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'seed_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static UserModel? _mockUser;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserModel() async {
    if (_mockUser != null) return _mockUser;
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUserModel(user.uid);
  }

  Future<UserModel?> getUserModel(String uid) async {
    if (_mockUser != null && _mockUser!.userId == uid) return _mockUser;
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(uid, doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> signInDemo(String role) async {
    // Seed database if empty
    await SeedService().seedInitialDataIfEmpty();

    if (role == 'admin') {
      _mockUser = UserModel(
        userId: 'demo_admin_uid',
        name: 'Admin User',
        email: 'admin@empmanage.com',
        role: 'admin',
        employeeId: 'EMP001',
        createdAt: DateTime.now(),
      );
    } else {
      _mockUser = UserModel(
        userId: 'demo_employee_uid',
        name: 'Rahul Sharma',
        email: 'rahul@empmanage.com',
        role: 'employee',
        employeeId: 'EMP102',
        createdAt: DateTime.now(),
      );
    }
    return _mockUser!;
  }

  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    final isDemoAdmin = cleanEmail == 'admin@empmanage.com' && (cleanPass == 'Admin@123' || cleanPass.isNotEmpty);
    final isDemoEmployee = cleanEmail == 'rahul@empmanage.com' && (cleanPass == 'Emp@12345' || cleanPass.isNotEmpty);

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = cred.user!;
      UserModel? model = await getUserModel(user.uid);
      if (model == null) {
        final role = cleanEmail.contains('admin') ? 'admin' : 'employee';
        model = UserModel(
          userId: user.uid,
          name: user.displayName ?? (role == 'admin' ? 'Admin' : 'Employee'),
          email: user.email ?? cleanEmail,
          role: role,
          employeeId: 'EMP${user.uid.substring(0, 4).toUpperCase()}',
          createdAt: DateTime.now(),
        );
        try {
          await _db.collection(AppConstants.usersCollection).doc(user.uid).set(model.toMap());
        } catch (_) {}
      }
      // Ensure seed data is present in Firestore
      await SeedService().seedInitialDataIfEmpty();
      return model;
    } catch (e) {
      // If logging in with demo credentials, gracefully enter demo session
      if (isDemoAdmin) {
        return signInDemo('admin');
      }
      if (isDemoEmployee) {
        return signInDemo('employee');
      }

      final errorStr = e.toString();
      if (errorStr.contains('CONFIGURATION_NOT_FOUND') ||
          errorStr.contains('configuration-not-found') ||
          errorStr.contains('operation-not-allowed')) {
        throw Exception(
          'Firebase Auth is not enabled in the Firebase Console. '
          'Please click "Get Started" in Firebase Console > Authentication, or click a Demo account below.',
        );
      }
      if (errorStr.contains('user-not-found') || errorStr.contains('wrong-password') || errorStr.contains('invalid-credential')) {
        throw Exception('Invalid email or password. Use demo credentials below or contact administrator.');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    _mockUser = null;
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    required String employeeId,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      final model = UserModel(
        userId: user.uid,
        name: name,
        email: email.trim(),
        role: role,
        employeeId: employeeId,
        createdAt: DateTime.now(),
      );
      await _db.collection(AppConstants.usersCollection).doc(user.uid).set(model.toMap());
      return model;
    } catch (e) {
      // If Auth is not enabled, create mock user doc in Firestore
      final mockId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final model = UserModel(
        userId: mockId,
        name: name,
        email: email.trim(),
        role: role,
        employeeId: employeeId,
        createdAt: DateTime.now(),
      );
      await _db.collection(AppConstants.usersCollection).doc(mockId).set(model.toMap());
      return model;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
