// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class MainPage extends StatefulWidget {
//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   User? _user = FirebaseAuth.instance.currentUser;
//   Uint8List? _selectedImageBytes;
//   String _predictionResult = '';
//   String _confidenceResult = '';
//   bool _loading = false;

//   Future<void> _pickImage() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['jpg', 'jpeg', 'png'],
//       );

//       if (result != null && result.files.isNotEmpty) {
//         setState(() {
//           _selectedImageBytes = Uint8List.fromList(result.files.first.bytes!);
//           _predictionResult =
//               ''; // Reset the prediction result when a new image is selected
//           _confidenceResult = '';
//         });
//       } else {
//         // Handle the case where 'bytes' is null
//         print('Error: Unable to access file bytes on the web.');
//       }
//     } catch (error) {
//       print('Error picking image: $error');
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _uploadImageToStorage() async {
//     try {
//       if (_selectedImageBytes != null) {
//         final String uniqueId =
//             DateTime.now().millisecondsSinceEpoch.toString();
//         final String storagePath = 'images/$uniqueId.jpg';

//         // Reference to Firebase Storage
//         final Reference storageReference =
//             FirebaseStorage.instance.ref().child(storagePath);

//         // Upload image to Firebase Storage
//         await storageReference.putData(_selectedImageBytes!);

//         // Get download URL
//         final String downloadURL = await storageReference.getDownloadURL();

//         // Send image to AI's API for prediction
//         await _predictImage(downloadURL);
//       } else {
//         print('Error uploading image to storage: _selectedImageBytes is null');
//       }
//     } catch (error) {
//       print('Error uploading image to storage: $error');
//     }
//   }

//   Future<void> _predictImage(String imageUrl) async {
//     try {
//       // Replace this URL with your AI's prediction API endpoint
//       final String predictionApiUrl =
//           'http://127.0.0.1:8080/getPredictionOutput';

//       // Create a multipart request
//       var request = http.MultipartRequest('POST', Uri.parse(predictionApiUrl));

//       // Add the image as a file in the request
//       request.files.add(http.MultipartFile.fromBytes(
//         'image',
//         _selectedImageBytes!,
//         filename: 'image.jpg',
//       ));

//       // Send the request
//       var response = await request.send();

//       // Check if the request was successful (HTTP status code 200)
//       if (response.statusCode == 200) {
//         // Parse the prediction result from the response
//         final Map<String, dynamic> result =
//             jsonDecode(await response.stream.bytesToString());

//         // Check if the 'prediction' key exists in the response
//         if (result.containsKey('predicted_label')) {
//           setState(() {
//             _predictionResult = result['predicted_label'].toString();
//             _confidenceResult = result['confidence'].toString();
//           });
//         } else {
//           print('Error: "prediction" key not found in the response.');
//           print('Response Body: ${await response.stream.bytesToString()}');
//         }
//       } else {
//         print('Error predicting image. Status Code: ${response.statusCode}');
//         print('Response Body: ${await response.stream.bytesToString()}');
//       }
//     } catch (error) {
//       print('Error predicting image: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Main Page'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Row(
//         children: [
//           // Left side menu
//           Container(
//             width: 100,
//             color: Colors.grey[300],
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/main');
//                   },
//                   child: Text('Main Page'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/user_history');
//                   },
//                   child: Text('User History'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/user_info');
//                   },
//                   child: Text('User Info'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/help');
//                   },
//                   child: Text('Help'),
//                 ),
//               ],
//             ),
//           ),
//           // Main content
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Display the chosen image
//                   _loading
//                       ? CircularProgressIndicator()
//                       : _selectedImageBytes != null
//                           ? Image.memory(
//                               _selectedImageBytes!,
//                               height: 200,
//                               width: 200,
//                               fit: BoxFit.cover,
//                             )
//                           : Container(
//                               height: 200,
//                               width: 200,
//                               color: Colors.grey[300],
//                             ),
//                   SizedBox(height: 20),
//                   // Button to pick an image
//                   ElevatedButton(
//                     onPressed: _loading ? null : _pickImage,
//                     child: Text('Choose Image'),
//                   ),
//                   SizedBox(height: 20),
//                   // Button to upload and send the image path to Firestore
//                   ElevatedButton(
//                     onPressed: _loading ? null : _uploadImageToStorage,
//                     child: Text('Upload Image to Firestore'),
//                   ),
//                   SizedBox(height: 20),
//                   // Display the prediction result
//                   _predictionResult.isNotEmpty
//                       ? Column(
//                         children: [
//                           Text('Prediction Result: $_predictionResult'),
//                           Text('Confidence precent: $_confidenceResult')
//                         ],
//                       )
//                       : Container(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
