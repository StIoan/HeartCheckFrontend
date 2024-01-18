import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Help Page'),
      //   automaticallyImplyLeading: false,
      // ),
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
                SizedBox(height: 20,),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_history');
                  },
                  child: Text('User History', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 20,),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user_info');
                  },
                  child: Text('User Info', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 20,),
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
                    'HealthCheck App Help',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildHelpGuide(
                    title: 'How to Take Your Heart Health?',
                    content: '1. Open the HealthCheck app on your browser.\n'
                        '2. Navigate to the "Main" page.\n'
                        '3. Click the "Choose image" button to choose an image.\n'
                        '4. After choosing an image, click the "Send Image to AI" button.\n'
                        '5. Wait for the prediction result to appear.',
                  ),
                  _buildHelpGuide(
                    title: 'Understanding the Results',
                    content: 'The prediction result will display the app\'s analysis of your heart health based on the submitted image.\n'
                        'The result includes confidence level and predicted label information.',
                  ),
                  _buildHelpGuide(
                    title: 'User History',
                    content: 'You can view your past heart health predictions by navigating to the "User History" page.\n'
                        'It provides a record of your previous submissions.',
                  ),
                  _buildHelpGuide(
                    title: 'User Info',
                    content: 'To view your account information, including your username and email, go to the "User Info" page.',
                  ),
                  _buildHelpGuide(
                    title: 'Additional Assistance',
                    content: 'If you encounter any issues or have questions not addressed in this guide, '
                        'please contact our support team at support@healthcheck.com.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpGuide({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(content, style: TextStyle(fontSize: 18),),
        SizedBox(height: 16),
      ],
    );
  }
}