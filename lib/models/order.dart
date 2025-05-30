import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cure_app/models/service.dart'; // تأكد من المسار الصحيح لمشروعك (cure_app أو cure)

class Order {
  final String id;
  final String userId;
  final List<Service> services;
  final double totalPrice;
  final String status;
  final DateTime orderDate;
  final DateTime? appointmentDate;
  final String? notes;
  final String
      deliveryAddress; // <--- تم تغيير الاسم من userAddress إلى deliveryAddress
  final String phoneNumber; // <--- تم إضافة هذا الحقل الجديد (إجباري)
  final String? serviceProviderType;

  Order({
    required this.id,
    required this.userId,
    required this.services,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.appointmentDate,
    this.notes,
    required this.deliveryAddress, // <--- تم تغيير الاسم هنا
    required this.phoneNumber, // <--- تم إضافة هذا الحقل (إجباري)
    this.serviceProviderType,
  });

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    List<Service> orderedServices = [];
    if (data?['services'] != null) {
      for (var serviceMap in data!['services']) {
        orderedServices.add(Service(
          id: serviceMap['id'] ?? '',
          name: serviceMap['name'] ?? '',
          price: (serviceMap['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: serviceMap['imageUrl'] ?? '',
          description: serviceMap['description'] ?? '',
          durationMinutes: serviceMap['durationMinutes'] ?? 0,
          safetyScore: serviceMap['safetyScore'] as String?,
        ));
      }
    }
    return Order(
      id: snapshot.id,
      userId: data?['userId'] ?? '',
      services: orderedServices,
      totalPrice: (data?['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: data?['status'] ?? 'pending',
      orderDate: (data?['orderDate'] as Timestamp).toDate(),
      appointmentDate: (data?['appointmentDate'] as Timestamp?)?.toDate(),
      notes: data?['notes'],
      deliveryAddress:
          data?['deliveryAddress'] ?? '', // <--- تم تغيير الاسم هنا
      phoneNumber: data?['phoneNumber'] ?? '', // <--- تم إضافة هذا الحقل هنا
      serviceProviderType: data?['serviceProviderType'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'services': services.map((s) => s.toFirestore()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'appointmentDate':
          appointmentDate != null ? Timestamp.fromDate(appointmentDate!) : null,
      'notes': notes,
      'deliveryAddress': deliveryAddress, // <--- تم تغيير الاسم هنا
      'phoneNumber': phoneNumber, // <--- تم إضافة هذا الحقل هنا
      'serviceProviderType': serviceProviderType,
    };
  }
}
