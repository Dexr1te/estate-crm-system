# Estate CRM

A CRM for real-estate agencies. An agent keeps their buyers and sellers, the flats
on the books, the deals between them and the viewings in the calendar — in one
place, on the phone, in the field. A manager runs the agency on top of that, and
an administrator runs the platform.

The repository holds the whole system: a Spring Boot API, a Flutter app for iOS
and Android, and the web clients. The app is the product being shipped; see
[Module status](#module-status) before you touch the web ones.

---

## Contents

- [What it does](#what-it-does)
- [Architecture](#architecture)
- [Repository layout](#repository-layout)
- [How the main flows work](#how-the-main-flows-work)
- [The domain](#the-domain)
- [Who sees what](#who-sees-what)
- [Module status](#module-status)
- [Running it](#running-it)
- [The API at a glance](#the-api-at-a-glance)
- [Configuration](#configuration)
- [Firebase](#firebase)
- [Where attachments live](#where-attachments-live)
- [Testing](#testing)
- [Deployment](#deployment)
- [Further reading](#further-reading)
- [Team](#team)
- [License](#license)

---

## What it does

**Clients.** Buyers and sellers, with the phone number an agent actually rings.
A buyer also carries a wish list — city, type, budget from and to, minimum rooms
and area — which is what makes matching possible. Clients carry tags, a lead
source, important dates (birthdays, lease ends), a history of contacts, and the
list flags the ones who are going cold.

**Listings.** Flats, houses, commercial space and land, with price, area, rooms,
floor, a pin on the map and photographs. A listing remembers every change of its
price, records the seller's agreement (exclusive or open, with its last day),
who holds its keys, offers made on it, open houses, expenses, and can be shared
with a client as a public web page with an "I'm interested" form.

**Matching.** A buyer's card lists the flats that answer what they asked for; a
listing's card lists the buyers it answers. A flat somebody has already turned
down after a viewing stops being offered to them.

**Deals.** Lead → Negotiation → Closed won / Closed lost, on a list or a board,
with documents, a checklist, comments with @mentions, the deposit, the
commission and how it is split between agents, and — for rentals — the lease.

**Meetings, viewings and tasks.** A meeting can name the flat being shown, and
the verdict after the showing is recorded. Tasks are follow-ups with a due time,
one-off or recurring. The phone reminds whoever has to do them.

**Dashboard.** The next meeting, today's tasks, what needs attention (stale
deals, clients going cold, agreements, deposits and leases about to end), the
month's target and the pipeline.

**Running the agency.** Managers add agents, set monthly targets, see the
leaderboard and analytics, hand work between agents, keep the agency's message
templates, deal checklist, partners and payouts. An administrator works across
agencies from a console: people, roles, teams, audit log.

**Around the edges.** Global search, a calendar, a route for the day's viewings,
comparison of listings, a mortgage calculator, CSV import and export, starred
records, a PIN lock, an offline read cache, three languages (en / ru / kk), light
and dark themes.

---

## Architecture

```text
┌──────────────────────────┐        ┌───────────────────────────────┐
│  Flutter app (mobile/)   │        │  Firebase                      │
│  iOS · Android           │◄──────►│  · Remote Config — API address │
│                          │        │  · Cloud Messaging — push      │
│  bloc ─► repository ─►   │        │  · Auth — e-mail verification  │
│  data source ─► Dio      │        └──────────────▲────────────────┘
└────────────┬─────────────┘                       │ Admin SDK
             │ HTTPS, JSON, Bearer JWT             │ (sign-up only)
             ▼                                     │
┌──────────────────────────────────────────────────┴─────────────────┐
│  Spring Boot API (backend/)  — /api                                 │
│  JWT filter ─► controller ─► service (ScopeService) ─► repository  │
│  public HTML: /privacy /support /invite /reset /l/{token}           │
│  scheduled jobs: client dates, leases ending, demo clean-up         │
└───────┬──────────────────────────┬──────────────────────┬───────────┘
        ▼                          ▼                      ▼
   PostgreSQL               File storage              Mail
   (Flyway schema)     database │ S3 │ filesystem   SMTP │ Brevo API
```

**One API, many clients.** The backend is the only place business rules live.
The app holds no rules a server would have to trust: it renders what the API
returns and sends what the user did. The web clients talk to the same API.

**Stateless authentication.** Signing in returns a short-lived access token and
a longer refresh token (JWT). Every request carries the access token; when it
expires the app refreshes it once, transparently, and replays the request.

**The tenant is the agency.** One deployment serves many agencies. Every
business row belongs to a team, and every query goes through the backend's
`ScopeService`, which also applies the person's data scope inside the agency.
See [Who sees what](#who-sees-what).

**The app finds the API at run time.** The address comes from Firebase Remote
Config with a built-in fallback, so the backend can move host without an app
release.

How each side is built inside: [`mobile/README.md`](mobile/README.md#architecture)
and [`backend/README.md`](backend/README.md#architecture).

---

## Repository layout

```text
.
├── backend/         Spring Boot API — Java 17, PostgreSQL, Flyway, JWT
├── mobile/          Flutter app — iOS and Android, the product
├── frontend/        React + Vite web client (behind, see Module status)
├── frontend-next/   Next.js web client, early foundation work
├── docs/            Firebase, App Store submission, invite links, design spec
├── .github/         CI workflows
├── AGENTS.md        per-module commands and conventions for contributors
└── README.md        this file
```

---

## How the main flows work

### Signing in and staying signed in

1. `POST /auth/login` returns an access token (24 h), a refresh token (7 days)
   and the user. The app keeps them in `SessionStore`, so a cold start knows who
   is signed in before the network answers.
2. A `401` on any call makes the app's `ApiClient` refresh the token once — a
   single request shared by everything waiting — and replay the original call.
   If the refresh fails, the session ends and the app returns to sign-in.
3. An optional PIN lock (stored as a PBKDF2 hash on the phone) covers the app on
   a cold start and after it has been in the background for a while.

### Getting into an agency

- **Sign-up**: a person chooses a role and confirms their e-mail through a link
  Firebase sends. A manager then creates an agency. An agent waits on a screen
  until a manager adds them.
- **Adding people**: a manager types an agent's e-mail. An existing account gets
  a join request to accept in the app; an unknown address gets an invite e-mail
  whose link opens the app.
- **Try the demo**: a button on the sign-in screen creates a throwaway agency
  with sample records, deleted after 24 hours.

Until someone is in an agency, the API answers `403 TEAM_REQUIRED` to anything
that needs one, and the app uses that to show the right onboarding screen.

### Reading and writing records

Screens dispatch events to a bloc; the bloc calls a repository; the repository
calls the API. Every list keeps showing its rows while a reload or a write is in
flight, and a failed write leaves the list intact and says what went wrong. On
the server, the same write updates the record, appends to its change log and
creates feed notifications in one transaction.

### Working offline

Successful reads of the main lists and records are written to a size-capped
disk cache on the phone, keyed by the session and wiped on sign-out. When the
server cannot be reached, the app answers from that cache and shows a strip
saying what time the data on screen is from, with a way to retry. Writes are
not queued: they need the server.

### Notifications — three separate channels

| Channel | Source | Delivery |
| --- | --- | --- |
| **In-app feed** (the bell) | the backend writes a row when something happens to you: a task assigned, a deal moved, a mention, a lead, a client's birthday… | the app polls `/notifications` every minute |
| **Reminders** | the app itself, from the meetings and tasks it has loaded | local notifications scheduled on the phone, 15 min / 1 h / 1 day ahead |
| **Push** | announcements sent from the Firebase Console | FCM topics: `all`, `lang_<code>`, `role_<role>` |

### Files and photographs

Deal documents and listing photographs are uploaded as multipart to the API,
which stores the bytes in the configured store and serves them back through
authenticated endpoints. See [Where attachments live](#where-attachments-live).

---

## The domain

```text
Team ─┬─ User (ADMIN | MANAGER | AGENT, scope OWN | TEAM | ALL)
      ├─ Client ─┬─ requirements (buyers), tags, dates, activity
      │          └─ Task
      ├─ Property ─┬─ PropertyPhoto, price history, keys, offers,
      │            │  open houses, expenses, share links
      ├─ Deal ─────┼─ Document, checklist, comments, deposit,
      │            │  commission split, lease
      │            └─ Meeting ── outcome
      ├─ Partner, MonthlyGoal, MessageTemplate, TimeOff
      └─ TeamJoinRequest, Notification, RecordChange, AuditLog
```

A **team is an agency**, and it is the tenant: nothing crosses between teams.
Another agency's record answers as missing rather than forbidden, so its
existence is not confirmed either.

---

## Who sees what

Two separate questions. The **role** decides what someone may do:

| Role | May |
| --- | --- |
| `AGENT` | work clients, listings, deals, meetings and tasks |
| `MANAGER` | that, plus run the agency: add and remove people, targets, templates, analytics, handovers |
| `ADMIN` | the console across agencies: people, roles, teams, audit log |

The **data scope** decides which records they see at all:

| Scope | Sees |
| --- | --- |
| `OWN` | their own clients, deals and meetings, and the tasks assigned to them |
| `TEAM` | everything in their agency |
| `ALL` | every agency (admins only) |

Listings are the exception: they are visible to the whole agency whatever the
scope, because a flat is not private the way a client's phone number is.

---

## Module status

| Module | State |
| --- | --- |
| `backend/` | Current. Java 17, Spring Boot 3.2, PostgreSQL, Flyway. |
| `mobile/` | Current. Flutter, iOS and Android, en / ru / kk, light and dark. **The product.** |
| `frontend/` | **Deliberately behind.** React + Vite, last caught up in August 2026. |
| `frontend-next/` | Foundation of a Next.js replacement for `frontend/`: session layer and API proxy, no product pages yet. See its own README. |

The React client knows nothing the API grew after August: no registration or
e-mail verification, no teams or join requests, no matching, viewings or
photographs. That is a decision, not an oversight — the app is what is being
shipped. Do not treat a feature's absence there as a gap, and do not assume
parity.

---

## Running it

**Backend** needs a PostgreSQL and two environment variables to exist at all
(`DB_URL`, `JWT_SECRET` — see [Configuration](#configuration)):

```bash
cd backend
docker-compose up --build     # API on :8080/api, Postgres on :5433
./mvnw test
```

**Mobile** — run it through the SDK the project pins, not whatever `flutter` is
on `PATH`:

```bash
cd mobile
fvm flutter pub get
fvm flutter run
fvm flutter test
```

A different Flutter version leaves a stale `mobile/build/unit_test_assets`, and
then every test that taps anything fails on `shaders/ink_sparkle.frag`. Clear
that directory after switching versions.

**Web** (if you have a reason):

```bash
cd frontend
npm install && npm run dev    # needs VITE_API_URL
```

---

## The API at a glance

Everything is under a `/api` context path and behind a bearer token, except the
handful marked public. Full OpenAPI at `/api/swagger-ui.html`.

| Area | Endpoints |
| --- | --- |
| Auth (public) | `/auth/login`, `/auth/register`, `/auth/demo`, `/auth/verify-email`, `/auth/verify-email/start`, `/auth/refresh`, `/auth/accept-invite`, `/auth/forgot-password`, `/auth/reset-password` |
| Me | `/auth/me` (get, update, **delete**), `/me/team`, `/me/team-requests` |
| Clients | `/clients`, `/clients/{id}`, `/clients/{id}/matches`, `/clients/tags`, cold clients, client dates, duplicates, activity |
| Properties | `/properties`, `/properties/{id}`, photos, cover, price history, mandates, keys, offers, open houses, expenses, share links |
| Deals | `/deals`, `/deals/{id}`, `/deals/{id}/status`, documents, checklist, comments, deposit, commission split, leases |
| Meetings and tasks | `/meetings`, `/meetings/{id}/outcome`, `/tasks`, recurring series |
| Agency | `/team`, `/team/members`, `/team/requests`, `/team/message-templates`, `/team/checklist-template`, `/goals`, `/payouts`, `/partners`, `/time-off`, `/handovers` |
| Insight | `/dashboard/summary`, `/analytics/funnel`, `/analytics/leaderboard`, `/analytics/lead-sources`, `/audit` (change log) |
| Data | `/import/{kind}`, `/export`, `/stars`, `/notifications` |
| Admin | `/admin/users`, `/admin/audit-log`, `/teams` |
| Pages (public) | `/privacy`, `/support`, `/invite`, `/reset`, `/l/{token}` |

`DELETE /auth/me` closes an account and hands its records to a chosen successor —
required by App Store guideline 5.1.1(v).

---

## Configuration

Everything has a default in `backend/src/main/resources/application.yml`. These
are the ones whose default is wrong for a real deployment:

| Variable | Why |
| --- | --- |
| `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` | No defaults. The service does not start without them. |
| `JWT_SECRET` | No default. Base64, at least 32 bytes. |
| `ADMIN_PASSWORD` | No default, and the admin console is shut without it. |
| `APP_BASE_URL` | Defaults to `localhost`, and the invite e-mail's button is built from it. |
| `MAIL_ENABLED`, `MAIL_USERNAME`, `MAIL_PASSWORD` | Off by default. Invites, password resets and team requests are mailed with them. Gmail wants a 16-character App Password. `MAIL_PROVIDER=brevo` + `BREVO_API_KEY` for hosts that block SMTP. |
| `FIREBASE_CREDENTIALS_PATH` | The Firebase service-account key. Sign-up needs it; without it registration answers `503 VERIFICATION_UNAVAILABLE`. `SIGNUP_VERIFY_EMAIL=false` skips the link. |
| `DOCUMENTS_STORAGE` | `database` \| `s3` \| `filesystem` — see below. |
| `S3_BUCKET`, `S3_ENDPOINT`, `S3_REGION`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` | Required once `s3` is chosen. |
| `DEMO_ENABLED`, `DEMO_PASSWORD` | The account App Review signs in with. Off outside a submission window. |
| `DEMO_TRY_ENABLED` | On by default. "Try the demo" on the sign-in screen. `false` answers 404. |

`backend/.env.example` is the fuller list.

The mobile app reads its API host from Firebase Remote Config (`api_base_url`)
and falls back to the Render host built into it. A build-time define pins the
host and makes the app ignore Remote Config for it, which is what a local or
staging build wants:

```bash
fvm flutter build ipa --dart-define=API_BASE_URL=https://api.example.com/api
```

---

## Firebase

One project, `estatecrm-3e55a`, three jobs:

| Job | Who uses it | Needs |
| --- | --- | --- |
| E-mail verification at sign-up | backend + app | `FIREBASE_CREDENTIALS_PATH` on the backend |
| Remote Config: `api_base_url`, `map_tile_url`, `map_attribution` | app only | parameters published in the console |
| Cloud Messaging: push to topics `all`, `lang_*`, `role_*` | app only, sent from the console | FCM API (V1) enabled; an APNs key once iOS is on a paid team |

The backend does not send pushes. Keys, defaults, validation rules, how to send
a push and how to check it all works: [`docs/firebase.md`](docs/firebase.md).

---

## Where attachments live

Deal documents and listing photographs share one `DocumentStorage` interface with
three implementations, chosen by `app.documents.storage`. The database keeps the
key either way, so moving between them is a config change and not a data
migration.

| Store | Use it when |
| --- | --- |
| `database` (default) | the host's filesystem does not survive a restart, and the files are contracts rather than photographs. The database's own size limit is the ceiling. |
| `s3` | anything real. Any S3-compatible bucket — R2, Backblaze, MinIO, AWS. What photographs want. |
| `filesystem` | a volume is genuinely mounted. Point `DOCUMENTS_DIR` at it. |

Photographs are refused unless the bytes are a format the app can draw — JPEG,
PNG, GIF, WebP or BMP — decided by reading the header rather than trusting the
file name, because an iPhone photograph named `.jpg` is often HEIC inside.

---

## Testing

```bash
cd backend && ./mvnw test              # integration tests on H2, MockMvc
cd mobile  && fvm flutter test         # unit, bloc and widget tests
cd mobile  && fvm flutter analyze      # must be clean
```

The backend suite runs against H2 with the schema generated from the entities.
That has disagreed with the migrated Postgres schema twice, so a migration is
also applied to a real PostgreSQL with `ddl-auto: validate` before it is trusted.

The mobile suite is mostly widget tests through `test/responsive_harness.dart`,
which runs an acceptance matrix — five widths from 320 dp, light and dark, three
text scales, three locales — and fails on any overflow. `test/design_rules_test.dart`
statically guards the house rules: no hardcoded font family, no emoji in copy,
no spinner where a skeleton belongs.

---

## Deployment

The API runs on Render at `https://estate-crm-system.onrender.com/api`, from the
`Dockerfile` in `backend/`. Two things about that host are worth knowing:

- **The filesystem is ephemeral.** Anything written to disk is gone on the next
  deploy, and on a free plan on the next wake from sleep. That is why the
  default attachment store is the database and why `s3` exists.
- **It sleeps.** The first request after an idle period waits for a container to
  start, measured at well over a minute. The app retries that first request
  once on a 90-second budget rather than reporting the network as down.

### Migrations that land out of order

Branches claim the next free migration number when they are written and merge
when they are reviewed, so a lower version can reach production after a higher
one. `spring.flyway.out-of-order` is on, so a version below the current highest
is applied on the next start; checksums are still validated. Migrations
therefore must not depend on a higher-numbered migration having run first.

To confirm a database is complete, run

```sql
select version, success from flyway_schema_history order by installed_rank;
```

and check every version is present with `success = true`.

### Moving the API to another host

The app finds the API through Remote Config, so a move needs no app release:
bring the new host up, publish `api_base_url` with its address, and keep the old
host running until its traffic stops. Steps and caveats in
[`docs/firebase.md`](docs/firebase.md#moving-the-backend).

### Shipping the app

iOS submission — what App Review needs, the demo account, the privacy answers —
is in [`docs/app-store-submission.md`](docs/app-store-submission.md).

---

## Further reading

| Document | Covers |
| --- | --- |
| [`mobile/README.md`](mobile/README.md) | the app in depth: start-up, layers, navigation, state, networking, offline, notifications, design system, every feature and where it lives |
| [`backend/README.md`](backend/README.md) | the API in depth: layers, the life of a request, security, tenancy, subsystems, migrations |
| [`docs/firebase.md`](docs/firebase.md) | Remote Config keys, push topics and custom data, console checklist, iOS push |
| [`docs/app-store-submission.md`](docs/app-store-submission.md) | what App Review needs, what the host has to carry, what is already handled in the build |
| [`docs/invite-deep-link-deploy.md`](docs/invite-deep-link-deploy.md) | invite e-mails and Universal Links |
| [`AGENTS.md`](AGENTS.md) | per-module commands and conventions for anyone editing this repository |

---

## Team

| Name | ID |
| --- | --- |
| Assan Sultan | 230103325 |
| Koibagar Nurserik | 230103145 |
| Amangeldi Dauirkhan | 230103386 |
| Muratbek Mukamet | 230103265 |

---

## License

MIT. See [LICENSE](LICENSE).
