import 'dart:math' show min;
import 'dart:ui' show Color;

extension StringX on String {
  Color hexToColor() =>
      Color(int.parse(substring(1, 7), radix: 16) + 0xFF000000);

  String toShortString() {
    return split('.').last.toLowerCase();
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