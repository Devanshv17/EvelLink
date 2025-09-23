import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> uploadUserPhotos(String userId, List<XFile> images) async {
    List<String> photoUrls = [];
    
    for (int i = 0; i < images.length; i++) {
      final file = File(images[i].path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'user_photos/$userId/image_${timestamp}_$i.jpg';
      
      try {
        final ref = _storage.ref().child(fileName);
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        photoUrls.add(url);
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }
    
    return photoUrls;
  }

  Future<List<XFile>> pickImages({int maxImages = 4}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.length > maxImages) {
        return images.take(maxImages).toList();
      }
      return images;
    } catch (e) {
      print('Error picking images: $e');
      return [];
    }
  }

  Future<XFile?> pickSingleImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
