/// Product information architecture for RC-0342..RC-0353.
///
/// The UI may render these definitions differently on phone/tablet, but it
/// must preserve the same simple-vs-expert visibility rules.
enum PrimaryDestination { today, discover, calculate, records, profile }

enum ToolDomain {
  westernAstrology,
  vedicAstrology,
  chineseAstrology,
  numerology,
  spiritual,
  personalGrowth,
  professional,
}

enum ExperienceMode { simple, professional }

enum OnboardingStep { language, optionalBirthProfile, permissionsSummary }

final class NavigationDefinition {
  const NavigationDefinition({
    required this.destination,
    required this.trLabel,
    required this.enLabel,
  });

  final PrimaryDestination destination;
  final String trLabel;
  final String enLabel;
}

final class ToolDomainDefinition {
  const ToolDomainDefinition({
    required this.domain,
    required this.trLabel,
    required this.enLabel,
    this.professionalOnly = false,
  });

  final ToolDomain domain;
  final String trLabel;
  final String enLabel;
  final bool professionalOnly;
}

abstract final class RuhInformationArchitecture {
  static const primaryNavigation = <NavigationDefinition>[
    NavigationDefinition(
      destination: PrimaryDestination.today,
      trLabel: 'Bugün',
      enLabel: 'Today',
    ),
    NavigationDefinition(
      destination: PrimaryDestination.discover,
      trLabel: 'Keşfet',
      enLabel: 'Discover',
    ),
    NavigationDefinition(
      destination: PrimaryDestination.calculate,
      trLabel: 'Hesapla',
      enLabel: 'Calculate',
    ),
    NavigationDefinition(
      destination: PrimaryDestination.records,
      trLabel: 'Kayıtlarım',
      enLabel: 'My Records',
    ),
    NavigationDefinition(
      destination: PrimaryDestination.profile,
      trLabel: 'Profil',
      enLabel: 'Profile',
    ),
  ];

  static const toolDomains = <ToolDomainDefinition>[
    ToolDomainDefinition(
      domain: ToolDomain.westernAstrology,
      trLabel: 'Batı Astrolojisi',
      enLabel: 'Western Astrology',
    ),
    ToolDomainDefinition(
      domain: ToolDomain.vedicAstrology,
      trLabel: 'Vedik Astroloji',
      enLabel: 'Vedic Astrology',
    ),
    ToolDomainDefinition(
      domain: ToolDomain.chineseAstrology,
      trLabel: 'Çin Astrolojisi',
      enLabel: 'Chinese Astrology',
    ),
    ToolDomainDefinition(
      domain: ToolDomain.numerology,
      trLabel: 'Numeroloji',
      enLabel: 'Numerology',
    ),
    ToolDomainDefinition(
      domain: ToolDomain.spiritual,
      trLabel: 'Spiritüel Araçlar',
      enLabel: 'Spiritual Tools',
    ),
    ToolDomainDefinition(
      domain: ToolDomain.personalGrowth,
      trLabel: 'Kişisel Gelişim',
      enLabel: 'Personal Growth',
    ),
    ToolDomainDefinition(
      domain: ToolDomain.professional,
      trLabel: 'Profesyonel Araçlar',
      enLabel: 'Professional Tools',
      professionalOnly: true,
    ),
  ];

  static const onboarding = <OnboardingStep>[
    OnboardingStep.language,
    OnboardingStep.optionalBirthProfile,
    OnboardingStep.permissionsSummary,
  ];

  static List<ToolDomainDefinition> visibleToolDomains(ExperienceMode mode) =>
      List.unmodifiable(
        toolDomains.where(
          (item) => !item.professionalOnly || mode == ExperienceMode.professional,
        ),
      );

  static bool isSimpleFirstLaunch() =>
      onboarding.length <= 3 &&
      !visibleToolDomains(ExperienceMode.simple).any((d) => d.professionalOnly);
}
