# Estate CRM Next.js foundation

This local foundation covers PH00/B01 runtime pinning, B03 server-only backend transport, the B04 private BFF boundary, and the B05 HttpOnly session layer. B06 adds the preserved light/dark CRM tokens, local Inter Variable, a synchronous theme preference bootstrap, native Button/Input/Card primitives, and a scoped zinc/amber auth visual baseline. It has no product pages or login behavior. `npm run build` validates the real API-only app and its `/api/backend/[...path]` handler; the app under `tests/fixtures/runtime-app` is a separate test fixture and must not be deployed.

B08 adds the private TanStack Query boundary used by later authenticated features. Server pages create a fresh QueryClient per render after their leaf access gate; the browser provider exists only under `SessionVerified`. Query keys use the existing B05 canonical identity tuple in a credential-free stable scope, while B05's numeric generation remains the late-result epoch. Closing or changing the identity cancels and clears the old private cache. RSC identity props that disagree with an already known browser identity are withheld, checked through `/api/session/me`, and refreshed only when the live session confirms a different page. A successful browser `loginSession` keeps the boundary closed and performs `location.replace(currentHref)` so the previous JavaScript realm and any prefetched RSC payload cannot hydrate across a new login. A future PH01 login page should let that fresh document render or redirect to its implemented safe entry route; a competing client-only `router.push` is not the auth boundary.

The provider checks lifecycle state again after descendant effects because React Query can apply queued RSC hydration there; a session close clears that cache again. `npm run runtime:query-cache` exercises same-key and later-generation hydration, URL Back/Forward, identity changes, stale-RSC withholding, and a queued-hydration close in the test-only runtime fixture.

API028 `GET /clients` is the B08 read fixture. Its BFF allowlist requires explicit `page` and `size` (size 1–100), forwards only the documented filters, and preserves repeated `tags` and `sort`. Sort values are limited to the verified Client persistence fields `id`, `createdAt`, and `fullName`, with `asc` or `desc` direction. Backend authorization continues to decide OWN/TEAM/ALL visibility and 403 meaning. Paged callers accept only the stable Page fields and require a row decoder; a legacy array or error remains an error. Long URL IDs stay decimal strings, while unsafe numeric IDs in decoded JSON are rejected. LocalDate, YearMonth and offset-free LocalDateTime values stay as ISO strings. Numeric BigDecimal drafts convert only when JSON number serialization preserves their mathematical value; lexical scale remains the later endpoint form's job. JSON parsing cannot restore BigDecimal precision already lost by a numeric response.

If a stale RSC identity cannot be reconciled because `/api/session/me` is unavailable, private children and dehydrated state remain withheld and the shared boundary offers a manual retry. A successful retry that confirms a different live identity refreshes the route before rendering that identity.

Run with Node 24.21.0 and npm 11.19.0:

```sh
npm ci
npm run lint
npm run typecheck
npm test
npm run test:vitest
npm run test:e2e
BACKEND_API_URL=http://127.0.0.1:8080/api WEB_ORIGIN=http://127.0.0.1:3000 npm run build
npm run runtime:bff
npm run runtime:proof
npm run runtime:session
npm run runtime:session-rsc
```

The BFF reads the access cookie and passes its bearer to Spring for resource authorization. B05 adds session cookie writes, refresh, logout, and RSC verification; its `runtime:session` and `runtime:session-rsc` commands exercise those boundaries. The explicit BFF proof allowlist is API074, API075, API076, API078, API152, API153, API161, and API164 from the [API contract](../docs/web-nextjs-spec/03-api-contract.md). Later feature slices expand that list with their own tests. Public enquiry and listing routes do not use this private BFF.

B07 is partial: it adds reusable server role/team entry gates and a responsive shell, while production login, dashboard, admin, and onboarding routes remain deferred. Each future private leaf page must gate on the verified server identity before reading private data. Run the fixture proof with `npm run runtime:entry-shell`; it requires installed Chrome, using `B07_BROWSER_EXECUTABLE` when set or `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` by default.

`runtime:bff` starts a production Next server against an ephemeral local mock backend and checks the private route boundary, uploads, downloads, CSV, cancellation, and error wire. `runtime:proof` builds the separate fixture, scans its browser assets for a private backend URL, checks multipart/binary/CSV behavior, and waits through its synthetic 90-second response. `runtime:session-rsc` also builds the fixture's `/session-proof` and `/theme-proof` pages; both reuse the actual Server Component root layout, but remain test-only. Unit checks cover preference migration, blocked storage, system changes, and token/control contracts. Local proofs do not establish a real Spring or production deployment contract.

B09 adds synchronous Vitest/jsdom checks for the existing Button, Input, and Card props, plus MSW integration checks through the real `bffJson` and B08 query adapter. The existing `npm test` Node suite remains unchanged. `npm run test:e2e` first builds the API-only Next app with loopback-only backend/origin settings, then runs the existing BFF, session, RSC, theme, role-shell, and query-cache proofs through Playwright. Run one e2e invocation at a time per checkout because the existing runtime fixture uses a shared `.next` build; the configured single worker runs its six cases one at a time. Browser proofs use installed Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` or `B09_BROWSER_EXECUTABLE`; they do not download a browser. Playwright writes each invocation's per-test outputs and result report in a unique child directory under `/private/tmp/estate-crm-next-b09-evidence`.

These local tests use synthetic fixtures. They do not prove Spring/PostgreSQL integration, cross-agency isolation, refresh-token purpose enforcement, or disabled-account behavior. Those backend-owned checks remain PH00 release gates.

The B06 browser proof uses an installed Chromium executable supplied by `B06_BROWSER_EXECUTABLE`; it does not download a browser. Build the fixture, start its production server in one terminal, then run the browser proof from the workspace root in another:

```sh
(cd tests/fixtures/runtime-app && BACKEND_API_URL=http://127.0.0.1:8080/api WEB_ORIGIN=http://127.0.0.1:3001 node ../../../node_modules/next/dist/bin/next build)
(cd tests/fixtures/runtime-app && BACKEND_API_URL=http://127.0.0.1:8080/api WEB_ORIGIN=http://127.0.0.1:3001 node ../../../node_modules/next/dist/bin/next start --hostname 127.0.0.1 --port 3001)
B06_BROWSER_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" B06_PROOF_URL=http://127.0.0.1:3001/theme-proof B06_PROOF_OUTPUT_DIR=/tmp/estate-crm-b06-browser-proof npm run runtime:theme-browser
```

The test-only `/theme-proof` checks the pre-paint theme state while Next JavaScript is held, hydration and system changes, local fonts, theme controls, keyboard focus, contrast, and responsive targets. Its coarse-pointer viewport is emulated; the 640 CSS-pixel viewport is not native browser zoom. It does not cover screen readers, axe, Firefox, or WebKit, and it does not establish full browser E2E or production readiness.

The prior `vite-ui-theme` preference is read only on this same origin, then migrated to `estate-crm-theme`. A first visit or blocked storage uses dark mode. The auth input placeholder uses the brighter locked zinc-400 token to meet the 4.5:1 text contrast target; the zinc surfaces and amber actions stay on the Tailwind 4.2.2 palette. Q8 remains open for an approved login image; until then the auth visual baseline uses a neutral zinc background and no external image. Q5 locale default remains undecided.

Production hosting/domain and deployed wake/body/stream limits, full browser E2E, real Spring/PostgreSQL integration, and backend G01/G02 JWT-purpose and disabled-account enforcement remain open release gates. Mobile token migration and backend security fixes are outside this UI foundation; see the [gap analysis](../docs/web-nextjs-spec/14-gap-analysis.md) and [architecture](../docs/web-nextjs-spec/07-nextjs-architecture.md).

Next.js announced an October 14, 2026 security update for upstream vulnerabilities. Review and apply the patched release before production deployment: [Next.js security update notice](https://nextjs.org/blog).
