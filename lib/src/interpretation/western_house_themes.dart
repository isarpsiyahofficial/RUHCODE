final class WesternHouseTheme {
  const WesternHouseTheme({
    required this.houseNumber,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
  });

  final int houseNumber;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
}

abstract final class WesternHouseThemes {
  static const List<WesternHouseTheme> all = [
    WesternHouseTheme(houseNumber: 1, titleTr: 'Benlik ve yaklaşım', titleEn: 'Self and approach', descriptionTr: 'Kimlik, dışa yansıyan tavır, hayata yaklaşım ve kişisel başlangıçlar.', descriptionEn: 'Identity, outward manner, approach to life, and personal beginnings.'),
    WesternHouseTheme(houseNumber: 2, titleTr: 'Kaynaklar ve değerler', titleEn: 'Resources and values', descriptionTr: 'Maddi kaynaklar, sahip olunanlar, özdeğer ve kişisel değer ölçütleri.', descriptionEn: 'Material resources, possessions, self-worth, and personal value systems.'),
    WesternHouseTheme(houseNumber: 3, titleTr: 'İletişim ve yakın çevre', titleEn: 'Communication and local environment', descriptionTr: 'İletişim, öğrenme biçimi, kardeşler, kısa yolculuklar ve yakın çevre.', descriptionEn: 'Communication, learning style, siblings, short journeys, and the local environment.'),
    WesternHouseTheme(houseNumber: 4, titleTr: 'Ev ve kökler', titleEn: 'Home and roots', descriptionTr: 'Ev yaşamı, aile kökleri, özel alan, aidiyet ve duygusal temel.', descriptionEn: 'Home life, family roots, private life, belonging, and emotional foundations.'),
    WesternHouseTheme(houseNumber: 5, titleTr: 'Yaratıcılık ve ifade', titleEn: 'Creativity and expression', descriptionTr: 'Yaratıcılık, kişisel ifade, romantizm, hobiler, keyif ve çocuklarla ilgili temalar.', descriptionEn: 'Creativity, self-expression, romance, hobbies, pleasure, and themes involving children.'),
    WesternHouseTheme(houseNumber: 6, titleTr: 'Günlük düzen ve hizmet', titleEn: 'Daily routines and service', descriptionTr: 'Günlük rutinler, çalışma düzeni, sorumluluklar, hizmet ve sağlık alışkanlıkları.', descriptionEn: 'Daily routines, work patterns, responsibilities, service, and health habits.'),
    WesternHouseTheme(houseNumber: 7, titleTr: 'Ortaklıklar', titleEn: 'Partnerships', descriptionTr: 'Bire bir ilişkiler, ortaklıklar, anlaşmalar ve açık karşıtlıklar.', descriptionEn: 'One-to-one relationships, partnerships, agreements, and open opposition.'),
    WesternHouseTheme(houseNumber: 8, titleTr: 'Paylaşılan kaynaklar ve dönüşüm', titleEn: 'Shared resources and transformation', descriptionTr: 'Paylaşılan kaynaklar, borçlar, miras, yakınlık, kriz ve dönüşüm süreçleri.', descriptionEn: 'Shared resources, debts, inheritance, intimacy, crisis, and transformation processes.'),
    WesternHouseTheme(houseNumber: 9, titleTr: 'Ufuklar ve inançlar', titleEn: 'Horizons and beliefs', descriptionTr: 'Yüksek öğrenim, uzun yolculuklar, dünya görüşü, inançlar ve anlam arayışı.', descriptionEn: 'Higher learning, long-distance travel, worldview, beliefs, and the search for meaning.'),
    WesternHouseTheme(houseNumber: 10, titleTr: 'Kariyer ve kamusal yön', titleEn: 'Career and public direction', descriptionTr: 'Kariyer, toplumsal rol, sorumluluk, itibar ve uzun vadeli hedefler.', descriptionEn: 'Career, social role, responsibility, reputation, and long-term goals.'),
    WesternHouseTheme(houseNumber: 11, titleTr: 'Topluluklar ve hedefler', titleEn: 'Communities and goals', descriptionTr: 'Arkadaşlıklar, gruplar, topluluklar, ortak idealler ve gelecek hedefleri.', descriptionEn: 'Friendships, groups, communities, shared ideals, and future goals.'),
    WesternHouseTheme(houseNumber: 12, titleTr: 'İç dünya ve geri çekilme', titleEn: 'Inner life and retreat', descriptionTr: 'İç dünya, yalnız kalma, geri çekilme, perde arkası süreçler ve kapanışlar.', descriptionEn: 'Inner life, solitude, retreat, behind-the-scenes processes, and endings.'),
  ];

  static WesternHouseTheme forHouse(int houseNumber) {
    if (houseNumber < 1 || houseNumber > 12) {
      throw RangeError.range(houseNumber, 1, 12, 'houseNumber');
    }
    return all[houseNumber - 1];
  }
}
