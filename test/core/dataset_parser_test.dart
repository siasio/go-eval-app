import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/dataset_parser.dart';
import '../../lib/models/training_position.dart';
import '../../lib/models/dataset_type.dart';

void main() {
  group('DatasetParser', () {
    group('parseMetadataToMap', () {
      test('should parse valid metadata correctly', () {
        final json = {
          'name': 'Test Dataset',
          'description': 'A test dataset',
          'version': '1.0.0',
          'created_at': '2025-01-15T10:30:00.000Z',
          'total_positions': 100,
          'dataset_type': 'final-9x9-area',
        };

        final metadata = DatasetParser.parseMetadataToMap(json);

        expect(metadata['name'], equals('Test Dataset'));
        expect(metadata['description'], equals('A test dataset'));
        expect(metadata['version'], equals('1.0.0'));
        expect(metadata['total_positions'], equals(100));
        expect(metadata['dataset_type'], equals('final-9x9-area'));
        expect(DateTime.parse(metadata['created_at'] as String).year, equals(2025));
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final parsed = DatasetParser.parseMetadataToMap(json);
        final metadata = DatasetMetadata.fromJson(parsed);

        expect(metadata.name, equals('Unknown Dataset'));
        expect(metadata.description, equals('No description'));
        expect(metadata.version, equals('1.0.0'));
        expect(metadata.totalPositions, equals(0));
        expect(metadata.datasetType, equals(DatasetType.final9x9Area));
        expect(metadata.createdAt, isNotNull);
      });

      test('should handle invalid date format', () {
        final json = {
          'name': 'Test',
          'created_at': 'invalid-date',
        };

        final parsed = DatasetParser.parseMetadataToMap(json);
        final metadata = DatasetMetadata.fromJson(parsed);

        expect(metadata.name, equals('Test'));
        expect(metadata.createdAt, isNotNull);
      });

      test('should handle unknown dataset type', () {
        final json = {
          'dataset_type': 'unknown-type',
        };

        final parsed = DatasetParser.parseMetadataToMap(json);
        final metadata = DatasetMetadata.fromJson(parsed);

        expect(metadata.datasetType, equals(DatasetType.final9x9Area));
      });
    });

    group('parseTrainingPosition', () {
      test('should parse valid position correctly', () {
        final json = {
          'id': 'test_position_1',
          'board_size': 19,
          'stones': 'AAABBBCCC',
          'score': 5.5,
          'result': 'B+5.5',
          'game_info': {
            'black_captured': 2,
            'white_captured': 3,
            'komi': 7.5,
            'last_move_row': 10,
            'last_move_col': 15,
          },
        };

        final parsed = DatasetParser.parseTrainingPositionToMap(json);
        final position = TrainingPosition.fromJson(parsed);

        expect(position.id, equals('test_position_1'));
        expect(position.boardSize, equals(19));
        expect(position.stonesBase64, equals('AAABBBCCC'));
        expect(position.score, equals(5.5));
        expect(position.result, equals('B+5.5'));
        expect(position.gameInfo, isNotNull);
        expect(position.gameInfo!.blackCaptured, equals(2));
        expect(position.gameInfo!.whiteCaptured, equals(3));
        expect(position.gameInfo!.komi, equals(7.5));
        expect(position.gameInfo!.lastMoveRow, equals(10));
        expect(position.gameInfo!.lastMoveCol, equals(15));
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final parsed = DatasetParser.parseTrainingPositionToMap(json);
        final position = TrainingPosition.fromJson(parsed);

        expect(position.id, equals(''));
        expect(position.boardSize, equals(19));
        expect(position.stonesBase64, equals(''));
        expect(position.score, equals(0.0));
        expect(position.result, equals('Unknown'));
        expect(position.gameInfo, isNull);
      });

      test('should parse position without game info', () {
        final json = {
          'id': 'minimal_position',
          'board_size': 9,
          'stones': 'XYZ',
          'score': -2.5,
          'result': 'W+2.5',
        };

        final parsed = DatasetParser.parseTrainingPositionToMap(json);
        final position = TrainingPosition.fromJson(parsed);

        expect(position.id, equals('minimal_position'));
        expect(position.boardSize, equals(9));
        expect(position.gameInfo, isNull);
      });
    });

    group('parseGameInfo', () {
      test('should parse complete game info', () {
        final json = {
          'black_captured': 5,
          'white_captured': 3,
          'komi': 6.5,
          'last_move_row': 12,
          'last_move_col': 8,
          'move_sequence': [
            {'row': 3, 'col': 3, 'move_number': 1},
            {'row': 15, 'col': 15, 'move_number': 2},
          ],
        };

        final parsed = DatasetParser.parseGameInfoToMap(json);
        final gameInfo = GameInfo.fromJson(parsed);

        expect(gameInfo.blackCaptured, equals(5));
        expect(gameInfo.whiteCaptured, equals(3));
        expect(gameInfo.komi, equals(6.5));
        expect(gameInfo.lastMoveRow, equals(12));
        expect(gameInfo.lastMoveCol, equals(8));
        expect(gameInfo.moveSequence, hasLength(2));
        expect(gameInfo.moveSequence![0].row, equals(3));
        expect(gameInfo.moveSequence![0].col, equals(3));
        expect(gameInfo.moveSequence![0].moveNumber, equals(1));
      });

      test('should handle missing optional fields', () {
        final json = <String, dynamic>{};

        final parsed = DatasetParser.parseGameInfoToMap(json);
        final gameInfo = GameInfo.fromJson(parsed);

        expect(gameInfo.blackCaptured, equals(0));
        expect(gameInfo.whiteCaptured, equals(0));
        expect(gameInfo.komi, equals(0.0));
        expect(gameInfo.lastMoveRow, isNull);
        expect(gameInfo.lastMoveCol, isNull);
        expect(gameInfo.moveSequence, isNull);
        expect(gameInfo.boardDisplay, isNull);
      });
    });

    group('validateDataset', () {
      test('should return no errors for valid dataset', () {
        final json = {
          'metadata': {
            'name': 'Valid Dataset',
            'total_positions': 2,
            'dataset_type': 'final-9x9-area',
          },
          'positions': [
            {
              'id': 'pos1',
              'board_size': 9,
              'stones': 'ABC',
              'score': 1.0,
              'result': 'B+1',
            },
            {
              'id': 'pos2',
              'board_size': 9,
              'stones': 'DEF',
              'score': -2.0,
              'result': 'W+2',
            },
          ],
        };

        final errors = DatasetParser.validateDataset(json);

        expect(errors, isEmpty);
      });

      test('should detect missing top-level fields', () {
        final json = <String, dynamic>{};

        final errors = DatasetParser.validateDataset(json);

        expect(errors, contains('Missing required field: metadata'));
        expect(errors, contains('Missing required field: positions'));
      });

      test('should detect missing metadata fields', () {
        final json = {
          'metadata': <String, dynamic>{},
          'positions': [],
        };

        final errors = DatasetParser.validateDataset(json);

        expect(errors, contains('Missing required field: metadata.name'));
        expect(errors, contains('Missing required field: metadata.total_positions'));
        expect(errors, contains('Missing required field: metadata.dataset_type'));
      });

      test('should detect missing position fields', () {
        final json = {
          'metadata': {
            'name': 'Test',
            'total_positions': 1,
            'dataset_type': 'final-9x9-area',
          },
          'positions': [
            {'id': 'pos1'}, // Missing required fields
          ],
        };

        final errors = DatasetParser.validateDataset(json);

        expect(errors, contains('Position 0 missing required field: board_size'));
        expect(errors, contains('Position 0 missing required field: stones'));
        expect(errors, contains('Position 0 missing required field: score'));
        expect(errors, contains('Position 0 missing required field: result'));
      });

      test('should handle invalid positions array', () {
        final json = {
          'metadata': {'name': 'Test', 'total_positions': 0, 'dataset_type': 'final-9x9-area'},
          'positions': 'not_an_array',
        };

        final errors = DatasetParser.validateDataset(json);

        expect(errors, contains('positions field must be a list'));
      });
    });

    group('parseDatasetFromString', () {
      test('should parse complete dataset from JSON string', () {
        final jsonString = json.encode({
          'metadata': {
            'name': 'String Test Dataset',
            'description': 'Test',
            'version': '1.0.0',
            'created_at': '2025-01-15T10:00:00.000Z',
            'total_positions': 1,
            'dataset_type': 'midgame-19x19-estimation',
          },
          'positions': [
            {
              'id': 'test_pos',
              'board_size': 19,
              'stones': 'TEST123',
              'score': 0.0,
              'result': 'Draw',
            },
          ],
        });

        final parsed = DatasetParser.parseDatasetFromStringToMap(jsonString);
        final dataset = TrainingDataset.fromJson(parsed);

        expect(dataset.metadata.name, equals('String Test Dataset'));
        expect(dataset.metadata.datasetType, equals(DatasetType.midgame19x19Estimation));
        expect(dataset.positions, hasLength(1));
        expect(dataset.positions[0].id, equals('test_pos'));
        expect(dataset.positions[0].result, equals('Draw'));
      });
    });
  });
}