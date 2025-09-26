enum TimerType {
  /// Traditional smooth progress bar
  smooth('smooth'),

  /// Segmented bar that removes one segment per second
  segmented('segmented');

  const TimerType(this.value);

  final String value;

  static TimerType? fromString(String? value) {
    if (value == null) return null;
    for (TimerType type in TimerType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }

  @override
  String toString() => value;
}