import 'personal_day.dart';
import 'pythagorean_profile.dart';

final class PythagoreanExtendedNameResult {
  const PythagoreanExtendedNameResult({
    required this.normalizedName,
    required this.balance,
    required this.karmicLessons,
    required this.hiddenPassions,
    required this.valueFrequencies,
  });

  final String normalizedName;
  final int balance;
  final List<int> karmicLessons;
  final List<int> hiddenPassions;
  final Map<int, int> valueFrequencies;
}

abstract final class PythagoreanExtendedNameEngine {
  static const String engineId = 'numerology.pythagorean.extended-name';
  static const String engineVersion = '1';

  static PythagoreanExtendedNameResult calculate({
    required String fullName,
    PersonalCycleReductionPolicy policy =
        PersonalCycleReductionPolicy.preserveMasterNumbers,
  }) {
    final components = _nameComponents(fullName);
    final normalized = components.join();

    final frequencies = <int, int>{for (var value = 1; value <= 9; value++) value: 0};
    for (final code in normalized.codeUnits) {
      final value = PythagoreanProfileEngine.letterValue(String.fromCharCode(code));
      frequencies[value] = frequencies[value]! + 1;
    }

    final karmicLessons = <int>[
      for (var value = 1; value <= 9; value++)
        if (frequencies[value] == 0) value,
    ];

    final highestFrequency = frequencies.values.reduce((a, b) => a > b ? a : b);
    final hiddenPassions = <int>[
      for (var value = 1; value <= 9; value++)
        if (frequencies[value] == highestFrequency) value,
    ];

    var initialTotal = 0;
    for (final component in components) {
      initialTotal += PythagoreanProfileEngine.letterValue(component[0]);
    }
    final balance = PythagoreanPersonalDayEngine.reduce(
      initialTotal,
      policy: policy,
    );

    return PythagoreanExtendedNameResult(
      normalizedName: normalized,
      balance: balance,
      karmicLessons: List<int>.unmodifiable(karmicLessons),
      hiddenPassions: List<int>.unmodifiable(hiddenPassions),
      valueFrequencies: Map<int, int>.unmodifiable(frequencies),
    );
  }

  static List<String> _nameComponents(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Numerology name cannot be blank.');
    }

    // Whitespace and hyphen delimit name components for Balance initials.
    // Apostrophes remain inside a component and are handled by the canonical
    // Pythagorean normalizer rather than silently changing the name structure.
    final rawComponents = trimmed.split(RegExp(r'[\s-]+'));
    final components = <String>[];
    for (final raw in rawComponents) {
      if (raw.isEmpty) continue;
      components.add(PythagoreanNameNormalizer.normalize(raw));
    }
    if (components.isEmpty) {
      throw const FormatException('Numerology name has no supported components.');
    }
    return components;
  }
}
