import 'package:bao_la_kete/screens/playing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Rules extends StatefulWidget {
  @override
  _RulesState createState() => _RulesState();
}

class _RulesState extends State<Rules> with TickerProviderStateMixin {
  List<String> pages = [
    "All latest news All latest news All latest news All latest news All latest news All latest news",
    "Habari Plus",
    "Get Started",
  ];
  late int _currentPage;
  bool getStartedPressed = false;
  late AnimationController _controllerControllerRect;
  late Animation<double> _animationRect;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    _controllerControllerRect.dispose();
    super.dispose();
  }

  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    _currentPage = 0;
    _controllerControllerRect = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animationRect = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controllerControllerRect,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  _updateCurrentPage(int currentPage) {
    setState(() {
      _currentPage = currentPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    _controllerControllerRect.repeat(reverse: true);
    final PageController controller = PageController(initialPage: 0);
    final cWidth = MediaQuery.of(context).size.width;
    final cHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            PageView.builder(
              allowImplicitScrolling: true,
              // pageSnapping: false,
              scrollDirection: Axis.horizontal,
              reverse: false,
              physics: BouncingScrollPhysics(),
              controller: controller,
              onPageChanged: (value) {
                _updateCurrentPage(value);
                getStartedPressed = false;
                print(_currentPage);
              },
              itemCount: pages.length,
              itemBuilder: (ctx, i) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Container(
                        width: cWidth,
                        height: cHeight,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    spreadRadius: 2,
                                  )
                                ]),
                            child: Text(
                              "0${i + 1}",
                              style: TextStyle(fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text("Rule #"),
                          // Text(
                          //   pages[i],
                          //   style: TextStyle(
                          //       fontSize: Theme.of(context)
                          //           .textTheme
                          //           .headline3!
                          //           .fontSize,
                          //       color: Theme.of(context)
                          //           .textTheme
                          //           .caption!
                          //           .color,
                          //       fontWeight: Theme.of(context)
                          //           .textTheme
                          //           .headline2!
                          //           .fontWeight),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            pages[i],
                            style: TextStyle(
                              color: Theme.of(context).textTheme.caption!.color,
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            /// GET STARTED BUTTON
            getStartedButtonContainer(context, cWidth, cHeight),

            /// DOTS INDICATORS
            dotsIndicator(context, controller, cWidth, cHeight)
          ],
        ),
      ),
    );
  }

  AnimatedPositioned getStartedButtonContainer(
      BuildContext context, double width, double height) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 400),
      bottom: _currentPage != 2 ? -width * 0.2 : height * 0.1,
      right: 0,
      left: 0,
      child: Center(
        child: InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              getStartedPressed = !getStartedPressed;
            });
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 600),
                reverseTransitionDuration: Duration(milliseconds: 500),
                fullscreenDialog: true,
                // barrierDismissible: true,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return Material(
                    elevation: 0,
                    child: PlayingScreen(
                      title: 'Bao la kete',
                    ),
                  );
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: Offset(1, 0), end: Offset(0, 0)).chain(
                        CurveTween(curve: Curves.ease),
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: getStartedButton(),
        ),
      ),
    );
  }

  Positioned dotsIndicator(BuildContext context, PageController controller,
      double width, double height) {
    return Positioned(
      bottom: height * 0.05,
      right: 0,
      left: 0,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < pages.length; i++) dot(controller, i)
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer getStartedButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.decelerate,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xffE8F0FD),
          boxShadow: [
            BoxShadow(
                color: Color(0xff4D6FAC).withOpacity(0.3),
                offset: getStartedPressed ? Offset(0, 0) : Offset(0, 5),
                blurRadius: getStartedPressed ? 0 : 3)
          ]),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "GET STARTED",
            style: TextStyle(
                color: Color(0xff4D6FAC), fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xff4D6FAC),
          )
        ],
      ),
    );
  }

  InkWell dot(PageController controller, int i) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        controller.animateToPage(
          _currentPage - 1,
          duration: Duration(seconds: 1),
          curve: Curves.linear,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.linear,
          height: _currentPage == i ? 16 : 8,
          width: _currentPage == i ? 16 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            gradient: _currentPage == i
                ? RadialGradient(
                    radius: 1,
                    center: Alignment.topRight,
                    colors: [
                      Colors.brown.shade100,
                      Colors.brown.shade800,
                    ],
                  )
                : RadialGradient(
                    colors: [
                      Color(0xffE8F0FD),
                      Color(0xffE8F0FD),
                    ],
                  ),
            boxShadow: [
              _currentPage == i
                  ? BoxShadow(
                      blurRadius: 1,
                      color: Colors.black12,
                      offset: Offset(0, 5),
                      spreadRadius: -1,
                    )
                  : BoxShadow(
                      color: Colors.transparent,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
