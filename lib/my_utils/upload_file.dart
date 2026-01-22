// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../ui_screen/ui_helper/error_helper.dart';
// import '../ui_screen/ui_helper/my_color.dart';
//
// void showPicker(context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: false,
//     isDismissible: false,
//     enableDrag: false,
//     backgroundColor: MyColor.yellow,
//     builder: (_) => Container(
//       margin: const EdgeInsets.only(top: 5),
//       decoration: const BoxDecoration(
//         color: MyColor.white,
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30)),
//       ),
//       child: Container(
//         margin: EdgeInsets.only(left: 15),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//
//             InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Container(
//                 alignment: Alignment.topRight,
//                 margin: const EdgeInsets.only(top: 10, right: 20),
//                 child: Image.asset(
//                   "assets/images/cancel.png",
//                   height: 25,
//                   width: 25,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary,),
//               title: Text('Camera', style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 18, fontWeight: FontWeight.w500),),
//               onTap: () {
//                 Navigator.pop(context);
//                 chooseFromCamera(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.image, color: Theme.of(context).colorScheme.primary,),
//               title: Text('Gallery', style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 18, fontWeight: FontWeight.w500),),
//               onTap: () {
//                 Navigator.pop(context);
//                 chooseFile(context);
//               },
//             ),
//             const SizedBox(height: 20,)
//
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// void chooseFile(context) async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//   );
//
//   if (result != null && result.files.single.path != null) {
//     File file = File(result.files.single.path!);
//
//     ErrorHelper.showSnackBar(
//       'Selected file path: ${file.path}',
//       context,
//     );
//
//     await uploadImageToFirebase(file);
//   }
// }
//
// Future<void> chooseFromCamera(context) async {
//   final ImagePicker picker = ImagePicker();
//
//   final XFile? photo = await picker.pickImage(
//     source: ImageSource.camera,
//     imageQuality: 70,
//   );
//
//   if (photo != null) {
//     File imageFile = File(photo.path);
//
//     ErrorHelper.showSnackBar(
//       'Camera image path: ${photo.path}',
//       context,
//     );
//
//     await uploadImageToFirebase(imageFile);
//   }
// }
//
// Future<String> uploadImageToFirebase(File image) async {
//   final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//
//   final ref = FirebaseStorage.instance
//       .ref()
//       .child('profile_images')
//       .child('$fileName.jpg');
//
//   await ref.putFile(File(image.path));
//
//   return await ref.getDownloadURL();
// }
//
// Future<void> saveImageUrl(String uid, String imageUrl) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(uid)
//       .update({
//     'profileImage': imageUrl,
//   });
// }