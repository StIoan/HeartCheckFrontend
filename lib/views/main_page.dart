import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  User? _user = FirebaseAuth.instance.currentUser;
  Uint8List? _selectedImageBytes;
  String _predictionResult = '';
  String _confidenceResult = '';
  bool _loadingImage = false;
  bool _loadingPrediction = false;

  Future<void> _pickImage() async {
    setState(() {
      _loadingImage = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImageBytes = Uint8List.fromList(result.files.first.bytes!);
          _predictionResult =
              ''; // Reset the prediction result when a new image is selected
          _confidenceResult = '';
        });
      } else {
        // Handle the case where 'bytes' is null
        print('Error: Unable to access file bytes on the web.');
      }
    } catch (error) {
      print('Error picking image: $error');
    } finally {
      setState(() {
        _loadingImage = false;
      });
    }
  }

  Future<void> _uploadImageToStorage() async {
    try {
      if (_selectedImageBytes != null) {
        final String uniqueId =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String storagePath = 'images/$uniqueId.jpg';

        // Reference to Firebase Storage
        final Reference storageReference =
            FirebaseStorage.instance.ref().child(storagePath);

        // Upload image to Firebase Storage
        await storageReference.putData(_selectedImageBytes!);

        // Get download URL
        final String downloadURL = await storageReference.getDownloadURL();

        // Send image to AI's API for prediction
        await _predictImage(downloadURL);
      } else {
        print('Error uploading image to storage: _selectedImageBytes is null');
      }
    } catch (error) {
      print('Error uploading image to storage: $error');
    }
  }

  Future<void> _predictImage(String imageUrl) async {
    try {
      // Replace this URL with your AI's prediction API endpoint
      final String predictionApiUrl =
          'http://127.0.0.1:8080/getPredictionOutput';

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(predictionApiUrl));

      // Add the image as a file in the request
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageBytes!,
        filename: 'image.jpg',
      ));

      // Set loading to true while waiting for the AI's response
      setState(() {
        _loadingPrediction = true;
      });

      // Send the request
      var response = await request.send();

      // Check if the request was successful (HTTP status code 200)
      if (response.statusCode == 200) {
        // Parse the prediction result from the response
        final Map<String, dynamic> result =
            jsonDecode(await response.stream.bytesToString());

        // Check if the 'predicted_label' key exists in the response
        if (result.containsKey('predicted_label')) {
          setState(() {
            _predictionResult = result['predicted_label'].toString();
            double confidence = result['confidence'] ?? 0.0;
            _confidenceResult = (confidence * 100).toStringAsFixed(2);
          });

          await _addToUserHistory(imageUrl);
        } else {
          print('Error: "predicted_label" key not found in the response.');
          print('Response Body: ${await response.stream.bytesToString()}');
        }
      } else {
        print('Error predicting image. Status Code: ${response.statusCode}');
        print('Response Body: ${await response.stream.bytesToString()}');
      }

      // Set loading to false after receiving the AI's response
      setState(() {
        _loadingPrediction = false;
      });
    } catch (error) {
      // Set loading to false if an error occurs
      setState(() {
        _loadingPrediction = false;
      });
      print('Error predicting image: $error');
    }
  }

  Future<void> _addToUserHistory(String imageUrl) async {
    try {
      // Reference to the 'user_history' collection in Firestore
      CollectionReference userHistoryCollection =
          FirebaseFirestore.instance.collection('user_history');

      // Add entry to 'user_history' collection
      await userHistoryCollection.add({
        'userId': _user?.uid,
        'timestamp': DateTime.now(),
        'image_url': imageUrl,
        'predicted_label': _predictionResult,
        'confidence': _confidenceResult.isNotEmpty
            ? double.parse(_confidenceResult)
            : null,
      });

      // Print the image URL
      print('Image URL: $imageUrl');
    } catch (error) {
      print('Error adding to user history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 150,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main');
                  },
                  child: Text('Main Page', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_history');
                  },
                  child: Text('User History', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_info');
                  },
                  child: Text('User Info', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/help');
                  },
                  child: Text('Help', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          // Image on the left
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: _selectedImageBytes != null
                  ? ClipRRect(
                      // borderRadius: BorderRadius.circular(20.0),
                      child: Image.memory(
                        _selectedImageBytes!,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        // borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
            ),
          ),
          // Buttons and prediction on the right
          Container(
            width: 300,
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Button to pick an image
                  Text("Scan Image", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
                  SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: _loadingImage ? null : _pickImage,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Choose Image',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Button to upload and send the image path to Firestore
                  ElevatedButton(
                    onPressed: _loadingImage ? null : _uploadImageToStorage,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Send Image to AI',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Display the prediction result or loading indicator
                  _loadingPrediction
                      ? CircularProgressIndicator()
                      : _predictionResult.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Prediction Result:',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  _predictionResult,
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Confidence Percent:',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '$_confidenceResult%',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}