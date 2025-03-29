import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

final _debugger = LivitDebugger('product_sale', isDebugEnabled: false);

enum LivitProductSalePaymentMethod {
  cash,
  card,
  transfer,
}

enum LivitProductSaleStatus {
  pending,
  completed,
  cancelled,
}

class LivitProductSale {
  final String id;
  final String locationId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final LivitProductSalePaymentMethod paymentMethod;
  final LivitProductSaleStatus status;

  LivitProductSale({
    required this.id,
    required this.locationId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.paymentMethod,
    required this.status,
  });

  toMap() {
    return {
      'id': id,
      'locationId': locationId,
      'productId': productId,
      'quantity': quantity,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
    };
  }

  factory LivitProductSale.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final map = document.data()!;
    return LivitProductSale(
      id: document.id,
      locationId: map['locationId'],
      productId: map['productId'],
      quantity: map['quantity'],
      createdAt: map['createdAt'].toDate(),
      paymentMethod: LivitProductSalePaymentMethod.values.byName(map['paymentMethod']),
      status: LivitProductSaleStatus.values.byName(map['status']),
    );
  }

  static Future<DocumentReference?> getReference(String saleId) async {
    try {
      _debugger.debPrint('Finding sale reference for ID: $saleId', DebugMessageType.reading);

      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('sales').where(FieldPath.documentId, isEqualTo: saleId).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        _debugger.debPrint('No sale found with ID: $saleId', DebugMessageType.error);
        return null;
      }

      // Get the full path from the found document
      final String path = querySnapshot.docs.first.reference.path;
      return FirebaseFirestore.instance.doc(path);
    } catch (e) {
      _debugger.debPrint('Error getting sale reference: $e', DebugMessageType.error);
      rethrow;
    }
  }
}
