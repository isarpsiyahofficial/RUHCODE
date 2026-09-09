import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/data/professional_search.dart';

void main() {
  ClientSearchDocument doc(int i) => ClientSearchDocument(
        clientId: 'client-${i.toString().padLeft(5, '0')}',
        displayName: i % 3 == 0 ? 'Saturn Client $i' : 'Client $i',
        tags: [if (i % 3 == 0) 'Satürn dönüşü', if (i % 5 == 0) 'Numeroloji'],
        createdAtUtc: DateTime.utc(2020 + (i % 7), 1 + (i % 12), 1 + (i % 27)),
        numerologyValues: {1 + (i % 9), 11 + (i % 3)},
      );

  test('professional search works by client name without server', () async {
    final source = InMemoryIndexedSearchSource(List.generate(1000, doc));
    final search = ProfessionalSearchCoordinator(source: source);
    final page = await search.search(LocalSearchQuery(name: 'Saturn'), pageSize: 25);
    expect(source.requiresServer, isFalse);
    expect(page.items, isNotEmpty);
    expect(page.items.every((e) => e.normalizedName.contains('saturn')), isTrue);
    expect(page.items.length, lessThanOrEqualTo(25));
  });

  test('tag search supports professional labels such as Saturn return', () async {
    final source = InMemoryIndexedSearchSource(List.generate(1000, doc));
    final search = ProfessionalSearchCoordinator(source: source);
    final page = await search.search(LocalSearchQuery(tag: 'Satürn dönüşü'), pageSize: 40);
    expect(page.items, isNotEmpty);
    expect(page.items.every((e) => e.tags.any((t) => t.contains('saturn donusu'))), isTrue);
  });

  test('date search filters local indexed records', () async {
    final source = InMemoryIndexedSearchSource(List.generate(1000, doc));
    final search = ProfessionalSearchCoordinator(source: source);
    final page = await search.search(
      LocalSearchQuery(fromUtc: DateTime.utc(2024), toUtc: DateTime.utc(2024, 12, 31, 23, 59, 59)),
      pageSize: 100,
    );
    expect(page.items, isNotEmpty);
    expect(page.items.every((e) => e.createdAtUtc.year == 2024), isTrue);
  });

  test('numerology result can be used as a local filter', () async {
    final source = InMemoryIndexedSearchSource(List.generate(1000, doc));
    final search = ProfessionalSearchCoordinator(source: source);
    final page = await search.search(LocalSearchQuery(numerologyValue: 7), pageSize: 50);
    expect(page.items, isNotEmpty);
    expect(page.items.every((e) => e.numerologyValues.contains(7)), isTrue);
  });

  test('1000 client scenario remains paged rather than all-at-once', () async {
    final source = InMemoryIndexedSearchSource(List.generate(1000, doc));
    final search = ProfessionalSearchCoordinator(source: source, maxPageSize: 80);
    final page = await search.search(LocalSearchQuery(), pageSize: 500);
    expect(page.items.length, 80);
    expect(page.hasMore, isTrue);
    expect(source.largestPageRequested, 80);
  });

  test('10000 profile stress scenario uses bounded pagination', () async {
    final source = InMemoryIndexedSearchSource(List.generate(10000, doc));
    final search = ProfessionalSearchCoordinator(source: source, maxPageSize: 100);
    final first = await search.search(LocalSearchQuery(name: 'Saturn'), pageSize: 100);
    final second = await search.search(LocalSearchQuery(name: 'Saturn'), offset: 100, pageSize: 100);
    expect(first.items.length, 100);
    expect(second.items.length, 100);
    expect(first.items.map((e) => e.clientId).toSet().intersection(second.items.map((e) => e.clientId).toSet()), isEmpty);
    expect(source.largestPageRequested, 100);
    expect(source.largestCandidateSetObserved, lessThan(10000));
  });

  test('search coordinator never accepts a server-required source', () {
    expect(
      () => ProfessionalSearchCoordinator(source: _ServerOnlySource()),
      throwsArgumentError,
    );
  });
}

final class _ServerOnlySource implements LocalSearchPageSource {
  @override
  bool get requiresServer => true;

  @override
  Future<SearchPage> query({required LocalSearchQuery query, required int offset, required int limit}) {
    throw UnimplementedError();
  }
}
