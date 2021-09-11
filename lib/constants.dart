import 'package:flutter/material.dart';

const pits = 32;
const maxSeeds = 64;
const southHouseIndex = 20;
const northHouseIndex = 11;

const activePitColor = Colors.greenAccent;

/// INITIAL CONDITIONS
const servesSeeds = 0;
const houseSeedsCount = 6; //11, 20
const adjacentPitsSeedsCount = 2; // 9, 10, 21, 22

/// 0   1   2   3   4   5   6   7
/// 8   9   10  11  12  13  14  15
/// 16  17  18  19  20  21  22  23
/// 24  25  26  27  28  29  30  31
const List<int> adjacentCapturingPairPits = [
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23
];
const List<int> northInnerRow = [8, 9, 10, 11, 12, 13, 14, 15];
const List<int> southInnerRow = [16, 17, 18, 19, 20, 21, 22, 23];
const List<int> northAntiClockwiseIndexes = [
  7,
  6,
  5,
  4,
  3,
  2,
  1,
  0,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15
];
const List<int> southAntiClockwiseIndexes = [
  23,
  22,
  21,
  20,
  19,
  18,
  17,
  16,
  24,
  25,
  26,
  27,
  28,
  29,
  30,
  31
];
const List<int> northClockwiseIndexes = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  15,
  14,
  13,
  12,
  11,
  10,
  9,
  8
];
const List<int> southClockwiseIndexes = [
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  31,
  30,
  29,
  28,
  27,
  26,
  25,
  24
];

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
      // print(sowingIndexes);
      // print(sowingIndexes.length);
      // print("########=========##########");
    }
  }
  return sowingIndexes;
}

List<int> sowingAfterCapture(
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

List<int> sowingAfterCaptureFromSowing(
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
      int startKey = -1;
      int endKey = -1;

      /// get Key for starting point from a map
      a.forEach((key, value) {
        if (value == start) {
          startKey = key;
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
