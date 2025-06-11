import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cure_app/models/service.dart';

class Order {
  final String id;
  final String userId;
  final String patientName;
  final List<Service> services;
  final double totalPrice;
  final String status;
  final DateTime orderDate;
  final DateTime? appointmentDate;
  final String? notes;
  final String deliveryAddress; // <-- Field was missing
  final String phoneNumber;
  final String? serviceProviderType;
  final String? nurseId;
  final String? nurseName;
  final bool isRated;

  Order({
    required this.id,
    required this.userId,
    required this.patientName,
    required this.services,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.appointmentDate,
    this.notes,
    required this.deliveryAddress, // <-- Added to constructor
    required this.phoneNumber,
    this.serviceProviderType,
    this.nurseId,
    this.nurseName,
    this.isRated = false,
  });

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    List<Service> orderedServices = (data['services'] as List<dynamic>? ?? [])
        .map(
            (serviceMap) => Service.fromMap(serviceMap as Map<String, dynamic>))
        .toList();

    return Order(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      patientName: data['patientName'] ?? 'مستخدم غير معروف',
      services: orderedServices,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      appointmentDate: (data['appointmentDate'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      deliveryAddress: data['deliveryAddress'] ?? '', // <-- Added here
      phoneNumber: data['phoneNumber'] ?? '',
      serviceProviderType: data['serviceProviderType'],
      nurseId: data['nurseId'],
      nurseName: data['nurseName'],
      isRated: data['isRated'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'patientName': patientName,
      'services': services.map((s) => s.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'appointmentDate':
          appointmentDate != null ? Timestamp.fromDate(appointmentDate!) : null,
      'notes': notes,
      'deliveryAddress': deliveryAddress, // <-- Added here
      'phoneNumber': phoneNumber,
      'serviceProviderType': serviceProviderType,
      'nurseId': nurseId,
      'nurseName': nurseName,
      'isRated': isRated,
    };
  }
}
