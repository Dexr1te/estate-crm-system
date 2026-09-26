import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/formatters.dart';
import 'package:real_estate_crm/core/widgets/status_chips.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class BrochureFonts {
  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;

  const BrochureFonts({
    required this.regular,
    required this.medium,
    required this.bold,
  });

  static const regularAsset = 'assets/fonts/Commissioner-400.ttf';
  static const mediumAsset = 'assets/fonts/Commissioner-600.ttf';
  static const boldAsset = 'assets/fonts/Commissioner-700.ttf';

  static BrochureFonts? _loaded;

  static Future<BrochureFonts> load([AssetBundle? bundle]) async {
    final cached = _loaded;
    if (cached != null && bundle == null) return cached;
    final source = bundle ?? rootBundle;
    final loaded = BrochureFonts(
      regular: pw.Font.ttf(await source.load(regularAsset)),
      medium: pw.Font.ttf(await source.load(mediumAsset)),
      bold: pw.Font.ttf(await source.load(boldAsset)),
    );
    if (bundle == null) _loaded = loaded;
    return loaded;
  }
}

class BrochureContact {
  final String? name;
  final String? email;
  final String? agency;

  const BrochureContact({this.name, this.email, this.agency});

  bool get isEmpty => _blank(name) && _blank(email) && _blank(agency);

  static bool _blank(String? s) => s == null || s.trim().isEmpty;
}

class ListingBrochure {
  const ListingBrochure._();

  static const int maxDescription = 1800;

  static const _navy = PdfColor.fromInt(0xFF0F1E3C);
  static const _gold = PdfColor.fromInt(0xFFE5B84C);
  static const _muted = PdfColor.fromInt(0xFF6B7A99);
  static const _hint = PdfColor.fromInt(0xFFADB5CC);
  static const _line = PdfColor.fromInt(0xFFE8ECF4);
  static const _wash = PdfColor.fromInt(0xFFF4F6FB);

  static String fileName(PropertyResponse property) {
    final slug = slugify(property.title);
    return slug.isEmpty
        ? 'listing-${property.id}.pdf'
        : 'listing-${property.id}-$slug.pdf';
  }

  static String slugify(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_translit[ch] ?? ch);
    }
    final slug = buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length <= 40) return slug;
    return slug.substring(0, 40).replaceAll(RegExp(r'-+$'), '');
  }

  static String capDescription(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= maxDescription) return trimmed;
    final cut = trimmed.substring(0, maxDescription);
    final space = cut.lastIndexOf(RegExp(r'\s'));
    final head = space > maxDescription * 0.8 ? cut.substring(0, space) : cut;
    return '${head.trimRight()}…';
  }

  static Future<Uint8List> build({
    required PropertyResponse property,
    required AppLocalizations l10n,
    required BrochureFonts fonts,
    List<Uint8List> photos = const [],
    BrochureContact contact = const BrochureContact(),
    DateTime? generatedAt,
  }) async {
    final images = <pw.ImageProvider>[];
    for (final bytes in photos) {
      try {
        images.add(pw.MemoryImage(bytes));
      } catch (_) {
        continue;
      }
    }
    final date = formatFullDate(generatedAt ?? DateTime.now(), l10n.localeName);
    final doc = pw.Document(
      title: property.title,
      author: contact.name,
      creator: contact.agency,
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        italic: fonts.regular,
        boldItalic: fonts.bold,
      ),
    );
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 32),
      footer: (context) => _footer(context, l10n, date),
      build: (context) => [
        _heading(property, l10n, fonts),
        if (images.isNotEmpty) ...[
          pw.SizedBox(height: 18),
          _cover(images.first),
        ],
        if (images.length > 1) ...[
          pw.SizedBox(height: 8),
          _grid(images.skip(1).take(4).toList()),
        ],
        pw.SizedBox(height: 20),
        _priceRow(property, l10n, fonts),
        pw.SizedBox(height: 16),
        _specs(property, l10n, fonts),
        ..._description(property, l10n, fonts),
        if (!contact.isEmpty) ...[
          pw.SizedBox(height: 22),
          pw.Inseparable(child: _contact(contact, l10n, fonts)),
        ],
      ],
    ));
    return doc.save();
  }

  static pw.Widget _heading(
      PropertyResponse p, AppLocalizations l10n, BrochureFonts fonts) {
    final place = [
      p.address.trim(),
      if (p.city != null && p.city!.trim().isNotEmpty) p.city!.trim(),
    ].where((s) => s.isNotEmpty).join(', ');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          propertyTypeLabel(l10n, p.type).toUpperCase(),
          style: pw.TextStyle(
              font: fonts.medium,
              fontSize: 8.5,
              letterSpacing: 0.6,
              color: _muted),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          p.title,
          maxLines: 3,
          style: pw.TextStyle(
              font: fonts.bold, fontSize: 22, lineSpacing: 2, color: _navy),
        ),
        if (place.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text(place,
              maxLines: 2,
              style: const pw.TextStyle(fontSize: 11, color: _muted)),
        ],
      ],
    );
  }

  static pw.Widget _cover(pw.ImageProvider image) => pw.ClipRRect(
        horizontalRadius: 6,
        verticalRadius: 6,
        child: pw.SizedBox(
          height: 240,
          width: double.infinity,
          child: pw.Image(image, fit: pw.BoxFit.cover),
        ),
      );

  static pw.Widget _grid(List<pw.ImageProvider> images) {
    return pw.Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) pw.SizedBox(width: 8),
          pw.Expanded(
            child: i < images.length
                ? pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.SizedBox(
                      height: 80,
                      child: pw.Image(images[i], fit: pw.BoxFit.cover),
                    ),
                  )
                : pw.SizedBox(height: 80),
          ),
        ],
      ],
    );
  }

  static pw.Widget _priceRow(
      PropertyResponse p, AppLocalizations l10n, BrochureFonts fonts) {
    final perSqm = p.areaSqm != null && p.areaSqm! > 0
        ? l10n.propertiesPricePerSqm(formatPrice(p.price / p.areaSqm!))
        : null;
    final flagged =
        p.status == PropertyStatus.SOLD || p.status == PropertyStatus.RESERVED;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(width: 3, height: 34, color: _gold),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(formatPrice(p.price),
                  maxLines: 1,
                  style: pw.TextStyle(
                      font: fonts.bold, fontSize: 24, color: _navy)),
              if (perSqm != null)
                pw.Text(perSqm,
                    maxLines: 1,
                    style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
            ],
          ),
        ),
        if (flagged)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _navy,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              propertyStatusLabel(l10n, p.status).toUpperCase(),
              maxLines: 1,
              style: pw.TextStyle(
                  font: fonts.bold,
                  fontSize: 9,
                  letterSpacing: 0.6,
                  color: PdfColors.white),
            ),
          ),
      ],
    );
  }

  static pw.Widget _specs(
      PropertyResponse p, AppLocalizations l10n, BrochureFonts fonts) {
    const dash = '—';
    final cells = [
      (l10n.propertiesType, propertyTypeLabel(l10n, p.type)),
      (
        l10n.propertiesArea,
        p.areaSqm == null
            ? dash
            : l10n.propertiesAreaValue(p.areaSqm!.toStringAsFixed(0)),
      ),
      (l10n.propertiesRooms, p.rooms?.toString() ?? dash),
      (
        l10n.propertiesFloor,
        p.floor == null
            ? dash
            : p.totalFloors == null
                ? '${p.floor}'
                : l10n.propertiesFloorOf(p.floor!, p.totalFloors!),
      ),
    ];
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      child: pw.Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14),
                decoration: i == 0
                    ? null
                    : const pw.BoxDecoration(
                        border: pw.Border(
                            left: pw.BorderSide(color: _line, width: 1))),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(cells[i].$1.toUpperCase(),
                        maxLines: 1,
                        style: pw.TextStyle(
                            font: fonts.medium,
                            fontSize: 7.5,
                            letterSpacing: 0.5,
                            color: _hint)),
                    pw.SizedBox(height: 4),
                    pw.Text(cells[i].$2,
                        maxLines: 1,
                        style: pw.TextStyle(
                            font: fonts.medium, fontSize: 12, color: _navy)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<pw.Widget> _description(
      PropertyResponse p, AppLocalizations l10n, BrochureFonts fonts) {
    final text = p.description?.trim() ?? '';
    if (text.isEmpty) return const [];
    return [
      pw.SizedBox(height: 22),
      _eyebrow(l10n.propertiesDescription, fonts),
      pw.SizedBox(height: 8),
      for (final para in capDescription(text).split(RegExp(r'\n\s*\n')))
        if (para.trim().isNotEmpty)
          pw.Paragraph(
            text: para.trim(),
            margin: const pw.EdgeInsets.only(bottom: 6),
            style: const pw.TextStyle(
                fontSize: 10.5, lineSpacing: 3.5, color: _navy),
          ),
    ];
  }

  static pw.Widget _contact(
      BrochureContact c, AppLocalizations l10n, BrochureFonts fonts) {
    String? clean(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    final name = clean(c.name);
    final email = clean(c.email);
    final agency = clean(c.agency);
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _wash,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.propertiesBrochureContact, fonts),
          pw.SizedBox(height: 8),
          if (name != null)
            pw.Text(name,
                maxLines: 1,
                style:
                    pw.TextStyle(font: fonts.bold, fontSize: 13, color: _navy)),
          if (agency != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(agency,
                  maxLines: 1,
                  style: const pw.TextStyle(fontSize: 10, color: _muted)),
            ),
          if (email != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
              child: pw.UrlLink(
                destination: 'mailto:$email',
                child: pw.Text(email,
                    maxLines: 1,
                    style: pw.TextStyle(
                        font: fonts.medium, fontSize: 10.5, color: _navy)),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _eyebrow(String text, BrochureFonts fonts) => pw.Text(
        text.toUpperCase(),
        maxLines: 1,
        style: pw.TextStyle(
            font: fonts.medium, fontSize: 8, letterSpacing: 0.6, color: _muted),
      );

  static pw.Widget _footer(
      pw.Context context, AppLocalizations l10n, String date) {
    const style = pw.TextStyle(fontSize: 8, color: _hint);
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _line, width: 1))),
      child: pw.Row(
        children: [
          pw.Expanded(
              child: pw.Text(l10n.propertiesBrochureGenerated(date),
                  maxLines: 1, style: style)),
          if (context.pagesCount > 1)
            pw.Text(
                l10n.propertiesBrochurePage(
                    context.pageNumber, context.pagesCount),
                maxLines: 1,
                style: style),
        ],
      ),
    );
  }

  static const _translit = {
    'а': 'a',
    'б': 'b',
    'в': 'v',
    'г': 'g',
    'д': 'd',
    'е': 'e',
    'ё': 'e',
    'ж': 'zh',
    'з': 'z',
    'и': 'i',
    'й': 'y',
    'к': 'k',
    'л': 'l',
    'м': 'm',
    'н': 'n',
    'о': 'o',
    'п': 'p',
    'р': 'r',
    'с': 's',
    'т': 't',
    'у': 'u',
    'ф': 'f',
    'х': 'h',
    'ц': 'ts',
    'ч': 'ch',
    'ш': 'sh',
    'щ': 'sch',
    'ъ': '',
    'ы': 'y',
    'ь': '',
    'э': 'e',
    'ю': 'yu',
    'я': 'ya',
    'ә': 'a',
    'ғ': 'g',
    'қ': 'q',
    'ң': 'n',
    'ө': 'o',
    'ұ': 'u',
    'ү': 'u',
    'һ': 'h',
    'і': 'i',
  };
}
