import 'package:flutter/cupertino.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class ScannerService {
  static final ScannerService _shared = ScannerService._sharedInstance();
  ScannerService._sharedInstance();
  factory ScannerService() => _shared;

  final Collections _collections = Collections();

  Future<CloudScanner> getScannerById(String scannerId) async {
    final doc = await _collections.scannersCollection.doc(scannerId).get();
    if (doc.exists) {
      return doc.data()!;
    }
    throw ScannerNotFoundException();
  }

  Future<List<CloudScanner>> getScannersByLocationId({required String locationId}) async {
    try {
      debugPrint('📥 [ScannerService] Getting scanners by location id: $locationId');
      final doc = await _collections.scannersCollection.where('locationIds', arrayContains: locationId).get();
      debugPrint('📥 [ScannerService] Found ${doc.docs.length} scanners');
      return doc.docs.map((e) => e.data()).toList();
    } catch (e) {
      debugPrint('❌ [ScannerService] Error getting scanners by location id: $locationId');
      throw CouldNotGetScannersByLocationIdException();
    }
  }
}
