import 'training_position.dart';

enum StoneColor { empty, black, white }

class GoPosition {
  final List<List<StoneColor>> board;
  final int size;
  final TrainingPosition? trainingData;

  const GoPosition({
    required this.board,
    required this.size,
    this.trainingData,
  });

  factory GoPosition.empty(int size) {
    return GoPosition(
      board: List.generate(
        size,
        (_) => List.generate(size, (_) => StoneColor.empty),
      ),
      size: size,
    );
  }

  /// Create a GoPosition from TrainingPosition data
  factory GoPosition.fromTrainingPosition(TrainingPosition position) {
    final decodedBoard = position.decodeStones();
    final boardSize = position.boardSize;
    final board = List.generate(
      boardSize,
      (row) => List.generate(
        boardSize,
        (col) {
          switch (decodedBoard[row][col]) {
            case 1:
              return StoneColor.black;
            case 2:
              return StoneColor.white;
            default:
              return StoneColor.empty;
          }
        },
      ),
    );

    return GoPosition(
      board: board,
      size: boardSize,
      trainingData: position,
    );
  }

  factory GoPosition.demo() {
    // Simplified demo for fallback only
    return GoPosition(
      board: List.generate(
        19,
        (_) => List.generate(19, (_) => StoneColor.empty),
      ),
      size: 19,
    );
  }

  /// Get position metadata for display
  String get description {
    if (trainingData != null) {
      return trainingData!.description;
    }
    return 'Demo position';
  }

  /// Get the correct result for this position
  String get correctResult {
    if (trainingData != null) {
      return trainingData!.result;
    }
    return 'Unknown';
  }

  /// Check if a user's guess matches the correct result
  bool isCorrectGuess(String userResult) {
    if (trainingData == null) return false;

    final correct = trainingData!.winner.toLowerCase();
    return userResult.toLowerCase() == correct.toLowerCase();
  }
}