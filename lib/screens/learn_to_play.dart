import 'package:flutter/material.dart';

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
            Container(color: Colors.red.shade100,),
            Container(
              child: Text("asdasdsda"),
            ),
          ],
        ),
      ),
    );
  }
}
