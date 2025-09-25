/// Dataset types enum for Go Territory Trainer project.
enum DatasetType {
  /// Final positions on 9x9 board evaluated using KataGo's ownership map
  final9x9Area('final-9x9-area'),

  /// Final positions on 19x19 board evaluated using KataGo's ownership map
  final19x19Area('final-19x19-area'),

  /// Midgame positions on 19x19 board with territory estimation
  midgame19x19Estimation('midgame-19x19-estimation'),

  /// Final positions on 9x9 board with variations (not yet implemented)
  final9x9AreaVars('final-9x9-area-vars'),

  /// Partial area analysis (not yet implemented)
  partialArea('partial-area');

  const DatasetType(this.value);

  /// The string representation of the dataset type
  final String value;

  /// Convert from string value to enum
  static DatasetType? fromString(String? value) {
    if (value == null) return null;
    for (DatasetType type in DatasetType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }

  @override
  String toString() => value;
}