import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/navigation/information_architecture.dart';

void main() {
  test('primary navigation stays deliberately small and bilingual', () {
    expect(RuhInformationArchitecture.primaryNavigation.length, 5);
    expect(
      RuhInformationArchitecture.primaryNavigation
          .map((item) => item.destination)
          .toSet(),
      PrimaryDestination.values.toSet(),
    );
    for (final item in RuhInformationArchitecture.primaryNavigation) {
      expect(item.trLabel.trim(), isNotEmpty);
      expect(item.enLabel.trim(), isNotEmpty);
    }
  });

  test('calculation and reflective systems remain separate domains', () {
    final domains = RuhInformationArchitecture.toolDomains.map((d) => d.domain).toSet();
    expect(domains, containsAll(<ToolDomain>{
      ToolDomain.westernAstrology,
      ToolDomain.vedicAstrology,
      ToolDomain.chineseAstrology,
      ToolDomain.numerology,
      ToolDomain.spiritual,
      ToolDomain.personalGrowth,
      ToolDomain.professional,
    }));
  });

  test('professional tools cannot leak into simple mode', () {
    final simple = RuhInformationArchitecture.visibleToolDomains(ExperienceMode.simple);
    final professional =
        RuhInformationArchitecture.visibleToolDomains(ExperienceMode.professional);
    expect(simple.any((item) => item.professionalOnly), isFalse);
    expect(professional.any((item) => item.professionalOnly), isTrue);
    expect(professional.length, greaterThan(simple.length));
  });

  test('first launch policy exposes only a short onboarding flow', () {
    expect(RuhInformationArchitecture.onboarding.length, lessThanOrEqualTo(3));
    expect(RuhInformationArchitecture.isSimpleFirstLaunch(), isTrue);
    expect(
      RuhInformationArchitecture.onboarding,
      contains(OnboardingStep.optionalBirthProfile),
    );
  });
}
