import 'dataset_type.dart';

class DatasetConfiguration {
  final double thresholdGood;
  final double thresholdClose;
  final int timePerProblemSeconds;
  final double markDisplayTimeSeconds;

  const DatasetConfiguration({
    required this.thresholdGood,
    required this.thresholdClose,
    required this.timePerProblemSeconds,
    required this.markDisplayTimeSeconds,
  });

  static DatasetConfiguration getDefaultFor(DatasetType datasetType) {
    switch (datasetType) {
      case DatasetType.final9x9Area:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 7,
          markDisplayTimeSeconds: 1.5,
        );
      case DatasetType.final19x19Area:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 30,
          markDisplayTimeSeconds: 1.5,
        );
      case DatasetType.midgame19x19Estimation:
        return const DatasetConfiguration(
          thresholdGood: 1.5,
          thresholdClose: 4.0,
          timePerProblemSeconds: 15,
          markDisplayTimeSeconds: 1.5,
        );
      case DatasetType.final9x9AreaVars:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 10,
          markDisplayTimeSeconds: 1.5,
        );
      case DatasetType.partialArea:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 7,
          markDisplayTimeSeconds: 1.5,
        );
    }
  }

  DatasetConfiguration copyWith({
    double? thresholdGood,
    double? thresholdClose,
    int? timePerProblemSeconds,
    double? markDisplayTimeSeconds,
  }) {
    return DatasetConfiguration(
      thresholdGood: thresholdGood ?? this.thresholdGood,
      thresholdClose: thresholdClose ?? this.thresholdClose,
      timePerProblemSeconds: timePerProblemSeconds ?? this.timePerProblemSeconds,
      markDisplayTimeSeconds: markDisplayTimeSeconds ?? this.markDisplayTimeSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thresholdGood': thresholdGood,
      'thresholdClose': thresholdClose,
      'timePerProblemSeconds': timePerProblemSeconds,
      'markDisplayTimeSeconds': markDisplayTimeSeconds,
    };
  }

  static DatasetConfiguration fromJson(Map<String, dynamic> json) {
    return DatasetConfiguration(
      thresholdGood: (json['thresholdGood'] as num?)?.toDouble() ?? 0.0,
      thresholdClose: (json['thresholdClose'] as num?)?.toDouble() ?? 0.0,
      timePerProblemSeconds: json['timePerProblemSeconds'] as int? ?? 30,
      markDisplayTimeSeconds: (json['markDisplayTimeSeconds'] as num?)?.toDouble() ?? 1.5,
    );
  }

  bool isValidConfiguration() {
    return thresholdClose >= thresholdGood &&
           timePerProblemSeconds > 0 &&
           markDisplayTimeSeconds >= 0;
  }
}