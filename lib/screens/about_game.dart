import 'package:bao_la_kete/screens/terminologies_en.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants_build.dart';
import 'about_en.dart';

class AboutGame extends StatefulWidget {
  const AboutGame({Key? key}) : super(key: key);

  @override
  _AboutGameState createState() => _AboutGameState();
}

class _AboutGameState extends State<AboutGame> {
  int currentPageIndex = 0;
  final PageController controller = PageController(initialPage: 0);
  void _onHorizontalDragStart(DragStartDetails details) {
    if (currentPageIndex == 0) {
      print(details.globalPosition.dx);
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (currentPageIndex == 0) {
      print(details.globalPosition.dx);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (currentPageIndex == 0) {
      print(details.velocity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.grey.shade50,
            ),
            Positioned(
              top: 50,
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                child: PageView(
                  onPageChanged: (pageIndex) {
                    setState(() {
                      currentPageIndex = pageIndex;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  children: <Widget>[
                    buildAboutTheGamePage(),
                    buildTerminologiesPage(),
                    buildRulesPage()
                  ],
                ),
              ),
            ),
            Positioned(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.brown.shade100,
                      width: 0.5,
                    ),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    buildNavigationTabs(
                        label: "About the game", labelIndex: 0, last: false),
                    buildNavigationTabs(
                        label: "Terminologies", labelIndex: 1, last: false),
                    buildNavigationTabs(
                        label: "Rules", labelIndex: 2, last: true),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Center buildRulesPage() {
    return Center(
      child: Text('Rules'),
    );
  }

  ListView buildAboutTheGamePage() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      restorationId: "list",
      key: UniqueKey(),
      itemBuilder: (BuildContext context, int i) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                aboutTheGame[i]["description"],
              ),
              if (aboutTheGame[i]["image"] != "")
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child:
                      Image.asset("assets/images/${aboutTheGame[i]["image"]}"),
                )
            ],
          ),
        );
      },
      itemCount: aboutTheGame.length,
    );
  }

  ListView buildTerminologiesPage() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      restorationId: "list",
      key: UniqueKey(),
      itemBuilder: (BuildContext context, int i) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                terminologies[i]["title"],
              ),
              Text(
                terminologies[i]["description"],
              ),
              if (terminologies[i]["image"] != "")
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child:
                      Image.asset("assets/images/${terminologies[i]["image"]}"),
                )
            ],
          ),
        );
      },
      itemCount: terminologies.length,
    );
  }

  InkWell buildNavigationTabs(
      {required String label, required int labelIndex, required bool last}) {
    return InkWell(
      onTap: () {
        setState(() {
          currentPageIndex = labelIndex;
          controller.animateToPage(
            currentPageIndex,
            duration: Duration(microseconds: 300),
            curve: Curves.linear,
          );
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(right: last ? 0 : 16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            boxShadow: boxShadow(),
            color: currentPageIndex == labelIndex
                ? Colors.brown.shade800
                : Colors.brown.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
