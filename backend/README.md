# Estate CRM — Backend

The Spring Boot API behind the Estate CRM app. It owns the accounts, the
agencies and every record in them; the mobile app is its main client.

Java 17, Spring Boot 3.2, PostgreSQL, Flyway, JWT. Everything is served under
the `/api` context path. OpenAPI lives at `/api/swagger-ui.html`.

What the product does, the domain, roles and data scopes, and the API at a
glance are in the [root README](../README.md). This file is about working on the
backend itself.

---

## Contents

- [Running it](#running-it)
- [Layout](#layout)
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

The mobile app talks to the Render host by default. To point a debug build at a
local backend instead:

```bash
cd mobile
.fvm/flutter_sdk/bin/flutter run --dart-define=API_BASE_URL=http://<your-ip>:8080/api
```

A build-time `API_BASE_URL` makes the app ignore the address in Remote Config,
so it stays on your machine. Use your computer's LAN address, not `localhost`,
for a physical phone.

---

## Layout

```
src/main/java/com/crm/realestate/
├── config/          security, CORS, Firebase, Flyway, scheduling, the team-required interceptor
├── controller/      REST endpoints, plus the public HTML pages (invite, reset, listing, legal)
├── dto/             request and response bodies
├── entity/          JPA entities; delete rules declared here as well as in the migrations
├── enums/
├── exception/       BusinessException and the error body the app reads
├── repository/      Spring Data repositories
├── security/        JWT filter, SecurityUtils.getCurrentUser()
├── service/         business rules, notifications, storage, mail
└── specification/   JPA specifications for list filters and matching
src/main/resources/
├── application.yml  every setting, each with its environment variable
├── db/migration/    Flyway migrations, V1 to V61
└── i18n/            strings of the public listing page, en / ru / kk
```

A team is the tenant. Every query on business data goes through `ScopeService`,
and `config/WebConfig.java` lists the paths that answer `403 TEAM_REQUIRED` to
someone who is not in a team yet.

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

The backend uses Firebase for one thing: **proving a new account's email
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
custom token; the app has Firebase email the link; `POST /auth/verify-email`
reads the Firebase user back and activates the account.

**Two Firebase features the app uses do not touch the backend at all:**

- **Push notifications** are sent from the Firebase Console to topics the app
  subscribes to. `FirebaseNotificationService` is present but nothing calls it,
  and no device tokens are stored here. The in-app notification feed
  (`/notifications`) is unrelated to push and works as before.
- **Remote Config** tells the app where this API is (`api_base_url`). Moving the
  API to another host needs no app release: bring the new host up, publish the
  new address, keep the old host running until its traffic stops.

Both are documented in [`docs/firebase.md`](../docs/firebase.md).

---

## Migrations

Flyway, in [`src/main/resources/db/migration`](src/main/resources/db/migration),
named `V<n>__what_it_does.sql`. Take the next free number when you write one.

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
