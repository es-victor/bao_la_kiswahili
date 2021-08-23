import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bao la kete',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int currentServesSouth = servesSeeds;
  late int currentServesNorth = servesSeeds;
  late bool northIsPlaying = false;
  late bool isNorthClockwiseSowingDirection = false;
  late bool isSouthClockwiseSowingDirection = false;
  late int homeSeeds = homeSeedsCount;
  late int adjacentPitsSeeds = adjacentPitsSeedsCount;
  late List<int> pitsIndexesToAddSeed = [];
  late Map<int, int> pitsSeedsList = {
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
    7: 0,
    8: 0,
    9: adjacentPitsSeeds,
    10: adjacentPitsSeeds,
    11: homeSeeds,
    12: 0,
    13: 0,
    14: 0,
    15: 0,
    16: 0,
    17: 0,
    18: 0,
    19: 0,
    20: homeSeeds,
    21: adjacentPitsSeeds,
    22: adjacentPitsSeeds,
    23: 0,
    24: 0,
    25: 0,
    26: 0,
    27: 0,
    28: 0,
    29: 0,
    30: 0,
    31: 0,
  };
  int leftClockwiseArrowIndicator = -1;
  int rightClockwiseArrowIndicator = -1;
  int selectedDirection = 0;
  late int currentCarryingSeeds = 0;
  late int activePit = -1;
  int centerPitIndexFrom = -1;

  /// Show both indicators when selectionDirection == 0 && currentCarryingSeed > 0
  /// Show indicator when on the next pit to add seed
  int rightIndicator = -1;
  int leftIndicator = -1;
  int nextComingPitToAddSeed = -1;
  indicator({required int pitIndex}) {
    if (selectedDirection == 0 && currentCarryingSeeds > 0) {
      print("nIpo hapaa");
      setState(() {
        rightIndicator = rightClockwiseArrowIndicator;
        leftIndicator = leftClockwiseArrowIndicator;
      });
    } else {
      if (nextComingPitToAddSeed == leftClockwiseArrowIndicator) {
        setState(() {
          rightIndicator = rightClockwiseArrowIndicator;
          leftIndicator = -1;
        });
      } else if (nextComingPitToAddSeed == rightClockwiseArrowIndicator) {
        setState(() {
          rightIndicator = -1;
          leftIndicator = leftClockwiseArrowIndicator;
        });
      }
    }
  }

  setActiveSelectedHole(id) {
    if (activePit == id) {
      setState(() {
        activePit = -1;
      });
    } else {
      setState(() {
        activePit = id;
      });
    }
  }

  getPitsSeeds(int pit) {
    return pitsSeedsList[pit]!;
  }

  // addToNorthCurrentSavingPits() {}
  // addToSouthCurrentSavingPits() {}
  pickFromNorthServes() {
    if (!northIsPlaying) {
      northIsPlaying = true;
      // addToNorthCurrentSavingPits();
      return currentServesNorth--;
    }
    return currentServesNorth;
  }

  pickFromSouthServes() {
    if (northIsPlaying) {
      northIsPlaying = false;
      // addToSouthCurrentSavingPits();
      return currentServesSouth--;
    }
    return currentServesSouth;
  }

  addSingleSeedToPit({
    required int pitIndex,
    required int centerIndex,
    required bool isFromServe,
  }) {
    /// TODO
    /// Where to add seed
    /// In which direction to add seed

    if (selectedDirection == 0 && currentCarryingSeeds != 0) {
      /// SET DIRECTION FOR SOWING
      if (leftClockwiseArrowIndicator == pitIndex) {
        print("Selected leftClockwiseArrowIndicator");
        print(leftClockwiseArrowIndicator);
        print(rightClockwiseArrowIndicator);
        selectedDirection = 1;
        pitsIndexesToAddSeed = sowing(
            start: centerIndex,
            steps: currentCarryingSeeds,
            dirAnticlockwise: selectedDirection);
      } else if (rightClockwiseArrowIndicator == pitIndex) {
        print("Selected rightClockwiseArrowIndicator");
        print(leftClockwiseArrowIndicator);
        print(rightClockwiseArrowIndicator);
        selectedDirection = -1;
        pitsIndexesToAddSeed = sowing(
            start: centerIndex,
            steps: currentCarryingSeeds,
            dirAnticlockwise: selectedDirection);
      }
    }
    print("##################");
    print("selectedDirection " + selectedDirection.toString());
    print("currentCarryingSeeds " + currentCarryingSeeds.toString());
    print("##################");

    setState(() {
      nextComingPitToAddSeed = pitsIndexesToAddSeed[0];
      if (currentCarryingSeeds > 0) {
        if (pitsIndexesToAddSeed.contains(pitIndex)) {
          if (pitsIndexesToAddSeed[0] == pitIndex) {
            currentCarryingSeeds--;
            pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
            pitsIndexesToAddSeed.remove(pitIndex);
            if (currentCarryingSeeds == 0) {
              selectedDirection = 0;
            }
          }
        }
      } else {
        selectedDirection = 0;
      }
    });
  }

  carryingSeedsFromPit({required int pitIndexFrom}) {
    if (currentCarryingSeeds == 0) {
      setState(() {
        /// TODO
        /// With exception to NAMUA start, limited to ONLY non-empty pits
        centerPitIndexFrom = pitIndexFrom;
        currentCarryingSeeds = pitsSeedsList[pitIndexFrom]!;
        print("currentCarryingSeeds = " + currentCarryingSeeds.toString());

        ///Emptying the pit
        pitsSeedsList[pitIndexFrom] = 0;
      });
    }
  }

  carryingSeedFromServe({required bool isNorth}) {}
  pickFromServes(bool isNorth) {
    isNorth
        ? setState(() {
            currentServesNorth != 0 ? pickFromNorthServes() : 0;
          })
        : setState(() {
            currentServesSouth != 0 ? pickFromSouthServes() : 0;
          });
  }

  setDirection() {}
  List<int> chooseDirection({required int fromPit}) {
    int leftDirectionIndicatorKey = -1;
    int rightDirectionIndicatorKey = -1;
    List<int> toReturn = [];
    var list = [];
    if (fromPit < 16) {
      /// This is on North
      /// Now get the adjacent pits
      list = northAntiClockwiseIndexes;
      if (list.contains(fromPit)) {
        var centerIndex = list.indexOf(fromPit);
        var listAsMap = {};
        listAsMap = list.asMap();
        listAsMap.forEach((key, value) {
          if (key == centerIndex) {
            leftDirectionIndicatorKey = key - 1;
            if (leftDirectionIndicatorKey < listAsMap.keys.first) {
              leftDirectionIndicatorKey = listAsMap.keys.last;
            }
          }
          if (key == centerIndex) {
            rightDirectionIndicatorKey = key + 1;
            if (rightDirectionIndicatorKey > listAsMap.keys.last) {
              rightDirectionIndicatorKey = listAsMap.keys.first;
            }
          }
        });
        print("left = " +
            leftDirectionIndicatorKey.toString() +
            " <===> right = " +
            rightDirectionIndicatorKey.toString());
      }
      toReturn = [
        list[leftDirectionIndicatorKey],
        list[rightDirectionIndicatorKey]
      ];
    } else {
      list = southAntiClockwiseIndexes;
      if (list.contains(fromPit)) {
        var centerIndex = list.indexOf(fromPit);
        var listAsMap = {};
        listAsMap = list.asMap();
        listAsMap.forEach((key, value) {
          if (key == centerIndex) {
            leftDirectionIndicatorKey = key - 1;
            if (leftDirectionIndicatorKey < listAsMap.keys.first) {
              leftDirectionIndicatorKey = listAsMap.keys.last;
            }
          }
          if (key == centerIndex) {
            rightDirectionIndicatorKey = key + 1;
            if (rightDirectionIndicatorKey > listAsMap.keys.last) {
              rightDirectionIndicatorKey = listAsMap.keys.first;
            }
          }
        });
        print("left = " +
            leftDirectionIndicatorKey.toString() +
            " <===> right = " +
            rightDirectionIndicatorKey.toString());
      }
      toReturn = [
        list[leftDirectionIndicatorKey],
        list[rightDirectionIndicatorKey]
      ];
    }
    print(toReturn);
    return toReturn;
  }

  ///TEST CYCLING ITERATION
  /// THIS FUNCTION WILL REQUIRE
  /// { pitsFromIndex as start, seedsFromThePit as steps, direction of sowing, isNorth bool}
  /// =>
  /// and will return List of pits to iterate to.
  List<int> sowing(
      {required int start, required int steps, required int dirAnticlockwise}) {
    int overflowCount = 0;
    var keysForSowing = [];
    List<int> sowingIndexes = [];
    var list = [];
    // print("##################");

    if (dirAnticlockwise != 0) {
      print("passedHere");

      if (start < 16) {
        // print(northAntiClockwiseIndexes);
        // print(northAntiClockwiseIndexes.reversed.toList());
        dirAnticlockwise < 0
            ? list = northAntiClockwiseIndexes
            : list = northAntiClockwiseIndexes.reversed.toList();
      } else {
        // print(southAntiClockwiseIndexes);
        // print(southAntiClockwiseIndexes.reversed.toList());
        dirAnticlockwise < 0
            ? list = southAntiClockwiseIndexes
            : list = southAntiClockwiseIndexes.reversed.toList();
      }
      // print("##################");
      if (list.contains(start)) {
        print("Anticlockwise Direction from => " +
            start.toString() +
            ", steps => " +
            steps.toString());
        var a = list.asMap();
        print(a);
        int startKey = -1;
        int endKey = -1;

        /// get Key for starting point from a map
        a.forEach((key, value) {
          if (value == start) {
            startKey = key + 1;
          }
        });
        // print(startKey);

        /// Now get the next keys to sow
        endKey = startKey + steps;
        if (endKey > a.keys.last) {
          overflowCount = endKey - a.keys.last;
          // print("Overflowed by " + overflowCount.toString());

          /// TODO: TESTING OVERFLOW
          keysForSowing = a.keys.toList().sublist(startKey, a.length);
          if (overflowCount < 16) {
            for (var i = 0; i < overflowCount; i++) {
              keysForSowing.add(i);
            }
          } else {
            var overflowLoopCount = (overflowCount / 16).floor();
            var overflowLoopCountReminder = overflowCount % 16;

            // print("%%%%%%%%%%%%%%%%%");
            // print("overflowLoopCount = " + overflowLoopCount.toString());
            // print("%%%%%%%%%%%%%%%%%");
            // print("overflowLoopCountReminder = " +
            //     overflowLoopCountReminder.toString());
            for (var j = 0; j < overflowLoopCount; j++) {
              for (var i = 0; i < 16; i++) {
                keysForSowing.add(i);
              }
            }
            for (var i = 0; i < overflowLoopCountReminder; i++) {
              keysForSowing.add(i);
            }
          }
        } else {
          keysForSowing = a.keys.toList().sublist(startKey, endKey);
        }
        // print("########---------##########");
        // print(endKey);
        // print("#########+++++++++#########");
        // print(keysForSowing);
        // print("#########*********#########");

        ///SOWING INDEXES
        for (var i in keysForSowing) {
          sowingIndexes.add(a[i]);
        }

        /// Remove initial index which holds value of the pit just collected
        // print(sowingIndexes);
        // print(sowingIndexes);
        // print(sowingIndexes.length);
        // print("########=========##########");
      }
    }
    return sowingIndexes;
  }

  @override
  Widget build(BuildContext context) {
    double sMin = MediaQuery.maybeOf(context)!.size.shortestSide;
    double sMax = MediaQuery.maybeOf(context)!.size.longestSide;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.grey.shade300),
            child: Center(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('assets/images/bao-bg.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
                width: sMax * 2 / 3,
                height: sMin * 0.95,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: serves(isNorth: true),
                    ),
                    Center(
                      child: Container(
                        child: GridView.count(
                          shrinkWrap: true,
                          primary: true,
                          crossAxisCount: 8,
                          children: List.generate(
                            pits,
                            (i) {
                              return pit(i: i, sMin: sMin);
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: serves(isNorth: false),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// PIT ON MOVE

          northIsPlaying
              ? Positioned(
                  top: sMin * 0.05,
                  left: sMin * 0.05,
                  child: seedOnMove(isNorth: northIsPlaying),
                )
              : Positioned(
                  bottom: sMin * 0.05,
                  right: sMin * 0.05,
                  child: seedOnMove(isNorth: !northIsPlaying),
                ),
        ],
      ),
    );
  }

  Widget serves({required bool isNorth}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            pickFromServes(isNorth);
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bao-bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black12,
                  BlendMode.colorBurn,
                ),
              ),
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.shortestSide),
              border: Border.all(
                width: 1,
                color: Colors.brown.shade600,
              ),
              gradient: RadialGradient(
                radius: 1.3,
                center: Alignment.center,
                colors: [
                  Colors.transparent,
                  Color(0xff7D4829),
                ],
              ),
            ),
            child: isNorth
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(math.pi),
                    child: kete(-2, currentServesNorth,
                        MediaQuery.of(context).size.shortestSide, true),
                  )
                : kete(-2, currentServesSouth,
                    MediaQuery.of(context).size.shortestSide, true),
          ),
        ),
      ],
    );
  }

  Widget pit({required int i, required double sMin}) {
    return Transform(
      alignment: Alignment.center,
      transform:
          i >= pits / 2 ? Matrix4.rotationZ(0) : Matrix4.rotationZ(math.pi),
      child: InkWell(
        onTap: () {
          if (centerPitIndexFrom != -1) {
            addSingleSeedToPit(
              pitIndex: i,
              centerIndex: centerPitIndexFrom,
              isFromServe: false,
            );
          }
          setActiveSelectedHole(i);
        },
        onDoubleTap: () {
          List<int> returned = chooseDirection(fromPit: i);
          int left = returned[0];
          int right = returned[1];
          setState(() {
            if (left < right || (left - right).abs() < 3) {
              leftClockwiseArrowIndicator = left;
              rightClockwiseArrowIndicator = right;
              print("Set Direction 1");
            } else if ((left - right).abs() > 3) {
              leftClockwiseArrowIndicator = left;
              rightClockwiseArrowIndicator = right;
              print("Set Direction 2");
            } else {
              leftClockwiseArrowIndicator = right;
              rightClockwiseArrowIndicator = left;
              print("Set Direction 3");
            }
          });
          carryingSeedsFromPit(pitIndexFrom: i);
        },
        onLongPress: () {
          /// TODO: CHOOSE DIRECTION OF SOWING CLOCKWISE (+1) OR ANTICLOCKWISE (-1)
          /// Function to show direction options on Adjacent pits
          /// Knowing adjacent pits???

          // List<int> returned = chooseDirection(fromPit: i);
          // int left = returned[0];
          // int right = returned[1];
          // setState(() {
          //   if (left < right && (left - right).abs() > 3) {
          //     leftClockwiseArrowIndicator = left;
          //     rightClockwiseArrowIndicator = right;
          //     print("Set Direction 1");
          //   } else {
          //     leftClockwiseArrowIndicator = right;
          //     rightClockwiseArrowIndicator = left;
          //     print("Set Direction 2");
          //   }
          // });
          // if (pitsSeedsList[i]! > 0 && selectedDirection != 0) {
          //   sowing(
          //       start: i,
          //       steps: pitsSeedsList[i]!,
          //       dirAnticlockwise: selectedDirection);
          // }
        },
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bao-bg.jpg'),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.black12,
                      BlendMode.colorBurn,
                    ),
                  ),
                  shape: i == southHomeIndex || i == northHomeIndex
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  gradient: RadialGradient(
                    radius: 3,
                    center: Alignment.center,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                  color: Colors.grey,
                ),

                /// TODO
                child: kete(i, getPitsSeeds(i), sMin, false),
              ),
              Positioned(
                child: Builder(
                  builder: (BuildContext context) {
                    return pitItem(i);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pitItem(int i) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: activePit == i ? activePitColor : Color(0xff7D4829),
          width: 1,
        ),
        shape: i == southHomeIndex || i == northHomeIndex
            ? BoxShape.rectangle
            : BoxShape.circle,
        gradient: RadialGradient(
          radius: 1.3,
          center: Alignment.center,
          colors: [
            Colors.transparent,
            Colors.black87,
          ],
        ),
      ),
    );
  }

  Widget seedOnMove({required bool isNorth}) {
    return Opacity(
      opacity: 1,
      child: Container(
        width: MediaQuery.of(context).size.longestSide / 32,
        height: MediaQuery.of(context).size.longestSide / 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            radius: 1,
            center: Alignment.topRight,
            colors: [
              Colors.brown.shade100,
              Colors.brown.shade800,
            ],
          ),
        ),
      ),
    );
  }

  Widget kete(int pit, int seeds, double w, bool isOnServes) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.start,
                clipBehavior: Clip.hardEdge,
                children: [
                  for (var j = 0;
                      j <
                          (seeds < 9
                              ? seeds
                              : isOnServes
                                  ? seeds
                                  : 9);
                      j++)
                    Container(
                      width: w / 32,
                      height: w / 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          radius: 1,
                          center: Alignment.topRight,
                          colors: [
                            Colors.brown.shade100,
                            Colors.brown.shade800,
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          !isOnServes && seeds > 9
              ? Positioned(
                  bottom: 0,
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      width: w / 16,
                      height: w / 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            activePit == pit ? activePitColor : Colors.white38,
                        shape: pit == southHomeIndex || pit == northHomeIndex
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                      ),
                      child: Text(
                        pit.toString(),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          leftIndicator == pit
              ? Positioned(
                  bottom: 0,
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.2),
                    ),
                  ),
                )
              : rightIndicator == pit
                  ? Positioned(
                      bottom: 0,
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.greenAccent.withOpacity(0.2),
                        ),
                      ),
                    )
                  : SizedBox(),
        ],
      ),
    );
  }
}
