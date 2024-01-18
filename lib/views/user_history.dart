import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserHistoryPage extends StatefulWidget {
  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  late List<Widget> _userHistoryWidgets;
  late User _user;

  @override
  void initState() {
    super.initState();
    _userHistoryWidgets = [];
    _user = FirebaseAuth.instance.currentUser!;
    _getUserHistory(); // Fetch user history when the page is initialized
  }

  Future<void> _getUserHistory() async {
    try {
      CollectionReference userHistoryCollection =
          FirebaseFirestore.instance.collection('user_history');

      QuerySnapshot querySnapshot = await userHistoryCollection
          .where('userId', isEqualTo: _user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Widget> entries =
            querySnapshot.docs.map((QueryDocumentSnapshot doc) {
          String imageUrl = doc['image_url'];

          // Check if timestamp is stored as a string or Timestamp
          dynamic timestampData = doc['timestamp'];
          DateTime dateTime;
          if (timestampData is String) {
            dateTime = DateTime.parse(timestampData);
          } else if (timestampData is Timestamp) {
            dateTime = timestampData.toDate();
          } else {
            throw FormatException("Unexpected timestamp format");
          }

          // Retrieve additional fields from Firestore
          String predictedLabel = doc['predicted_label'] ?? '';
          double confidence = doc['confidence'] ?? 0.0;

          return _buildUserHistoryTile(
            imageUrl,
            dateTime,
            predictedLabel,
            confidence,
          );
        }).toList();

        setState(() {
          _userHistoryWidgets = entries;
        });
      } else {
        setState(() {
          _userHistoryWidgets = [
            Text('User History is empty.'),
          ];
        });
        print('User History is empty.');
      }
    } catch (error) {
      print('Error getting user history: $error');
    }
  }

  Widget _buildUserHistoryTile(
    String imageUrl,
    DateTime dateTime,
    String predictedLabel,
    double confidence,
  ) {
    return ListTile(
      title: Row(
        children: [
          SizedBox(width: 30,),
          Text('Timestamp: ${dateTime.toString()}'),
          SizedBox(width: 30,),
          Text('Predicted Label: $predictedLabel'),
          SizedBox(width: 30,),
          Text('Confidence: ${confidence.toStringAsFixed(2)}'),
        ],
      ),
      leading: Image.network(
        imageUrl,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side menu
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
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User History Page',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  Expanded(
                    child: _userHistoryWidgets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _userHistoryWidgets,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _userHistoryWidgets.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _userHistoryWidgets[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}