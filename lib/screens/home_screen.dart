import 'package:bao_la_kete/screens/playing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants_build.dart';
import 'about_game.dart';
import 'components/menu_bars.dart';
import 'learn_to_play.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Color primaryColor = Colors.brown.shade700;

  /// Animation Flag colors

  late Animation<double> _animationFlagDots;
  late AnimationController _controllerControllerFlagDots;

  /// Animation Fade in Buttons
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 1.5),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ),
  );

  @override
  void initState() {
    /// Flag buttons
    _controllerControllerFlagDots = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _animationFlagDots =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controllerControllerFlagDots,
      curve: Curves.easeInOut,
    ));
    _controllerControllerFlagDots.repeat(
      reverse: true,
      period: Duration(seconds: 5),
    );

    /// Fade in Buttons start
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controllerControllerFlagDots.dispose();
    super.dispose();
  }

  _navigateToPlayPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return Material(
              elevation: 10,
              child: PlayingScreen(),
            );
          },
          transitionDuration: Duration(milliseconds: 600),
          reverseTransitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: Offset(0, 1),
                  end: Offset(0, 0),
                ).chain(
                  CurveTween(curve: Curves.ease),
                ),
              ),
              child: ScaleTransition(
                scale: animation,
                alignment: Alignment.centerRight,
                child: child,
              ),
            );
          }),
    );
  }

  _navigateAboutTheGame() {
    Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return Material(
              elevation: 10,
              child: AboutGame(),
            );
          },
          transitionDuration: Duration(milliseconds: 600),
          reverseTransitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: Offset(0, 1),
                  end: Offset(0, 0),
                ).chain(
                  CurveTween(curve: Curves.ease),
                ),
              ),
              child: ScaleTransition(
                scale: animation,
                alignment: Alignment.centerRight,
                child: child,
              ),
            );
          }),
    );
  }

  _navigateToLearnToPlayPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return Material(
              elevation: 10,
              child: LearnToPlay(),
            );
          },
          transitionDuration: Duration(milliseconds: 600),
          reverseTransitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: Offset(0, 1),
                  end: Offset(0, 0),
                ).chain(
                  CurveTween(curve: Curves.ease),
                ),
              ),
              child: ScaleTransition(
                scale: animation,
                alignment: Alignment.centerRight,
                child: child,
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.grey.shade50,
            ),
            flagColorDots(
              width: width / 4,
              color: Colors.green.shade500,
              beginOffset: Offset(0, 0.99),
              endOffset: Offset(0, 0.97),
            ),
            flagColorDots(
              width: width / 4,
              color: Colors.grey.shade800,
              beginOffset: Offset(0, 0.99),
              endOffset: Offset(0, 0.975),
            ),
            flagColorDots(
              width: width / 4,
              color: Colors.yellowAccent.shade400,
              beginOffset: Offset(0, 0.99),
              endOffset: Offset(0, 0.98),
            ),
            flagColorDots(
              width: width / 4,
              color: Colors.grey.shade800,
              beginOffset: Offset(0, 0.99),
              endOffset: Offset(0, 0.985),
            ),
            flagColorDots(
              width: width / 4,
              color: Colors.blue.shade700,
              beginOffset: Offset(0, 0.99),
              endOffset: Offset(0, 0.99),
            ),
            Positioned(
              top: 64,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 48,
                ),
                child: FittedBox(
                  child: Text(
                    "Bao la kete",
                    style: TextStyle(
                      fontFamily: GoogleFonts.zillaSlab().fontFamily,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: buildButtonLists(width),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: MenuBars(
                color: primaryColor,
                lineHeight: 3,
                function: () {
                  print("Menu");
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Column buildButtonLists(double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildMaterialButton(
          width: width,
          label: "PLAY",
          function: _navigateToPlayPage,
        ),
        buildMaterialButton(
          width: width,
          label: "LEARN TO PLAY",
          // function: _navigateToLearnToPlayPage,
        ),
        buildMaterialButton(
          width: width,
          label: "ABOUT THE GAME",
          function: _navigateAboutTheGame,
        )
      ],
    );
  }

  SlideTransition flagColorDots({
    required double width,
    required Color color,
    required Offset beginOffset,
    required Offset endOffset,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(_animationFlagDots),
      child: Opacity(
        opacity: 0,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              RotationTransition(
                child: Container(
                  height: width * 0.5,
                  width: width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                turns: _animationFlagDots,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMaterialButton(
      {required String label, required double width, VoidCallback? function}) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: InkWell(
          onTap: function ??
              () {
                print("NULL");
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadow(),
                color: Colors.brown.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
