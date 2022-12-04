import 'package:flutter/material.dart';
import 'package:tes_victoria_care/auth.dart';
import 'package:tes_victoria_care/screens/auth_screen.dart';
import 'package:tes_victoria_care/screens/check_in_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return CheckInScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}
