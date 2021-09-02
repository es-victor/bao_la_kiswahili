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
  late bool northIsPlaying = false;
  late bool winnerSouth = false;
  late bool winnerNorth = false;
  late bool currentCarryingSeedsFromServe = false;
  late int homeSeeds = homeSeedsCount;
  late bool northHouseFunctional = true;
  late bool southHouseFunctional = true;
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
  List<int> possibleCapturePits = [];

  /// Show both indicators when selectionDirection == 0 && currentCarryingSeed > 0
  /// Show indicator when on the next pit to add seed
  int rightIndicator = -1;
  int leftIndicator = -1;
  int nextComingPitToAddSeed = -1;
  resetGame() {
    print("Reset");
    setState(() {
      currentServesSouth = servesSeeds;
      currentServesNorth = servesSeeds;

      /// North starts the game
      northIsPlaying = false;
      winnerSouth = false;
      winnerNorth = false;
      currentCarryingSeedsFromServe = false;
      homeSeeds = homeSeedsCount;
      northHouseFunctional = true;
      southHouseFunctional = true;
      adjacentPitsSeeds = adjacentPitsSeedsCount;
      pitsIndexesToAddSeed = [];
      pitsSeedsList = {
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
      leftClockwiseArrowIndicator = -1;
      rightClockwiseArrowIndicator = -1;
      selectedDirection = 0;
      currentCarryingSeeds = 0;
      activePit = -1;
      centerPitIndexFrom = -1;
      isNamuaPhase = true;
      southCarryingSeedFromServe = 0;
      northCarryingSeedFromServe = 0;
      isCapturedFromServe = false;
      possibleCapturePits = [];
    });
  }

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

  _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text("${winnerNorth ? "North has Won!!!" : "South has Won!!"}"),
            actions: [
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Close"),
                ),
                onTap: () => Navigator.pop(context, false),
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("New game"),
                ),
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          );
        }).then((reset) {
      if (reset) {
        print("Reset Game");
        resetGame();
      } else {
        print("Don't Reset Game");
      }
    });
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
      var possiblePitsWithCapture =
          forceCaptureFromServeIfPossible(isNorthPlaying: northIsPlaying);

      /// Check for possible force capture
      if (possiblePitsWithCapture.isNotEmpty) {
        pitsIndexesToAddSeed = possiblePitsWithCapture;
      }

      print("North");
      return currentServesNorth--;
    }
    return currentServesNorth;
  }

  pickFromSouthServes() {
    if (!northIsPlaying) {
      southCarryingSeedFromServe = 1;
      pitsIndexesToAddSeed = southAntiClockwiseIndexes;
      var possiblePitsWithCapture =
          forceCaptureFromServeIfPossible(isNorthPlaying: northIsPlaying);

      /// Check for possible force capture
      if (possiblePitsWithCapture.isNotEmpty) {
        pitsIndexesToAddSeed = possiblePitsWithCapture;
      }
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
    /// Check InnerRow for north if Empty
    for (int inner in northInnerRow) {
      if (pitsSeedsList[inner] != 0) {
        winnerSouth = false;
        break;
      }
      winnerSouth = true;
    }

    /// Check InnerRow for south if Empty
    for (int inner in southInnerRow) {
      if (pitsSeedsList[inner] != 0) {
        winnerNorth = false;
        break;
      }
      winnerNorth = true;
    }
    if (winnerNorth) {
      print("winnerNorth");
      _dialogBuilder(context);

      return;
    } else if (winnerSouth) {
      print("winnerSouth");
      _dialogBuilder(context);

      return;
    } else {
      print("Game continues ...");
    }
    if (!winnerNorth && !winnerSouth) {
      if (currentServesNorth == 0) {
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
    }
    if (winnerNorth == winnerSouth && (winnerNorth || winnerSouth)) {
      print("Something went wrong, can't all be winners");
      return;
    }
    if (winnerNorth) {
      print("winnerNorth");
      _dialogBuilder(context);
    } else if (winnerSouth) {
      print("winnerSouth");
      _dialogBuilder(context);
    } else {
      print("Game continues ...");
    }
  }

  checkIfHouseStillHasReputation({required int houseIndex}) {
    if (((houseIndex == southHouseIndex) && southHouseFunctional) ||
        ((houseIndex == northHouseIndex) && northHouseFunctional)) {
      if (pitsSeedsList[houseIndex]! >= 6) {
        print("House has Reputation");
        return true;
      }
      print("House has No Reputation");
      return false;
    } else {
      return false;
    }
  }

  updateHouseFunctional({required int houseIndex}) {
    print("House $houseIndex changed");
    if (houseIndex == southHouseIndex) {
      southHouseFunctional = false;
    } else {
      northHouseFunctional = false;
    }
  }

  checkOtherInnerRowPitsWithMoreThanOneSeed({required int pitIndex}) {
    List<int> eligiblePitsToPlay = [];

    /// Check for North
    if (northInnerRow.contains(pitIndex)) {
      for (int i in northInnerRow) {
        if (pitsSeedsList[i]! > 1) {
          eligiblePitsToPlay.add(i);
        }
      }
    }

    /// Check for South
    if (southInnerRow.contains(pitIndex)) {
      for (int i in southInnerRow) {
        if (pitsSeedsList[i]! > 1) {
          eligiblePitsToPlay.add(i);
        }
      }
    }
    if (eligiblePitsToPlay.isNotEmpty) {
      print(
          "You have to play ${eligiblePitsToPlay.length == 1 ? "this" : "these"} first " +
              eligiblePitsToPlay.toString());
      return true;
    }
    return false;
  }

  directionExceptions({required int pitIndex}) {
    int startFrom = -1;
    if (pitIndex < 16) {
      if (pitIndex < 10) {
        selectedDirection = -1;
        startFrom = 8;
        print("Start from left North");
      } else if (pitIndex > 13) {
        selectedDirection = 1;
        startFrom = 15;
        print("Start from right North");
      }
    } else {
      if (pitIndex < 18) {
        selectedDirection = 1;
        startFrom = 16;
        print("Start from left South");
      } else if (pitIndex > 21) {
        selectedDirection = -1;
        startFrom = 23;
        print("Start from right South");
      }
    }
    return startFrom;
  }

  pitIndexToStartAfterCapture({required int pitIndex}) {
    int startFrom = 0;
    if (pitIndex < 16) {
      if (selectedDirection == -1) {
        startFrom = 8;
      } else {
        startFrom = 15;
      }
    } else {
      if (selectedDirection == -1) {
        startFrom = 23;
      } else {
        startFrom = 16;
      }
    }
    return startFrom;
  }

  addSingleSeedToPit({
    required int pitIndex,
    required int centerIndex,
    required bool isFromServe,
  }) {
    /// TODO
    /// Where to add seed
    /// In which direction to add seed
    if (currentCarryingSeeds != 0 && selectedDirection == 0) {
      print("Nimeishia hapaaaaaaaaa");

      /// SET DIRECTION FOR SOWING
      if (leftClockwiseArrowIndicator == pitIndex) {
        if (isCapturedFromServe) {
          selectedDirection = -1;
          pitsIndexesToAddSeed = [
            leftClockwiseArrowIndicator,
            ...sowingAfterCapture(
                start: leftClockwiseArrowIndicator,
                steps: currentCarryingSeeds,
                dirAnticlockwise: selectedDirection)
          ];
          pitsIndexesToAddSeed.removeLast();
          isCapturedFromServe = false;
        } else {
          selectedDirection = 1;
          pitsIndexesToAddSeed = sowing(
              start: centerIndex,
              steps: currentCarryingSeeds,
              dirAnticlockwise: selectedDirection);
        }
      } else if (rightClockwiseArrowIndicator == pitIndex) {
        if (isCapturedFromServe) {
          selectedDirection = 1;
          pitsIndexesToAddSeed = [
            rightClockwiseArrowIndicator,
            ...sowingAfterCapture(
                start: rightClockwiseArrowIndicator,
                steps: currentCarryingSeeds,
                dirAnticlockwise: selectedDirection)
          ];
          pitsIndexesToAddSeed.removeLast();
          isCapturedFromServe = false;
        } else {
          selectedDirection = -1;
          pitsIndexesToAddSeed = sowing(
              start: centerIndex,
              steps: currentCarryingSeeds,
              dirAnticlockwise: selectedDirection);
        }
      }
    }
    setState(() {
      if (currentCarryingSeeds > 0) {
        if (pitsIndexesToAddSeed.contains(pitIndex)) {
          if (pitsIndexesToAddSeed[0] == pitIndex) {
            if (pitsIndexesToAddSeed.length == 1) {
              var last = pitsIndexesToAddSeed[0];

              /// Check sowing last pit
              if (pitsIndexesToAddSeed.isNotEmpty && pitsSeedsList[last]! > 0) {
                if (pitsSeedsList[last]! > 0) {
                  /// Check if the move ends in a House
                  /// Check if the move started with a Capture
                  /// if the move does not start with a capture and last seed falls in the House, check if the house is valid
                  /// if House is valid && started WITHOUT capture, END THE MOVE
                  /// else if House is valid && started WITH capture, CHOOSE either ==> Continue SOWING or END MOVE
                  if (last == northHouseIndex &&
                      checkIfHouseStillHasReputation(
                          houseIndex: northHouseIndex)) {
                    if (isCapturedFromServe) {
                      print("I'm North and Alive House CAN capture");
                    } else {
                      print("I'm North and Alive House but can't capture");
                    }
                  }
                  if (last == southHouseIndex &&
                      checkIfHouseStillHasReputation(
                          houseIndex: southHouseIndex)) {
                    if (isCapturedFromServe) {
                      print("I'm South and Alive House CAN capture");
                    } else {
                      print("I'm South and Alive House but can't capture");
                    }
                  }
                  print("Last non-empty sowing  pit " +
                      pitsSeedsList[pitsIndexesToAddSeed.last]!.toString());
                  print("Carry all seeds");
                  pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
                  pitsIndexesToAddSeed.remove(pitIndex);
                  // selectedDirection = 0;
                  centerPitIndexFrom = pitIndex;
                  currentCarryingSeeds--;
                  if (adjacentCapturingPairPits.contains(pitIndex)) {
                    if (pitIndex < 16 && pitsSeedsList[pitIndex + 8]! > 0) {
                      if (pitIndex + 8 == southHouseIndex) {
                        updateHouseFunctional(houseIndex: southHouseIndex);
                      }
                      currentCarryingSeeds = pitsSeedsList[pitIndex + 8]!;
                      pitsSeedsList[pitIndex + 8] = 0;
                      // isCapturedFromServe = true;
                      if (selectedDirection == 0) {
                        print("77777777777777777777");

                        chooseDirectionFromCapture(fromPit: pitIndex);
                      }
                      carryingSeedsFromPit(pitIndexFrom: pitIndex);
                      directionExceptions(pitIndex: pitIndex);
                      int startFrom =
                          pitIndexToStartAfterCapture(pitIndex: pitIndex);
                      pitsIndexesToAddSeed = sowingAfterCaptureFromSowing(
                          start: startFrom,
                          steps: currentCarryingSeeds,
                          dirAnticlockwise: selectedDirection);
                      return;
                    } else if (pitIndex >= 16 &&
                        pitsSeedsList[pitIndex - 8]! > 0) {
                      if (pitIndex - 8 == northHouseIndex) {
                        updateHouseFunctional(houseIndex: northHouseIndex);
                      }
                      currentCarryingSeeds = pitsSeedsList[pitIndex - 8]!;
                      pitsSeedsList[pitIndex - 8] = 0;
                      // isCapturedFromServe = true;
                      if (selectedDirection == 0) {
                        print("88888888888888");
                        chooseDirectionFromCapture(fromPit: pitIndex);
                      } else
                        carryingSeedsFromPit(pitIndexFrom: pitIndex);
                      directionExceptions(pitIndex: pitIndex);
                      int startFrom =
                          pitIndexToStartAfterCapture(pitIndex: pitIndex);
                      pitsIndexesToAddSeed = sowingAfterCaptureFromSowing(
                          start: startFrom,
                          steps: currentCarryingSeeds,
                          dirAnticlockwise: selectedDirection);
                      return;
                    }
                  }
                  if (selectedDirection == 0) {
                    chooseDirectionFromCapture(fromPit: pitIndex);
                  }
                  carryingSeedsFromPit(pitIndexFrom: pitIndex);
                  print("currentCarryingSeeds = " +
                      currentCarryingSeeds.toString());

                  if (currentCarryingSeeds > 0) {
                    pitsIndexesToAddSeed = sowing(
                        start: pitIndex,
                        steps: currentCarryingSeeds,
                        dirAnticlockwise: selectedDirection);
                    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
                    print(pitsIndexesToAddSeed);
                  }
                  print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
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
              isCapturedFromServe = false;
            }
          }
        }
      } else {}
    });
  }

  addSingleSeedToPitFromServe({
    required int pitIndex,
  }) {
    /// TODO: Follow the rules of adding to ActiveHouse(Having 6+ seeds)
    /// Can't add on House unless other
    /// 1. Other innerRows are empty
    /// 2. It can Capture

    /// Seed From serve can only be added to innerRow
    if (!(northInnerRow.contains(pitIndex) ||
        southInnerRow.contains(pitIndex))) {
      print("Seed from serves can only be added to innerRow");
      return;
    }

    if (pitsIndexesToAddSeed.contains(pitIndex) &&
        pitsSeedsList[pitIndex]! > 0) {
      /// Can't add to single seed pit, IF it's house has no reputation AND there are other pits with more than one seed
      /// Check seeds on  reputation
      if (pitsSeedsList[pitIndex]! == 1) {
        /// Check if it can capture

        if (!checkForPitIndexIfCanCapture(pitIndex: pitIndex)) {
          if (!checkIfHouseStillHasReputation(
              houseIndex: pitIndex > 15 ? southHouseIndex : northHouseIndex)) {
            /// Check if there are other innerRow pits with more than 1 seed
            if (checkOtherInnerRowPitsWithMoreThanOneSeed(pitIndex: pitIndex)) {
              return;
            }
          }
        }
      }
      northCarryingSeedFromServe = 0;
      southCarryingSeedFromServe = 0;
      pitsSeedsList[pitIndex] = (pitsSeedsList[pitIndex]! + 1);
      if (adjacentCapturingPairPits.contains(pitIndex)) {
        if (pitIndex < 16 && pitsSeedsList[pitIndex + 8]! > 0) {
          print("Now capturing from South");
          if (pitIndex + 8 == southHouseIndex) {
            updateHouseFunctional(houseIndex: southHouseIndex);
          }
          currentCarryingSeeds = pitsSeedsList[pitIndex + 8]!;
          currentCarryingSeedsFromServe = true;
          pitsSeedsList[pitIndex + 8] = 0;
          isCapturedFromServe = true;
          var startFrom = directionExceptions(pitIndex: pitIndex);

          if (startFrom != -1) {
            pitsIndexesToAddSeed = sowingAfterCaptureFromSowing(
                start: startFrom,
                steps: currentCarryingSeeds,
                dirAnticlockwise: selectedDirection);
          } else {
            chooseDirectionFromCapture(fromPit: pitIndex);
          }
          carryingSeedsFromPit(pitIndexFrom: pitIndex);
          currentCarryingSeedsFromServe = false;
          possibleCapturePits = [];
          // selectedDirection = 0;
          return;
        } else if (pitIndex >= 16 && pitsSeedsList[pitIndex - 8]! > 0) {
          print("Now capturing from North");
          if (pitIndex - 8 == northHouseIndex) {
            updateHouseFunctional(houseIndex: northHouseIndex);
          }
          currentCarryingSeeds = pitsSeedsList[pitIndex - 8]!;
          pitsSeedsList[pitIndex - 8] = 0;
          currentCarryingSeedsFromServe = true;
          isCapturedFromServe = true;
          var startFrom = directionExceptions(pitIndex: pitIndex);
          if (startFrom != -1) {
            pitsIndexesToAddSeed = sowingAfterCaptureFromSowing(
                start: startFrom,
                steps: currentCarryingSeeds,
                dirAnticlockwise: selectedDirection);
          } else {
            chooseDirectionFromCapture(fromPit: pitIndex);
          }
          carryingSeedsFromPit(pitIndexFrom: pitIndex);
          currentCarryingSeedsFromServe = false;
          possibleCapturePits = []; // RESET PITS HINTS
          // selectedDirection = 0;
          return;
        }
      }

      /// Resetting
      // pitsIndexesToAddSeed = [];
      isCapturedFromServe = false;
      print("Added from serve, WITHOUT capture");
      chooseDirection(fromPit: pitIndex);
      carryingSeedsFromPit(pitIndexFrom: pitIndex);
      possibleCapturePits = [];

      /// TODO :: continue to sow
      /// Maintain the playing session for South/North
      /// Choose direction
      /// Sow until final seed fall to empty pit
    } else {
      print("Can't add to Empty pit or You should capture");
      return;
    }
  }

  ///TODO
  List<int> forceCaptureFromServeIfPossible({required bool isNorthPlaying}) {
    // List<int> possibleCapturePitsToPlay = [];

    ///Now check if there is any possible opposite seed(s) to capture
    if (isNorthPlaying) {
      for (int i in northInnerRow) {
        if (pitsSeedsList[i]! > 0 && pitsSeedsList[i + 8]! > 0) {
          possibleCapturePits.add(i);
        }
      }
    } else {
      for (int i in southInnerRow) {
        if (pitsSeedsList[i]! > 0 && pitsSeedsList[i - 8]! > 0) {
          possibleCapturePits.add(i);
        }
      }
    }
    if (possibleCapturePits.isNotEmpty) {
      print("Dude you can capture on $possibleCapturePits, just do it!");
      return possibleCapturePits;
    } else {
      print("You can't capture");
      return possibleCapturePits;
    }
  }

  checkForPitIndexIfCanCapture({required int pitIndex}) {
    if (pitIndex < 16 && pitsSeedsList[pitIndex + 8]! > 0) {
      print("Can capture North");
      return true;
    } else if (pitIndex >= 16 && pitsSeedsList[pitIndex - 8]! > 0) {
      print("Can capture South");
      return true;
    }
    return false;
  }

  checkIfHouseIsEligibleToAcceptSeedFromServe({required int houseIndex}) {
    /// Check the other innerRows pits if can accept seed
    if (southInnerRow.contains(houseIndex)) {
      /// Check if house can capture South
      if (checkForPitIndexIfCanCapture(pitIndex: houseIndex)) {
        print("House can capture, ACCEPTED");
        return true;
      }
      for (int i in southInnerRow) {
        if (pitsSeedsList[i]! > 0 && i != houseIndex) {
          return false;
        }
      }
      return true;
    }
    if (northInnerRow.contains(houseIndex)) {
      /// Check if house can capture North
      if (checkForPitIndexIfCanCapture(pitIndex: houseIndex)) {
        print("House can capture, ACCEPTED");
        return true;
      }
      for (int i in northInnerRow) {
        if (pitsSeedsList[i]! > 0 && i != houseIndex) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  checkIfHouseIsEligibleToStartTheMove({required int houseIndex}) {
    /// Check the other innerRows pits if can start the move
    if (southInnerRow.contains(houseIndex)) {
      for (int i in southInnerRow) {
        if (pitsSeedsList[i]! > 1 && i != houseIndex) {
          /// Check if house can capture South
          return false;
        }
      }
    }
    if (northInnerRow.contains(houseIndex)) {
      for (int i in northInnerRow) {
        if (pitsSeedsList[i]! > 1 && i != houseIndex) {
          return false;
        }
      }
    }
    return true;
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
      } else {
        leftClockwiseArrowIndicator = 23;
        rightClockwiseArrowIndicator = 16;
      }
    });
  }

  carryingSeedsFromPit({required int pitIndexFrom}) {
    if (currentCarryingSeeds == 0 || currentCarryingSeedsFromServe) {
      setState(() {
        /// TODO
        /// With exception to NAMUA start, limited to ONLY non-empty pits
        centerPitIndexFrom = pitIndexFrom;

        ///Emptying the pit
        if (!currentCarryingSeedsFromServe) {
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
          Positioned(child: Text(currentCarryingSeeds.toString()))
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
            if (currentCarryingSeeds > 0) {
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
            if (i == southHouseIndex || i == northHouseIndex) {
              /// Check if House is eligible
              if (checkIfHouseStillHasReputation(houseIndex: i)) {
                if (!checkIfHouseIsEligibleToAcceptSeedFromServe(
                    houseIndex: i)) {
                  print(
                      "FAILED! Can't add to House, House can't capture and there are other pits to play");
                  return;
                }
                print(
                    "House has reputation, still can ACCEPT as others innerRow pits don't qualify");
              } else {
                print("House just LOST his reputation, So can ACCEPT");
              }
            }
            print("Add from serve");
            addSingleSeedToPitFromServe(
              pitIndex: i,
            );
          } else if (centerPitIndexFrom != -1) {
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

            /// Check if is House
            if (i == northHouseIndex || i == southHouseIndex) {
              if (checkIfHouseStillHasReputation(houseIndex: i)) {
                if (!checkIfHouseIsEligibleToStartTheMove(houseIndex: i)) {
                  /// TODO
                  return;
                }
              }
            }
            if (currentCarryingSeeds == 0) {
              setState(() {
                /// TODO
                /// With exception to NAMUA start, limited to ONLY non-empty pits
                /// Reset capturedFromServe bool value
                isCapturedFromServe = false;
                centerPitIndexFrom = i;
                currentCarryingSeeds = pitsSeedsList[i]!;

                ///Emptying the pit
                pitsSeedsList[i] = 0;
              });
            }
          }
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
                  shape: i == southHouseIndex || i == northHouseIndex
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
              possibleCapturePits.contains(i)
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(),
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
        shape: i == southHouseIndex || i == northHouseIndex
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
                        shape: pit == southHouseIndex || pit == northHouseIndex
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
