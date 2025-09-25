/// Pure functions for parsing Go game results without Flutter dependencies
class GameResultParser {
  /// Parse the winner from a result string
  /// Examples: "B+5.5" -> "Black", "W+12" -> "White", "Draw" -> "Draw"
  static String parseWinner(String result) {
    if (result.startsWith('B+')) {
      return 'Black';
    } else if (result.startsWith('W+')) {
      return 'White';
    } else if (result.toLowerCase() == 'draw') {
      return 'Draw';
    } else {
      return 'Unknown';
    }
  }

  /// Parse the margin of victory from a result string
  /// Examples: "B+5.5" -> "5.5 points", "W+R" -> "Resignation", "Draw" -> "Draw"
  static String parseMargin(String result) {
    if (result.contains('R')) {
      return 'Resignation';
    }

    if (result.toLowerCase() == 'draw') {
      return 'Draw';
    }

    final match = RegExp(r'[+-]?(\d+\.?\d*)').firstMatch(result);
    if (match != null) {
      return '${match.group(1)} points';
    }

    return result;
  }

  /// Parse the score difference from a result string
  /// Returns positive for Black advantage, negative for White advantage
  /// Examples: "B+5.5" -> 5.5, "W+12" -> -12.0, "Draw" -> 0.0
  static double parseScoreDifference(String result) {
    if (result.toLowerCase() == 'draw') {
      return 0.0;
    }

    if (result.contains('R')) {
      // For resignation, we don't know the exact margin
      // Return a large value indicating decisive victory
      if (result.startsWith('B+')) {
        return 100.0; // Black wins by resignation
      } else if (result.startsWith('W+')) {
        return -100.0; // White wins by resignation
      }
      return 0.0;
    }

    final match = RegExp(r'([BW])[+-]?(\d+\.?\d*)').firstMatch(result);
    if (match != null) {
      final winner = match.group(1)!;
      final margin = double.tryParse(match.group(2)!) ?? 0.0;

      if (winner == 'B') {
        return margin;
      } else {
        return -margin;
      }
    }

    return 0.0;
  }

  /// Check if a user's guess matches the correct result
  static bool isCorrectGuess(String userGuess, String correctResult) {
    final userWinner = parseWinner(userGuess.trim());
    final correctWinner = parseWinner(correctResult);

    return userWinner.toLowerCase() == correctWinner.toLowerCase();
  }

  /// Format a score as a standard Go result string
  /// Examples: formatResult(5.5, true) -> "B+5.5", formatResult(12, false) -> "W+12"
  static String formatResult(double margin, bool blackWins, {bool resignation = false}) {
    if (margin == 0.0) {
      return 'Draw';
    }

    final prefix = blackWins ? 'B+' : 'W+';

    if (resignation) {
      return '${prefix}R';
    }

    // Format margin appropriately (remove .0 for whole numbers)
    final marginStr = margin == margin.roundToDouble()
        ? margin.round().toString()
        : margin.toString();

    return '$prefix$marginStr';
  }

  /// Validate if a result string is in correct format
  static bool isValidResultFormat(String result) {
    // Check for standard patterns: B+12.5, W+R, Draw, etc.
    final patterns = [
      RegExp(r'^B\+\d+(\.\d+)?$'), // B+5, B+5.5
      RegExp(r'^W\+\d+(\.\d+)?$'), // W+12, W+7.5
      RegExp(r'^B\+R$'),           // B+R (resignation)
      RegExp(r'^W\+R$'),           // W+R (resignation)
      RegExp(r'^Draw$', caseSensitive: false), // Draw
    ];

    return patterns.any((pattern) => pattern.hasMatch(result));
  }

  /// Parse multiple results and return statistics
  static ResultStatistics analyzeResults(List<String> results) {
    int blackWins = 0;
    int whiteWins = 0;
    int draws = 0;
    int resignations = 0;
    double totalScoreDiff = 0.0;
    int validResults = 0;

    for (final result in results) {
      if (!isValidResultFormat(result)) {
        continue;
      }

      validResults++;
      final winner = parseWinner(result);
      final scoreDiff = parseScoreDifference(result);

      switch (winner.toLowerCase()) {
        case 'black':
          blackWins++;
          break;
        case 'white':
          whiteWins++;
          break;
        case 'draw':
          draws++;
          break;
      }

      if (result.contains('R')) {
        resignations++;
      }

      totalScoreDiff += scoreDiff.abs();
    }

    return ResultStatistics(
      totalGames: validResults,
      blackWins: blackWins,
      whiteWins: whiteWins,
      draws: draws,
      resignations: resignations,
      averageMargin: validResults > 0 ? totalScoreDiff / validResults : 0.0,
    );
  }
}

/// Statistics about a collection of game results
class ResultStatistics {
  final int totalGames;
  final int blackWins;
  final int whiteWins;
  final int draws;
  final int resignations;
  final double averageMargin;

  const ResultStatistics({
    required this.totalGames,
    required this.blackWins,
    required this.whiteWins,
    required this.draws,
    required this.resignations,
    required this.averageMargin,
  });

  double get blackWinRate => totalGames > 0 ? blackWins / totalGames : 0.0;
  double get whiteWinRate => totalGames > 0 ? whiteWins / totalGames : 0.0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0.0;
  double get resignationRate => totalGames > 0 ? resignations / totalGames : 0.0;

  @override
  String toString() {
    return 'ResultStatistics(games: $totalGames, B: $blackWins, W: $whiteWins, '
           'draws: $draws, resignations: $resignations, avgMargin: ${averageMargin.toStringAsFixed(1)})';
  }
}