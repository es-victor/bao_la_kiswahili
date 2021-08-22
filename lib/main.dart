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
  late int currentCarryingSeeds = 0;
  late int activePit = -1;
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

  getPitsSeeds(int hole) {
    return pitsSeedsList[hole]!;
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

  addSingleSeedToPit(
      {required int pitIndex,
      required bool isFromServe,
      required bool sowingDirection}) {
    /// TODO
    /// Where to add seed
    /// In which direction to add seed
    setState(() {
      if (currentCarryingSeeds > 0) {
        if (pitsIndexesToAddSeed.contains(pitIndex)) {
          currentCarryingSeeds--;
          pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
          pitsIndexesToAddSeed.remove(pitIndex);
        }
      }
    });

    /// TODO
    /// Capture may occur on the last seed
    /// Relay-Sowing may occur
  }

  carryingSeedsFromPit({required int pitIndexFrom}) {
    if (currentCarryingSeeds == 0) {
      setState(() {
        // Transfer to sowing/carrying
        if (pitIndexFrom <= pits / 2) {
          print("North");
          pitsIndexesToAddSeed =
              pitsSeedsList.keys.where((key) => key < pits / 2).toList();
          print(pitsIndexesToAddSeed);

          /// TODO
          /// If currentCarryingSeeds < 16, remove pitIndexFrom from the pitsIndexesToAddSeed
          /// and any other seeds basing on the Direction of sowing

          pitsIndexesToAddSeed =
              pitsIndexesToAddSeed.sublist(pitIndexFrom, pitIndexFrom + 2);
          print(pitsIndexesToAddSeed);
        } else {
          print("South");
          pitsIndexesToAddSeed =
              pitsSeedsList.keys.where((key) => key >= pits / 2).toList();
          print(pitsIndexesToAddSeed);
        }

        /// TODO
        // With exception to Namua start, limited to ONLY  pits

        currentCarryingSeeds = pitsSeedsList[pitIndexFrom]!;
        print(currentCarryingSeeds);
        //Empty the hole
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
                fit: BoxFit.fill,
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
          addSingleSeedToPit(
              pitIndex: i,
              isFromServe: false,
              sowingDirection: i >= pits / 2
                  ? isSouthClockwiseSowingDirection
                  : isNorthClockwiseSowingDirection);
          setActiveSelectedHole(i);
        },
        onDoubleTap: () {
          carryingSeedsFromPit(pitIndexFrom: i);
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

  Container pitItem(int i) {
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

  Widget kete(int hole, int pitsCounts, double w, bool isOnServes) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        children: [
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
                          (pitsCounts < 9
                              ? pitsCounts
                              : isOnServes
                                  ? pitsCounts
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
          !isOnServes && pitsCounts > 9
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
                            activePit == hole ? activePitColor : Colors.white38,
                        shape: hole == southHomeIndex || hole == northHomeIndex
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                      ),
                      child: Text(
                        hole.toString(),
                      ),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
