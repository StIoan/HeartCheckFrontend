import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/main_page.dart';
import 'views/user_history.dart';
import 'views/user_info.dart';
import 'views/help.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCYfebT-He-ZTjzNp1OdFKJKbCK622ODfE",
            authDomain: "heartcheck-7546b.firebaseapp.com",
            projectId: "heartcheck-7546b",
            storageBucket: "heartcheck-7546b.appspot.com",
            messagingSenderId: "1079764986020",
            appId: "1:1079764986020:web:814c84e29c040887509e31",
            measurementId: "G-LVNWDGBL6V"
        ));
  }

  await Firebase.initializeApp();
  runApp(MyApp());
}
//dgsah
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeartCheck - Empowering heart health, every beat matters!',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/main': (context) => MainPage(),
        '/user_history': (context) => UserHistoryPage(),
        '/user_info': (context) => UserInfoPage(),
        '/help': (context) => HelpPage(),
      },
    );
  }
}
