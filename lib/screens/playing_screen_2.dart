import 'dart:math' as math;

import 'package:bao_la_kete/constants.dart';
import 'package:flutter/material.dart';

class PlayingScreen extends StatefulWidget {
  PlayingScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  late int currentServesSouth = servesSeeds;
  late int currentServesNorth = servesSeeds;

  /// North starts the game
  late bool northIsPlaying = true;
  late bool winnerSouth = false;
  late bool winnerNorth = false;
  late bool currentCarryingSeedsFromServe = false;
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
  bool isNamuaPhase = true;
  int southCarryingSeedFromServe = 0;
  int northCarryingSeedFromServe = 0;
  bool isCapturedFromServe = false;

  /// Show both indicators when selectionDirection == 0 && currentCarryingSeed > 0
  /// Show indicator when on the next pit to add seed
  int rightIndicator = -1;
  int leftIndicator = -1;
  int nextComingPitToAddSeed = -1;
  bool indicator({required int pitIndex}) {
    bool returnValue = false;
    if (selectedDirection == 0 && currentCarryingSeeds > 0) {
      if (pitIndex == leftClockwiseArrowIndicator ||
          pitIndex == rightClockwiseArrowIndicator) {
        returnValue = true;
      }
    } else {
      if (pitsIndexesToAddSeed.isNotEmpty &&
          pitsIndexesToAddSeed[0] == pitIndex) {
        returnValue = true;
      } else {
        returnValue = false;
      }
    }
    return returnValue;
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

  pickFromNorthServes() {
    if (northIsPlaying) {
      northCarryingSeedFromServe = 1;
      pitsIndexesToAddSeed = northAntiClockwiseIndexes;
      print("North");
      return currentServesNorth--;
    }
    return currentServesNorth;
  }

  pickFromSouthServes() {
    if (!northIsPlaying) {
      southCarryingSeedFromServe = 1;
      pitsIndexesToAddSeed = southAntiClockwiseIndexes;
      print("South");
      return currentServesSouth--;
    }
    return currentServesSouth;
  }

  checkForWinner() {
    /// TODO:
    /// Winning conditions:
    /// When opponent inner row is empty or opponent has no more move to make
    /// 1. Checking for InnerRows
    /// Check InnerRow for north
    for (int inner in northInnerRow) {
      if (pitsSeedsList[inner] != 0) {
        winnerSouth = false;
        break;
      }
      winnerSouth = true;
    }

    /// Check InnerRow for south
    for (int inner in southInnerRow) {
      if (pitsSeedsList[inner] != 0) {
        winnerNorth = false;
        break;
      }
      winnerNorth = true;
    }

    if (!winnerNorth || !winnerSouth) {
      /// Check if user has at least one move for North
      for (int pit in northAntiClockwiseIndexes) {
        if (pitsSeedsList[pit]! > 1) {
          winnerSouth = false;
          break;
        }
        winnerSouth = true;
      }

      /// Check if user has at least one move for South

      for (int pit in southAntiClockwiseIndexes) {
        if (pitsSeedsList[pit]! > 1) {
          winnerNorth = false;
          break;
        }
        winnerNorth = true;
      }
    }
    if (winnerNorth == winnerSouth && (winnerNorth || winnerSouth)) {
      print("Something went wrong, can't all be winners");
      return;
    }
    if (winnerNorth) {
      print("winnerNorth");
    } else if (winnerSouth) {
      print("winnerSouth");
    } else {
      print("Game continues ...");
    }
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
        print(pitsIndexesToAddSeed.length);
        print(pitsIndexesToAddSeed);
      } else if (rightClockwiseArrowIndicator == pitIndex) {
        // print("Selected rightClockwiseArrowIndicator");
        // print(leftClockwiseArrowIndicator);
        // print(rightClockwiseArrowIndicator);
        selectedDirection = -1;
        pitsIndexesToAddSeed = sowing(
            start: centerIndex,
            steps: currentCarryingSeeds,
            dirAnticlockwise: selectedDirection);
        print(pitsIndexesToAddSeed.length);
        print(pitsIndexesToAddSeed);
      }
    }
    // print("##################");
    // print("selectedDirection " + selectedDirection.toString());
    // print("currentCarryingSeeds " + currentCarryingSeeds.toString());
    // print("##################");

    setState(() {
      if (currentCarryingSeeds > 0) {
        if (pitsIndexesToAddSeed.contains(pitIndex)) {
          if (pitsIndexesToAddSeed[0] == pitIndex) {
            if (pitsIndexesToAddSeed.length == 1) {
              /// Check sowing last pit
              if (pitsIndexesToAddSeed.isNotEmpty &&
                  pitsIndexesToAddSeed.last > 0) {
                if (pitsSeedsList[pitsIndexesToAddSeed.last]! > 0) {
                  print("Last non-empty sowing  pit " +
                      pitsSeedsList[pitsIndexesToAddSeed.last]!.toString());
                  print("Carry all seeds");
                  pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
                  pitsIndexesToAddSeed.remove(pitIndex);
                  selectedDirection = 0;
                  centerPitIndexFrom = pitIndex;
                  currentCarryingSeeds--;
                  if (adjacentCapturingPairPits.contains(pitIndex)) {
                    if (pitIndex < 16 && pitsSeedsList[pitIndex + 8]! > 0) {
                      // pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! +
                      //     pitsSeedsList[pitIndex + 8]!);
                      // pitsSeedsList[pitIndex + 8] = 0;
                      // pitsSeedsList[pitIndex] = pitsSeedsList[pitIndex]! + 1;
                      currentCarryingSeeds = pitsSeedsList[pitIndex + 8]!;
                      pitsSeedsList[pitIndex + 8] = 0;
                      print("Now capturing from South fdsfsfsdfsfsdfsd");
                    } else if (pitIndex >= 16 &&
                        pitsSeedsList[pitIndex - 8]! > 0) {
                      // pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! +
                      //     pitsSeedsList[pitIndex - 8]!);
                      // pitsSeedsList[pitIndex - 8] = 0;
                      // pitsSeedsList[pitIndex] = pitsSeedsList[pitIndex]! + 1;
                      currentCarryingSeeds = pitsSeedsList[pitIndex - 8]!;
                      pitsSeedsList[pitIndex - 8] = 0;
                      print("Now capturing from North sdfsdfsdfsdfsas");
                    }
                  }
                  chooseDirection(fromPit: pitIndex);
                  carryingSeedsFromPit(pitIndexFrom: pitIndex);
                  return;
                }
              }
              pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
              pitsIndexesToAddSeed.remove(pitIndex);
            } else {
              pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
              pitsIndexesToAddSeed.remove(pitIndex);
            }
            currentCarryingSeeds--;
            if (currentCarryingSeeds == 0) {
              checkForWinner();
              northIsPlaying = !northIsPlaying;
              selectedDirection = 0;
            }
          }
        }
      } else {}
    });
  }

  addSingleSeedToPitFromServe({
    required int pitIndex,
  }) {
    ///TODO: Only add to non-empty pit

    if (pitsIndexesToAddSeed.contains(pitIndex) &&
        pitsSeedsList[pitIndex]! > 0) {
      northCarryingSeedFromServe = 0;
      southCarryingSeedFromServe = 0;
      pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
      if (adjacentCapturingPairPits.contains(pitIndex)) {
        if (pitIndex < 16 && pitsSeedsList[pitIndex + 8]! > 0) {
          print("Now capturing from South");
          currentCarryingSeeds = pitsSeedsList[pitIndex + 8]!;
          currentCarryingSeedsFromServe = true;
          pitsSeedsList[pitIndex + 8] = 0;
          isCapturedFromServe = true;
          chooseDirectionFromCapture(fromPit: pitIndex);
          carryingSeedsFromPit(pitIndexFrom: pitIndex);
          currentCarryingSeedsFromServe = false;
          selectedDirection = 0;
          return;
        } else if (pitIndex >= 16 && pitsSeedsList[pitIndex - 8]! > 0) {
          print("Now capturing from North");
          currentCarryingSeeds = pitsSeedsList[pitIndex - 8]!;
          pitsSeedsList[pitIndex - 8] = 0;
          currentCarryingSeedsFromServe = true;
          isCapturedFromServe = true;
          chooseDirectionFromCapture(fromPit: pitIndex);
          carryingSeedsFromPit(pitIndexFrom: pitIndex);
          currentCarryingSeedsFromServe = false;
          selectedDirection = 0;
          return;
        }
      }

      /// Resetting
      // pitsIndexesToAddSeed = [];
      isCapturedFromServe = false;
      print("Added from serve");
      chooseDirection(fromPit: pitIndex);
      carryingSeedsFromPit(pitIndexFrom: pitIndex);

      /// TODO :: continue to sow
      /// Maintain the playing session for South/North
      /// Choose direction
      /// Sow until final seed fall to empty pit
    } else {
      print("Can't add to Empty pit");
      return;
    }
  }

  chooseDirection({required int fromPit}) {
    List<int> returned = directionOptions(fromPit: fromPit);
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
  }

  chooseDirectionFromCapture({required int fromPit}) {
    // , required bool isDirectFromServe
    /// check isNorth or not
    setState(() {
      if (fromPit < 16) {
        /// isNorth == true
        leftClockwiseArrowIndicator = 8;
        rightClockwiseArrowIndicator = 15;
        print("Northeeeeeeeeeeeeeeeeeeeeee");
      } else {
        leftClockwiseArrowIndicator = 23;
        rightClockwiseArrowIndicator = 16;
        print("Southeeeeeeeeeeeeeeeeeeeeee");
      }
    });
    // return;
    // List<int> returned = directionOptions(fromPit: fromPit);
    // int left = returned[0];
    // int right = returned[1];
    // setState(() {
    //   if (left < right || (left - right).abs() < 3) {
    //     leftClockwiseArrowIndicator = left;
    //     rightClockwiseArrowIndicator = right;
    //     print("Set Direction 1");
    //   } else if ((left - right).abs() > 3) {
    //     leftClockwiseArrowIndicator = left;
    //     rightClockwiseArrowIndicator = right;
    //     print("Set Direction 2");
    //   } else {
    //     leftClockwiseArrowIndicator = right;
    //     rightClockwiseArrowIndicator = left;
    //     print("Set Direction 3");
    //   }
    // });
  }

  carryingSeedsFromPit({required int pitIndexFrom}) {
    if (currentCarryingSeeds == 0 || currentCarryingSeedsFromServe) {
      setState(() {
        /// TODO
        /// With exception to NAMUA start, limited to ONLY non-empty pits
        centerPitIndexFrom = pitIndexFrom;
        print("nimepitaaaaaaaa");

        ///Emptying the pit
        if (!currentCarryingSeedsFromServe) {
          print("sdfffffffffffffffffffffffffffffffffff");

          currentCarryingSeeds = pitsSeedsList[pitIndexFrom]!;
          pitsSeedsList[pitIndexFrom] = 0;
        }
      });
    }
  }

  pickFromServes(bool isNorth) {
    isNorth
        ? setState(() {
            currentServesNorth != 0 ? pickFromNorthServes() : 0;
          })
        : setState(() {
            currentServesSouth != 0 ? pickFromSouthServes() : 0;
          });
  }

  List<int> directionOptions({required int fromPit}) {
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
            rightDirectionIndicatorKey = key + 1;
            if (leftDirectionIndicatorKey < listAsMap.keys.first) {
              leftDirectionIndicatorKey = listAsMap.keys.last;
            }
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
  /// and will return List of pits to iterate to.
  List<int> sowing(
      {required int start, required int steps, required int dirAnticlockwise}) {
    int overflowCount = 0;
    var keysForSowing = [];
    List<int> sowingIndexes = [];
    var list = [];
    // print("##################");
    if (dirAnticlockwise != 0) {
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
          overflowCount = endKey - a.keys.last - 1;
          print("Overflowed by " + overflowCount.toString());

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

        /// SOWING INDEXES
        for (var i in keysForSowing) {
          sowingIndexes.add(a[i]);
        }

        /// Remove initial index which holds value of the pit just collected
        // print(sowingIndexes);
        print(sowingIndexes);
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

          /// SEED FROM SERVES ON MOVE

          northCarryingSeedFromServe == 1
              ? Positioned(
                  top: sMin * 0.05,
                  left: sMin * 0.05,
                  child: seedOnMove(isNorth: northIsPlaying),
                )
              : SizedBox.shrink(),
          southCarryingSeedFromServe == 1
              ? Positioned(
                  bottom: sMin * 0.05,
                  right: sMin * 0.05,
                  child: seedOnMove(isNorth: !northIsPlaying),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Column serves({required bool isNorth}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (isNorth && currentServesNorth == 0 && northIsPlaying) {
              print("No seeds to take from North");
              return;
            }
            if (!isNorth && currentServesSouth == 0 && !northIsPlaying) {
              print("No seeds to take from South");
              return;
            }
            if (northCarryingSeedFromServe == 1 ||
                southCarryingSeedFromServe == 1) {
              if (northCarryingSeedFromServe == 1) {
                print("Play north seed from serve");
              } else {
                print("Play south seed from serve");
              }
              return;
            }
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

  Transform pit({required int i, required double sMin}) {
    bool isNorth = true;
    if (i >= pits / 2) {
      isNorth = false;
    }
    return Transform(
      alignment: Alignment.center,
      transform:
          i >= pits / 2 ? Matrix4.rotationZ(0) : Matrix4.rotationZ(math.pi),
      child: InkWell(
        onTap: () {
          if (northCarryingSeedFromServe == 1 ||
              southCarryingSeedFromServe == 1) {
            print("Add from serve");
            addSingleSeedToPitFromServe(
              pitIndex: i,
            );
          } else if (centerPitIndexFrom != -1) {
            print("asdsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaasdasasa");

            addSingleSeedToPit(
              pitIndex: i,
              centerIndex: centerPitIndexFrom,
              isFromServe: false,
            );
          }
          setActiveSelectedHole(i);
        },
        onDoubleTap: () {
          if (isNorth && currentServesNorth > 0 && northIsPlaying) {
            print("Play the serves North");
            return;
          } else if (!isNorth && currentServesSouth > 0 && !northIsPlaying) {
            print("Play the serves South");
            return;
          }

          /// Can't carry if you have currentCarryingSeeds in hand or on pit with less than 2 seeds
          if (currentCarryingSeeds > 0 || pitsSeedsList[i]! < 2) {
            return;
          }
          if ((i < pits / 2 &&
                  northIsPlaying &&
                  northCarryingSeedFromServe == 0) ||
              (i >= pits / 2 &&
                  !northIsPlaying &&
                  southCarryingSeedFromServe == 0)) {
            chooseDirection(fromPit: i);
            if (currentCarryingSeeds == 0) {
              setState(() {
                /// TODO
                /// With exception to NAMUA start, limited to ONLY non-empty pits
                centerPitIndexFrom = i;
                currentCarryingSeeds = pitsSeedsList[i]!;

                ///Emptying the pit
                pitsSeedsList[i] = 0;
              });
            }
          }
        },
        onLongPress: () {
          /// TODO: CHOOSE DIRECTION OF SOWING CLOCKWISE (+1) OR ANTICLOCKWISE (-1)
          /// Function to show direction options on Adjacent pits
          /// Knowing adjacent pits???

          // List<int> returned = directionOptions(fromPit: i);
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
                child: kete(i, pitsSeedsList[i]!, sMin, false),
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

  Opacity seedOnMove({required bool isNorth}) {
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

  Container kete(int pit, int seeds, double w, bool isOnServes) {
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
          isOnServes && seeds > 9
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
                        seeds.toString(),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          indicator(pitIndex: pit) &&
                  (northCarryingSeedFromServe == 0 &&
                      southCarryingSeedFromServe == 0)
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
