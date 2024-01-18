import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String _userInfo = '';

  @override
  void initState() {
    super.initState();
    // Automatically get user info when the page is entered
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    try {
      // Use Firebase Authentication to get the currently signed-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Access user information
        String uid = user.uid;
        String email = user.email ?? '';

        setState(() {
          _userInfo = 'UserID: $uid\nEmail: $email';
        });

        // Print the user info
        print('$_userInfo');
      } else {
        // User is not signed in
        print('No user signed in');
      }
    } catch (error) {
      print('Error getting user info: $error');
    }
  }

  // Function to handle user logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side menu (unchanged)
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Improved aesthetics for user details
                  Container(
                    padding: EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'User Details',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(_userInfo),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Logout button centered below user details
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 35, // Adjust the button height
                    child: ElevatedButton(
                      onPressed: _logout,
                      child: Text('Logout'),
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
