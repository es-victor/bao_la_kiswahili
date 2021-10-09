import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnToPlay extends StatefulWidget {
  const LearnToPlay({Key? key}) : super(key: key);

  @override
  _LearnToPlayState createState() => _LearnToPlayState();
}

class _LearnToPlayState extends State<LearnToPlay> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.grey.shade50,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Hero(
                tag: "LEARN TO PLAY",
                child: Material(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: GoogleFonts.kufam().fontFamily,
                  ),
                  child: Text("LEARN TO PLAY"),
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                color: Colors.brown.shade700,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
