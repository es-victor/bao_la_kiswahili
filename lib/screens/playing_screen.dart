import 'dart:math' as math;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bao_la_kete/constants.dart';
import 'package:bao_la_kete/screens/components/remove_scroll_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayingScreen extends StatefulWidget {
  PlayingScreen({
    Key? key,
  }) : super(key: key);

  @override
  _PlayingScreenState createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen>
    with SingleTickerProviderStateMixin {
  final assetsAudioPlayer = AssetsAudioPlayer();
  late int currentServesSouth = servesSeeds;
  late int currentServesNorth = servesSeeds;

  /// North starts the game
  late bool northIsPlaying = true;
  late bool winnerSouth = false;
  late bool winnerNorth = false;
  late bool currentCarryingSeedsFromServe = false;
  late int houseSeeds = houseSeedsCount;
  late bool northHouseFunctional = true;
  late bool southHouseFunctional = true;
  late int adjacentPitsSeeds = adjacentPitsSeedsCount;
  late List<int> pitsIndexesToAddSeed = [];
  late List<int> nextPhasePitsStartMoveWithCapture = [];
  late Map<String, List<int>> nextPhasePitsStartMoveWithCaptureHintsMap;
  late List<int> viewHintCaptureMoveList = [];
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
    11: houseSeeds,
    12: 0,
    13: 0,
    14: 0,
    15: 0,
    16: 0,
    17: 0,
    18: 0,
    19: 0,
    20: houseSeeds,
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
  bool isCapturedFromTakataPhase = false;

  /// Show both indicators when selectionDirection == 0 && currentCarryingSeed > 0
  /// Show indicator when on the next pit to add seed
  int rightIndicator = -1;
  int leftIndicator = -1;
  int nextComingPitToAddSeed = -1;
  late AnimationController _animationController;
  addSeedToPitSoundEffect() {
    AssetsAudioPlayer.playAndForget(
      Audio('assets/audios/addSeedToPit.mp3'),
    );
  }

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
      houseSeeds = houseSeedsCount;
      northHouseFunctional = true;
      southHouseFunctional = true;
      adjacentPitsSeeds = adjacentPitsSeedsCount;
      pitsIndexesToAddSeed = [];
      nextPhasePitsStartMoveWithCapture = [];
      viewHintCaptureMoveList = [];
      possibleCapturePits = []; // RESET PITS HINTS
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
        11: houseSeeds,
        12: 0,
        13: 0,
        14: 0,
        15: 0,
        16: 0,
        17: 0,
        18: 0,
        19: 0,
        20: houseSeeds,
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

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600),
        upperBound: 1.0,
        value: 0.2,
        lowerBound: 0.2);
    _animationController.repeat(reverse: true);

    checkForPossibleCaptureForNextPlayerMove(isNorthPlaying: northIsPlaying);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(
              "${winnerNorth ? "NORTH HAS WON" : "SOUTH HAS WON"}",
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () => Navigator.pop(context, true),
                    color: Colors.brown.shade900,
                    textColor: Colors.white,
                    child: Text("New game"),
                  ),
                ],
              )
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

  checkForPossibleCaptureForNextPlayerMove({required bool isNorthPlaying}) {
    if (isNorthPlaying && currentServesNorth > 0) {
      print("North now pick 1 seed");
      return;
    } else if (!isNorthPlaying && currentServesSouth > 0) {
      print("South now pick 1 seed");
      return;
    }
    forceCaptureIfPossibleForNextPhase(isNorthPlaying: isNorthPlaying);
  }

  forceCaptureIfPossibleForNextPhase({required bool isNorthPlaying}) {
    /// TODO
    /// Check for non-empty pits
    /// For each pit's seeds(must be more than 1) check if it can be sowed and end-up on capturing innerRow pit on either direction
    List<int> pitIndexesToStartMove = [];
    nextPhasePitsStartMoveWithCapture = []; //reset
    nextPhasePitsStartMoveWithCaptureHintsMap = {}; // reset
    if (isNorthPlaying) {
      for (int i in northAntiClockwiseIndexes) {
        if (pitsSeedsList[i]! > 1) {
          pitIndexesToStartMove.add(i);
        }
      }
    } else if (!isNorthPlaying) {
      for (int i in southAntiClockwiseIndexes) {
        if (pitsSeedsList[i]! > 1) {
          pitIndexesToStartMove.add(i);
        }
      }
    } else {
      print("I have no idea what is happening right now!");
      return;
    }
    if (pitIndexesToStartMove.isNotEmpty) {
      print("You may start move from these $pitIndexesToStartMove");
      checkForPossibleCaptureHints(
          pitIndexesToStartMove: pitIndexesToStartMove,
          isNorthPlaying: isNorthPlaying);
    } else {
      print("Sorry, you have no more move");
    }
  }

  checkForPossibleCaptureHints(
      {required List<int> pitIndexesToStartMove,
      required bool isNorthPlaying}) {
    for (int i in pitIndexesToStartMove) {
      /// Check number of seeds in a pit, as Steps
      /// Find the end pit of it is to be sowed
      /// Check if end ends up in a capturing pits
      int steps = pitsSeedsList[i]!;
      List<int> listPathAntiClockwise =
          sowing(start: i, steps: steps, dirAnticlockwise: -1);
      List<int> listPathClockwise =
          sowing(start: i, steps: steps, dirAnticlockwise: 1);
      int listPathAntiClockwiseLast = listPathAntiClockwise.last;
      int listPathClockwiseLast = listPathClockwise.last;

      /// Now check the end pit on each list if it can capture
      bool listPathAntiClockwiseCanCapture =
          checkForPitIndexIfCanCapture(pitIndex: listPathAntiClockwiseLast) &&
              (northInnerRow.contains(listPathAntiClockwiseLast) ||
                  southInnerRow.contains(listPathAntiClockwiseLast)) &&
              pitsSeedsList[listPathAntiClockwiseLast]! > 0;

      bool listPathClockwiseCanCapture =
          checkForPitIndexIfCanCapture(pitIndex: listPathClockwiseLast) &&
              (northInnerRow.contains(listPathClockwiseLast) ||
                  southInnerRow.contains(listPathClockwiseLast)) &&
              pitsSeedsList[listPathClockwiseLast]! > 0;
      if (listPathAntiClockwiseCanCapture) {
        nextPhasePitsStartMoveWithCapture.add(i);
        nextPhasePitsStartMoveWithCaptureHintsMap["$i-"] =
            listPathAntiClockwise;
      }
      if (listPathClockwiseCanCapture) {
        nextPhasePitsStartMoveWithCapture.add(i);
        nextPhasePitsStartMoveWithCaptureHintsMap["$i+"] = listPathClockwise;
      }
      print(
          "Steps $steps antiClockwise $listPathAntiClockwise / ${listPathAntiClockwiseCanCapture ? " CAPTURE" : "NO CAPTURE"}  and clockwise $listPathClockwise / ${listPathClockwiseCanCapture ? " CAPTURE" : "NO CAPTURE"}");
    }
    print(
        "nextPhasePitsStartMoveWithCapture $nextPhasePitsStartMoveWithCapture");
    print(
        "nextPhasePitsStartMoveWithCaptureHintsMap $nextPhasePitsStartMoveWithCaptureHintsMap");
  }

  viewHintCaptureMove({required int pitIndex}) {
    /// Highlight path of a capture move
    print("Showing hints for $pitIndex");
    print(nextPhasePitsStartMoveWithCaptureHintsMap["$pitIndex-"] ?? []);
    print(nextPhasePitsStartMoveWithCaptureHintsMap["$pitIndex+"] ?? []);
    setState(() {
      viewHintCaptureMoveList =
          nextPhasePitsStartMoveWithCaptureHintsMap["$pitIndex-"] ?? [];
      viewHintCaptureMoveList.addAll(
          nextPhasePitsStartMoveWithCaptureHintsMap["$pitIndex+"] ?? []);
    });
    print("viewHintCaptureMoveList $viewHintCaptureMoveList");
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
    setState(() {
      /// TODO
      /// Where to add seed
      /// In which direction to add seed
      if (currentCarryingSeeds != 0 && selectedDirection == 0) {
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
            // isCapturedFromServe = false;
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
            // isCapturedFromServe = false;
          } else {
            selectedDirection = -1;
            pitsIndexesToAddSeed = sowing(
                start: centerIndex,
                steps: currentCarryingSeeds,
                dirAnticlockwise: selectedDirection);
          }
        }
        if (pitsSeedsList[pitsIndexesToAddSeed.last]! > 0 &&
            (southInnerRow.contains(pitsIndexesToAddSeed.last) ||
                northInnerRow.contains(pitsIndexesToAddSeed.last)) &&
            checkForPitIndexIfCanCapture(pitIndex: pitsIndexesToAddSeed.last)) {
          isCapturedFromTakataPhase = true;
          print(
              "isCapturedFromTakataPhase $isCapturedFromTakataPhase ${pitsIndexesToAddSeed.last}");
        } else {
          isCapturedFromTakataPhase = false;
          print(
              "isCapturedFromTakataPhase $isCapturedFromTakataPhase  ${pitsIndexesToAddSeed.last}");
        }
      }
      if (currentCarryingSeeds > 0) {
        if (pitsIndexesToAddSeed.contains(pitIndex)) {
          if (pitsIndexesToAddSeed[0] == pitIndex) {
            addSeedToPitSoundEffect();

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
                      /// TODO
                      print("I'm North and Alive House CAN capture");
                    } else {
                      print("I'm North and Alive House but can't capture");
                    }
                  }
                  if (last == southHouseIndex &&
                      checkIfHouseStillHasReputation(
                          houseIndex: southHouseIndex)) {
                    if (isCapturedFromServe) {
                      /// TODO
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
                  if (adjacentCapturingPairPits.contains(pitIndex) &&
                      (isCapturedFromServe || isCapturedFromTakataPhase)) {
                    if (pitIndex < 16 && pitsSeedsList[pitIndex + 8]! > 0) {
                      if (pitIndex + 8 == southHouseIndex) {
                        updateHouseFunctional(houseIndex: southHouseIndex);
                      }
                      currentCarryingSeeds = pitsSeedsList[pitIndex + 8]!;
                      pitsSeedsList[pitIndex + 8] = 0;
                      // isCapturedFromServe = true;
                      if (selectedDirection == 0) {
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
              checkForPossibleCaptureForNextPlayerMove(
                  isNorthPlaying: northIsPlaying);
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
        /// If No House, seed must be added to pits with more than 1 seed if present

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
            print("Now capturing from South house");
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
            pitsIndexesToAddSeed = []; // reset after capture options
            chooseDirectionFromCapture(fromPit: pitIndex);
          }
          carryingSeedsFromPit(pitIndexFrom: pitIndex);
          currentCarryingSeedsFromServe = false;
          possibleCapturePits = [];
          print("isCapturedFromServe $isCapturedFromServe");
          return;
        } else if (pitIndex >= 16 && pitsSeedsList[pitIndex - 8]! > 0) {
          print("Now capturing from North");
          if (pitIndex - 8 == northHouseIndex) {
            print("Now capturing from North house");
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
            pitsIndexesToAddSeed = []; // reset after capture options
            chooseDirectionFromCapture(fromPit: pitIndex);
          }
          carryingSeedsFromPit(pitIndexFrom: pitIndex);
          currentCarryingSeedsFromServe = false;
          possibleCapturePits = []; // RESET PITS HINTS
          print("isCapturedFromServe $isCapturedFromServe");
          return;
        }
      }

      /// Resetting
      // pitsIndexesToAddSeed = [];
      isCapturedFromServe = false;
      print("Added from serve, WITHOUT capture");
      print("isCapturedFromServe $isCapturedFromServe");
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

  /// TODO:
  forceCaptureTakataPhase({required int pitIndex}) {}
  addSeedFromServeToHouseWithoutCapture({required int houseIndex}) {
    setState(() {
      northCarryingSeedFromServe = 0;
      southCarryingSeedFromServe = 0;

      /// Resetting
      // pitsIndexesToAddSeed = [];
      isCapturedFromServe = false;
      print("Added from serve, WITHOUT capture");
      chooseDirection(fromPit: houseIndex);
      centerPitIndexFrom = houseIndex;

      ///Emptying the pit
      if (!currentCarryingSeedsFromServe) {
        currentCarryingSeeds = 2;
        pitsSeedsList[houseIndex] = pitsSeedsList[houseIndex]! - 1;
        print("Remove one from House");
      }
    });
  }

  checkIfItsCorrespondingInnerRowHasMoreThanOneSeedPit(
      {required int pitIndex}) {
    if (pitIndex < 16) {
      /// Check on North
      for (int i in northInnerRow) {
        if (pitsSeedsList[i]! > 1) {
          print("Can't start from $pitIndex pit, just play the innerRow pit");
          return true;
        }
      }
    } else {
      /// Check on South
      for (int i in southInnerRow) {
        if (pitsSeedsList[i]! > 1) {
          print("Can't start from $pitIndex pit, just play the innerRow pit");
          return true;
        }
      }
    }
    return false; // Has it
  }

  ///TODO
  forceCaptureFromServeIfPossible({required bool isNorthPlaying}) {
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

  checkIfThereAreOtherPitsWithMoreThanOneSeed(
      {required bool isNorth, required int pitIndex}) {
    if (isNorth) {
      for (int i in northAntiClockwiseIndexes) {
        if (pitsSeedsList[i]! > 1 && i != pitIndex) {
          if (i == 11 && checkIfHouseStillHasReputation(houseIndex: 11)) {
            return false;
          } else {
            return true;
          }
        }
      }
      return false;
    } else {
      for (int i in southAntiClockwiseIndexes) {
        if (pitsSeedsList[i]! > 1 && i != pitIndex) {
          if (i == 20 && checkIfHouseStillHasReputation(houseIndex: 20)) {
            return false;
          } else {
            return true;
          }
        }
      }
      return false;
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
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    double sMin = MediaQuery.maybeOf(context)!.size.shortestSide;
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
                    colorFilter: ColorFilter.mode(
                      Color(0xff402609),
                      BlendMode.screen,
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  boxShadow: boxShadow(),
                ),
                width: sMin * 3 / 2,
                height: sMin * 3 / 4,
                child: Stack(
                  // shrinkWrap: true,
                  // clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Container(
                        child: removeScrollGlow(
                          listChild: GridView.count(
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// SEED FROM SERVES ON MOVE
          Positioned(
            top: 0,
            height: sMin * 1 / 8,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: currentServesNorth == 0 && currentServesSouth == 0
                  ? SizedBox()
                  : serves(isNorth: true, w: sMin),
            ),
          ),
          Positioned(
            height: sMin * 1 / 8,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: currentServesNorth == 0 && currentServesSouth == 0
                  ? SizedBox()
                  : serves(isNorth: false, w: sMin),
            ),
          ),
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
          Positioned(
            child: Text(
              currentCarryingSeeds.toString(),
              style: TextStyle(fontSize: 48, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> boxShadow() {
    return [
      BoxShadow(
        color: Colors.brown.shade800,
        blurRadius: 0,
        spreadRadius: 1,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.brown.shade400,
        blurRadius: 0,
        spreadRadius: 1,
        offset: Offset(-4, 0),
      ),
      BoxShadow(
        color: Colors.brown.shade600,
        blurRadius: 0,
        spreadRadius: 1,
        offset: Offset(4, 0),
      ),
      BoxShadow(
        color: Colors.brown.shade500,
        blurRadius: 0,
        spreadRadius: 1,
        offset: Offset(0, -4),
      ),
    ];
  }

  Widget slideIt(BuildContext context, int index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: seedOnMove(isNorth: true),
    );
  }

  Wrap serves({required bool isNorth, required double w}) {
    return Wrap(
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
            // padding: EdgeInsets.all(8),
            width: w * 3 / 2,

            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bao-bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xff402609),
                  BlendMode.screen,
                ),
              ),
              boxShadow: boxShadow(),
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.shortestSide),
            ),
            child: isNorth
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(math.pi),
                    child: kete(-2, currentServesNorth, w, true),
                  )
                : kete(-2, currentServesSouth, w, true),
          ),
        ),
      ],
    );
  }

  Container pit({required int i, required double sMin}) {
    bool isNorth = true;
    if (i >= pits / 2) {
      isNorth = false;
    }
    return Container(
      child: Transform(
        alignment: Alignment.center,
        transform: i >= pits / 2 ? Matrix4.rotationZ(0) : Matrix4.rotationZ(0),
        child: InkWell(
          onTap: () {
            print("onTap Okay");
            print(pitsIndexesToAddSeed);
            if (northCarryingSeedFromServe == 1 ||
                southCarryingSeedFromServe == 1) {
              if (i == southHouseIndex || i == northHouseIndex) {
                /// Check if House is eligible
                if (pitsIndexesToAddSeed.contains(i)) {
                  if (checkIfHouseStillHasReputation(houseIndex: i)) {
                    print("pitsIndexesToAddSeed " +
                        pitsIndexesToAddSeed.toString());
                    // if (checkForPitIndexIfCanCapture(pitIndex: i)) {
                    //   /// Add with capture
                    //   addSingleSeedToPitFromServe(
                    //     pitIndex: i,
                    //   );
                    //   return;
                    // } else {
                    //   /// Add without capture
                    //   addSeedFromServeToHouseWithoutCapture(houseIndex: i);
                    // }
                    // return;
                    if (!checkIfHouseIsEligibleToAcceptSeedFromServe(
                        houseIndex: i)) {
                      print(
                          "FAILED! Can't add to House, House can't capture and there are other pits to play");
                      return;
                    }
                    print(
                        "House has reputation, still can ACCEPT as others innerRow pits don't qualify");
                    if (checkForPitIndexIfCanCapture(pitIndex: i)) {
                    } else {
                      addSeedFromServeToHouseWithoutCapture(houseIndex: i);
                      return;
                    }
                  } else {
                    print("House just LOST his reputation, So can ACCEPT");
                  }
                } else {
                  return;
                }
              }
              print("Add from serve");
              addSingleSeedToPitFromServe(
                pitIndex: i,
              );
            } else if (centerPitIndexFrom != -1) {
              print("centerPitIndexFrom $centerPitIndexFrom");
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

            /// Can not sow from a pit with more than 15 seeds
            if (pitsSeedsList[i]! > 15) {
              if (checkIfThereAreOtherPitsWithMoreThanOneSeed(
                  isNorth: isNorth, pitIndex: i)) {
                print(
                    "Can not sow from a pit with more than 15 seeds, while there are other pits with more than one seed to play");
                return;
              }
            }

            /// Can not play non-capture move pit if there are capture moves
            if (nextPhasePitsStartMoveWithCapture.isNotEmpty &&
                !nextPhasePitsStartMoveWithCapture.contains(i)) {
              print(
                  "Can not play non-capture move pit if there are capture moves or You play on wrong Side");
              return;
            }
            print("viewHintCaptureMoveList $viewHintCaptureMoveList");
            if (!nextPhasePitsStartMoveWithCapture.contains(i)) {
              /// Restrict start on a move without capture from outer/back rows
              /// IF inner row has at least a single pit with 2 or more seeds
              /// Now check if the pit is on the outer/back row
              if (northInnerRow.contains(i) || southInnerRow.contains(i)) {
                /// Safe to Go
              } else {
                /// Check if innerRows has at least a single pit with 2 or more seeds
                if (checkIfItsCorrespondingInnerRowHasMoreThanOneSeedPit(
                    pitIndex: i)) {
                  return;
                }
              }
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
                  isCapturedFromTakataPhase = false;
                  isCapturedFromServe = false;
                  centerPitIndexFrom = i;
                  currentCarryingSeeds = pitsSeedsList[i]!;
                  nextPhasePitsStartMoveWithCapture = []; //reset
                  viewHintCaptureMoveList = []; //reset
                  ///Emptying the pit
                  pitsSeedsList[i] = 0;
                });
              }
            }
          },
          onLongPress: () {
            if (nextPhasePitsStartMoveWithCapture.contains(i)) {
              viewHintCaptureMove(pitIndex: i);

              /// TODO
              /// Highlight start pit
            }
          },
          child: Container(
            width: sMin * 3 / 16 * 22 / 24,
            height: sMin * 3 / 16 * 22 / 24,
            padding: EdgeInsets.all(
              sMin * 3 / 16 * 1 / 24,
            ),
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
                  // child: kete(i, pitsSeedsList[i]!, sMin, false),
                ),
                Positioned(
                  child: Builder(
                    builder: (BuildContext context) {
                      return pitItem(i);
                    },
                  ),
                ),
                possibleCapturePits.contains(i) ||
                        nextPhasePitsStartMoveWithCapture.contains(i)
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Opacity(
                          opacity: 1.0,
                          child: Container(
                            width: sMin / 32,
                            height: sMin / 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
                Container(
                  child: kete(i, pitsSeedsList[i]!, sMin, false),
                ),
                // Container(
                //   color: i < 16 ? Colors.red : Colors.yellow,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container pitItem(int i) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // border: Border.all(
        // color: activePit == i ? activePitColor : Color(0xffFFBD5E),
        // width: 1,
        // style: BorderStyle.none,
        // ),
        shape: i == southHouseIndex || i == northHouseIndex
            ? BoxShape.rectangle
            : BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xffC3762E),
          ),
          BoxShadow(
            color: Color(0xffFFBD5E),
            spreadRadius: -10,
            blurRadius: 4,
          ),
        ],
        gradient: RadialGradient(
          radius: 0.9,
          center: Alignment(0.5, 0.5),
          focalRadius: 0.01,
          focal: Alignment(0.4, 0.3),
          colors: [
            Color(0xffe89635),
            Colors.black38,
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
            center: Alignment(0.2, 0.2),
            focalRadius: 0.01,
            colors: [
              Colors.brown.shade200,
              Colors.brown.shade800,
              Colors.brown.shade200,
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
        clipBehavior: Clip.none,
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
                        border: Border.all(
                          color: Colors.grey.shade900,
                          width: 0.1,
                        ),
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          radius: 1,
                          center: Alignment(0.4, 0.2),
                          focalRadius: 0.01,
                          colors: [
                            Colors.brown.shade200,
                            Colors.brown.shade800,
                            Colors.brown.shade200,
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          seeds > 9
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
          (indicator(pitIndex: pit) &&
                      (northCarryingSeedFromServe == 0 &&
                          southCarryingSeedFromServe == 0)) ||
                  viewHintCaptureMoveList.contains(pit)
              ? Positioned(
                  bottom: 0,
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.3),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
