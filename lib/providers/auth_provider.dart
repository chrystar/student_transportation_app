import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userRole;
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole();
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> getCurrentUser() async {
    await _auth.currentUser;
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      _userRole = doc.data()?['role'] as String?;
      notifyListeners();
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  Future<String> getUserRole(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final role = doc.data()?['role'];
    return role ?? 'unknown';
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadUserRole(); // Ensure user role is loaded after sign in
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String email, String password, String name, String role) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
