# Estate CRM — Mobile

The Flutter app of Estate CRM, for iOS and Android. Agents, managers and
administrators work their clients, listings, deals, meetings and tasks against
the Spring Boot API in [`backend/`](../backend/README.md).

Three locales (en / ru / kk), light and dark, phones from 320 pt to tablets.

---

## Contents

- [Running it](#running-it)
- [How the app starts](#how-the-app-starts)
- [Architecture](#architecture)
- [Navigation](#navigation)
- [State management](#state-management)
- [Networking and the session](#networking-and-the-session)
- [Offline](#offline)
- [Notifications](#notifications)
- [Remote Config](#remote-config)
- [App lock](#app-lock)
- [Features and where they live](#features-and-where-they-live)
- [Design system](#design-system)
- [Responsive rules](#responsive-rules)
- [Localization](#localization)
- [Testing](#testing)
- [Traps](#traps)

---

## Running it

```bash
cd mobile
fvm flutter pub get
fvm flutter run
```

| Task | Command |
|---|---|
| Run | `fvm flutter run` |
| Run against a local backend | `fvm flutter run --dart-define=API_BASE_URL=http://<lan-ip>:8080/api` |
| Test | `fvm flutter test` |
| Analyze | `fvm dart analyze --fatal-infos lib test` |
| Format check (CI) | `fvm dart format --output=none --set-exit-if-changed lib test` |
| Regenerate strings | `fvm flutter gen-l10n` |
| Regenerate models | `fvm dart run build_runner build --delete-conflicting-outputs` |
| Regenerate app icons | `fvm dart run flutter_launcher_icons` |
| Regenerate splash | `fvm dart run flutter_native_splash:create` |
| Build APK | `fvm flutter build apk` |
| Build for the App Store | `fvm flutter build ipa` |

**Use the pinned SDK.** The project needs Flutter 3.41+/Dart 3.11+. An older `flutter` on `PATH` will fail `pub get` on `intl` and, worse, delete the committed `lib/l10n/app_localizations*.dart`. Run through FVM (`fvm flutter …`) or call `.fvm/flutter_sdk/bin/flutter` directly. CI ([`.github/workflows/mobile-tests.yml`](../.github/workflows/mobile-tests.yml)) runs the format check, the analyzer with `--fatal-infos`, a check that the generated strings match the ARBs, and the tests.

---

## How the app starts

```
main()
 ├─ initializeDateFormatting()          intl's date names for en / ru / kk
 ├─ Firebase.initializeApp()            a failure is logged, never fatal
 ├─ Injector.bootstrap()
 │   ├─ SessionStore.load()             tokens + the saved user, from the Keychain
 │   ├─ RemoteConfigSync.start()        last fetched API address applied before any request
 │   └─ PackageInfo                     the version shown on the profile
 └─ runApp(MyApp)
     └─ _MyAppState.initState
         ├─ the app-wide blocs          auth, theme, locale, dashboard, clients,
         │                              properties, deals, meetings, tasks, stars, reminders
         ├─ PushHandler                 FCM topics, taps on a push
         ├─ app shortcuts, deep links   wait behind the session and the PIN lock
         └─ GoRouter                    /splash until the saved session is known
```

Two splashes cover the start: `flutter_native_splash` paints the window white
before Flutter draws (Android 12+ only allows a centred icon there), then the
`/splash` route shows the full artwork with `BoxFit.cover`.

The router holds everyone on `/splash` until `AuthBloc` has read the saved
session — "don't know yet" is not "signed out". Then `resolveRedirect` in
[`core/utils/router.dart`](lib/core/utils/router.dart) sends the person where
they belong: sign-in, e-mail verification, "create your agency" or "waiting to be
added" for someone without a team, or the dashboard. If the PIN lock is on, the
lock screen covers whatever opens.

---

## Architecture

Feature-first, three layers per feature, no use-case classes — a bloc talks to a
repository directly.

```
lib/
├── main.dart, my_app.dart   start-up, the app-wide blocs, listeners between them
├── core/
│   ├── auth/            role helpers on BuildContext (context.isManager …)
│   ├── bloc/            cross-feature bloc contracts: ActionOutcome, LoadGeneration
│   ├── config/          Remote Config: keys, validation, live apply
│   ├── di/              Injector — the composition root
│   ├── feedback/        haptics
│   ├── forms/           form drafts that survive leaving the screen
│   ├── locale/          locale bloc + persistence
│   ├── map/             map tiles and attribution
│   ├── models/          freezed API models, shared enums
│   ├── navigation/      the active tab, the role's console ("hub"), page transitions
│   ├── network/         ApiClient (Dio), error mapping, JSON checks, offline cache
│   ├── notifications/   local reminders, FCM push gateway + handler
│   ├── quick_add/       the one "+" and everything it can start
│   ├── session/         SessionStore — tokens + saved user
│   ├── shortcuts/       home-screen icon shortcuts
│   ├── theme/           colours, tokens, metrics, fonts
│   ├── utils/           router, formatters, money, clock, contact actions, deep links
│   └── widgets/         the design system
├── features/<name>/
│   ├── data/
│   │   ├── datasources/     raw HTTP against ApiClient
│   │   └── repositories/    implements the domain contract
│   ├── domain/              abstract repository, plain domain types and rules
│   └── presentation/
│       ├── bloc/            events, states, bloc
│       ├── screens/
│       └── widgets/
└── l10n/                ARB files and the generated localizations
```

**Dependency rule.** `presentation → domain ← data`. A bloc depends on the
abstract repository, never on a data source or on Dio. That is what lets every
screen test run against an in-memory fake.

**Composition root.** [`Injector`](lib/core/di/injector.dart) builds the single
`ApiClient` and every repository as static fields. There is no get_it. The
repository fields are assignable so tests can swap fakes in — production code
never reassigns them.

**Everything that touches the phone sits behind a gateway** — `FileGateway`
(pick, save, open a file), `ShareGateway`, `NotificationGateway` (local
notifications), `PushGateway` (FCM), `RemoteConfigSource`, `QuickActions`. Each
has a device implementation and a fake, so no test reaches a plugin.

**Blocs live at two levels.** The core lists — clients, properties, deals,
meetings, tasks, stars, the dashboard — have app-wide blocs created once in
`_MyAppState.initState` and provided through `MultiBlocProvider`; they outlive
every screen, which the next section deals with. Everything scoped to one record
or one screen (a deal's documents, comments, checklist and deposit, the admin
console, team stats, a lease list…) gets a bloc created by the screen that owns
it, so opening another record cannot inherit the previous one's data.

---

## Navigation

go_router, configured in [`core/utils/router.dart`](lib/core/utils/router.dart).

- **Five tabs** — Dashboard, Clients, Properties, Deals, Calendar — in a
  `StatefulShellRoute.indexedStack`, so each tab keeps its scroll position and
  its stack while you are elsewhere. On a wide screen the bar becomes a rail and
  gains a sixth entry, the manager's or admin's console.
- **Records and forms are pushed on the root navigator** (`/clients/:id`,
  `/deals/:id/edit` …) so they cover the tab bar. The list underneath stays
  mounted, which is why a write reloads the list rather than relying on the list
  screen's `initState` (see [State management](#state-management)).
- **One "+"** ([`core/quick_add/`](lib/core/quick_add)) floats over the tabs and
  sits in the record headers. It starts a client, listing, deal, meeting, task or
  a logged contact, pre-linked to the record you are on, and puts the thing you
  picked last first.
- **Ways in from outside** all wait for the session and for the PIN lock:
  `estatecrm://invite` and `estatecrm://reset` links from e-mails
  ([`deep_links.dart`](lib/core/utils/deep_links.dart)), long-press shortcuts on
  the app icon (new client, task, meeting, search), and a tapped push carrying a
  `route` or an https `url`.
- **Redirects** are a pure function, `resolveRedirect`, because `GoRouter`
  resolves nothing until it is attached to a widget tree; as a function the
  start-up ordering is testable on its own.

---

## State management

flutter_bloc. Events in, states out, no `setState` for server data. Screens that own purely local UI state (a filter chip selection, a form step) still use `setState` — that state is not worth an event.

### The state hierarchy

Every list feature has the same shape:

```
XInitial
XLoading
XLoaded(items)
 ├── XActionSuccess(message, items)   implements ActionOutcome
 ├── XActionFailure(message, items)   implements ActionOutcome
 └── XCreated(entity, items)          create only
XError(message)
```

The inheritance is load-bearing:

- **A write's outcome extends `XLoaded`** and carries the list forward. A screen tests `state is XLoaded`, so the list stays on screen while the reload runs. Before this, every delete or status change blanked the list to a skeleton for a beat.
- **`XError` means the *load* failed** — there is nothing to show, so the screen renders a full-page error. A failed *write* is `XActionFailure`, which keeps the data. Emitting `XError` for a rejected status update threw away a perfectly good screen, and since nothing reloads after an error, the list stayed gone until the user hit Retry.
- **`ActionOutcome`** ([`core/bloc/action_outcome.dart`](lib/core/bloc/action_outcome.dart)) is the marker both outcome states implement. Listeners call `showActionOutcome(ctx, state)` once instead of a success branch that silently omits failure. A swallowed failure looks to the user like a silent no-op.

### Out-of-order loads

`bloc`'s default event transformer runs handlers **concurrently**. Two loads triggered close together — a mutation queuing a reload while a pull-to-refresh is in flight, or two quick status changes — resolve in whatever order the network answers, and without a guard the *slower* one wins simply because it landed last.

Every list bloc mixes in [`LoadGeneration`](lib/core/bloc/load_generation.dart): a load takes a ticket before its first `await` and drops its result if a newer load has started since.

`PropertiesBloc` needs it in two places, because it also pages. A load-more that lands after a reload must not append its page to a list that has already been replaced — that is what showed every property twice until the next manual refresh.

### Stale-while-revalidate

`Loading` is only emitted when there is nothing to show:

```dart
if (_current.isEmpty || queryChanged) emit(XLoading());
```

Screens inside the shell route are rebuilt on every tab switch and fire a load in `initState`, so emitting `Loading` unconditionally meant a full-page skeleton on every visit however fresh the data was.

`queryChanged` is not optional. When a *filter* changes, the rows on screen answer the previous query — they are the wrong rows, so the skeleton is honest there.

### Reloading after a write

Create and update queue a reload, the same way delete and status changes do. The forms are pushed on the **root** navigator, so the list screen underneath stays mounted; its `initState` never runs again and nothing else would pick the new row up.

### Session-scoped data

Feature blocs outlive the session, so signing out has to clear them explicitly. `MyApp` listens for the transition out of `AuthAuthenticated` and dispatches `XResetEvent` to every feature bloc. The reset also bumps the load generation, so a response fetched with the old token cannot repopulate the list afterwards.

Without this the next account rendered the previous one's rows on its first frame — `add()` is asynchronous, so the screen builds once before the reload lands.

### Optimistic updates

The detail screens move a status chip immediately so the tap feels instant, and keep the last server-confirmed value. On `XActionFailure` they revert. The message itself comes from the list screen's listener, which stays mounted underneath the route.

---

## Networking and the session

[`ApiClient`](lib/core/network/api_client.dart) owns the Dio instance and every cross-cutting HTTP concern. Feature data sources depend only on `dio`.

**Token refresh** is the part with teeth:

- Refresh runs on a **separate Dio without the auth interceptor**. The interceptor rewrites `Authorization` on every request it sees, so a refresh sent through the main client went out carrying the very access token that had just expired — and its own 401 re-entered the interceptor that issued it, refreshing forever.
- It is **single-flight**. The dashboard fans out three calls at once; without a shared in-flight future each would spend the refresh token separately, and a backend that rotates refresh tokens rejects all but the first — signing the user out mid-session.
- A request is **replayed at most once**, tracked in `RequestOptions.extra`. A server that keeps answering 401 cannot drive a loop.
- A 401 from `/auth/*` is a **credential error**, not an expired session, and never triggers a refresh.
- When the session cannot be recovered, `onSessionExpired` fires exactly once. `MyApp` wires it to a logout. Clearing storage alone left the router believing the user was still signed in, and every screen kept failing with 401s rendered as "Invalid email or password".

**Decoding is a seam, not a cast.** Dio hands back `dynamic`, so every data source used to pour `res.data` straight into `fromJson`; a body that was not the promised shape — a proxy's HTML error page, a `null`, an array with one bad element — died as a bare `TypeError` with no request path in it. [`core/network/json.dart`](lib/core/network/json.dart) checks the shape first and throws `ApiFormatException`, which `ApiFailure` reads as a server error. `strict-casts` in [`analysis_options.yaml`](analysis_options.yaml) is what keeps a new data source from skipping it.

**The base URL is not a constant any more.** `apiBaseUrl` is only the built-in default. The address in use is `ApiEndpoint.baseUrl`, which Remote Config can change while the app runs. `ApiClient.useBaseUrl` moves both Dio clients with it, and `backendPageUrl` reads it too. A build with `--dart-define=API_BASE_URL=…` sets `apiBaseUrlPinned`, and then Remote Config leaves the address alone. See [Remote Config and push](#remote-config-and-push).

`SessionStore` holds the tokens in memory and mirrors them to `SharedPreferences`, alongside a compact encoding of the signed-in user so a cold start knows who it is before the network answers.

---

## Offline

[`OfflineCache`](lib/core/network/offline_cache.dart) and
[`OfflineCacheInterceptor`](lib/core/network/offline_interceptor.dart) give the
app something to show when the signal drops in a lift or a basement.

- **Network first.** A successful `GET` of a main list or record is written to
  disk; the cache answers only when the server cannot be reached (a 502/503/504
  counts — on this host that is the proxy saying the app is asleep).
- **Per account.** Entries are files named by a hash of the request *and* the
  signed-in user and team; the whole cache is wiped when the session ends.
- **Bounded.** Entries older than 14 days are never served; past 20 MB the least
  recently used go first.
- **Honest.** While anything on screen came from the cache, `OfflineBanner` says
  so once, across every screen, with the time of the data and a Retry.
- **Reads only.** A create, edit or delete without a connection fails with its
  own message ("needs a connection"); writes are never queued.

Forms keep a draft ([`core/forms/form_draft.dart`](lib/core/forms/form_draft.dart)):
what you typed into a client, listing, deal, meeting or task form survives
leaving the screen, per account.

---

## Notifications

Three separate channels — none of them depends on another.

| Channel | Where it comes from | Code |
|---|---|---|
| **The bell** — the in-app feed | the backend writes a row when something happens to you (a task assigned, a deal moved, a mention, a lead, a birthday…) | `features/notifications`; `UnreadCountPoller` asks for the unread count every 60 s while the app is in front |
| **Reminders** | the app itself, from the meetings and tasks it has loaded — your own only | [`reminder_plan.dart`](lib/core/notifications/reminder_plan.dart) plans, [`reminder_sync.dart`](lib/core/notifications/reminder_sync.dart) replaces what is scheduled; lead time 15 min / 1 h / 1 day, chosen on the profile, which is also where permission is asked |
| **Push** | announcements sent from the Firebase Console to topics | [`push_gateway.dart`](lib/core/notifications/push_gateway.dart), [`push_handler.dart`](lib/core/notifications/push_handler.dart) |

Reminders are re-planned whenever the meetings or tasks lists load and whenever
the lead time changes, and everything scheduled is cancelled on sign-out or when
the person's agency changes. At most 60 are pending, soonest first.

**Push** in detail:

| Piece | Does |
|---|---|
| `PushGateway` / `FirebasePushGateway` | permission, token, topic (un)subscribe, the three message streams; creates the Android **Activity** channel |
| `PushHandler` | keeps the topics `all`, `lang_<code>`, `role_<role>` in step with the session and the language; asks for permission once somebody signs in and a push could actually arrive; opens a tapped push's `route` or `url` once the session is known and the PIN lock is open |
| `PushLanguage` | sits under `MaterialApp` and tells the handler the language actually in use |
| `openPushRoute` | switches to a shell tab, pushes anything else |
| `showPushBanner` | what a push looks like while the app is on screen: a snack bar with **Open** |

**iOS gets no pushes yet**: the free signing team cannot carry the APNs
entitlement, so there is no APNs token — and the app does not ask an iPhone for
permission until there is one. No code changes when that moves;
[`docs/firebase.md`](../docs/firebase.md#ios-push-once-there-is-a-paid-apple-team)
lists the steps.

---

## Remote Config

[`core/config/remote_config.dart`](lib/core/config/remote_config.dart) reads
`api_base_url`, `map_tile_url` and `map_attribution` from Firebase.
`RemoteConfigSync` starts in `Injector.bootstrap()`: it applies the values
fetched last time before the first request, fetches in the background, and
applies realtime updates while the app is open. `RemoteSettings.from` validates
every value (https only, tile URLs need `{z}`/`{x}`/`{y}`) and falls back to the
built-in default, so a bad publish cannot break the app. A build with
`--dart-define=API_BASE_URL=…` pins the address and ignores Remote Config for it.
Every key and how to publish it: [`docs/firebase.md`](../docs/firebase.md).

---

## App lock

An optional PIN ([`features/app_lock`](lib/features/app_lock)), set on the
profile under Security.

- The PIN is never stored: a salted PBKDF2 (HMAC-SHA256) hash is, in the
  Keychain / Keystore, tied to the signed-in user — signing out or switching
  accounts takes it away.
- `AppLockController` locks on a cold start that restores a session and on
  coming back after the chosen idle time; the app is covered in the app switcher.
- Wrong guesses are counted with the hash, so killing the app does not reset
  them; after ten the lock screen offers to sign out instead.
- `AppLockGate` sits over the whole app. Deep links, shortcuts and tapped pushes
  wait behind it through `LaunchGate`.

---

## Features and where they live

Each is a folder in `lib/features/`, built the same way. "Where" is how a user
reaches it.

**The core**

| Feature | What it is | Where |
|---|---|---|
| `auth` | sign-in, sign-up with e-mail confirmation, invites, password reset, "Try the demo", the no-agency onboarding screens | first screens |
| `dashboard` | next meeting, today's tasks, follow-up cards, monthly target, metrics, pipeline, deals needing attention, leaderboard, upcoming meetings | tab 1 |
| `clients` | buyers and sellers, wish lists, tags, lead source, contact history, duplicates, matching listings, going-cold and client-dates lists | tab 2 |
| `properties` | listings, photos and cover, price history and price check, seller's agreement, map, public link, brochure (PDF), seller report | tab 3 |
| `deals` | pipeline as list or board, stages, lost reason, documents, discussion with @mentions | tab 4 |
| `meetings`, `calendar` | meetings and viewings, viewing outcomes, the calendar with meetings and tasks by day | tab 5 |
| `tasks` | follow-ups with a due time, one-off or recurring, on their own or on a client/deal | dashboard, records, "+" |
| `search` | across clients, listings and deals | dashboard header, icon shortcut |
| `notifications` | the bell's feed | dashboard header |
| `profile` | name, theme, language, reminders, PIN lock, legal pages, sign out, delete account | avatar on the dashboard |
| `app_lock` | the optional PIN, see [App lock](#app-lock) | profile → Security |

**On a record**

| Feature | What it is |
|---|---|
| `checklist` | a deal's checklist per stage from the agency's template; required items warn before the deal moves on |
| `deposits` | a buyer's deposit on a deal, held until a date, then applied, returned or kept |
| `leases` | a rent deal's lease, renewals, leases ending |
| `commission_split` | how a deal's commission is shared between agents and partners |
| `documents` | files attached to a deal (≤ 20 MB) |
| `offers` | offers and counter-offers on a listing |
| `open_houses` | open house events on a listing, with visitors who become buyers |
| `keys` | who holds a listing's keys, handed over and returned |
| `expenses` | money spent on a listing |
| `mortgage` | a mortgage calculator for a listing's price |
| `change_log` | who changed what on a record, and the agency-wide feed for managers |
| `stars` | starred clients, listings and deals, one list away from the dashboard |
| `compare` | two to four listings side by side, shareable |
| `route` | the day's viewings as a route in a maps app |
| `partners` | brokers, notaries and others who send clients, and fees owed |

**Running the agency** (manager's console, admin console)

| Feature | What it is |
|---|---|
| `teams`, `agents` | the agency, its members, adding people by e-mail, join requests, handing work between agents |
| `goals` | monthly targets per agent and for the agency |
| `leaderboard`, `analytics` | agents ranked; funnel and lead-source analytics |
| `payouts` | commission shares owed and paid |
| `message_templates` | the agency's message templates, filled in for a client and sent from the phone |
| `imports`, `exports` | CSV in (clients, listings, with column mapping) and out |
| `time_off` | absences, who covers whom, who is out today |
| `admin` | across agencies: people, roles, scopes, teams, the audit log |

---

## Design system

Everything visual comes from tokens. Screens never branch on `Theme.of(context).brightness` — a light screen and a dark screen are the same widget tree.

```dart
final t = context.tokens;
Container(color: t.surface, ...)
```

**[`AppTokens`](lib/core/theme/app_tokens.dart)** resolves colour by brightness: surfaces, text, `primary`/`onPrimary` (navy in light, gold in dark), hero surfaces, danger fills, scrims, chart ink.

`statusText(hue)` exists because the raw status hues are tuned as *fills*. Amber `#F59E0B` on the light background is about 2:1, unreadable at 10–11 px. `statusText` returns the same hue at a contrast that works in both themes.

**[`AppMetrics`](lib/core/theme/app_metrics.dart)** holds layout constants. Only *spacing* scales with width, and only in two steps. Radii (12 / 16 / 18 / 999), border widths, icon boxes and the 44 pt minimum hit target are absolute — never scaled with MediaQuery.

`AppMetrics.constrain()` caps content width on tablets. It aligns to **top**-centre: plain `Center` also centres vertically, which floated short detail and form screens in the middle of the viewport. Auth screens centre themselves deliberately.

**Typeface — Commissioner.** The design handoff specified Sora, which ships latin + latin-ext only, so every Russian and Kazakh string would have fallen back to the platform font. Onest and Manrope claim `cyrillic-ext` in their metadata but are actually missing the Kazakh letters — verified by reading the real `cmap`, not the subset metadata. Commissioner covers Ә Ғ Қ Ң Ө Ұ Ү Һ І plus ₽ and ₸.

Four static instances are cut from the upstream variable font so `fontWeight` maps to a real cut rather than a synthetic bold. The family is referenced through `AppFonts.sans` — never hardcode it; a test enforces that.

**Components** ([`core/widgets/`](lib/core/widgets/), all re-exported from `widgets.dart`):

| Widget | Notes |
|---|---|
| `AppCard`, `AppHeroCard` | surface + 1 px border + radius 16, **no shadow** |
| `AppFilledButton`, `AppGhostButton`, `AppDangerButton` | 52 pt full-width, 40 pt inline |
| `AppHeaderAction` | the inline "+ Client" in a list header, not a FAB |
| `AppIconTile` | 34 pt visual box, 44 pt tap target |
| `ScreenTitle`, `SectionHeader`, `EyebrowLabel`, `InfoRow`, `DetailGrid` | typography |
| `FilterPill`, `FilterPillRow`, `SegmentedTabs` | |
| `AppTextField` | page and card skins |
| `AppBottomNav` | 6 items, fixed 18 px icon box |
| `DetailScaffold`, `DetailAppBar` | detail and form chrome |
| `MetricsCard` | 2×2 grid with 1 px internal dividers, one card not four tiles |
| `EmptyState`, `ErrorWidget2`, `ShimmerGroup`, `ShimmerBox`, `ShimmerList` | |
| `showConfirmDialog`, `AppBottomSheet` | destructive confirm, radius 24 sheet |

**Colour signals status only.** Navigation and structure stay navy/neutral. No pastel-tinted feature tiles, no emoji in chips or labels, no raw enum text on screen, and 30 px is the largest type in the app (the hero price).

---

## Responsive rules

Every screen is verified against a matrix, and the acceptance criterion is **zero overflow**:

| Axis | Values |
|---|---|
| Size | 320×568, 375×667, 390×844, 430×932, 768×1024 |
| Brightness | light, dark |
| Text scale | 1.0, 1.3 |
| Locale | en, ru, kk |

Text scale is clamped to 1.3 in `MyApp` — the layouts are designed to stay readable and overflow-free up to that, and beyond it they are not.

Two breakpoints matter: below 340 pt the 2-column detail grids collapse to one; at 600 pt content stops stretching and is capped at 560 pt.

The harness is [`test/responsive_harness.dart`](test/responsive_harness.dart) — `forEachAcceptanceCase(...)` and `expectNoOverflow(...)`.

---

## Localization

`gen-l10n` with ARB files in [`lib/l10n/`](lib/l10n/) — `app_en.arb`, `app_ru.arb`, `app_kk.arb`. Generated Dart is committed.

- Keys are **feature-prefixed and alphabetical**: `clientsAddShort`, `dashboardConversion`, `coreStatusWon`.
- The ARBs carry **no `@key` metadata**. ICU plurals still work without it.
- `gen-l10n` orders generated method parameters **alphabetically**, not by appearance — `clientsDeleteCascade(num count, Object name)`, whatever order the placeholders appear in the string.
- Russian and Kazakh plurals use the real categories (`=1 / few / other`), not a two-branch English shape.
- Some labels have a short variant (`clientsAddShort`) for headers, because the full Russian or Kazakh string overflows a 320 pt header at 1.3×.

A test asserts the three files have identical key sets, and that no ARB contains emoji.

---

## Testing

```bash
fvm flutter test                              # all
fvm flutter test test/deals_screens_test.dart # one file
fvm dart analyze --fatal-infos lib test
```

Mostly widget tests: every screen is pumped against in-memory fakes and run
through the acceptance matrix; the rest are behavioural tests of blocs, the
network layer and pure rules.

| File | Covers |
|---|---|
| `responsive_harness.dart` | the matrix, `forEachAcceptanceCase`, `expectNoOverflow` |
| `fakes.dart`, `*_fakes.dart`, `*_fixtures.dart` | in-memory repositories and sample records |
| `*_screen(s)_test.dart`, `*_layout_test.dart` | per-feature behaviour + the matrix |
| `bloc_audit_test.dart` | failed writes keep the list, out-of-order loads, logout clears |
| `refresh_behaviour_test.dart` | a create shows up without a manual refresh; no skeleton on a warm reload |
| `api_client_refresh_test.dart`, `api_client_cold_start_test.dart` | the 401 contract and the sleeping host, against a fake backend |
| `offline_*_test.dart` | the offline cache, banner and screens |
| `remote_config_test.dart`, `push_handler_test.dart` | Firebase behaviour without Firebase |
| `startup_test.dart`, `deep_links_test.dart` | redirect rules, start-up ordering, links |
| `design_rules_test.dart` | no hardcoded font family, no emoji in ARBs, ARB key parity, no spinner where a skeleton belongs |

**Every bug fix lands with a test that was first confirmed to fail against the pre-fix code.** That is the bar — a regression test that passes both before and after proves nothing.

---

## Traps

Things that cost real debugging time. Each one has a test guarding it.

**`Flexible` defaults to `flex: 1`.** In a `Row` alongside an `Expanded`, it takes half the row and then lays its child out at natural size against the *left* edge of that half — so a button or a switch ends up stranded mid-row instead of flush right. Non-flex children take their natural width and let `Expanded` absorb the rest. This bit the list-header create button and the settings-row toggle identically.

**An empty `Text('')` collapses to zero height.** Reserving a line for a label that has not arrived yet needs a single space, so the line box comes from the same style and text scale the real label will use. A hardcoded pixel height passes at 1.0× and drifts at 1.3×.

**A subtitle that only exists once loaded makes the header jump.** The counters under a list title arrive with the data; without a reserved line they push the search field, the pills and the list down the moment the request finishes. `ScreenTitle(reserveSubtitle: true)`.

**`Center` centres on both axes.** For a page wrapper that is almost never what you want.

**Google Fonts subset metadata is not glyph coverage.** Read the `cmap`.

**bloc's default transformer is concurrent.** Covered above, and it is the single most expensive lesson in this codebase.

**Awaiting `endOfFrame` in a widget test hangs.** `openPushRoute` and `openAppShortcut` wait for the next frame before navigating, and a test only produces frames when it pumps. Start the call, `pumpAndSettle`, then await it.

**A free Apple team has no APNs token.** On iOS `getToken()` fails and every topic call throws until the app is signed by a paid team with the Push Notifications capability. `FirebasePushGateway.token()` checks for the APNs token first, and `PushHandler` logs and carries on.

**Android 11+ hides other apps from `open_file`.** Opening a downloaded document asks `queryIntentActivities` which app can read it, and without a `VIEW` intent query in the manifest that call sees nothing — every document came back "no app can open it".
