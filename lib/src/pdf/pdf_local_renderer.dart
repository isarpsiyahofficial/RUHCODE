import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_data_contract.dart';
import 'pdf_output_inspector.dart';
import 'pdf_report_contract.dart';
import 'pdf_table_layout.dart';

final class PdfFontBundle {
  const PdfFontBundle({
    required this.regularBytes,
    required this.boldBytes,
    required this.regularSha256,
    required this.boldSha256,
    required this.familyName,
    required this.licenseId,
  });

  final Uint8List regularBytes;
  final Uint8List boldBytes;
  final String regularSha256;
  final String boldSha256;
  final String familyName;
  final String licenseId;

  void validate() {
    if (regularBytes.isEmpty || boldBytes.isEmpty) {
      throw const FormatException('PDF font bundle cannot contain empty font data.');
    }
    if (familyName.trim().isEmpty || licenseId.trim().isEmpty) {
      throw const FormatException('PDF font provenance must include family and license identifiers.');
    }
    final hashPattern = RegExp(r'^[a-f0-9]{64}$');
    if (!hashPattern.hasMatch(regularSha256) || !hashPattern.hasMatch(boldSha256)) {
      throw const FormatException('PDF font digests must be lowercase SHA-256 hex.');
    }
    if (sha256.convert(regularBytes).toString() != regularSha256 ||
        sha256.convert(boldBytes).toString() != boldSha256) {
      throw const FormatException('PDF font digest does not match bundled bytes.');
    }
  }
}

final class PdfRenderSection {
  const PdfRenderSection({
    required this.sectionId,
    required this.snapshotDigest,
    required this.title,
    required this.paragraphs,
    this.rows = const <List<String>>[],
  });

  final String sectionId;
  final String snapshotDigest;
  final String title;
  final List<String> paragraphs;
  final List<List<String>> rows;

  bool get hasContent =>
      title.trim().isNotEmpty ||
      paragraphs.any((value) => value.trim().isNotEmpty) ||
      rows.any((row) => row.any((value) => value.trim().isNotEmpty));
}

final class PdfRenderPayload {
  const PdfRenderPayload({
    required this.plan,
    required this.dataset,
    required this.documentTitle,
    required this.sections,
    required this.fonts,
  });

  final PdfReportPlan plan;
  final PdfReportDataset dataset;
  final String documentTitle;
  final List<PdfRenderSection> sections;
  final PdfFontBundle fonts;
}

/// Pure section-contract validation shared by the byte renderer and unit tests.
///
/// An adapter may expose every verified section it knows how to render while a
/// user selects only a subset for this report. Extra verified payloads are
/// therefore allowed but never rendered. Selected sections remain strict: each
/// one must exist, be non-empty, belong to the same snapshot and have a render
/// payload.
final class PdfRenderContractValidator {
  const PdfRenderContractValidator({
    this.dataValidator = const PdfReportDataValidator(),
    this.tableLayout = const PdfTableLayout(),
  });

  final PdfReportDataValidator dataValidator;
  final PdfTableLayout tableLayout;

  void validate(PdfRenderPayload payload) {
    payload.fonts.validate();
    if (payload.documentTitle.trim().isEmpty) {
      throw const FormatException('PDF document title cannot be blank.');
    }
    final projected = dataValidator.validateAndProject(payload.dataset);
    if (payload.dataset.origin != payload.plan.dataOrigin) {
      throw const FormatException('PDF plan and dataset data origins do not match.');
    }

    final available = {for (final section in projected) section.id: section.hasContent};
    final renderIds = <String>{};
    for (final section in payload.sections) {
      if (!PdfSectionIds.all.contains(section.sectionId)) {
        throw FormatException('Unknown render section id: ${section.sectionId}.');
      }
      if (!renderIds.add(section.sectionId)) {
        throw FormatException('Duplicate render section id: ${section.sectionId}.');
      }
      if (section.snapshotDigest != payload.dataset.identity.snapshotDigest) {
        throw FormatException('Render section ${section.sectionId} belongs to another snapshot.');
      }
      if (!available.containsKey(section.sectionId)) {
        throw FormatException(
          'Render section ${section.sectionId} is not declared by the verified dataset.',
        );
      }
      if (available[section.sectionId] != true || !section.hasContent) {
        throw FormatException('Render section ${section.sectionId} is empty or unavailable.');
      }
      tableLayout.chunk(section.rows);
    }

    for (final id in payload.plan.sectionIds) {
      if (available[id] != true) {
        throw FormatException('Selected PDF section $id is unavailable in the verified dataset.');
      }
      if (!renderIds.contains(id)) {
        throw FormatException('Selected PDF section $id has no render payload.');
      }
    }
  }
}

final class PdfLocalRenderer {
  const PdfLocalRenderer({
    this.dataValidator = const PdfReportDataValidator(),
    this.outputInspector = const PdfOutputInspector(),
    this.tableLayout = const PdfTableLayout(),
  });

  static const int maxReportPages = 200;
  static const double sectionKeepTogetherFreeSpacePt = 72;

  final PdfReportDataValidator dataValidator;
  final PdfOutputInspector outputInspector;
  final PdfTableLayout tableLayout;

  Future<Uint8List> render(PdfRenderPayload payload) async {
    PdfRenderContractValidator(
      dataValidator: dataValidator,
      tableLayout: tableLayout,
    ).validate(payload);

    final regular = pw.Font.ttf(ByteData.sublistView(payload.fonts.regularBytes));
    final bold = pw.Font.ttf(ByteData.sublistView(payload.fonts.boldBytes));
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final document = pw.Document(
      title: payload.documentTitle,
      author: payload.plan.branding.professionalName ?? payload.plan.branding.brandName ?? 'Ruh Code',
      subject: 'Ruh Code ${payload.plan.kind.name} report',
    );

    final mm = PdfPageFormat.mm;
    final pageSpec = payload.plan.pageSpec;
    final pageFormat = PdfPageFormat(
      pageSpec.widthMm * mm,
      pageSpec.heightMm * mm,
      marginTop: pageSpec.marginTopMm * mm,
      marginRight: pageSpec.marginRightMm * mm,
      marginBottom: pageSpec.marginBottomMm * mm,
      marginLeft: pageSpec.marginLeftMm * mm,
    );

    final byId = <String, PdfRenderSection>{
      for (final section in payload.sections) section.sectionId: section,
    };

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        theme: theme,
        maxPages: maxReportPages,
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(fontSize: payload.plan.typography.captionPt),
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];
          for (final sectionId in payload.plan.sectionIds) {
            final section = byId[sectionId];
            if (section == null || !section.hasContent) {
              continue;
            }
            if (sectionId == PdfSectionIds.cover) {
              widgets.addAll(_coverWidgets(payload, section));
            } else {
              widgets.addAll(_sectionWidgets(payload, section));
            }
          }
          return widgets;
        },
      ),
    );

    final bytes = Uint8List.fromList(await document.save());
    outputInspector.requireUsable(bytes);
    return bytes;
  }

  List<pw.Widget> _coverWidgets(PdfRenderPayload payload, PdfRenderSection section) {
    final tokens = payload.plan.typography;
    return <pw.Widget>[
      pw.SizedBox(height: 28),
      pw.Text(
        payload.documentTitle,
        style: pw.TextStyle(fontSize: tokens.coverTitlePt, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 14),
      if (payload.plan.branding.brandName?.trim().isNotEmpty == true)
        pw.Text(payload.plan.branding.brandName!.trim(), style: pw.TextStyle(fontSize: tokens.h2Pt)),
      if (payload.plan.branding.professionalName?.trim().isNotEmpty == true)
        pw.Text(payload.plan.branding.professionalName!.trim(), style: pw.TextStyle(fontSize: tokens.bodyPt)),
      pw.SizedBox(height: 20),
      ...section.paragraphs.where((text) => text.trim().isNotEmpty).map(
            (text) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(text, style: pw.TextStyle(fontSize: tokens.bodyPt)),
            ),
          ),
      pw.SizedBox(height: 20),
    ];
  }

  List<pw.Widget> _sectionWidgets(PdfRenderPayload payload, PdfRenderSection section) {
    final tokens = payload.plan.typography;
    final paragraphs = section.paragraphs.where((value) => value.trim().isNotEmpty).toList(growable: false);
    final widgets = <pw.Widget>[
      pw.NewPage(freeSpace: sectionKeepTogetherFreeSpacePt),
      pw.SizedBox(height: 10),
    ];

    final heading = pw.Header(
      level: 1,
      text: section.title,
      textStyle: pw.TextStyle(fontSize: tokens.h1Pt, fontWeight: pw.FontWeight.bold),
    );
    if (paragraphs.isNotEmpty) {
      widgets.add(
        pw.Inseparable(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              heading,
              _paragraphWidget(paragraphs.first, tokens),
            ],
          ),
        ),
      );
      for (final paragraph in paragraphs.skip(1)) {
        widgets.add(_paragraphWidget(paragraph, tokens));
      }
    } else {
      widgets.add(heading);
    }

    for (final chunk in tableLayout.chunk(section.rows)) {
      widgets.add(
        pw.TableHelper.fromTextArray(
          data: chunk.rows,
          cellStyle: pw.TextStyle(fontSize: tokens.tablePt),
          headerStyle: pw.TextStyle(fontSize: tokens.tablePt, fontWeight: pw.FontWeight.bold),
          cellPadding: const pw.EdgeInsets.all(4),
        ),
      );
      widgets.add(pw.SizedBox(height: 6));
    }
    return widgets;
  }

  pw.Widget _paragraphWidget(String paragraph, PdfTypographyTokens tokens) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Text(
          paragraph,
          style: pw.TextStyle(fontSize: tokens.bodyPt, lineSpacing: tokens.lineHeight),
        ),
      );
}
