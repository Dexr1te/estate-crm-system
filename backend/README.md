# Estate CRM — Backend

The Spring Boot API behind the Estate CRM app. It owns the accounts, the
agencies and every record in them; the mobile app is its main client.

Java 17, Spring Boot 3.2, Spring Security with JWT, Spring Data JPA over
PostgreSQL, Flyway. Everything is served under the `/api` context path, and the
OpenAPI description lives at `/api/swagger-ui.html`.

What the product does and how the three modules fit together is in the
[root README](../README.md). This file is about how the API itself is built.

---

## Contents

- [Running it](#running-it)
- [Architecture](#architecture)
- [The life of a request](#the-life-of-a-request)
- [Security and sessions](#security-and-sessions)
- [Tenancy: who sees which records](#tenancy-who-sees-which-records)
- [Subsystems](#subsystems)
- [Configuration](#configuration)
- [Firebase](#firebase)
- [Migrations](#migrations)
- [Testing](#testing)
- [Deployment](#deployment)

---

## Running it

With Docker, the API and a PostgreSQL together:

```bash
cd backend
cp .env.example .env          # then fill in DB_*, JWT_SECRET, ADMIN_PASSWORD
docker-compose up --build     # API on :8080/api, Postgres on :5433
```

Without Docker, against a PostgreSQL you already run:

```bash
cd backend
export DB_URL=jdbc:postgresql://localhost:5432/crm_db DB_USERNAME=crm_user DB_PASSWORD=...
export JWT_SECRET=$(openssl rand -base64 48)
./mvnw spring-boot:run
```

| Task | Command |
| --- | --- |
| Run | `./mvnw spring-boot:run` |
| Test | `./mvnw test` |
| Package | `./mvnw package` (the jar lands in `target/`) |
| One test class | `./mvnw test -Dtest=NotificationEndpointsTest` |

To point a debug build of the app at a local backend:

```bash
cd mobile
.fvm/flutter_sdk/bin/flutter run --dart-define=API_BASE_URL=http://<your-ip>:8080/api
```

A build-time `API_BASE_URL` makes the app ignore the address in Remote Config,
so it stays on your machine. Use the computer's LAN address, not `localhost`,
for a physical phone.

---

## Architecture

A classic layered Spring application. Each layer only calls the one below it.

```
          HTTP
            │
  ┌─────────▼──────────┐   security/   JwtAuthenticationFilter — who is calling
  │  filters           │   config/     TeamRequiredInterceptor — are they in an agency
  ├────────────────────┤
  │  controller/       │   REST endpoints. Validate the body (@Valid), check the role
  │                    │   (@PreAuthorize), call one service method, return a DTO.
  ├────────────────────┤
  │  service/          │   Business rules and transactions. Every read and write is
  │                    │   scoped by ScopeService. Side effects (change log, feed
  │                    │   notifications, mail) are raised here.
  ├────────────────────┤
  │  repository/       │   Spring Data JPA. Filters and matching are composed from
  │  specification/    │   JPA Specifications rather than hand-written queries.
  ├────────────────────┤
  │  entity/           │   JPA entities = tables. Delete rules are declared here
  │                    │   (@OnDelete) as well as in the migrations.
  └─────────▼──────────┘
        PostgreSQL  (schema owned by Flyway, db/migration/V1…V61)
```

```
src/main/java/com/crm/realestate/
├── config/          security, CORS, Firebase, Flyway, S3, scheduling, Swagger,
│                    the team-required interceptor, admin bootstrap, demo seeder
├── controller/      40 REST controllers, plus the public HTML pages
│                    (invite, password reset, listing page, privacy, support)
├── dto/             request and response bodies — entities never leave the API
├── entity/          40 JPA entities
├── enums/           roles, scopes, statuses, kinds
├── exception/       BusinessException, ResourceNotFoundException, the error body
├── repository/      Spring Data repositories
├── security/        JWT issue/verify, the auth filter, SecurityUtils.getCurrentUser()
├── service/         business logic; sub-packages demo/, imports/, exports/
└── specification/   JPA specifications for list filters, map bounds and matching
src/main/resources/
├── application.yml  every setting, each bound to an environment variable
├── db/migration/    Flyway migrations
└── i18n/            strings of the public listing page, en / ru / kk
```

**DTOs at the edge.** Controllers accept `dto/request/*` and return
`dto/response/*`. Entities stay inside the service layer, so a lazy collection
is never serialised by accident and the wire format can change without a
migration.

**Errors have one shape.** `GlobalExceptionHandler` turns every exception into
an `ErrorResponse`: HTTP status, a human message, per-field validation errors
and, where the client has to react rather than just show it, a stable `code`
(`TEAM_REQUIRED`, `INVITE_PENDING`, `VERIFICATION_UNAVAILABLE`, `MANAGER_ONLY`
…). The app branches on `code`, never on the message text.

---

## The life of a request

Take `PATCH /api/deals/42/status` from an agent's phone:

1. **`JwtAuthenticationFilter`** reads `Authorization: Bearer …`, verifies the
   signature and expiry with `JwtService`, loads the user and puts it in the
   `SecurityContext`. No session is kept on the server (`STATELESS`).
2. **`SecurityConfig`** lets through only the public paths without a token;
   everything else needs an authenticated user, and a missing or expired token
   answers `401` — which is what makes the app refresh its token.
3. **`TeamRequiredInterceptor`** answers `403 TEAM_REQUIRED` if the caller is not
   in an agency yet (admins excepted). The app reads that code and sends the
   person to "create your agency" or "waiting to be added" instead of showing
   empty lists.
4. **`DealController`** validates the body and calls `DealService`.
5. **`DealService`** loads the deal through `ScopeService`. A deal in another
   agency, or a colleague's deal for an agent on own-data scope, reads as
   `404` — not `403` — so its existence is not confirmed either.
6. Inside the same transaction the service changes the status, writes a
   `DealStatusChange`, a line in the change log (`ChangeLogService`) and, through
   `NotificationEvents`, a feed notification for whoever should hear about it.
   A failure to notify is logged and swallowed: telling somebody must never undo
   the thing being told.
7. The response DTO is serialised to JSON. Any exception on the way becomes an
   `ErrorResponse`.

---

## Security and sessions

| Piece | Where | What it does |
| --- | --- | --- |
| Password hashing | `SecurityConfig` | BCrypt |
| Tokens | `JwtService`, `JwtProperties` | HS256, signed with `JWT_SECRET`. Access token lives 24 h, refresh token 7 days (`jwt.*` in `application.yml`) |
| Refresh | `POST /auth/refresh` | issues a new access token for a valid refresh token of an enabled user |
| Roles | `@PreAuthorize` on controllers | `ADMIN`, `MANAGER`, `AGENT` — see the [root README](../README.md#who-sees-what) |
| Public paths | `SecurityConfig.PUBLIC_URLS` | login, register, demo, verify email, refresh, invites, password reset, `/privacy`, `/support`, `/.well-known/**`, public listing pages `/l/**`, Swagger |
| Admin account | `AdminAccountBootstrap` | creates or updates the platform admin from `ADMIN_PASSWORD` on start; no password lives in a migration |

**Ways into an account:**

- **Sign-up** (`RegistrationService`). The account is created inactive, a
  Firebase user is created alongside it, and the app has Firebase e-mail the
  confirmation link. `POST /auth/verify-email` reads the Firebase user back and
  activates the account. A manager then creates an agency; an agent waits to be
  added to one.
- **Adding a member** (`TeamMembershipService`, `POST /team/members`). A manager
  types an agent's e-mail. If that person already has an account, they get a
  join request (`TeamJoinRequest`) to accept or decline in the app. If nobody has
  that address yet, an invite is sent instead: the link opens the app (or the
  `/invite` page) and `POST /auth/accept-invite` sets the password.
- **Try the demo** (`service/demo/`). `POST /auth/demo` creates a throwaway
  `[Demo] Agency` with sample records and signs the caller in. Rate-limited per
  address; `DemoAgencyCleaner` deletes such agencies after 24 hours.
- **App Review account** (`DemoDataSeeder`). With `DEMO_ENABLED=true` and a
  `DEMO_PASSWORD` it seeds a fixed reviewer account in its own agency. See
  [`docs/app-store-submission.md`](../docs/app-store-submission.md).

**Leaving.** `DELETE /auth/me` closes the caller's own account
(`AccountRemovalService`): deals, meetings and documents cannot be orphaned, so
they are handed to a successor the person chooses first. Admin removal goes
through the same service.

---

## Tenancy: who sees which records

A **team is an agency** and is the tenant. There is no separate database per
agency — every business row carries its team, and **`ScopeService`** applies
two walls on every read and write:

1. **The team.** Nothing crosses between agencies.
2. **The data scope inside the team.** `OWN` narrows to records the person is
   the agent on; `TEAM` sees the whole agency; `ALL` is honoured for admins only
   — anyone else holding it is treated as `TEAM`, so a stray value can never open
   another agency's books.

The rule lives in one place (`visibleTo` for queries, `canSee` for single
records) instead of a filter each service has to remember. Two documented
exceptions: listings are visible to the whole agency whatever the scope, and a
colleague with a share of a deal's commission (`CommissionSplitStore`) sees that
deal.

---

## Subsystems

| Subsystem | Main classes | How it works |
| --- | --- | --- |
| **Notification feed** | `NotificationEvents`, `NotificationService`, `NotificationWriter`, `NotificationController` | Services raise business events — a task assigned, a deal moved, a comment that mentions you, a join request, a lead from a listing page, a price cut, a client's birthday, a lease ending. Each becomes a `Notification` row for the person who should hear about it, never for the person who did it. The app polls `/notifications` once a minute for the bell's badge. Push notifications are separate, see [Firebase](#firebase). |
| **Change log** | `ChangeLogService` (write), `ChangeHistoryService` (read), `RecordChange` | Every create, edit and delete of a client, listing or deal writes a line with the changed fields, who and when — in the same transaction, so a rolled-back change leaves no line. A record's history is visible to whoever sees the record; the agency-wide feed is for managers. |
| **Audit log** | `AuditLogService`, `AuditService`, `AuditLog` | Who did what to the agency itself: creating a team, accepting or removing members, invites, removing accounts, merging duplicate clients, setting goals, changing the checklist template. Read in the admin console. Written synchronously on purpose — an audit line that may or may not exist is worth less than none. |
| **Files** | `DocumentStorage` with `DatabaseDocumentStorage`, `S3DocumentStorage`, `FilesystemDocumentStorage`; `ImageNormalizer` | Deal documents and listing photographs share one storage interface; the implementation is picked by `DOCUMENTS_STORAGE`. The database keeps only the key, so switching stores is a config change. Photographs are checked by their first bytes, not the file name: HEIC is refused because the app cannot draw it. |
| **Matching** | `MatchingService`, `MatchSpecification` | A buyer's wish list (city, type, budget, rooms, area) against listings and back, through the same scoping as every other read. Listings a buyer has turned down after a viewing stop being offered to them. |
| **Public listing pages** | `ListingShareService`, `ListingPageController`, `ListingPageRenderer`, `ListingLeadService`, `LeadRateLimiter` | An agent creates an unguessable link `/l/{token}` to a listing. The page is server-rendered HTML in en/ru/kk with photographs and an "I'm interested" form. A submission becomes a client (or is attached to the existing one with that phone), a history entry and a notification. Rate-limited per address and per link. |
| **Mail** | `EmailService`, `BrevoMailClient` | Invites, password resets and team requests. `@Async` and failure-tolerant. Sent over SMTP or, on hosts that block SMTP, through Brevo's HTTPS API (`MAIL_PROVIDER=brevo`). Off unless `MAIL_ENABLED=true`. |
| **Import / export** | `service/imports/`, `service/exports/` | CSV import of clients and listings with a column-mapping step and duplicate skipping; CSV export of the agency's records, with the delimiter that matches the user's Excel locale. |
| **Handover** | `AccountRemovalService`, `RecordHandoverService`, `WorkHandoverService` | Moving records when somebody leaves, changes team, or a manager hands part of an agent's work to a colleague. A client moves together with its open deals, upcoming meetings and open tasks. |
| **Analytics** | `DashboardService`, `AnalyticsService`, `LeaderboardService`, `LeadSourceAnalyticsService`, `GoalService` | Dashboard summary, funnel and lead-source analytics, the agents' leaderboard and monthly targets, all computed on request within the caller's scope. |
| **Scheduled jobs** | `ClientDateNotifier`, `LeaseEndNotifier`, `DemoAgencyCleaner` | Hourly between 08:00 and 21:00: birthdays and other client dates, leases about to end. Hourly: deleting expired demo agencies. Configured in `SchedulingConfig`, switched off in tests. |

---

## Configuration

Every setting is in [`application.yml`](src/main/resources/application.yml),
read from an environment variable with a default where one is safe.
[`.env.example`](.env.example) lists them with an explanation each, and the
[root README](../README.md#configuration) names the ones whose default is wrong
for a real deployment: `DB_URL`, `JWT_SECRET`, `ADMIN_PASSWORD`, `APP_BASE_URL`,
mail, `FIREBASE_CREDENTIALS_PATH` and the document store.

---

## Firebase

The backend uses Firebase for one thing: **proving a new account's e-mail
address.** Passwords and sessions stay here.

| Variable | Meaning |
| --- | --- |
| `FIREBASE_CREDENTIALS_PATH` | path to the service-account key (Firebase → Project settings → Service accounts → Generate new private key). Locally `firebase-service-account.json` in this folder, which is gitignored. On Render, a Secret File under `/etc/secrets/` |
| `FIREBASE_PROJECT_ID` | blank means the project the key belongs to, `estatecrm-3e55a` |
| `SIGNUP_VERIFY_EMAIL` | `true` by default. `false` signs new accounts straight in, for when Firebase is unreachable |

`FirebaseConfig` starts the Admin SDK when the key is readable and logs a
warning when it is not. The API still boots then, but registration answers
`503 VERIFICATION_UNAVAILABLE`. The flow is in `RegistrationService` and
`FirebaseIdentityService`: register creates a Firebase user and hands the app a
custom token; the app has Firebase e-mail the link; `POST /auth/verify-email`
reads the Firebase user back and activates the account.

**Two Firebase features the app uses do not touch the backend at all:**

- **Push notifications** are sent from the Firebase Console to topics the app
  subscribes to. `FirebaseNotificationService` is present but nothing calls it,
  and no device tokens are stored here. The in-app notification feed
  (`/notifications`) is unrelated to push.
- **Remote Config** tells the app where this API is (`api_base_url`). Moving the
  API to another host needs no app release: bring the new host up, publish the
  new address, keep the old host running until its traffic stops.

Both are documented in [`docs/firebase.md`](../docs/firebase.md).

---

## Migrations

Flyway, in [`src/main/resources/db/migration`](src/main/resources/db/migration),
named `V<n>__what_it_does.sql`. Take the next free number when you write one.
Hibernate only validates the schema (`ddl-auto: validate`) and never changes
it; the migrations are the only source of truth for it.

`spring.flyway.out-of-order` is on: branches merge in review order, not number
order, so a lower version can reach production after a higher one and is
applied on the next start. A migration must therefore not depend on a
higher-numbered one having run. The root README has the history and the SQL to
check `flyway_schema_history` ([Deployment](../README.md#migrations-that-land-out-of-order)).

Entities declare their delete rules (`@OnDelete`) as well as the migrations do,
because the tests build their schema from the entities.

---

## Testing

```bash
./mvnw test
```

The suite runs against in-memory H2 in PostgreSQL mode, with the schema
generated from the entities and Flyway off
([`src/test/resources/application.yml`](src/test/resources/application.yml)).
Mail is disabled, scheduling is disabled, and there is no Firebase: anything
Firebase-backed is either mocked or exercised through its fallback
(`SignUpWithoutFirebaseTest`).

Most tests are in `src/test/java/com/crm/realestate/integration/`: a full
Spring context and MockMvc with filters off, signing in by putting a user in the
`SecurityContextHolder`. Several of them count SQL statements per request
(`DealQueryCountTest`, `ExportQueryCountTest`), so an N+1 fails the build
rather than slowing production.

H2 and PostgreSQL have disagreed before, on an `ON DELETE SET NULL` and on a
`byte[]` column's length. Apply a new migration to a real PostgreSQL with
`ddl-auto: validate` before trusting it.

---

## Deployment

Production runs on Render from the [`Dockerfile`](Dockerfile): a Maven build
stage, then a JRE 17 Alpine image running as a non-root user. The live API is
`https://estate-crm-system.onrender.com/api`.

- The Render filesystem is ephemeral, so deal documents and photographs go to
  the database or to S3 (`DOCUMENTS_STORAGE`), never to local disk.
- The free plan sleeps. The first request after a while waits for a container,
  and the app retries it once on a 90-second budget.
- The Firebase key is a Secret File; point `FIREBASE_CREDENTIALS_PATH` at it.

[`docker-compose.prod.yml`](docker-compose.prod.yml) is the variant for a VPS
behind a reverse proxy: the API bound to loopback, memory capped, settings from
`.env`.
