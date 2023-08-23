import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

extension StringX on String {
  Color hexToColor() =>
      Color(int.parse(substring(1, 7), radix: 16) + 0xFF000000);

  int toInt() => int.parse(this);
  double get toDouble => double.parse(this);

  Uri toUri() => Uri.parse(this);

  String toShortString() {
    return split('.').last.toLowerCase();
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String capitalizeWords() {
    List<String> words = split(' ');

    List<String> capitalizedWords = words.map((word) {
      String firstLetter = word.substring(0, 1).toUpperCase();
      String remainingLetters = word.substring(1);
      return '$firstLetter$remainingLetters';
    }).toList();

    return capitalizedWords.join(' ');
  }

  DateTime fromTimeStamp() {
    return DateTime.fromMillisecondsSinceEpoch(toInt() * 1000);
  }

  Map<String, dynamic>  get fromJwtStringToMap {
    return json.decode(decodeBase64);
  }

  String get decodeBase64 {
    String output = base64Url.normalize(this);
    return utf8.decode(base64Url.decode(output));
  }

  String findMostSimilarString(List<String> stringList) {
    int minDistance = double.maxFinite.toInt();
    String mostSimilarString = '';

    for (String otherString in stringList) {
      int distance = _levenshteinDistance(otherString, this);
      if (distance < minDistance) {
        minDistance = distance;
        mostSimilarString = otherString;
      }
    }

    return mostSimilarString;
  }

  int _levenshteinDistance(String a, String b) {
    int m = a.length;
    int n = b.length;

    List<int> previousRow = List<int>.filled(n + 1, 0);
    List<int> currentRow = List<int>.filled(n + 1, 0);

    for (int j = 0; j <= n; j++) {
      previousRow[j] = j;
    }

    for (int i = 1; i <= m; i++) {
      currentRow[0] = i;

      for (int j = 1; j <= n; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        int insert = currentRow[j - 1] + 1;
        int delete = previousRow[j] + 1;
        int replace = previousRow[j - 1] + cost;

        currentRow[j] = [insert, delete, replace].reduce((min));
      }

      List<int> tempRow = previousRow;
      previousRow = currentRow;
      currentRow = tempRow;
    }

    return previousRow[n];
  }
}

extension IntX on num {
  String toStringAndFill({int length = 2, String value = '0'}) => toString().padLeft(length, value);
}

extension DoubleX on double {
  double truncateToDecimals(int decimals) =>
      double.parse(toStringAsFixed(decimals));
}

extension DurationX on Duration {
  String toTimeFormattedString() {
    String twoDigitSeconds = inSeconds.remainder(60).toStringAndFill();
    String twoDigitMinutes = '${inMinutes.remainder(60).toStringAndFill()}:';
    String twoDigitHours = inHours == 0 ? '' : '${inHours.toStringAndFill()}:';

    String finalStr = '$twoDigitHours$twoDigitMinutes$twoDigitSeconds';
    return finalStr;
  }
}

extension DateTimeX on DateTime {
  int get toTimeStamp => millisecondsSinceEpoch ~/ 1000;
}


extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  Size get sizeOf {
    return MediaQuery.sizeOf(this);
  }
}