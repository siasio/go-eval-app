enum LayoutType {
  /// Vertical layout: menu bar - game info - board - buttons (top to bottom)
  vertical('vertical'),

  /// Horizontal layout: menu bar - game info - board - buttons (left to right)
  horizontal('horizontal');

  const LayoutType(this.value);

  final String value;

  static LayoutType? fromString(String? value) {
    if (value == null) return null;
    for (LayoutType type in LayoutType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }

  @override
  String toString() => value;
}