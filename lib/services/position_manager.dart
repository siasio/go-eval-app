import 'dart:async';
import '../models/go_position.dart';
import '../models/training_position.dart';
import 'position_loader.dart';

class PositionManager {
  GoPosition? _currentPosition;
  TrainingPosition? _currentTrainingPosition;
  bool _isLoading = false;

  /// Get the current position
  GoPosition? get currentPosition => _currentPosition;

  /// Get the current training position data
  TrainingPosition? get currentTrainingPosition => _currentTrainingPosition;

  /// Check if currently loading a position
  bool get isLoading => _isLoading;

  /// Load and return a random position
  Future<GoPosition> loadRandomPosition() async {
    _isLoading = true;

    try {
      _currentTrainingPosition = await PositionLoader.getRandomPosition();
      _currentPosition = GoPosition.fromTrainingPosition(_currentTrainingPosition!);

      print('Loaded position: ${_currentTrainingPosition!.id}');
      print('Players: ${_currentTrainingPosition!.source.players.black} vs ${_currentTrainingPosition!.source.players.white}');
      print('Result: ${_currentTrainingPosition!.result}');
      print('Difficulty: ${_currentTrainingPosition!.difficulty}');

      return _currentPosition!;
    } catch (e) {
      print('Error loading position: $e');
      // Fallback to demo position
      _currentPosition = GoPosition.demo();
      _currentTrainingPosition = null;
      return _currentPosition!;
    } finally {
      _isLoading = false;
    }
  }

  /// Load a position by difficulty level
  Future<GoPosition> loadPositionByDifficulty(String difficulty) async {
    _isLoading = true;

    try {
      _currentTrainingPosition = await PositionLoader.getRandomPositionByDifficulty(difficulty);
      _currentPosition = GoPosition.fromTrainingPosition(_currentTrainingPosition!);

      print('Loaded $difficulty position: ${_currentTrainingPosition!.id}');

      return _currentPosition!;
    } catch (e) {
      print('Error loading $difficulty position: $e');
      // Fallback to random position
      return await loadRandomPosition();
    } finally {
      _isLoading = false;
    }
  }

  /// Check if the user's result selection is correct
  bool checkResult(String userResult) {
    if (_currentPosition == null || _currentTrainingPosition == null) {
      return false;
    }

    final correctResult = _currentTrainingPosition!.winner.toLowerCase();
    final userGuess = userResult.toLowerCase();

    return correctResult == userGuess;
  }

  /// Get feedback message for the user's selection
  String getFeedbackMessage(String userResult) {
    if (_currentTrainingPosition == null) {
      return 'You selected: $userResult';
    }

    final isCorrect = checkResult(userResult);
    final correctAnswer = _currentTrainingPosition!.winner;
    final margin = _currentTrainingPosition!.margin;

    if (isCorrect) {
      return '✓ Correct! $correctAnswer wins by $margin';
    } else {
      return '✗ Incorrect. $correctAnswer wins by $margin';
    }
  }

  /// Get position info for display
  String getPositionInfo() {
    if (_currentTrainingPosition == null) {
      return 'Demo position';
    }

    return _currentTrainingPosition!.description;
  }

  /// Preload the dataset during app initialization
  static Future<void> initialize() async {
    try {
      await PositionLoader.preloadDataset();
      print('Position manager initialized successfully');
    } catch (e) {
      print('Warning: Failed to preload positions: $e');
    }
  }

  /// Clear current position (useful for testing)
  void clear() {
    _currentPosition = null;
    _currentTrainingPosition = null;
    _isLoading = false;
  }
}