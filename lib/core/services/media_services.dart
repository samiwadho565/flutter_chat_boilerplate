import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadMedia(File file, String folderName) async {
    final fileId = const Uuid().v4();
    final ref = _storage.ref().child('$folderName/$fileId');

    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  }
}
