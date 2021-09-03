import 'package:flutter/material.dart';

class CenterLine extends StatelessWidget {
  const CenterLine({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.black87,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 0.5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: SizedBox.expand(),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.yellow.shade800,
                              Color(0xff7D4829),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                offset: Offset(0, 2),
                                blurRadius: 2)
                          ]),
                    ),
                  ),
                  Flexible(
                    flex: 8,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.yellow.shade800,
                              Color(0xff7D4829),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                offset: Offset(0, 2),
                                blurRadius: 2)
                          ]),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SizedBox.expand(),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 0,
                bottom: 0,
                right: -2,
                left: -2,
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        color: Colors.grey.shade300,
                      ),
                      flex: 1,
                    ),
                    Flexible(flex: 32, child: SizedBox.expand()),
                    Flexible(
                      flex: 1,
                      child: Container(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
