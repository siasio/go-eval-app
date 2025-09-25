class ScoringConfig {
  final double drawBorder;
  final double colorBorder;

  const ScoringConfig({
    required this.drawBorder,
    required this.colorBorder,
  });

  /// Default configuration: draw within 3 points, colors beyond 3 points
  static const ScoringConfig defaultConfig = ScoringConfig(
    drawBorder: 3.0,
    colorBorder: 3.0,
  );

  /// Check if a score should be considered a draw
  bool isDraw(double score) {
    return score >= -drawBorder && score <= drawBorder;
  }

  /// Check if White should win (score < -colorBorder)
  bool isWhiteWin(double score) {
    return score < -colorBorder;
  }

  /// Check if Black should win (score > colorBorder)
  bool isBlackWin(double score) {
    return score > colorBorder;
  }

  /// Get all valid results for a given score
  /// Returns a list of GameResult that should show green tick
  List<GameResult> getValidResults(double score) {
    List<GameResult> validResults = [];

    if (isDraw(score)) {
      validResults.add(GameResult.draw);
    }

    if (isWhiteWin(score)) {
      validResults.add(GameResult.whiteWins);
    }

    if (isBlackWin(score)) {
      validResults.add(GameResult.blackWins);
    }

    return validResults;
  }

  /// Parse score from result string (e.g., "W+2.5" -> -2.5, "B+7" -> 7.0)
  static double parseScore(String result) {
    if (result.isEmpty) return 0.0;

    // Handle resignation - treat as large margin
    if (result.endsWith('+R')) {
      return result.startsWith('B') ? 50.0 : -50.0;
    }

    // Extract numeric part
    final match = RegExp(r'([BW])([+-])(\d+\.?\d*)').firstMatch(result);
    if (match != null) {
      final color = match.group(1)!;
      final sign = match.group(2)!;
      final points = double.tryParse(match.group(3)!) ?? 0.0;

      // Black wins are positive, White wins are negative
      if (color == 'B') {
        return sign == '+' ? points : -points;
      } else {
        return sign == '+' ? -points : points;
      }
    }

    return 0.0;
  }
}

enum GameResult { whiteWins, draw, blackWins }