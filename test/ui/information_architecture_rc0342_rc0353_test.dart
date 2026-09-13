import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/navigation/information_architecture.dart';

void main() {
  test('primary navigation is the canonical four-tab bilingual shell', () {
    expect(RuhInformationArchitecture.primaryNavigation.length, 4);
    expect(
      RuhInformationArchitecture.primaryNavigation
          .map((item) => item.destination)
          .toList(growable: false),
      const <PrimaryDestination>[
        PrimaryDestination.today,
        PrimaryDestination.tools,
        PrimaryDestination.records,
        PrimaryDestination.profile,
      ],
    );
    expect(
      RuhInformationArchitecture.primaryNavigation.map((item) => item.trLabel),
      const <String>['Bugün', 'Araçlar', 'Kayıtlar', 'Profil'],
    );
    expect(
      RuhInformationArchitecture.primaryNavigation.map((item) => item.enLabel),
      const <String>['Today', 'Tools', 'Records', 'Profile'],
    );
    expect(
      RuhInformationArchitecture.primaryNavigation.any(
        (item) => item.trLabel == 'Hesapla' || item.enLabel == 'Calculate',
      ),
      isFalse,
    );
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
