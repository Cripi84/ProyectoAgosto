import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

Future<String?> uploadImage(File image) async {
  final String namefile = image.path.split('/').last;

  final Reference ref = storage.ref().child("Imagenes").child(namefile);
  final UploadTask uploadTask = ref.putFile(image);

  try {
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl; // Devuelve la URL de la imagen subida
  } catch (e) {
    print('Error uploading image: $e');
    return null; // Devuelve null en caso de error
  }
}
