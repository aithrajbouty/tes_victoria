import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:tes_victoria_care/screens/auth_screen.dart';
import 'package:tes_victoria_care/screens/check_in_screen.dart';
import 'package:tes_victoria_care/widget_tree.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
      // initialRoute: '/',
      routes: {
        '/auth': (_) => const AuthScreen(),
        CheckInScreen.routeName: (_) => const CheckInScreen(),
      },
    );
  }
}
