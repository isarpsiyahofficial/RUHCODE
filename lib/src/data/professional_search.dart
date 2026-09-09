import 'dart:collection';

final class ClientSearchDocument {
  ClientSearchDocument({
    required this.clientId,
    required this.displayName,
    required Iterable<String> tags,
    required this.createdAtUtc,
    required Iterable<int> numerologyValues,
  })  : tags = List.unmodifiable(tags.map(_normalize).where((e) => e.isNotEmpty)),
        normalizedName = _normalize(displayName),
        numerologyValues = Set.unmodifiable(numerologyValues) {
    if (clientId.trim().isEmpty || displayName.trim().isEmpty) {
      throw ArgumentError('Search documents require stable client id and display name');
    }
    if (!createdAtUtc.isUtc) {
      throw ArgumentError('Search document date must be a UTC instant');
    }
  }

  final String clientId;
  final String displayName;
  final String normalizedName;
  final List<String> tags;
  final DateTime createdAtUtc;
  final Set<int> numerologyValues;

  bool matches(LocalSearchQuery query) {
    if (query.normalizedName != null && !normalizedName.contains(query.normalizedName!)) {
      return false;
    }
    if (query.normalizedTag != null && !tags.any((tag) => tag.contains(query.normalizedTag!))) {
      return false;
    }
    if (query.fromUtc != null && createdAtUtc.isBefore(query.fromUtc!)) return false;
    if (query.toUtc != null && createdAtUtc.isAfter(query.toUtc!)) return false;
    if (query.numerologyValue != null && !numerologyValues.contains(query.numerologyValue)) {
      return false;
    }
    return true;
  }
}

final class LocalSearchQuery {
  LocalSearchQuery({
    String? name,
    String? tag,
    this.fromUtc,
    this.toUtc,
    this.numerologyValue,
  })  : normalizedName = _nullableNormalize(name),
        normalizedTag = _nullableNormalize(tag) {
    if (fromUtc != null && !fromUtc!.isUtc) {
      throw ArgumentError('fromUtc must be UTC');
    }
    if (toUtc != null && !toUtc!.isUtc) {
      throw ArgumentError('toUtc must be UTC');
    }
    if (fromUtc != null && toUtc != null && toUtc!.isBefore(fromUtc!)) {
      throw ArgumentError('toUtc cannot precede fromUtc');
    }
  }

  final String? normalizedName;
  final String? normalizedTag;
  final DateTime? fromUtc;
  final DateTime? toUtc;
  final int? numerologyValue;

  bool get isEmpty =>
      normalizedName == null &&
      normalizedTag == null &&
      fromUtc == null &&
      toUtc == null &&
      numerologyValue == null;
}

final class SearchPage {
  SearchPage({
    required Iterable<ClientSearchDocument> items,
    required this.offset,
    required this.limit,
    required this.hasMore,
  }) : items = List.unmodifiable(items) {
    if (offset < 0 || limit < 1 || items.length > limit) {
      throw ArgumentError('Invalid page bounds');
    }
  }

  final List<ClientSearchDocument> items;
  final int offset;
  final int limit;
  final bool hasMore;
}

abstract interface class LocalSearchPageSource {
  bool get requiresServer;

  Future<SearchPage> query({
    required LocalSearchQuery query,
    required int offset,
    required int limit,
  });
}

/// Professional search is deliberately page-source driven. The coordinator never
/// asks the source to load all clients at startup and caps each request.
final class ProfessionalSearchCoordinator {
  ProfessionalSearchCoordinator({required this.source, this.maxPageSize = 100}) {
    if (source.requiresServer) {
      throw ArgumentError('Professional search must work without a server');
    }
    if (maxPageSize < 1 || maxPageSize > 200) {
      throw ArgumentError('maxPageSize must be between 1 and 200');
    }
  }

  final LocalSearchPageSource source;
  final int maxPageSize;

  Future<SearchPage> search(
    LocalSearchQuery query, {
    int offset = 0,
    int pageSize = 50,
  }) {
    if (offset < 0) throw ArgumentError('offset cannot be negative');
    final boundedSize = pageSize.clamp(1, maxPageSize) as int;
    return source.query(query: query, offset: offset, limit: boundedSize);
  }
}

/// Deterministic local fixture/source used by tests and desktop/local adapters.
/// Production SQLite adapters can implement the same paging contract with indexes.
final class InMemoryIndexedSearchSource implements LocalSearchPageSource {
  InMemoryIndexedSearchSource(Iterable<ClientSearchDocument> documents)
      : _documents = List.unmodifiable(documents) {
    _namePrefixBuckets = _buildBuckets(_documents);
  }

  final List<ClientSearchDocument> _documents;
  late final Map<String, List<ClientSearchDocument>> _namePrefixBuckets;

  int largestCandidateSetObserved = 0;
  int largestPageRequested = 0;

  @override
  bool get requiresServer => false;

  @override
  Future<SearchPage> query({
    required LocalSearchQuery query,
    required int offset,
    required int limit,
  }) async {
    largestPageRequested = largestPageRequested < limit ? limit : largestPageRequested;
    final candidates = _candidateDocuments(query);
    if (largestCandidateSetObserved < candidates.length) {
      largestCandidateSetObserved = candidates.length;
    }
    final matches = candidates.where((document) => document.matches(query));
    final pageItems = matches.skip(offset).take(limit + 1).toList(growable: false);
    final hasMore = pageItems.length > limit;
    return SearchPage(
      items: hasMore ? pageItems.sublist(0, limit) : pageItems,
      offset: offset,
      limit: limit,
      hasMore: hasMore,
    );
  }

  Iterable<ClientSearchDocument> _candidateDocuments(LocalSearchQuery query) {
    final name = query.normalizedName;
    if (name != null && name.length >= 3) {
      return _namePrefixBuckets[name.substring(0, 3)] ?? const <ClientSearchDocument>[];
    }
    return _documents;
  }

  static Map<String, List<ClientSearchDocument>> _buildBuckets(
    Iterable<ClientSearchDocument> documents,
  ) {
    final buckets = <String, List<ClientSearchDocument>>{};
    for (final document in documents) {
      if (document.normalizedName.length < 3) continue;
      final key = document.normalizedName.substring(0, 3);
      buckets.putIfAbsent(key, () => <ClientSearchDocument>[]).add(document);
    }
    return UnmodifiableMapView(
      buckets.map((key, value) => MapEntry(key, List.unmodifiable(value))),
    );
  }
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ş', 's')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c');
}

String? _nullableNormalize(String? value) {
  if (value == null) return null;
  final normalized = _normalize(value);
  return normalized.isEmpty ? null : normalized;
}
