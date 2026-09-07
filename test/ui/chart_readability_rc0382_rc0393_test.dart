import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/chart/chart_readability_policy.dart';

void main() {
  const policy = ChartReadabilityPolicy();

  test('phone degree and planet glyph sizing has explicit readable floor', () {
    expect(policy.minimumPhoneDegreeFontSize, greaterThanOrEqualTo(12));
    expect(policy.minimumPlanetGlyphSize, greaterThanOrEqualTo(18));
  });

  test('nearby planet labels are visually separated without changing source longitude', () {
    final result = const CircularLabelLayout(policy).position(const [
      AngularLabel(id: 'sun', longitude: 10),
      AngularLabel(id: 'moon', longitude: 11),
      AngularLabel(id: 'mercury', longitude: 12),
    ]);
    expect(result[0].originalLongitude, 10);
    expect(result[1].originalLongitude, 11);
    expect(
      result[1].displayLongitude - result[0].displayLongitude,
      greaterThanOrEqualTo(policy.minimumLabelSeparationDegrees),
    );
    expect(
      result[2].displayLongitude - result[1].displayLongitude,
      greaterThanOrEqualTo(policy.minimumLabelSeparationDegrees),
    );
  });

  test('aspect-line density is capped on phones and preserves strongest items', () {
    final aspects = List.generate(
      60,
      (i) => AspectVisual(id: 'a$i', orbDegrees: i / 10, priority: i),
    );
    final phone = const AspectLineReducer(policy).forDensity(aspects, ChartDensity.phone);
    expect(phone.length, policy.maximumAspectLinesPhone);
    expect(phone.first.id, 'a59');
  });

  test('zoom stays available inside a bounded professional chart range', () {
    expect(policy.clampZoom(0.2), policy.minimumZoom);
    expect(policy.clampZoom(2.0), 2.0);
    expect(policy.clampZoom(9.0), policy.maximumZoom);
  });

  test('visual policy is professional modern and domain layer remains platform neutral', () {
    expect(UiPlatformPolicy.productTone, ProductVisualTone.professionalModern);
    expect(UiPlatformPolicy.computationScreensPrioritizeReadability, isTrue);
    expect(UiPlatformPolicy.primaryPlatform, 'android');
    expect(UiPlatformPolicy.renderingFramework, 'flutter');
    expect(UiPlatformPolicy.platformNeutralDomainLayer, isTrue);
  });
}
