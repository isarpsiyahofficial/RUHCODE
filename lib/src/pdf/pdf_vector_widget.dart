import 'package:pdf/widgets.dart' as pw;

import 'pdf_vector_rendering.dart';

/// Converts a validated SVG primitive payload into a `package:pdf` vector
/// widget. `SvgImage` keeps the source as vector drawing commands in the PDF
/// pipeline; this class intentionally has no raster/JPEG/PNG input path.
final class PdfVectorWidget {
  const PdfVectorWidget();

  pw.Widget build(PdfVectorGraphic graphic) {
    graphic.validate();
    return pw.SizedBox(
      width: graphic.widthPt,
      height: graphic.heightPt,
      child: pw.SvgImage(svg: graphic.svg),
    );
  }
}
