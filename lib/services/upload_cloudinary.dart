import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final ImagePicker _picker = ImagePicker();

Future<XFile?> pickImage() async {
  return await _picker.pickImage(source: ImageSource.gallery);
}


Future<String?> uploadToCloudinary(String filePath) async {
  final url = Uri.parse(
    "https://api.cloudinary.com/v1_1/dd7kgf2io/image/upload",
  );

  final request = http.MultipartRequest("POST", url)
    ..fields['upload_preset'] = 'uploadFromFlutter'
    ..files.add(await http.MultipartFile.fromPath('file', filePath));

  final response = await request.send();

  if (response.statusCode == 200) {
    final resBody = await response.stream.bytesToString();
    final data = jsonDecode(resBody);

    print("UPLOAD SUCCESS: ${data['secure_url']}"); 

    return data['secure_url'];
  } else {
    print("UPLOAD FAILED: ${response.statusCode}"); 
    return null;
  }
}


Future<void> saveImageURL(String collection, String uid, String fieldName, String imageUrl) async {
  await FirebaseFirestore.instance.collection(collection).doc(uid).update({
    fieldName: imageUrl,
  });

  print("FIRESTORE UPDATED");
}



Future<void> updateProfilePicture(String uid) async {

  final image = await pickImage();
  if (image == null) {
    print("No image selected"); 
    return;
  }


  final imageUrl = await uploadToCloudinary(image.path);
  if (imageUrl == null) {
    print("Upload failed"); 
    return;
  }

  
  await saveImageURL('users', uid, 'profileURL', imageUrl);

  print("PROFILE UPDATED SUCCESSFULLY"); 
}