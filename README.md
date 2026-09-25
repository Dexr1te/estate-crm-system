# Estate CRM

A CRM for real-estate agencies. An agent keeps their buyers and sellers, the flats
on the books, the deals between them and the viewings in the calendar — in one
place, on the phone, in the field.

Three modules in one repository: a Spring Boot API, a Flutter app for iOS and
Android, and a React web client. The app is the product being shipped; see
[Module status](#module-status) before you touch the web one.

---

## Contents

- [What it does](#what-it-does)
- [The domain](#the-domain)
- [Who sees what](#who-sees-what)
- [Module status](#module-status)
- [Running it](#running-it)
- [The API at a glance](#the-api-at-a-glance)
- [Configuration](#configuration)
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
and area — which is what makes the next two features possible.

**Listings.** Flats, houses, commercial space and land, with price, area, rooms,
floor and photographs. The first photograph is the cover the lists show, and the
order can be changed by holding one and dragging it. A listing remembers every
change of its price and who made it; a cut made in the last thirty days is
flagged wherever the listing is named.

**Matching.** A buyer's card lists the flats that answer what they asked for,
cheapest first, with the ones a little over the ceiling marked rather than
hidden. A listing's card does the mirror: the buyers it answers. A requirement
nobody stated does not narrow anything; a flat somebody has already turned down
stops being offered to them.

**Deals.** Lead → Negotiation → Closed won / Closed lost, on a list or a board,
with the paperwork attached and a stale-deal warning after five untouched days.

**Meetings and viewings.** A meeting can name the flat being shown, which gives
a listing a history of who has seen it. After a showing the verdict is recorded —
interested, turned it down, nobody came — and matching reads it.

**Dashboard.** The next meeting, the month's goal against what has closed, four
counters with sparklines, the pipeline, deals needing attention, meeting load and
the agency's leaderboard.

**Teams and access.** Anyone can sign up. A manager creates an agency; an agent
asks to join one and waits to be accepted. An administrator works across
agencies from a console: people, roles, teams, audit log.

---

## The domain

```text
Team ─┬─ User (ADMIN | MANAGER | AGENT, scope OWN | TEAM | ALL)
      ├─ Client ── requirements (buyers only)
      ├─ Property ── PropertyPhoto ─── bytes in the configured store
      ├─ Deal ─┬─ Document ───────────┘
      │        └─ Meeting ── outcome
      └─ TeamJoinRequest, AuditLog
```

A **team is an agency**, and it is the tenant: nothing crosses between teams.
Every read and write is filtered by it, and another agency's record answers as
missing rather than forbidden, so its existence is not confirmed either.

---

## Who sees what

Two separate questions. The **role** decides what someone may do:

| Role | May |
| --- | --- |
| `AGENT` | work clients, listings, deals, meetings |
| `MANAGER` | that, plus run the agency: invite people, accept join requests, remove members |
| `ADMIN` | that, plus the console across agencies: people, roles, teams, audit log |

The **data scope** decides which records they see at all:

| Scope | Sees |
| --- | --- |
| `OWN` | their own clients, deals and meetings |
| `TEAM` | everything in their agency |
| `ALL` | every agency |

Listings are the exception: they are visible to the whole agency whatever the
scope, because a flat is not private the way a client's phone number is.

---

## Module status

| Module | State |
| --- | --- |
| `backend/` | Current. Java 17, Spring Boot 3.2, PostgreSQL, Flyway (23 migrations). |
| `mobile/` | Current. Flutter, iOS and Android, en / ru / kk, light and dark. **The product.** |
| `frontend/` | **Deliberately behind.** React + Vite, last touched 2026-08-30. |

The web client knows nothing the API grew after August: no registration or email
verification, no teams or join requests, no matching, viewings, viewing outcomes
or photographs. That is a decision, not an oversight — the app is what is being
shipped, so catching the web client up is work nobody is waiting for. Do not
treat a feature's absence there as a gap, and do not assume parity.

---

## Running it

**Backend** needs a PostgreSQL and two environment variables to exist at all
(`DB_URL`, `JWT_SECRET` — see [Configuration](#configuration)):

```bash
cd backend
docker-compose up --build     # API on :8080/api, Postgres on :5433
./mvnw test                   # 131 tests
```

**Mobile** — run it through the SDK the project pins, not whatever `flutter` is
on `PATH`:

```bash
cd mobile
fvm flutter pub get
fvm flutter run
fvm flutter test              # 1896 tests
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
| Auth (public) | `/auth/login`, `/auth/register`, `/auth/verify-email`, `/auth/resend-verification`, `/auth/refresh`, `/auth/accept-invite`, `/auth/forgot-password`, `/auth/reset-password` |
| Me | `/auth/me` (get, update, **delete**), `/me/team`, `/me/team-requests` |
| Clients | `/clients`, `/clients/{id}`, `/clients/with-details`, `/clients/{id}/matches` |
| Properties | `/properties`, `/properties/{id}`, `/properties/{id}/status`, `/properties/{id}/photos` (+ `order`, `{photoId}/content`), `/properties/{id}/cover`, `/properties/{id}/interested`, `/properties/{id}/viewings`, `/properties/{id}/price-history` |
| Deals | `/deals`, `/deals/{id}`, `/deals/{id}/status`, `/deals/{dealId}/documents` |
| Meetings | `/meetings`, `/meetings/upcoming`, `/meetings/{id}`, `/meetings/{id}/complete`, `/meetings/{id}/outcome` |
| Teams | `/teams`, `/team`, `/team/members`, `/team/requests` |
| Admin | `/admin/users`, `/admin/audit-log`, `/admin/users/{id}/…` |
| Dashboard | `/dashboard/summary` |
| Pages (public) | `/privacy`, `/support`, `/invite`, `/reset` |

`DELETE /auth/me` closes an account and hands its records to a chosen successor —
required by App Store guideline 5.1.1(v), and the reason it exists at all.

---

## Configuration

Everything has a default in `backend/src/main/resources/application.yml`. These
are the ones whose default is wrong for a real deployment:

| Variable | Why |
| --- | --- |
| `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` | No defaults. The service does not start without them. |
| `JWT_SECRET` | No default. Base64, at least 32 bytes. |
| `ADMIN_PASSWORD` | No default, and the admin console is shut without it. Migrations used to carry an admin password, which published it with the repository; `V18` retired those. |
| `APP_BASE_URL` | Defaults to `localhost`, and the invite email's button is built from it. |
| `MAIL_ENABLED`, `MAIL_USERNAME`, `MAIL_PASSWORD` | Off by default, and sign-up needs them: with no way to send the code, registration answers `503 CODE_NOT_SENT` and creates nothing. Gmail wants a 16-character App Password. |
| `DOCUMENTS_STORAGE` | `database` \| `s3` \| `filesystem` — see below. |
| `S3_BUCKET`, `S3_ENDPOINT`, `S3_REGION`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` | Required once `s3` is chosen. |
| `DEMO_ENABLED`, `DEMO_PASSWORD` | The account App Review signs in with. Off outside a submission window. |

`backend/.env.example` is the fuller list. The mobile app's API host is baked in
at build time and overridable:

```bash
fvm flutter build ipa --dart-define=API_BASE_URL=https://api.example.com/api
```

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
file name, because an iPhone photograph named `.jpg` is often HEIC inside and
would be stored happily and then shown as an empty tile.

---

## Testing

```bash
cd backend && ./mvnw test              # 131 tests, 19 classes
cd mobile  && fvm flutter test         # 1896 tests, 44 files
cd mobile  && fvm flutter analyze      # must be clean
```

The backend suite runs against H2 with the schema generated from the entities.
That has disagreed with the migrated Postgres schema twice — an `ON DELETE SET
NULL` and a `byte[]` column's length — so a migration is also applied to a real
PostgreSQL with `ddl-auto: validate` before it is trusted.

The mobile suite is mostly widget tests through `test/responsive_harness.dart`,
which runs an acceptance matrix — five widths from 320 dp, light and dark, three
text scales, three locales — and fails on any overflow. `test/design_rules_test.dart`
statically guards the house rules: no hardcoded font family, no emoji in copy,
no spinner where a skeleton belongs, no grey slab pretending to be one.

---

## Deployment

The API runs on Render at `https://estate-crm-system.onrender.com/api`, from the
`Dockerfile` in `backend/`. Two things about that host are worth knowing:

- **The filesystem is ephemeral.** Anything written to disk is gone on the next
  deploy, and on a free plan on the next wake from sleep. That is why the
  default attachment store is the database and why `s3` exists.
- **It sleeps.** The first request after an idle period waits for a container to
  be built, measured at well over a minute. The app retries that first request
  once on a 90-second budget rather than reporting the network as down.

The web client deploys to Vercel and reads `VITE_API_URL` from its environment.

---

## Further reading

| Document | Covers |
| --- | --- |
| [`mobile/README.md`](mobile/README.md) | the app in depth: architecture, state, the design system, responsive rules, localization, screens, traps |
| [`docs/app-store-submission.md`](docs/app-store-submission.md) | what App Review needs, what the host has to carry, what is already handled in the build |
| [`docs/invite-deep-link-deploy.md`](docs/invite-deep-link-deploy.md) | invite emails, and why Universal Links are one root rewrite short of working |
| [`AGENTS.md`](AGENTS.md) | per-module commands and conventions for anyone — human or otherwise — editing this repository |

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
