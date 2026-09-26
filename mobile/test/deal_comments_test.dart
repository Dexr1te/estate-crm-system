import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_card.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_comment_row.dart';
import 'package:real_estate_crm/features/deals/presentation/widgets/deal_discussion_card.dart';
import 'package:real_estate_crm/features/notifications/presentation/widgets/notification_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

import 'fakes.dart';
import 'responsive_harness.dart';

/// The discussion on a deal: who said what, in order, with the people they
/// brought in picked out — and a place to add to it that never loses a
/// message. What matters here is that a comment shows up the moment it is
/// sent and comes back into the composer if it did not go through, that only
/// the author edits and only the author or a manager deletes, and that "@"
/// brings in a colleague by id rather than by a name typed by hand.

final _now = DateTime(2026, 9, 27, 15, 30);

const _agent = AuthResponse(
    userId: 5, fullName: 'Aigul Bekova', role: Role.AGENT, teamId: 1);
const _manager = AuthResponse(
    userId: 7, fullName: 'Asel Nurlanovna', role: Role.MANAGER, teamId: 1);

final _thread = [
  DealComment(
    id: 11,
    dealId: 3,
    body: 'Owner agreed to 5% off if we sign before the end of the month.',
    authorId: 5,
    authorName: 'Aigul Bekova',
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  DealComment(
    id: 12,
    dealId: 3,
    body: '@Timur Aliev can you cover the Saturday viewing? The buyer is '
        'bringing her husband and the mortgage broker.',
    authorId: 7,
    authorName: 'Asel Nurlanovna',
    createdAt: _now.subtract(const Duration(hours: 1)),
    editedAt: _now.subtract(const Duration(minutes: 30)),
    mentions: const [CommentMention(id: 9, fullName: 'Timur Aliev')],
  ),
];

const _colleagues = [
  AgentOption(id: 5, fullName: 'Aigul Bekova'),
  AgentOption(id: 7, fullName: 'Asel Nurlanovna'),
  AgentOption(id: 9, fullName: 'Timur Aliev'),
];

late FakeDealCommentsRepository _repo;

Widget _card({AuthResponse user = _agent}) => BlocProvider(
      create: (_) =>
          AuthBloc(FakeAuthRepository(user: user))..add(AuthCheckEvent()),
      child: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: DealDiscussionCard(dealId: 3),
        ),
      ),
    );

Future<void> _pump(WidgetTester tester,
    {AuthResponse user = _agent, Size size = const Size(390, 844)}) async {
  await expectNoOverflow(tester, _card(user: user),
      size: size, brightness: Brightness.light, textScale: 1.0);
  await tester.pumpAndSettle();
}

Finder get _field => find.byKey(const ValueKey('deal-comment-field'));
Finder get _send => find.byKey(const ValueKey('deal-comment-send'));

IconButton _sendButton(WidgetTester tester) => tester.widget<IconButton>(_send);

DioException _offline() => DioException(
    requestOptions: RequestOptions(path: '/deals/3/comments', method: 'POST'),
    type: DioExceptionType.connectionError);

void main() {
  setUp(() {
    AppClock.freeze(_now);
    _repo = FakeDealCommentsRepository(
        comments: List.of(_thread), mentionable: _colleagues);
    Injector.dealCommentsRepository = _repo;
  });
  tearDown(() {
    AppClock.reset();
    Injector.dealCommentsRepository = FakeDealCommentsRepository();
  });

  group('reading', () {
    testWidgets('comments read oldest first, with who, when and "edited"',
        (tester) async {
      await _pump(tester);
      expect(find.text('DISCUSSION'), findsOneWidget);
      final first = tester.getTopLeft(find.textContaining('Owner agreed'));
      final second = tester.getTopLeft(
          find.textContaining('Saturday viewing', findRichText: true));
      expect(first.dy, lessThan(second.dy));
      expect(find.text('Asel Nurlanovna'), findsOneWidget);
      expect(find.textContaining('edited'), findsOneWidget);
    });

    testWidgets('a mention is picked out of the text', (tester) async {
      await _pump(tester);
      final spans = <TextSpan>[];
      for (final r in tester.widgetList<RichText>(find.byType(RichText))) {
        r.text.visitChildren((s) {
          if (s is TextSpan) spans.add(s);
          return true;
        });
      }
      final mention = spans.firstWhere((s) => s.text == '@Timur Aliev');
      expect(mention.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('an empty discussion invites the first comment',
        (tester) async {
      _repo.comments = [];
      await _pump(tester);
      expect(find.text('No comments yet'), findsOneWidget);
      expect(_field, findsOneWidget);
    });

    testWidgets('a failed load offers a retry', (tester) async {
      _repo.readError = _offline();
      await _pump(tester);
      expect(find.text("Couldn't load the discussion"), findsOneWidget);
      _repo.readError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Owner agreed'), findsOneWidget);
    });

    testWidgets('"show earlier" asks for what came before the oldest shown',
        (tester) async {
      _repo.hasEarlier = true;
      await _pump(tester);
      await tester.tap(find.text('Show earlier'));
      await tester.pumpAndSettle();
      expect(_repo.requestedBefore.last, 11);
      expect(find.text('Show earlier'), findsNothing);
    });
  });

  group('writing', () {
    testWidgets('send is off while the composer is empty', (tester) async {
      await _pump(tester);
      expect(_sendButton(tester).onPressed, isNull);
      await tester.enterText(_field, '   ');
      await tester.pump();
      expect(_sendButton(tester).onPressed, isNull);
      await tester.enterText(_field, 'Booked the notary');
      await tester.pump();
      expect(_sendButton(tester).onPressed, isNotNull);
    });

    testWidgets('a comment shows at the bottom the moment it is sent',
        (tester) async {
      _repo.gate = Completer<void>();
      await _pump(tester);
      await tester.enterText(_field, 'Booked the notary for Monday');
      await tester.pump();
      await tester.tap(_send);
      await tester.pump();

      expect(find.text('Booked the notary for Monday', findRichText: true),
          findsOneWidget);
      expect(find.textContaining('Sending'), findsOneWidget);
      expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          isEmpty);
      expect(_sendButton(tester).onPressed, isNull,
          reason: 'one comment in flight at a time');

      final sent = tester.getTopLeft(
          find.text('Booked the notary for Monday', findRichText: true));
      final earlier = tester.getTopLeft(find.textContaining('Owner agreed'));
      expect(sent.dy, greaterThan(earlier.dy));

      _repo.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Sending'), findsNothing);
      expect(_repo.sent.single.body, 'Booked the notary for Monday');
      expect(find.text('Booked the notary for Monday', findRichText: true),
          findsOneWidget);
    });

    testWidgets(
        'a comment that did not go through leaves, and its text comes back',
        (tester) async {
      _repo.gate = Completer<void>();
      _repo.writeError = _offline();
      await _pump(tester);
      await tester.enterText(_field, 'Booked the notary');
      await tester.pump();
      await tester.tap(_send);
      await tester.pump();
      expect(
          find.text('Booked the notary', findRichText: true), findsOneWidget);

      _repo.gate!.complete();
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(DealCommentRow),
              matching: find.text('Booked the notary', findRichText: true)),
          findsNothing);
      expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          'Booked the notary');
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('rights', () {
    testWidgets('the author edits and deletes their own comment',
        (tester) async {
      await _pump(tester);
      await tester.longPress(find.textContaining('Owner agreed'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('comment-action-edit')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('comment-action-delete')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('comment-action-edit')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('comment-edit-field')),
          'Owner agreed to 4%');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('comment-edit-save')));
      await tester.pumpAndSettle();
      expect(_repo.updated.single.id, 11);
      expect(_repo.updated.single.body, 'Owner agreed to 4%');
      expect(
          find.text('Owner agreed to 4%', findRichText: true), findsOneWidget);
      expect(find.text('Comment updated'), findsOneWidget);

      await tester
          .longPress(find.text('Owner agreed to 4%', findRichText: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('comment-action-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(_repo.deleted, [11]);
      expect(find.text('Owner agreed to 4%', findRichText: true), findsNothing);
    });

    testWidgets("an agent is offered nothing on a colleague's comment",
        (tester) async {
      await _pump(tester);
      await tester.longPress(
          find.textContaining('Saturday viewing', findRichText: true));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('comment-action-edit')), findsNothing);
      expect(find.byKey(const ValueKey('comment-action-delete')), findsNothing);
    });

    testWidgets("a manager may delete a colleague's comment but not edit it",
        (tester) async {
      await _pump(tester, user: _manager);
      await tester.longPress(find.textContaining('Owner agreed'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('comment-action-edit')), findsNothing);
      expect(
          find.byKey(const ValueKey('comment-action-delete')), findsOneWidget);
    });

    testWidgets('a failed delete puts the comment back where it was',
        (tester) async {
      _repo.writeError = _offline();
      await _pump(tester);
      await tester.longPress(find.textContaining('Owner agreed'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('comment-action-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Owner agreed'), findsOneWidget);
      final first = tester.getTopLeft(find.textContaining('Owner agreed'));
      final second = tester.getTopLeft(
          find.textContaining('Saturday viewing', findRichText: true));
      expect(first.dy, lessThan(second.dy));
    });
  });

  group('mentions', () {
    testWidgets('typing @ offers colleagues, inserts the name and sends the id',
        (tester) async {
      await _pump(tester);
      await tester.enterText(_field, 'Can ');
      await tester.pump();
      await tester.enterText(_field, 'Can @');
      await tester.pumpAndSettle();

      expect(find.text('Mention a colleague'), findsOneWidget);
      expect(find.byKey(const ValueKey('mention-option-5')), findsNothing,
          reason: 'nobody mentions themselves');
      await tester.tap(find.byKey(const ValueKey('mention-option-9')));
      await tester.pumpAndSettle();

      final text = tester
          .widget<EditableText>(find.byType(EditableText))
          .controller
          .text;
      expect(text, 'Can @Timur Aliev ');
      await tester.enterText(_field, '${text}cover Saturday?');
      await tester.pump();
      await tester.tap(_send);
      await tester.pumpAndSettle();

      expect(_repo.sent.single.body, 'Can @Timur Aliev cover Saturday?');
      expect(_repo.sent.single.mentionedUserIds, [9]);
    });

    testWidgets('a mention deleted from the draft is not sent', (tester) async {
      await _pump(tester);
      await tester.enterText(_field, '@');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('mention-option-9')));
      await tester.pumpAndSettle();
      await tester.enterText(_field, 'Never mind');
      await tester.pump();
      await tester.tap(_send);
      await tester.pumpAndSettle();
      expect(_repo.sent.single.mentionedUserIds, isEmpty);
    });

    testWidgets(
        'a mention the server refuses is explained in the reader\'s words',
        (tester) async {
      _repo.writeError = DioException(
        requestOptions:
            RequestOptions(path: '/deals/3/comments', method: 'POST'),
        response: Response(
          requestOptions: RequestOptions(path: '/deals/3/comments'),
          statusCode: 400,
          data: const {
            'code': 'MENTION_NOT_ALLOWED',
            'message': 'Only colleagues who can see this deal can be mentioned',
          },
        ),
        type: DioExceptionType.badResponse,
      );
      await _pump(tester);
      await tester.enterText(_field, 'Hello');
      await tester.pump();
      await tester.tap(_send);
      await tester.pumpAndSettle();
      expect(
          find.text('Only colleagues who can see this deal can be mentioned'),
          findsOneWidget);
    });
  });

  group('deal cards', () {
    DealResponse deal(int comments) => DealResponse(
          id: 3,
          title: 'Dostyk 5, flat 12',
          status: DealStatus.NEGOTIATION,
          clientId: 1,
          clientName: 'Irina Sokolova',
          agentId: 5,
          agentName: 'Aigul Bekova',
          dealPrice: 42000000,
          commentCount: comments,
        );

    Widget list(DealResponse d) => Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: DealCard(deal: d, onTap: () {})));

    testWidgets('a card shows how much has been said, once anything has',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await expectNoOverflow(tester, list(deal(3)),
          size: const Size(320, 568),
          brightness: Brightness.light,
          textScale: 1.5);
      expect(find.byKey(const ValueKey('deal-comment-count')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('3 comments')), findsOneWidget);
      semantics.dispose();

      await expectNoOverflow(tester, list(deal(0)),
          size: const Size(320, 568),
          brightness: Brightness.light,
          textScale: 1.0);
      expect(find.byKey(const ValueKey('deal-comment-count')), findsNothing);
    });

    test('the count comes from the deal list', () {
      final parsed = DealResponse.fromJson(const {
        'id': 3,
        'title': 'Dostyk',
        'clientId': 1,
        'agentId': 5,
        'commentCount': 4,
      });
      expect(parsed.commentCount, 4);
      expect(
          DealResponse.fromJson(const {
            'id': 3,
            'title': 'Dostyk',
            'clientId': 1,
            'agentId': 5,
          }).commentCount,
          0);
    });
  });

  group('notifications', () {
    AppNotification n(NotificationType type) => AppNotification(
          id: 1,
          type: type,
          targetId: 3,
          params: const {
            'dealTitle': 'Dostyk flat',
            'authorName': 'Asel',
            'snippet': '@Timur can you cover Saturday?',
          },
          createdAt: _now,
        );

    test('a mention and a comment read in each language', () async {
      final expected = {
        'en': [
          'Asel mentioned you in Dostyk flat',
          'Asel commented on Dostyk flat'
        ],
        'ru': [
          'Asel упоминает вас в сделке Dostyk flat',
          'Asel оставляет комментарий к сделке Dostyk flat'
        ],
        'kk': [
          'Asel сізді Dostyk flat мәмілесінде атап өтті',
          'Asel Dostyk flat мәмілесіне пікір қалдырды'
        ],
      };
      for (final locale in kAcceptanceLocales) {
        final l10n = await AppLocalizations.delegate.load(locale);
        final mention = notificationCopy(l10n, n(NotificationType.dealMention));
        final comment = notificationCopy(l10n, n(NotificationType.dealComment));
        expect(mention.title, expected[locale.languageCode]![0]);
        expect(comment.title, expected[locale.languageCode]![1]);
        expect(mention.detail, '@Timur can you cover Saturday?');
      }
    });

    test('both open the deal at its discussion', () {
      for (final type in [
        NotificationType.dealMention,
        NotificationType.dealComment
      ]) {
        expect(
            notificationTarget(n(type))?.location, '/deals/3?focus=discussion');
      }
    });

    test('the new types are read off the wire', () {
      final parsed = AppNotification.fromJson({
        'id': 1,
        'type': 'DEAL_MENTION',
        'createdAt': _now.toIso8601String(),
      });
      expect(parsed.type, NotificationType.dealMention);
    });
  });

  group('fits every screen', () {
    final long = DealComment(
      id: 13,
      dealId: 3,
      body: '@Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky ${'the buyer '
          'wants the paperwork before Friday and a second viewing with the '
          'mortgage broker, please call the owner. ' * 6}',
      authorId: 9,
      authorName: 'Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky',
      createdAt: _now.subtract(const Duration(days: 40)),
      editedAt: _now.subtract(const Duration(days: 39)),
      mentions: const [
        CommentMention(
            id: 4,
            fullName: 'Aleksandr Konstantinovich Vishnevsky-Rozhdestvensky')
      ],
    );

    forEachAcceptanceCase('discussion card',
        (tester, size, brightness, scale) async {
      _repo.comments = [..._thread, long];
      _repo.hasEarlier = true;
      await expectNoOverflow(tester, _card(),
          size: size, brightness: brightness, textScale: scale);
      await tester.pumpAndSettle();
      await tester.enterText(_field, 'A long draft ' * 20);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    for (final locale in kAcceptanceLocales) {
      testWidgets('discussion card renders in ${locale.languageCode}',
          (tester) async {
        for (final comments in [
          [..._thread, long],
          <DealComment>[]
        ]) {
          _repo.comments = comments;
          await expectNoOverflow(tester, _card(),
              size: const Size(320, 568),
              brightness: Brightness.dark,
              textScale: 1.5,
              locale: locale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        _repo.readError = _offline();
        await expectNoOverflow(tester, _card(),
            size: const Size(320, 568),
            brightness: Brightness.light,
            textScale: 1.5,
            locale: locale);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
