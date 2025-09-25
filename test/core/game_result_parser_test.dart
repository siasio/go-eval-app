import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/game_result_parser.dart';

void main() {
  group('GameResultParser', () {
    group('parseWinner', () {
      test('should parse black wins correctly', () {
        expect(GameResultParser.parseWinner('B+5.5'), equals('Black'));
        expect(GameResultParser.parseWinner('B+12'), equals('Black'));
        expect(GameResultParser.parseWinner('B+0.5'), equals('Black'));
        expect(GameResultParser.parseWinner('B+R'), equals('Black'));
      });

      test('should parse white wins correctly', () {
        expect(GameResultParser.parseWinner('W+7.5'), equals('White'));
        expect(GameResultParser.parseWinner('W+25'), equals('White'));
        expect(GameResultParser.parseWinner('W+1'), equals('White'));
        expect(GameResultParser.parseWinner('W+R'), equals('White'));
      });

      test('should parse draws correctly', () {
        expect(GameResultParser.parseWinner('Draw'), equals('Draw'));
        expect(GameResultParser.parseWinner('draw'), equals('Draw'));
        expect(GameResultParser.parseWinner('DRAW'), equals('Draw'));
      });

      test('should handle unknown results', () {
        expect(GameResultParser.parseWinner('Unknown'), equals('Unknown'));
        expect(GameResultParser.parseWinner('Invalid'), equals('Unknown'));
        expect(GameResultParser.parseWinner(''), equals('Unknown'));
      });
    });

    group('parseMargin', () {
      test('should parse point margins correctly', () {
        expect(GameResultParser.parseMargin('B+5.5'), equals('5.5 points'));
        expect(GameResultParser.parseMargin('W+12'), equals('12 points'));
        expect(GameResultParser.parseMargin('B+0.5'), equals('0.5 points'));
        expect(GameResultParser.parseMargin('W+7'), equals('7 points'));
      });

      test('should parse resignations correctly', () {
        expect(GameResultParser.parseMargin('B+R'), equals('Resignation'));
        expect(GameResultParser.parseMargin('W+R'), equals('Resignation'));
        expect(GameResultParser.parseMargin('B+Resign'), equals('Resignation'));
      });

      test('should handle draws', () {
        expect(GameResultParser.parseMargin('Draw'), equals('Draw'));
        expect(GameResultParser.parseMargin('draw'), equals('Draw'));
      });

      test('should handle malformed results', () {
        expect(GameResultParser.parseMargin('Invalid'), equals('Invalid'));
        expect(GameResultParser.parseMargin('B+'), equals('B+'));
        expect(GameResultParser.parseMargin(''), equals(''));
      });
    });

    group('parseScoreDifference', () {
      test('should parse black wins as positive', () {
        expect(GameResultParser.parseScoreDifference('B+5.5'), equals(5.5));
        expect(GameResultParser.parseScoreDifference('B+12'), equals(12.0));
        expect(GameResultParser.parseScoreDifference('B+0.5'), equals(0.5));
      });

      test('should parse white wins as negative', () {
        expect(GameResultParser.parseScoreDifference('W+7.5'), equals(-7.5));
        expect(GameResultParser.parseScoreDifference('W+25'), equals(-25.0));
        expect(GameResultParser.parseScoreDifference('W+1'), equals(-1.0));
      });

      test('should handle draws as zero', () {
        expect(GameResultParser.parseScoreDifference('Draw'), equals(0.0));
        expect(GameResultParser.parseScoreDifference('draw'), equals(0.0));
      });

      test('should handle resignations with large values', () {
        expect(GameResultParser.parseScoreDifference('B+R'), equals(100.0));
        expect(GameResultParser.parseScoreDifference('W+R'), equals(-100.0));
      });

      test('should handle malformed results', () {
        expect(GameResultParser.parseScoreDifference('Invalid'), equals(0.0));
        expect(GameResultParser.parseScoreDifference(''), equals(0.0));
      });
    });

    group('isCorrectGuess', () {
      test('should match correct guesses', () {
        expect(GameResultParser.isCorrectGuess('Black', 'B+5.5'), isTrue);
        expect(GameResultParser.isCorrectGuess('White', 'W+12'), isTrue);
        expect(GameResultParser.isCorrectGuess('Draw', 'Draw'), isTrue);
        expect(GameResultParser.isCorrectGuess('BLACK', 'B+R'), isTrue); // Case insensitive
        expect(GameResultParser.isCorrectGuess('white', 'W+0.5'), isTrue);
      });

      test('should reject incorrect guesses', () {
        expect(GameResultParser.isCorrectGuess('White', 'B+5.5'), isFalse);
        expect(GameResultParser.isCorrectGuess('Black', 'W+12'), isFalse);
        expect(GameResultParser.isCorrectGuess('Draw', 'B+1'), isFalse);
      });

      test('should handle whitespace in guesses', () {
        expect(GameResultParser.isCorrectGuess(' Black ', 'B+5.5'), isTrue);
        expect(GameResultParser.isCorrectGuess('\tWhite\n', 'W+12'), isTrue);
      });
    });

    group('formatResult', () {
      test('should format black wins correctly', () {
        expect(GameResultParser.formatResult(5.5, true), equals('B+5.5'));
        expect(GameResultParser.formatResult(12.0, true), equals('B+12'));
        expect(GameResultParser.formatResult(0.5, true), equals('B+0.5'));
      });

      test('should format white wins correctly', () {
        expect(GameResultParser.formatResult(7.5, false), equals('W+7.5'));
        expect(GameResultParser.formatResult(25.0, false), equals('W+25'));
        expect(GameResultParser.formatResult(1.0, false), equals('W+1'));
      });

      test('should format draws', () {
        expect(GameResultParser.formatResult(0.0, true), equals('Draw'));
        expect(GameResultParser.formatResult(0.0, false), equals('Draw'));
      });

      test('should format resignations', () {
        expect(GameResultParser.formatResult(10.0, true, resignation: true), equals('B+R'));
        expect(GameResultParser.formatResult(5.0, false, resignation: true), equals('W+R'));
      });
    });

    group('isValidResultFormat', () {
      test('should validate correct formats', () {
        expect(GameResultParser.isValidResultFormat('B+5.5'), isTrue);
        expect(GameResultParser.isValidResultFormat('W+12'), isTrue);
        expect(GameResultParser.isValidResultFormat('B+0.5'), isTrue);
        expect(GameResultParser.isValidResultFormat('W+7'), isTrue);
        expect(GameResultParser.isValidResultFormat('B+R'), isTrue);
        expect(GameResultParser.isValidResultFormat('W+R'), isTrue);
        expect(GameResultParser.isValidResultFormat('Draw'), isTrue);
        expect(GameResultParser.isValidResultFormat('draw'), isTrue);
        expect(GameResultParser.isValidResultFormat('DRAW'), isTrue);
      });

      test('should reject invalid formats', () {
        expect(GameResultParser.isValidResultFormat('B+'), isFalse);
        expect(GameResultParser.isValidResultFormat('W-5'), isFalse);
        expect(GameResultParser.isValidResultFormat('Black+5'), isFalse);
        expect(GameResultParser.isValidResultFormat('5.5'), isFalse);
        expect(GameResultParser.isValidResultFormat('B+5.5.5'), isFalse);
        expect(GameResultParser.isValidResultFormat(''), isFalse);
        expect(GameResultParser.isValidResultFormat('Unknown'), isFalse);
      });
    });

    group('analyzeResults', () {
      test('should analyze mixed results correctly', () {
        final results = [
          'B+5.5',
          'W+12',
          'B+R',
          'Draw',
          'W+7.5',
          'B+3',
          'Invalid', // This should be ignored
        ];

        final stats = GameResultParser.analyzeResults(results);

        expect(stats.totalGames, equals(6)); // Invalid result excluded
        expect(stats.blackWins, equals(3));
        expect(stats.whiteWins, equals(2));
        expect(stats.draws, equals(1));
        expect(stats.resignations, equals(1));

        expect(stats.blackWinRate, closeTo(0.5, 0.01));
        expect(stats.whiteWinRate, closeTo(0.333, 0.01));
        expect(stats.drawRate, closeTo(0.167, 0.01));
        expect(stats.resignationRate, closeTo(0.167, 0.01));

        expect(stats.averageMargin, greaterThan(0.0));
      });

      test('should handle empty result list', () {
        final stats = GameResultParser.analyzeResults([]);

        expect(stats.totalGames, equals(0));
        expect(stats.blackWins, equals(0));
        expect(stats.whiteWins, equals(0));
        expect(stats.draws, equals(0));
        expect(stats.resignations, equals(0));
        expect(stats.averageMargin, equals(0.0));
        expect(stats.blackWinRate, equals(0.0));
        expect(stats.whiteWinRate, equals(0.0));
      });

      test('should handle all invalid results', () {
        final results = ['Invalid', 'Bad Format', ''];

        final stats = GameResultParser.analyzeResults(results);

        expect(stats.totalGames, equals(0));
        expect(stats.blackWinRate, equals(0.0));
      });

      test('should calculate rates correctly for edge cases', () {
        final results = ['Draw', 'Draw', 'Draw'];

        final stats = GameResultParser.analyzeResults(results);

        expect(stats.totalGames, equals(3));
        expect(stats.blackWins, equals(0));
        expect(stats.whiteWins, equals(0));
        expect(stats.draws, equals(3));
        expect(stats.drawRate, equals(1.0));
        expect(stats.blackWinRate, equals(0.0));
        expect(stats.whiteWinRate, equals(0.0));
      });
    });
  });

  group('ResultStatistics', () {
    test('should calculate rates correctly', () {
      final stats = ResultStatistics(
        totalGames: 10,
        blackWins: 4,
        whiteWins: 5,
        draws: 1,
        resignations: 2,
        averageMargin: 7.5,
      );

      expect(stats.blackWinRate, equals(0.4));
      expect(stats.whiteWinRate, equals(0.5));
      expect(stats.drawRate, equals(0.1));
      expect(stats.resignationRate, equals(0.2));
    });

    test('should handle zero games', () {
      final stats = ResultStatistics(
        totalGames: 0,
        blackWins: 0,
        whiteWins: 0,
        draws: 0,
        resignations: 0,
        averageMargin: 0.0,
      );

      expect(stats.blackWinRate, equals(0.0));
      expect(stats.whiteWinRate, equals(0.0));
      expect(stats.drawRate, equals(0.0));
      expect(stats.resignationRate, equals(0.0));
    });

    test('should have meaningful toString', () {
      final stats = ResultStatistics(
        totalGames: 5,
        blackWins: 2,
        whiteWins: 2,
        draws: 1,
        resignations: 1,
        averageMargin: 6.25,
      );

      final str = stats.toString();

      expect(str, contains('games: 5'));
      expect(str, contains('B: 2'));
      expect(str, contains('W: 2'));
      expect(str, contains('draws: 1'));
      expect(str, contains('resignations: 1'));
      expect(str, contains('avgMargin: 6.3'));
    });
  });
}