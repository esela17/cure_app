import 'dart:io'; // For File operations (e.g., when selecting an image from device)
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Cloud Storage

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload an image file to a specified path in Firebase Storage
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Upload the file to the specified storage reference
      TaskSnapshot snapshot = await _storage.ref(path).putFile(imageFile);
      // Get the public download URL of the uploaded file
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      // Catch and re-throw Firebase Storage specific exceptions
      rethrow;
    }
  }
}
