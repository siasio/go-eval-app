import 'timer_type.dart';
import 'layout_type.dart';
import 'app_skin.dart';

class GlobalConfiguration {
  final double markDisplayTimeSeconds;
  final TimerType timerType;
  final LayoutType layoutType;
  final AppSkin appSkin;

  const GlobalConfiguration({
    required this.markDisplayTimeSeconds,
    required this.timerType,
    required this.layoutType,
    required this.appSkin,
  });

  static const GlobalConfiguration defaultConfig = GlobalConfiguration(
    markDisplayTimeSeconds: 1.5,
    timerType: TimerType.smooth,
    layoutType: LayoutType.vertical,
    appSkin: AppSkin.classic,
  );

  GlobalConfiguration copyWith({
    double? markDisplayTimeSeconds,
    TimerType? timerType,
    LayoutType? layoutType,
    AppSkin? appSkin,
  }) {
    return GlobalConfiguration(
      markDisplayTimeSeconds: markDisplayTimeSeconds ?? this.markDisplayTimeSeconds,
      timerType: timerType ?? this.timerType,
      layoutType: layoutType ?? this.layoutType,
      appSkin: appSkin ?? this.appSkin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'markDisplayTimeSeconds': markDisplayTimeSeconds,
      'timerType': timerType.value,
      'layoutType': layoutType.value,
      'appSkin': appSkin.value,
    };
  }

  static GlobalConfiguration fromJson(Map<String, dynamic> json) {
    return GlobalConfiguration(
      markDisplayTimeSeconds: (json['markDisplayTimeSeconds'] as num?)?.toDouble() ?? defaultConfig.markDisplayTimeSeconds,
      timerType: TimerType.fromString(json['timerType'] as String?) ?? defaultConfig.timerType,
      layoutType: LayoutType.fromString(json['layoutType'] as String?) ?? defaultConfig.layoutType,
      appSkin: AppSkin.fromString(json['appSkin'] as String?) ?? defaultConfig.appSkin,
    );
  }

  bool isValidConfiguration() {
    return markDisplayTimeSeconds >= 0;
  }
}