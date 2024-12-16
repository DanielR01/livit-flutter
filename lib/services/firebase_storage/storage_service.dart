import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService _shared = StorageService._sharedInstance();
  StorageService._sharedInstance();
  factory StorageService() => _shared;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String locationId, String type) async {
    final storageRef = _storage.ref();
    final locationRef = storageRef.child('locations/$locationId/$type/${DateTime.now().millisecondsSinceEpoch}');
    
    await locationRef.putFile(file);
    return await locationRef.getDownloadURL();
  }
}
