import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/training_position.dart';
import '../core/dataset_parser.dart' as parser;

enum DatasetSource {
  asset,
  file,
  bytes,
}

class PositionLoader {
  static TrainingDataset? _cachedDataset;
  static final Random _random = Random();
  static String _datasetFile = 'assets/19x19_midgame_positions.json';
  static DatasetSource _datasetSource = DatasetSource.asset;
  static String? _filePath;
  static Uint8List? _fileBytes;

  /// Set which dataset file to load from assets
  static void setDatasetFile(String filename) {
    _datasetFile = filename.startsWith('assets/') ? filename : 'assets/$filename';
    _datasetSource = DatasetSource.asset;
    _filePath = null;
    _fileBytes = null;
    _cachedDataset = null; // Clear cache when switching datasets
  }

  /// Load dataset from a file path (mobile/desktop)
  static Future<TrainingDataset> loadFromFile(String filePath) async {
    _datasetFile = filePath;
    _datasetSource = DatasetSource.file;
    _filePath = filePath;
    _fileBytes = null;
    _cachedDataset = null;
    return await loadDataset();
  }

  /// Load dataset from bytes (web)
  static Future<TrainingDataset> loadFromBytes(Uint8List bytes, String filename) async {
    _datasetFile = filename;
    _datasetSource = DatasetSource.bytes;
    _filePath = null;
    _fileBytes = bytes;
    _cachedDataset = null;
    return await loadDataset();
  }

  /// Get the current dataset filename
  static String get datasetFile => _datasetFile;

  /// Load the training dataset from the configured source
  static Future<TrainingDataset> loadDataset() async {
    if (_cachedDataset != null) {
      return _cachedDataset!;
    }

    try {
      String jsonString;

      switch (_datasetSource) {
        case DatasetSource.asset:
          jsonString = await rootBundle.loadString(_datasetFile);
          break;
        case DatasetSource.file:
          if (_filePath == null) {
            throw Exception('File path not set for file source');
          }
          if (kIsWeb) {
            throw Exception('File system access not supported on web');
          }
          try {
            final file = File(_filePath!);
            jsonString = await file.readAsString();
          } catch (e) {
            throw Exception('Failed to read file $_filePath: $e');
          }
          break;
        case DatasetSource.bytes:
          if (_fileBytes == null) {
            throw Exception('File bytes not set for bytes source');
          }
          jsonString = String.fromCharCodes(_fileBytes!);
          break;
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Validate dataset before parsing
      final validationErrors = parser.DatasetParser.validateDataset(jsonData);
      if (validationErrors.isNotEmpty) {
        throw Exception('Dataset validation failed: ${validationErrors.join(', ')}');
      }

      _cachedDataset = TrainingDataset.fromJson(jsonData);

      print('Loaded dataset from $_datasetFile: ${_cachedDataset!.metadata.totalPositions} positions');
      print('Dataset name: ${_cachedDataset!.metadata.name}');

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


  /// Get dataset statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final dataset = await loadDataset();
    return {
      'total_positions': dataset.metadata.totalPositions,
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

  /// Get current dataset source information
  static Map<String, dynamic> getSourceInfo() {
    return {
      'source': _datasetSource.toString().split('.').last,
      'file': _datasetFile,
      'path': _filePath,
      'has_bytes': _fileBytes != null,
    };
  }
}