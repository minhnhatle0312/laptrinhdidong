import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String?> uploadImage(File file, {String? folder}) async {
    try {
      final ext = file.path.split('.').last;
      final id = _uuid.v4();
      final ref = _storage.ref().child('${folder ?? 'uploads'}/$id.$ext');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
