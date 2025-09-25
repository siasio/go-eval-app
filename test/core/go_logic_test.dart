import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/go_logic.dart';

void main() {
  group('GoLogic', () {
    group('decodeStones', () {
      test('should decode base64 stones correctly for 9x9 board', () {
        // Create a simple pattern: first row has stones
        final board = List.generate(9, (i) => List.generate(9, (j) => i == 0 && j < 3 ? j + 1 : 0));
        final encoded = GoLogic.encodeStones(board);

        final decoded = GoLogic.decodeStones(encoded, 9);

        expect(decoded, hasLength(9));
        expect(decoded[0][0], equals(1)); // Black
        expect(decoded[0][1], equals(2)); // White
        expect(decoded[0][2], equals(3)); // Invalid, but preserved
        expect(decoded[0][3], equals(0)); // Empty
        expect(decoded[1][0], equals(0)); // Empty
      });

      test('should handle empty board', () {
        final emptyBoard = GoLogic.createEmptyBoard(19);
        final encoded = GoLogic.encodeStones(emptyBoard);

        final decoded = GoLogic.decodeStones(encoded, 19);

        expect(decoded, hasLength(19));
        for (int i = 0; i < 19; i++) {
          for (int j = 0; j < 19; j++) {
            expect(decoded[i][j], equals(0));
          }
        }
      });

      test('should handle truncated data gracefully', () {
        const shortBase64 = 'AAAA'; // Much shorter than needed for full board

        final decoded = GoLogic.decodeStones(shortBase64, 9);

        expect(decoded, hasLength(9));
        expect(decoded[0], hasLength(9));
        // Should fill missing positions with 0
        expect(decoded[8][8], equals(0));
      });
    });

    group('encodeStones', () {
      test('should encode and decode consistently', () {
        final originalBoard = [
          [1, 2, 0, 1, 2],
          [2, 1, 2, 0, 1],
          [0, 0, 1, 2, 0],
          [1, 0, 0, 0, 2],
          [2, 1, 0, 1, 0],
        ];

        final encoded = GoLogic.encodeStones(originalBoard);
        final decoded = GoLogic.decodeStones(encoded, 5);

        expect(GoLogic.boardsEqual(originalBoard, decoded), isTrue);
      });

      test('should produce valid base64', () {
        final board = GoLogic.createEmptyBoard(3);
        board[1][1] = 1; // Place one stone

        final encoded = GoLogic.encodeStones(board);

        // Should be valid base64 and decodable
        expect(() => base64Decode(encoded), returnsNormally);
        final decoded = GoLogic.decodeStones(encoded, 3);
        expect(decoded[1][1], equals(1));
      });
    });

    group('createEmptyBoard', () {
      test('should create board with correct dimensions', () {
        final board = GoLogic.createEmptyBoard(13);

        expect(board, hasLength(13));
        expect(board[0], hasLength(13));
        expect(board[12], hasLength(13));
      });

      test('should initialize all positions to 0', () {
        final board = GoLogic.createEmptyBoard(5);

        for (int i = 0; i < 5; i++) {
          for (int j = 0; j < 5; j++) {
            expect(board[i][j], equals(0));
          }
        }
      });
    });

    group('isValidCoordinate', () {
      test('should validate coordinates correctly', () {
        expect(GoLogic.isValidCoordinate(0, 0, 19), isTrue);
        expect(GoLogic.isValidCoordinate(18, 18, 19), isTrue);
        expect(GoLogic.isValidCoordinate(10, 5, 19), isTrue);

        expect(GoLogic.isValidCoordinate(-1, 0, 19), isFalse);
        expect(GoLogic.isValidCoordinate(0, -1, 19), isFalse);
        expect(GoLogic.isValidCoordinate(19, 0, 19), isFalse);
        expect(GoLogic.isValidCoordinate(0, 19, 19), isFalse);
        expect(GoLogic.isValidCoordinate(19, 19, 19), isFalse);
      });
    });

    group('countStones', () {
      test('should count stones correctly', () {
        final board = [
          [1, 2, 0, 1],
          [0, 1, 2, 2],
          [1, 0, 0, 1],
          [2, 2, 1, 0],
        ];

        expect(GoLogic.countStones(board, 0), equals(5)); // Empty
        expect(GoLogic.countStones(board, 1), equals(6)); // Black
        expect(GoLogic.countStones(board, 2), equals(5)); // White
      });

      test('should return 0 for empty board', () {
        final board = GoLogic.createEmptyBoard(9);

        expect(GoLogic.countStones(board, 1), equals(0));
        expect(GoLogic.countStones(board, 2), equals(0));
        expect(GoLogic.countStones(board, 0), equals(81)); // All empty
      });
    });

    group('copyBoard', () {
      test('should create independent copy', () {
        final original = [
          [1, 2],
          [0, 1],
        ];

        final copy = GoLogic.copyBoard(original);

        // Modify original
        original[0][0] = 2;

        expect(copy[0][0], equals(1)); // Copy should be unchanged
        expect(original[0][0], equals(2)); // Original should be changed
      });
    });

    group('boardsEqual', () {
      test('should detect equal boards', () {
        final board1 = [[1, 2], [0, 1]];
        final board2 = [[1, 2], [0, 1]];

        expect(GoLogic.boardsEqual(board1, board2), isTrue);
      });

      test('should detect different boards', () {
        final board1 = [[1, 2], [0, 1]];
        final board2 = [[1, 2], [0, 2]];

        expect(GoLogic.boardsEqual(board1, board2), isFalse);
      });

      test('should handle different sizes', () {
        final board1 = [[1, 2]];
        final board2 = [[1, 2], [0, 1]];

        expect(GoLogic.boardsEqual(board1, board2), isFalse);
      });
    });

    group('getNeighbors', () {
      test('should return 4 neighbors for center position', () {
        final neighbors = GoLogic.getNeighbors(5, 5, 19);

        expect(neighbors, hasLength(4));
        expect(neighbors, contains(Position(4, 5))); // Up
        expect(neighbors, contains(Position(6, 5))); // Down
        expect(neighbors, contains(Position(5, 4))); // Left
        expect(neighbors, contains(Position(5, 6))); // Right
      });

      test('should return 2 neighbors for corner position', () {
        final neighbors = GoLogic.getNeighbors(0, 0, 19);

        expect(neighbors, hasLength(2));
        expect(neighbors, contains(Position(1, 0))); // Down
        expect(neighbors, contains(Position(0, 1))); // Right
      });

      test('should return 3 neighbors for edge position', () {
        final neighbors = GoLogic.getNeighbors(0, 5, 19);

        expect(neighbors, hasLength(3));
        expect(neighbors, contains(Position(1, 5))); // Down
        expect(neighbors, contains(Position(0, 4))); // Left
        expect(neighbors, contains(Position(0, 6))); // Right
      });
    });

    group('getEmptyPositions', () {
      test('should find all empty positions', () {
        final board = [
          [1, 0, 2],
          [0, 1, 0],
          [2, 0, 0],
        ];

        final empty = GoLogic.getEmptyPositions(board);

        expect(empty, hasLength(5));
        expect(empty, contains(Position(0, 1)));
        expect(empty, contains(Position(1, 0)));
        expect(empty, contains(Position(1, 2)));
        expect(empty, contains(Position(2, 1)));
        expect(empty, contains(Position(2, 2)));
      });

      test('should return empty list for full board', () {
        final board = [
          [1, 2, 1],
          [2, 1, 2],
          [1, 2, 1],
        ];

        final empty = GoLogic.getEmptyPositions(board);

        expect(empty, isEmpty);
      });
    });

    group('boardToString', () {
      test('should convert board to readable string', () {
        final board = [
          [1, 2, 0],
          [0, 1, 2],
          [2, 0, 1],
        ];

        final str = GoLogic.boardToString(board);

        expect(str, contains('BW.'));
        expect(str, contains('.BW'));
        expect(str, contains('W.B'));
      });
    });
  });

  group('Position', () {
    test('should have equality and hashCode', () {
      final pos1 = Position(3, 5);
      final pos2 = Position(3, 5);
      final pos3 = Position(3, 6);

      expect(pos1, equals(pos2));
      expect(pos1.hashCode, equals(pos2.hashCode));
      expect(pos1, isNot(equals(pos3)));
    });

    test('should have meaningful toString', () {
      final pos = Position(10, 15);

      expect(pos.toString(), equals('Position(10, 15)'));
    });
  });
}