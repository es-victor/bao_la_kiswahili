import 'package:flutter/material.dart';

const pits = 32;
const maxSeeds = 64;
const southHomeIndex = 20;
const northHomeIndex = 11;

const activePitColor = Colors.greenAccent;

/// INITIAL CONDITIONS
const servesSeeds = 22;
const homeSeedsCount = 6; //11, 20
const adjacentPitsSeedsCount = 2; // 9, 10, 21, 22

/// 0   1   2   3   4   5   6   7
/// 8   9   10  11  12  13  14  15
/// 16  17  18  19  20  21  22  23
/// 24  25  26  27  28  29  30  31

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
