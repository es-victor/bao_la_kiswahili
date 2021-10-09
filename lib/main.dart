import 'package:bao_la_kete/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bao la kete',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        textTheme: GoogleFonts.kufamTextTheme(),
      ),
      // home: PlayingScreen(title: 'Bao la kete'),
      // home: Rules(),
      home: HomeScreen(),
    );
  }
}
