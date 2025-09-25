import 'dart:convert';

/// Pure functions for parsing dataset JSON data without Flutter dependencies
class DatasetParser {
  // Forward declarations for type checking
  static const String _datasetMetadataType = 'DatasetMetadata';
  static const String _trainingPositionType = 'TrainingPosition';
  static const String _gameInfoType = 'GameInfo';
  static const String _moveSequenceType = 'MoveSequence';
  static const String _boardDisplayType = 'BoardDisplay';
  /// Parse dataset metadata from JSON - returns Map to avoid type conflicts
  static Map<String, dynamic> parseMetadataToMap(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now();
    return {
      'name': json['name'] as String? ?? 'Unknown Dataset',
      'description': json['description'] as String? ?? 'No description',
      'version': json['version'] as String? ?? '1.0.0',
      'created_at': createdAt.toIso8601String(),
      'total_positions': json['total_positions'] as int? ?? 0,
      'dataset_type': json['dataset_type'] as String? ?? 'final-9x9-area',
    };
  }

  /// Parse game info from JSON - returns Map to avoid type conflicts
  static Map<String, dynamic> parseGameInfoToMap(Map<String, dynamic> json) {
    return {
      'black_captured': json['black_captured'] as int? ?? 0,
      'white_captured': json['white_captured'] as int? ?? 0,
      'komi': (json['komi'] as num?)?.toDouble() ?? 0.0,
      'last_move_row': json['last_move_row'] as int?,
      'last_move_col': json['last_move_col'] as int?,
      'move_sequence': json['move_sequence'],
      'board_display': json['board_display'],
    };
  }

  /// Parse move sequence from JSON - returns Map to avoid type conflicts
  static Map<String, dynamic> parseMoveSequenceToMap(Map<String, dynamic> json) {
    return {
      'row': json['row'] as int? ?? 0,
      'col': json['col'] as int? ?? 0,
      'move_number': json['move_number'] as int? ?? 0,
    };
  }

  /// Parse board display configuration from JSON - returns Map to avoid type conflicts
  static Map<String, dynamic> parseBoardDisplayToMap(Map<String, dynamic> json) {
    return {
      'crop_start_row': json['crop_start_row'] as int?,
      'crop_start_col': json['crop_start_col'] as int?,
      'crop_width': json['crop_width'] as int?,
      'crop_height': json['crop_height'] as int?,
      'focus_start_row': json['focus_start_row'] as int?,
      'focus_start_col': json['focus_start_col'] as int?,
      'focus_width': json['focus_width'] as int?,
      'focus_height': json['focus_height'] as int?,
    };
  }

  /// Parse training position from JSON - returns Map to avoid type conflicts
  static Map<String, dynamic> parseTrainingPositionToMap(Map<String, dynamic> json) {
    return {
      'id': json['id'] as String? ?? '',
      'board_size': json['board_size'] as int? ?? 19,
      'stones': json['stones'] as String? ?? '',
      'score': (json['score'] as num?)?.toDouble() ?? 0.0,
      'result': json['result'] as String? ?? 'Unknown',
      'game_info': json['game_info'] != null
          ? parseGameInfoToMap(json['game_info'] as Map<String, dynamic>)
          : null,
    };
  }

  /// Parse complete training dataset from JSON - returns Map to avoid type conflicts
  static Map<String, dynamic> parseDatasetToMap(Map<String, dynamic> json) {
    final metadata = parseMetadataToMap(json['metadata'] as Map<String, dynamic>);
    final positions = (json['positions'] as List)
        .map((p) => parseTrainingPositionToMap(p as Map<String, dynamic>))
        .toList();

    return {
      'metadata': metadata,
      'positions': positions,
    };
  }

  /// Parse dataset from JSON string - returns Map to avoid type conflicts
  static Map<String, dynamic> parseDatasetFromStringToMap(String jsonString) {
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return parseDatasetToMap(jsonData);
  }

  /// Validate dataset structure
  static List<String> validateDataset(Map<String, dynamic> json) {
    final errors = <String>[];

    // Check required top-level fields
    if (!json.containsKey('metadata')) {
      errors.add('Missing required field: metadata');
    }
    if (!json.containsKey('positions')) {
      errors.add('Missing required field: positions');
    }

    // Validate metadata
    if (json.containsKey('metadata')) {
      final metadata = json['metadata'] as Map<String, dynamic>?;
      if (metadata == null) {
        errors.add('metadata field is null');
      } else {
        if (!metadata.containsKey('name')) {
          errors.add('Missing required field: metadata.name');
        }
        if (!metadata.containsKey('total_positions')) {
          errors.add('Missing required field: metadata.total_positions');
        }
        if (!metadata.containsKey('dataset_type')) {
          errors.add('Missing required field: metadata.dataset_type');
        }
      }
    }

    // Validate positions
    if (json.containsKey('positions')) {
      final positions = json['positions'];
      if (positions is! List) {
        errors.add('positions field must be a list');
      } else {
        for (int i = 0; i < positions.length; i++) {
          final pos = positions[i];
          if (pos is! Map<String, dynamic>) {
            errors.add('Position $i must be an object');
            continue;
          }

          final posMap = pos as Map<String, dynamic>;
          final requiredFields = ['id', 'board_size', 'stones', 'score', 'result'];
          for (final field in requiredFields) {
            if (!posMap.containsKey(field)) {
              errors.add('Position $i missing required field: $field');
            }
          }
        }
      }
    }

    return errors;
  }
}

