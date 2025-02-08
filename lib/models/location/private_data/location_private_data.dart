import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPrivateData {
  final String id;
  final List<String> defaultScanners;

  LocationPrivateData({
    required this.id,
    required this.defaultScanners,
  });

  factory LocationPrivateData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LocationPrivateData(
      id: doc.id,
      defaultScanners: List<String>.from(data['defaultScanners'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'defaultScanners': defaultScanners,
    };
  }

  @override
  String toString() {
    return 'LocationPrivateData(id: $id, defaultScanners: $defaultScanners)';
  }
}
