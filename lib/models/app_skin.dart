enum AppSkin {
  /// Default brown wood theme with animations
  classic('classic'),

  /// Modern dark theme
  modern('modern'),

  /// Blue ocean theme
  ocean('ocean'),

  /// Minimalist black and white theme for e-ink displays
  eink('eink');

  const AppSkin(this.value);

  final String value;

  static AppSkin? fromString(String? value) {
    if (value == null) return null;
    for (AppSkin skin in AppSkin.values) {
      if (skin.value == value) {
        return skin;
      }
    }
    return null;
  }

  @override
  String toString() => value;
}