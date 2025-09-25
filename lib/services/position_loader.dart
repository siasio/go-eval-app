import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/training_position.dart';

class PositionLoader {
  static TrainingDataset? _cachedDataset;
  static final Random _random = Random();
  static String _datasetFile = 'assets/19x19_midgame_positions.json';

  /// Set which dataset file to load
  static void setDatasetFile(String filename) {
    _datasetFile = filename.startsWith('assets/') ? filename : 'assets/$filename';
    _cachedDataset = null; // Clear cache when switching datasets
  }

  /// Get the current dataset filename
  static String get datasetFile => _datasetFile;

  /// Load the training dataset from assets
  static Future<TrainingDataset> loadDataset() async {
    if (_cachedDataset != null) {
      return _cachedDataset!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_datasetFile);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedDataset = TrainingDataset.fromJson(jsonData);

      print('Loaded dataset from $_datasetFile: ${_cachedDataset!.metadata.totalPositions} positions');
      print('Dataset name: ${_cachedDataset!.metadata.name}');
      print('Difficulty distribution: ${_cachedDataset!.metadata.difficultyDistribution}');

      return _cachedDataset!;
    } catch (e) {
      print('Error loading dataset: $e');
      rethrow;
    }
  }

  /// Get a random position from the dataset
  static Future<TrainingPosition> getRandomPosition() async {
    final dataset = await loadDataset();
    final randomIndex = _random.nextInt(dataset.positions.length);
    return dataset.positions[randomIndex];
  }

  /// Get a random position from a specific difficulty level
  static Future<TrainingPosition> getRandomPositionByDifficulty(String difficulty) async {
    final dataset = await loadDataset();
    final positions = dataset.getByDifficulty(difficulty);

    if (positions.isEmpty) {
      throw Exception('No positions found for difficulty: $difficulty');
    }

    final randomIndex = _random.nextInt(positions.length);
    return positions[randomIndex];
  }

  /// Get dataset statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final dataset = await loadDataset();
    return {
      'total_positions': dataset.metadata.totalPositions,
      'difficulty_distribution': dataset.metadata.difficultyDistribution,
      'created_at': dataset.metadata.createdAt.toIso8601String(),
      'version': dataset.metadata.version,
    };
  }

  /// Preload the dataset (call this during app initialization)
  static Future<void> preloadDataset() async {
    await loadDataset();
  }

  /// Clear the cached dataset (useful for testing)
  static void clearCache() {
    _cachedDataset = null;
  }
}