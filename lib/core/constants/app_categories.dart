/// Built-in app category identifiers used for automatic and manual classification.
enum AppCategory {
  social('Social'),
  messaging('Messaging'),
  productivity('Productivity'),
  education('Education'),
  finance('Finance'),
  health('Health'),
  entertainment('Entertainment'),
  gaming('Gaming'),
  shopping('Shopping'),
  food('Food'),
  music('Music'),
  photography('Photography'),
  business('Business'),
  utilities('Utilities'),
  news('News'),
  travel('Travel'),
  lifestyle('Lifestyle'),
  other('Other');

  const AppCategory(this.label);

  final String label;

  static AppCategory fromStorage(String? value) {
    if (value == null || value.isEmpty) return AppCategory.other;
    return AppCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => AppCategory.other,
    );
  }
}
