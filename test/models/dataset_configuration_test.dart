import 'package:flutter_test/flutter_test.dart';
import 'package:countingapp/models/dataset_configuration.dart';
import 'package:countingapp/models/dataset_type.dart';

void main() {
  group('DatasetConfiguration', () {
    test('should have correct defaults for final9x9Area', () {
      final config = DatasetConfiguration.getDefaultFor(DatasetType.final9x9Area);

      expect(config.thresholdGood, 0.0);
      expect(config.thresholdClose, 0.0);
      expect(config.timePerProblemSeconds, 7);
      expect(config.hideGameInfoBar, isTrue);
    });

    test('should have correct defaults for midgame19x19Estimation', () {
      final config = DatasetConfiguration.getDefaultFor(DatasetType.midgame19x19Estimation);

      expect(config.thresholdGood, 1.5);
      expect(config.thresholdClose, 4.0);
      expect(config.timePerProblemSeconds, 15);
      expect(config.hideGameInfoBar, isFalse);
    });

    test('should have correct defaults for final9x9AreaVars', () {
      final config = DatasetConfiguration.getDefaultFor(DatasetType.final9x9AreaVars);

      expect(config.thresholdGood, 0.0);
      expect(config.thresholdClose, 0.0);
      expect(config.timePerProblemSeconds, 10);
      expect(config.hideGameInfoBar, isTrue);
    });

    test('copyWith should preserve unchanged values', () {
      const original = DatasetConfiguration(
        thresholdGood: 1.0,
        thresholdClose: 2.0,
        timePerProblemSeconds: 30,
        hideGameInfoBar: false,
      );

      final modified = original.copyWith(
        thresholdGood: 1.5,
        hideGameInfoBar: true,
      );

      expect(modified.thresholdGood, 1.5);
      expect(modified.thresholdClose, 2.0);
      expect(modified.timePerProblemSeconds, 30);
      expect(modified.hideGameInfoBar, isTrue);
    });

    test('should serialize to JSON correctly', () {
      const config = DatasetConfiguration(
        thresholdGood: 1.5,
        thresholdClose: 3.0,
        timePerProblemSeconds: 20,
        hideGameInfoBar: true,
      );

      final json = config.toJson();

      expect(json['thresholdGood'], 1.5);
      expect(json['thresholdClose'], 3.0);
      expect(json['timePerProblemSeconds'], 20);
      expect(json['hideGameInfoBar'], isTrue);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'thresholdGood': 2.0,
        'thresholdClose': 4.0,
        'timePerProblemSeconds': 25,
        'hideGameInfoBar': true,
      };

      final config = DatasetConfiguration.fromJson(json);

      expect(config.thresholdGood, 2.0);
      expect(config.thresholdClose, 4.0);
      expect(config.timePerProblemSeconds, 25);
      expect(config.hideGameInfoBar, isTrue);
    });

    test('should use defaults for missing JSON fields', () {
      final json = <String, dynamic>{};

      final config = DatasetConfiguration.fromJson(json);

      expect(config.thresholdGood, 0.0);
      expect(config.thresholdClose, 0.0);
      expect(config.timePerProblemSeconds, 30);
      expect(config.hideGameInfoBar, isFalse);
    });

    test('isValidConfiguration should validate thresholds and time', () {
      const validConfig = DatasetConfiguration(
        thresholdGood: 1.0,
        thresholdClose: 2.0,
        timePerProblemSeconds: 30,
        hideGameInfoBar: false,
      );

      const invalidThresholdConfig = DatasetConfiguration(
        thresholdGood: 3.0,
        thresholdClose: 2.0, // Close < Good is invalid
        timePerProblemSeconds: 30,
        hideGameInfoBar: false,
      );

      const invalidTimeConfig = DatasetConfiguration(
        thresholdGood: 1.0,
        thresholdClose: 2.0,
        timePerProblemSeconds: 0, // Time <= 0 is invalid
        hideGameInfoBar: false,
      );

      expect(validConfig.isValidConfiguration(), isTrue);
      expect(invalidThresholdConfig.isValidConfiguration(), isFalse);
      expect(invalidTimeConfig.isValidConfiguration(), isFalse);
    });
  });
}