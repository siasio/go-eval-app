import 'dataset_type.dart';

class DatasetConfiguration {
  final double thresholdGood;
  final double thresholdClose;
  final int timePerProblemSeconds;
  final bool hideGameInfoBar;

  const DatasetConfiguration({
    required this.thresholdGood,
    required this.thresholdClose,
    required this.timePerProblemSeconds,
    required this.hideGameInfoBar,
  });

  static DatasetConfiguration getDefaultFor(DatasetType datasetType) {
    switch (datasetType) {
      case DatasetType.final9x9Area:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 7,
          hideGameInfoBar: true,
        );
      case DatasetType.final19x19Area:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 30,
          hideGameInfoBar: false,
        );
      case DatasetType.midgame19x19Estimation:
        return const DatasetConfiguration(
          thresholdGood: 1.5,
          thresholdClose: 4.0,
          timePerProblemSeconds: 15,
          hideGameInfoBar: false,
        );
      case DatasetType.final9x9AreaVars:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 10,
          hideGameInfoBar: true,
        );
      case DatasetType.partialArea:
        return const DatasetConfiguration(
          thresholdGood: 0.0,
          thresholdClose: 0.0,
          timePerProblemSeconds: 7,
          hideGameInfoBar: false,
        );
    }
  }

  DatasetConfiguration copyWith({
    double? thresholdGood,
    double? thresholdClose,
    int? timePerProblemSeconds,
    bool? hideGameInfoBar,
  }) {
    return DatasetConfiguration(
      thresholdGood: thresholdGood ?? this.thresholdGood,
      thresholdClose: thresholdClose ?? this.thresholdClose,
      timePerProblemSeconds: timePerProblemSeconds ?? this.timePerProblemSeconds,
      hideGameInfoBar: hideGameInfoBar ?? this.hideGameInfoBar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thresholdGood': thresholdGood,
      'thresholdClose': thresholdClose,
      'timePerProblemSeconds': timePerProblemSeconds,
      'hideGameInfoBar': hideGameInfoBar,
    };
  }

  static DatasetConfiguration fromJson(Map<String, dynamic> json) {
    return DatasetConfiguration(
      thresholdGood: (json['thresholdGood'] as num?)?.toDouble() ?? 0.0,
      thresholdClose: (json['thresholdClose'] as num?)?.toDouble() ?? 0.0,
      timePerProblemSeconds: json['timePerProblemSeconds'] as int? ?? 30,
      hideGameInfoBar: json['hideGameInfoBar'] as bool? ?? false,
    );
  }

  bool isValidConfiguration() {
    return thresholdClose >= thresholdGood &&
           timePerProblemSeconds > 0;
  }
}