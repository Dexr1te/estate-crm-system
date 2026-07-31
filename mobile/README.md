# Estate CRM — Mobile

Flutter client for the Real Estate CRM. Agents, managers and admins work clients, properties, deals and meetings against the Spring Boot API.

Three locales (en / ru / kk), light and dark, phones from 320 pt to tablets.

---

## Contents

- [Running it](#running-it)
- [Architecture](#architecture)
- [State management](#state-management)
- [Networking and the session](#networking-and-the-session)
- [Design system](#design-system)
- [Responsive rules](#responsive-rules)
- [Localization](#localization)
- [Screens](#screens)
- [Testing](#testing)
- [Traps](#traps)

---

## Running it

```bash
cd mobile
flutter pub get
flutter run
```

| Task | Command |
|---|---|
| Run | `flutter run` |
| Test | `flutter test` |
| Analyze | `dart analyze lib test` |
| Regenerate strings | `flutter gen-l10n` |
| Regenerate models | `dart run build_runner build --delete-conflicting-outputs` |
| Regenerate app icons | `dart run flutter_launcher_icons` |
| Regenerate splash | `dart run flutter_native_splash:create` |
| Build APK | `flutter build apk` |
| Build iOS | `flutter build ios` |

**Use the pinned SDK.** The project needs Flutter 3.41+/Dart 3.11+. An older `flutter` on `PATH` will fail `pub get` on `intl` and, worse, delete the committed `lib/l10n/app_localizations*.dart`. Run through FVM (`fvm flutter …`) or call the pinned binary directly.

---

## Architecture

Feature-first, three layers per feature, no use-case classes — a bloc talks to a repository directly.

```
lib/
├── core/
│   ├── auth/         role helpers on BuildContext
│   ├── bloc/         cross-feature bloc contracts
│   ├── di/           Injector — the composition root
│   ├── locale/       locale bloc + persistence
│   ├── models/       freezed API models, shared enums
│   ├── network/      ApiClient (Dio), error mapping
│   ├── session/      SessionStore — tokens + saved user
│   ├── theme/        colours, tokens, metrics, fonts
│   ├── utils/        router, formatters, contact actions
│   └── widgets/      the design system
├── features/<name>/
│   ├── data/
│   │   ├── datasources/    raw HTTP against ApiClient
│   │   └── repositories/   implements the domain contract
│   ├── domain/repositories/  abstract contract
│   └── presentation/
│       ├── bloc/       events, states, bloc
│       ├── screens/
│       └── widgets/
└── main.dart
```

Features: `auth`, `dashboard`, `clients`, `properties`, `deals`, `meetings`, `admin`, `teams`, `agents`, `profile`.

**Dependency rule.** `presentation → domain ← data`. A bloc depends on the abstract repository, never on a data source or on Dio. That is what lets every screen test run against an in-memory fake.

**Composition root.** [`Injector`](lib/core/di/injector.dart) builds the single `ApiClient` and every repository as static fields. There is no get_it. The repository fields are assignable so tests can swap fakes in — production code never reassigns them.

**Blocs are created once**, in `_MyAppState.initState`, and provided app-wide via `MultiBlocProvider`. They outlive every screen. Two consequences run through the whole app, and both are handled deliberately — see [State management](#state-management).

Two blocs are per-screen instead, created by the console that owns them: `AdminUsersBloc`, `AuditLogBloc`, `TeamsBloc`.

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

`SessionStore` holds the tokens in memory and mirrors them to `SharedPreferences`, alongside a compact encoding of the signed-in user so a cold start knows who it is before the network answers.

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

## Screens

| Route | Screen |
|---|---|
| `/splash` | holds while the saved session is read |
| `/login`, `/accept-invite` | auth |
| `/dashboard` | greeting, next meeting, metrics, pipeline, value by stage, conversion, meeting load, top agents, upcoming list |
| `/clients`, `/clients/new`, `/clients/:id`, `/clients/:id/edit` | |
| `/properties`, `…/new`, `…/:id`, `…/:id/edit` | paged list with server-side filters |
| `/deals`, `…/new`, `…/:id`, `…/:id/edit` | stage pills filter client-side so the counts stay live |
| `/meetings`, `…/new`, `…/:id`, `…/:id/edit` | date-grouped |
| `/admin` | ADMIN only — users, teams, audit log |
| `/team-console` | MANAGER only |
| `/profile` | theme, language, sign out |

**Routing** is go_router with a `ShellRoute` for the bottom nav. Detail and form routes are pushed on the **root** navigator so they cover the nav bar.

`resolveRedirect` in [`core/utils/router.dart`](lib/core/utils/router.dart) is a pure function, deliberately: `GoRouter` resolves nothing until its delegate is attached to a widget tree, so the startup ordering — the part that is easy to get wrong — is otherwise untestable without booting the whole app.

That ordering matters. Reading the saved session is asynchronous, so at startup the app does not yet know whether anyone is signed in. `isSessionResolved` is separate from `isAuthenticated`: treating "don't know" as "signed out" sent every returning user to `/login` and bounced them to the dashboard a frame later.

**Splash** is two layers. `flutter_native_splash` covers the window before Flutter paints — white, matching the artwork's own field, so there is no seam. Android 12+ replaced custom splash layouts with an OS-drawn centred icon on one colour, so a full-bleed composition is not possible there. The Flutter `/splash` route then renders the real artwork with `BoxFit.cover`; `fill` would squash the circles, since the image is 780×1688 and phones are not.

---

## Testing

637 tests. Widget tests run every screen through the acceptance matrix; the rest are behavioural.

```bash
flutter test                          # all
flutter test test/deals_screen_test.dart
dart analyze lib test
```

| File | Covers |
|---|---|
| `responsive_harness.dart` | the matrix, `expectNoOverflow` |
| `fakes.dart` | in-memory repositories |
| `*_screen(s)_test.dart` | per-feature render + matrix |
| `bloc_audit_test.dart` | failed writes keep the list, out-of-order loads, logout clears |
| `refresh_behaviour_test.dart` | a create shows up without a manual refresh; no skeleton on a warm reload |
| `properties_bloc_test.dart` | the paging/reload race |
| `api_client_refresh_test.dart` | the 401 contract, against a fake backend |
| `startup_test.dart` | redirect rules and startup ordering |
| `header_stability_test.dart` | the header does not move when data lands |
| `layout_regression_test.dart` | header action is flush right, `constrain()` top-aligns |
| `dashboard_metrics_test.dart` | win rate, stage values, meeting buckets, agent ranking |
| `design_rules_test.dart` | no hardcoded font family, no emoji in ARBs, ARB key parity |

**Every bug fix here landed with a test that was first confirmed to fail against the pre-fix code.** That is the bar — a regression test that passes both before and after proves nothing.

---

## Traps

Things that cost real debugging time. Each one has a test guarding it.

**`Flexible` defaults to `flex: 1`.** In a `Row` alongside an `Expanded`, it takes half the row and then lays its child out at natural size against the *left* edge of that half — so a button or a switch ends up stranded mid-row instead of flush right. Non-flex children take their natural width and let `Expanded` absorb the rest. This bit the list-header create button and the settings-row toggle identically.

**An empty `Text('')` collapses to zero height.** Reserving a line for a label that has not arrived yet needs a single space, so the line box comes from the same style and text scale the real label will use. A hardcoded pixel height passes at 1.0× and drifts at 1.3×.

**A subtitle that only exists once loaded makes the header jump.** The counters under a list title arrive with the data; without a reserved line they push the search field, the pills and the list down the moment the request finishes. `ScreenTitle(reserveSubtitle: true)`.

**`Center` centres on both axes.** For a page wrapper that is almost never what you want.

**Google Fonts subset metadata is not glyph coverage.** Read the `cmap`.

**bloc's default transformer is concurrent.** Covered above, and it is the single most expensive lesson in this codebase.
