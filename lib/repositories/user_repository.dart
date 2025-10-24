import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

abstract class UserRepository {
  Future<AppUser?> getUserByEmail(String email);
  Future<AppUser?> getUserById(String id);
  Future<bool> createUser(AppUser user);
  Future<bool> updateUser(AppUser user);
  Future<bool> updateLastLogin(String userId);
  Future<List<AppUser>> getAllUsers();
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      print('Attempting to fetch user by email: $email');
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final user = AppUser.fromJson({
          'id': doc.id,
          ...data,
        });
        print('Successfully fetched user: ${user.fullName} (${user.email})');
        print('User role: ${user.role.value}, Active: ${user.isActive}');
        return user;
      }
      
      print('No user found with email: $email');
      return null;
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    try {
      print('Attempting to fetch user by ID: $id');
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(id)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final user = AppUser.fromJson({
          'id': doc.id,
          ...data,
        });
        print('Successfully fetched user: ${user.fullName}');
        return user;
      }
      
      print('No user found with ID: $id');
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  @override
  Future<bool> createUser(AppUser user) async {
    try {
      print('Attempting to create user: ${user.email}');
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
      
      print('Successfully created user: ${user.fullName}');
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  @override
  Future<bool> updateUser(AppUser user) async {
    try {
      print('Attempting to update user: ${user.email}');
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toJson());
      
      print('Successfully updated user: ${user.fullName}');
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  @override
  Future<bool> updateLastLogin(String userId) async {
    try {
      print('Attempting to update last login for user: $userId');
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
      
      print('Successfully updated last login for user: $userId');
      return true;
    } catch (e) {
      print('Error updating last login: $e');
      return false;
    }
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    try {
      print('Attempting to fetch all users');
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      
      final users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppUser.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
      
      print('Successfully fetched ${users.length} users');
      return users;
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }
}
