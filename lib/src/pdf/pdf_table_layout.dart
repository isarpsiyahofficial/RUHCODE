/// Deterministic preprocessing for long report tables.
///
/// The PDF renderer receives logical rows and splits them into bounded table
/// widgets. This gives MultiPage explicit break opportunities instead of one
/// unbounded table widget and repeats the logical header on later chunks.
final class PdfTableChunk {
  const PdfTableChunk({required this.rows});

  final List<List<String>> rows;
}

final class PdfTableLayout {
  const PdfTableLayout({this.maxBodyRowsPerChunk = 24});

  final int maxBodyRowsPerChunk;

  List<PdfTableChunk> chunk(List<List<String>> input) {
    if (maxBodyRowsPerChunk < 1) {
      throw const FormatException('PDF table chunk size must be at least one body row.');
    }
    if (input.isEmpty) {
      return const <PdfTableChunk>[];
    }

    final width = input.first.length;
    if (width == 0) {
      throw const FormatException('PDF table cannot contain zero-column rows.');
    }
    for (var index = 0; index < input.length; index++) {
      if (input[index].length != width) {
        throw FormatException(
          'PDF table row $index has ${input[index].length} columns; expected $width.',
        );
      }
    }

    if (input.length == 1) {
      return <PdfTableChunk>[PdfTableChunk(rows: <List<String>>[List<String>.from(input.first)])];
    }

    final header = List<String>.from(input.first);
    final body = input.skip(1).toList(growable: false);
    final chunks = <PdfTableChunk>[];
    for (var start = 0; start < body.length; start += maxBodyRowsPerChunk) {
      final end = (start + maxBodyRowsPerChunk < body.length)
          ? start + maxBodyRowsPerChunk
          : body.length;
      chunks.add(
        PdfTableChunk(
          rows: <List<String>>[
            List<String>.from(header),
            ...body.sublist(start, end).map(List<String>.from),
          ],
        ),
      );
    }
    return List<PdfTableChunk>.unmodifiable(chunks);
  }
}
