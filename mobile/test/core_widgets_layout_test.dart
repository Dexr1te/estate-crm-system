import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const _screen = 800.0;
const _column = 390.0;
const _inset = 20.0;
const _contentLeft = (_screen - _column) / 2 + _inset;
const _contentRight = (_screen + _column) / 2 - _inset;

Widget _app(Widget home) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

Widget _host(Widget child) => _app(Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: _column,
          child: Padding(
            padding: const EdgeInsets.all(_inset),
            child: child,
          ),
        ),
      ),
    ));

Color _fill(WidgetTester tester, Key key) => tester
    .widget<Material>(find
        .descendant(of: find.byKey(key), matching: find.byType(Material))
        .first)
    .color!;

void main() {
  const t = AppTokens.light;

  testWidgets('a section header link ends on the content edge', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(Column(children: [
      const SizedBox(height: 30),
      SectionHeader(
        key: const ValueKey('header'),
        title: 'Today',
        count: 3,
        actionLabel: 'See all',
        onAction: () => taps++,
      ),
      const SizedBox(height: 30),
    ])));

    final header = tester.getRect(find.byKey(const ValueKey('header')));
    final link = tester.getRect(find.byType(InkWell));
    final glyph = tester.getRect(find.descendant(
        of: find.byType(RowChevron), matching: find.byType(Icon)));
    const sideBearing = 5.0;

    expect(header.left, _contentLeft);
    expect(header.right, _contentRight);
    expect(link.right, header.right);
    expect(glyph.right - sideBearing, header.right);
    expect(tester.getRect(find.text('3')).right, lessThan(header.center.dx));

    expect(header.height, lessThan(AppMetrics.minHitTarget));
    final slop = (AppMetrics.minHitTarget - header.height) / 2;
    await tester.tapAt(Offset(link.center.dx, header.top - slop + 1));
    await tester.tapAt(Offset(link.center.dx, header.bottom + slop - 1));
    expect(taps, 2);

    await tester.tapAt(Offset(link.center.dx, header.top - slop - 1));
    await tester.tapAt(Offset(header.left + 4, header.top - 2));
    expect(taps, 2);
  });

  testWidgets('an info row sets its value flush with the trailing edge',
      (tester) async {
    const value = '+7 701 000 00 00';
    await tester.pumpWidget(_host(const Column(children: [
      InfoRow(key: ValueKey('row'), label: 'Phone', value: value),
    ])));

    final row = tester.getRect(find.byKey(const ValueKey('row')));
    expect(row.right, _contentRight);
    expect(tester.getRect(find.text(value)).right, row.right);

    final paragraph = tester.renderObject<RenderParagraph>(find.text(value));
    final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: value.length));
    expect(boxes.last.right, moreOrLessEquals(paragraph.size.width));
  });

  testWidgets('metrics in a row share their value top; an odd one spans it',
      (tester) async {
    await tester.pumpWidget(_host(const MetricsCard(metrics: [
      Metric(value: '24', caption: 'Active deals', series: [1, 3, 2, 5]),
      Metric(value: '138', caption: 'Clients'),
      Metric(value: '7', caption: 'Meetings'),
    ])));

    final card = tester.getRect(find.byType(MetricsCard));
    final withSeries = tester.getRect(find.text('24'));
    final without = tester.getRect(find.text('138'));

    expect(withSeries.top, without.top);
    expect(withSeries.height, without.height);
    expect(withSeries.left - card.left,
        AppMetrics.cardPadding(tester.element(find.byType(MetricsCard))));

    final lone = tester.getRect(find.ancestor(
        of: find.text('7'), matching: find.byType(IntrinsicHeight)));
    expect(lone.width, card.width);
  });

  testWidgets('a settings row lets a long value use the room its label leaves',
      (tester) async {
    const name = 'Sultan Assan-Doroshenko Bekmukhambetov';
    await tester.pumpWidget(_host(SettingsGroup(rows: [
      SettingsRow(
        key: const ValueKey('row'),
        label: 'Name',
        value: name,
        showChevron: true,
        onTap: () {},
      ),
    ])));

    final row = tester.getRect(find.byKey(const ValueKey('row')));
    final label = tester.renderObject<RenderParagraph>(find.text('Name'));
    expect(label.didExceedMaxLines, isFalse);
    expect(tester.getRect(find.text(name)).width, greaterThan(150));
    expect(tester.getRect(find.byType(RowChevron)).right, row.right - 15);
  });

  testWidgets('a settings section keeps its label close to its group',
      (tester) async {
    await tester.pumpWidget(_host(const SettingsSection(
      label: 'Security',
      child: SettingsGroup(rows: [SettingsRow(label: 'PIN')]),
    )));

    final label = tester.getRect(find.byType(EyebrowLabel));
    final group = tester.getRect(find.byType(SettingsGroup));
    expect(group.top - label.bottom, 8);
  });

  testWidgets('fills contrast with the surface they sit on', (tester) async {
    await tester.pumpWidget(_host(Column(children: [
      AppGhostButton(key: const ValueKey('page'), label: 'a', onPressed: () {}),
      FilterPill(
          key: const ValueKey('page-pill'),
          label: 'p',
          selected: false,
          onTap: () {}),
      AppCard(
        child: Column(children: [
          AppGhostButton(
              key: const ValueKey('card'), label: 'b', onPressed: () {}),
          FilterPill(
              key: const ValueKey('card-pill'),
              label: 'q',
              selected: false,
              onTap: () {}),
          AppCard(
            nested: true,
            child: AppGhostButton(
                key: const ValueKey('nested'), label: 'c', onPressed: () {}),
          ),
        ]),
      ),
      GlassSurface(
        child: AppGhostButton(
            key: const ValueKey('glass'), label: 'd', onPressed: () {}),
      ),
      AppGhostButton(
          key: const ValueKey('override'),
          label: 'e',
          fill: t.accent,
          onPressed: () {}),
    ])));

    expect(_fill(tester, const ValueKey('page')), t.surface);
    expect(_fill(tester, const ValueKey('page-pill')), t.surface);
    expect(_fill(tester, const ValueKey('card')), t.surfaceVariant);
    expect(_fill(tester, const ValueKey('card-pill')), t.surfaceVariant);
    expect(_fill(tester, const ValueKey('nested')), t.surface);
    expect(_fill(tester, const ValueKey('glass')), t.surfaceVariant);
    expect(_fill(tester, const ValueKey('override')), t.accent);
  });

  testWidgets('a disabled filled button keeps its colour, dimmed',
      (tester) async {
    await tester.pumpWidget(_host(const AppFilledButton(
        key: ValueKey('off'), label: 'Save', onPressed: null)));

    expect(
        _fill(tester, const ValueKey('off')), t.primary.withValues(alpha: 0.4));
    expect(tester.widget<Text>(find.text('Save')).style?.color, t.onPrimary);
  });

  testWidgets('text fields and pickers share an inset, a size and a height',
      (tester) async {
    await tester.pumpWidget(_host(Column(children: [
      AppTextField(
        key: const ValueKey('field'),
        controller: TextEditingController(text: 'Typed'),
      ),
      PickerField(
          key: const ValueKey('picker'),
          value: 'Picked',
          placeholder: 'Pick',
          onTap: () {}),
    ])));

    final field = tester.getRect(find.byKey(const ValueKey('field')));
    final picker = tester.getRect(find.byKey(const ValueKey('picker')));
    expect(picker.height, field.height);
    expect(tester.getRect(find.text('Typed')).left - field.left,
        AppMetrics.fieldInset);
    expect(tester.getRect(find.text('Picked')).left - picker.left,
        AppMetrics.fieldInset);
    expect(
        tester.widget<Text>(find.text('Picked')).style?.fontSize, AppType.body);
  });

  testWidgets('a pill row starts at the content edge and can paint past it',
      (tester) async {
    Widget pill(String label) =>
        FilterPill(label: label, selected: false, onTap: () {});
    await tester.pumpWidget(_host(Column(children: [
      FilterPillRow(pills: [pill('One')]),
      FilterPillRow(key: const ValueKey('bleed'), bleed: true, pills: [
        pill('Two'),
      ]),
    ])));

    expect(tester.getRect(find.text('One')).left, greaterThan(_contentLeft));
    expect(
        tester
            .getRect(find.ancestor(
                of: find.text('One'), matching: find.byType(FilterPill)))
            .left,
        _contentLeft);

    final bleed = find.descendant(
        of: find.byKey(const ValueKey('bleed')),
        matching: find.byType(SingleChildScrollView));
    expect(tester.widget<SingleChildScrollView>(bleed).clipBehavior, Clip.none);
    expect(tester.getRect(bleed).left, _contentLeft);
    expect(tester.getRect(bleed).right, _contentRight);
    expect(
        tester
            .getRect(find.ancestor(
                of: find.text('Two'), matching: find.byType(FilterPill)))
            .left,
        _contentLeft);
  });

  testWidgets('an empty state in a detail page is centred and padded once',
      (tester) async {
    const title = 'Nothing has happened here yet, and that is quite all right '
        'because the list fills itself as soon as there is something to say';
    await tester.pumpWidget(_app(const DetailScaffold(
      title: 'Details',
      children: [EmptyState(icon: Icons.inbox_outlined, title: title)],
    )));

    const content = AppMetrics.wideMaxContentWidth - 2 * 20;
    expect(tester.getRect(find.text(title)).width, content);
    expect(tester.getCenter(find.byIcon(Icons.inbox_outlined)).dx, _screen / 2);
    final tile = tester.widget<Container>(find
        .ancestor(
            of: find.byIcon(Icons.inbox_outlined),
            matching: find.byType(Container))
        .first);
    expect((tile.decoration! as BoxDecoration).border, isNull);
  });

  testWidgets('the app bar ends text and glyphs on the page inset',
      (tester) async {
    await tester.pumpWidget(_app(const Scaffold(
      body: DetailAppBar(title: 'Form', trailingLabel: 'Step 1 of 2'),
    )));
    expect(tester.getRect(find.text('Step 1 of 2')).right, _screen - 20);

    await tester.pumpWidget(_app(Scaffold(
      body: DetailAppBar(title: 'Form', actions: [
        AppIconTile(icon: Icons.edit_outlined, onPressed: () {}),
      ]),
    )));
    final glyph = tester.getRect(find.byIcon(Icons.edit_outlined));
    expect(_screen - glyph.right, moreOrLessEquals(20, epsilon: 1));
  });

  testWidgets('an edge-aligned icon tile keeps its target, moves its glyph',
      (tester) async {
    await tester.pumpWidget(_host(Row(children: [
      const Spacer(),
      AppIconTile(
          key: const ValueKey('tile'),
          icon: Icons.close_rounded,
          alignEnd: true,
          onPressed: () {}),
    ])));

    final tile = tester.getRect(find.byKey(const ValueKey('tile')));
    expect(tile.width, AppMetrics.minHitTarget);
    expect(tile.right, _contentRight);
    expect(tester.getRect(find.byIcon(Icons.close_rounded)).right, tile.right);
  });

  testWidgets('an avatar with no name shows a person, not a question mark',
      (tester) async {
    await tester.pumpWidget(_host(const Row(children: [
      UserAvatar(name: ' '),
      InitialAvatar(name: ''),
    ])));

    expect(find.text('?'), findsNothing);
    expect(find.byIcon(Icons.person_rounded), findsNWidgets(2));
  });

  testWidgets('a skeleton card is a real card with bones on it',
      (tester) async {
    await tester.pumpWidget(_host(const ShimmerGroup(
      child: ShimmerCard(
        key: ValueKey('card'),
        child: ShimmerBar(widthFactor: 0.5),
      ),
    )));

    final card = tester.widget<Container>(find
        .descendant(
            of: find.byKey(const ValueKey('card')),
            matching: find.byType(Container))
        .first);
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, t.surface);
    expect(decoration.borderRadius, BorderRadius.circular(AppMetrics.radiusMd));
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
