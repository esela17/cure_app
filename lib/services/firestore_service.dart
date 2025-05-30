import 'package:cloud_firestore/cloud_firestore.dart'
    as firestore_package; // <--- هذا هو الاستيراد الصحيح والوحيد
import 'package:cure_app/models/service.dart'; // استيراد نموذج الخدمة
import 'package:cure_app/models/order.dart'; // استيراد نموذج الطلب الخاص بك

class FirestoreService {
  final firestore_package.FirebaseFirestore _db =
      firestore_package.FirebaseFirestore.instance; // استخدام الـ prefix

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

  // إضافة مستند طلب جديد إلى مجموعة 'orders' في Firestore
  Future<void> addOrder(Order order) async {
    // هنا 'Order' تشير إلى نموذجك
    await _db.collection('orders').add(order.toFirestore());
  }

  // الحصول على Stream للطلبات السابقة لمستخدم معين، مرتبة من الأحدث إلى الأقدم
  Stream<List<Order>> getUserOrders(String userId) {
    // هنا 'Order' تشير إلى نموذجك
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .withConverter<Order>(
          // هنا 'Order' تشير إلى نموذجك
          fromFirestore: Order.fromFirestore,
          toFirestore: (Order order, options) => order.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
