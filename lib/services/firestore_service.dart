// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart' as firestore_package;
import 'package:cure_app/models/order.dart';
import 'package:cure_app/models/service.dart';
import 'package:cure_app/models/user_model.dart';

class FirestoreService {
  final firestore_package.FirebaseFirestore _db =
      firestore_package.FirebaseFirestore.instance;

  // --- دوال المستخدم ---
  Future<void> addUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.id)
        .withConverter<UserModel>(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel user, options) => user.toFirestore(),
        )
        .set(user);
  }

  // **** تم تعديل هذه الدالة ****
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .withConverter<UserModel>(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel user, options) => user.toFirestore(),
        )
        .get();
    return doc.data();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // --- دوال الخدمات والطلبات ---
  Stream<List<Service>> getServices() {
    return _db
        .collection('services')
        .withConverter<Service>(
          fromFirestore: Service.fromFirestore,
          toFirestore: (Service service, options) => service.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addOrder(Order order) async {
    await _db.collection('orders').add(order.toFirestore());
  }

  Stream<List<Order>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .withConverter<Order>(
          fromFirestore: Order.fromFirestore,
          toFirestore: (Order order, options) => order.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
