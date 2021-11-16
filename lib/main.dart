import 'package:bao_la_kete/screens/home_screen.dart';
import 'package:bao_la_kete/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.brown,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bao la kete',
      theme: theme,
      // home: PlayingScreen(),
      // home: Rules(),
      home: HomeScreen(),
    );
  }
}
