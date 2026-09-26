# Invite deep links — what the backend needs

**No backend code changed, so nothing has to be rebuilt or redeployed for this
to work.**

The mobile app now registers the `estatecrm://` scheme, which is what makes the
"Open in the app" button on the invite landing page do something. That button
was already there, and the backend already emits it: `app.invite-deep-link`
defaults to `estatecrm://accept-invite`, which is exactly what the app claims.

What is left is confirming two settings in production. Redeploy only if one of
them actually has to change.

## Already handled

`docker-compose.prod.yml` now lives in the repository and declares `env_file`,
so `.env` reaches the container (PR #70). Two things follow from that:

- On the first deploy after that change, the untracked copy sitting on the VM
  has to be moved aside, or `git pull` aborts with *"untracked working tree
  files would be overwritten"*.
- `EmailService` now states its resolved configuration at boot, so mail being
  off is visible in the startup log instead of only after someone clicks
  "invite".

## The two settings

### `APP_BASE_URL` — the public origin

The invite email builds its link from this. Unset, it falls back to
`http://localhost:8080`, which is a dead link on the recipient's phone. It has
to be the public https origin, no trailing slash:

```ini
APP_BASE_URL=https://your-public-host
```

A listing's public link (`/api/l/<token>`) is built from the same origin, and
so is the page's `og:image` tag that WhatsApp and Telegram fetch for the
preview. `LISTING_URL` overrides the whole prefix, and only matters if that
page is ever served from another origin:

```ini
# default: ${APP_BASE_URL}/api/l
LISTING_URL=https://your-public-host/api/l
```

Check it the same way as the invite page — an unknown token must answer the
friendly 404 page, never a 401 or 403:

```sh
curl -si "$APP_BASE_URL/api/l/nope" | head -1
# expect: HTTP/1.1 404
```

### `INVITE_DEEP_LINK` — leave it unset

The default is `estatecrm://accept-invite` and the app registers exactly that
scheme. An override that differs by even one character produces a button that
opens nothing. It is now listed in `.env.example` precisely so nobody sets it
"helpfully".

## Applying a change

Environment changes need the container recreated. `docker compose restart`
reuses the existing container's config and will **not** pick up an edited
`.env`:

```bash
docker compose -f docker-compose.prod.yml up -d
```

No rebuild — the image is unchanged.

## Verifying

**Read the boot log first.** It answers both settings at once:

```bash
docker compose -f docker-compose.prod.yml logs app | grep -i "^.*Mail is"
```

| Line | Meaning |
| --- | --- |
| `Mail is ON — host=…, from=…, invite links point at …` | Check that the invite link base is the public origin, not `localhost` |
| `Mail is ON but spring.mail.username is empty` | SMTP will reject every send |
| `Mail is OFF (app.mail.enabled=false)` | `MAIL_ENABLED` never reached Spring — check `.env` and `env_file` |

**The landing page is public.** An unknown token should render the "not valid"
page, not an auth error:

```bash
curl -si "$APP_BASE_URL/api/invite?token=nope" | head -1
# expect: HTTP/1.1 200
```

A 401 or 403 means `/invite` is no longer in `SecurityConfig.PUBLIC_URLS`, and
every invite link in every already-sent email is broken.

**The deep link is emitted.** Invite a throwaway address from the admin console
— the dialog shows the token — then:

```bash
curl -s "$APP_BASE_URL/api/invite?token=$TOKEN" | grep -o 'estatecrm://[^"]*'
# expect: estatecrm://accept-invite?token=<the token>
```

**Mail actually left.** After creating or resending an invite:

```bash
docker compose -f docker-compose.prod.yml logs app | grep -i "invite email"
```

`Invite email sent to …` means SMTP accepted it; `Failed to send invite email
to …` carries the reason on the same line. Watch for the second one: mail
failures are swallowed on purpose so a broken SMTP box cannot break invite
creation, which means **the admin UI reports success either way**. The log is
the only place the truth shows up.

For Gmail, `MAIL_PASSWORD` must be a 16-character App Password (Google account →
Security → 2-Step Verification → App passwords), never the account password.

## Not needed

No migration, no new endpoint, no API change, no image rebuild. The token is
still the same one-time `UUID` on `users.invite_token`, still 48 hours, still
spent by `POST /auth/accept-invite`.

## Universal Links are half-shipped — one root rewrite short

Since this was written, the iOS side went ahead: `Runner.entitlements` claims
`applinks:estate-crm-system.onrender.com`, and `WellKnownController` serves the
association file. The rewrite that section called for was never added, so the
file is not where Apple looks:

```sh
curl -sI https://estate-crm-system.onrender.com/.well-known/apple-app-site-association
# actual:   404, from Tomcat — outside its context path
# needed:   200, application/json
```

Spring is mounted at `/api`, so the app answers on
`/api/.well-known/apple-app-site-association`, which Apple never requests. Until
something bridges the two, the entitlement promises a domain that cannot
validate and every invite link falls back to the landing page. The custom scheme
still works, so nothing is broken for users — the feature simply is not live.

On Render there is no proxy in front of the container to rewrite the path, so
the fix has to come from the app itself. Either drop `server.servlet.context-path`
and move the `/api` prefix into the controllers' mappings, or register the
association file on a second, root-level route that Tomcat can reach — Apple
fetches it from the root and does not follow redirects, so a 301 to the `/api`
copy will not do.

`SecurityConfig` already permits `/.well-known/**`, and the response is served
with a JSON content type and no `.json` extension, which is what Apple requires.
Re-run the curl above once the route answers at the root; then reinstall the app,
because iOS only fetches the association file at install time.

The same change would let `/privacy` and `/support` answer at the root. That is
cosmetic now — the app builds those links with the `/api` prefix itself — but it
makes for tidier URLs in the App Store Connect form.

Android needs the equivalent whenever you want it: `/.well-known/assetlinks.json`
at the root, carrying `com.sultan.estatecrm` and the release signing cert's
SHA-256 fingerprint. Nothing serves that file yet.
