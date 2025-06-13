import 'package:image_picker/image_picker.dart';

Future<XFile?> getImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      // El usuario canceló la selección de la imagen
      print('No image selected.');
      return null;
    }
    return image;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}

Future<XFile?> takeImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      // El usuario canceló la captura de la foto
      print('No image captured.');
      return null;
    }
    return photo;
  } catch (e) {
    print('Error taking photo: $e');
    return null;
  }
}
