import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hanyang_app/data/join_or_login.dart';
import 'package:hanyang_app/screens/how_to_use_page.dart';
import 'package:hanyang_app/screens/login.dart';
import 'package:hanyang_app/screens/main_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '두근두근 한양ㅎㅎ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
      routes: {
        '/first' : (context) => MainPage(),
        '/second' : (context) => HowToUse(),
      },
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return ChangeNotifierProvider<JoinOrLogin>.value(
                value: JoinOrLogin(), child: AuthPage());
          } else {
            return MainPage();
          }
        });
  }
}
