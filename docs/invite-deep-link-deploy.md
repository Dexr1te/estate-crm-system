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

## Later: real App Links

The custom scheme works today without owning a verified domain, which is why it
was chosen. Turning it into a proper https link that opens the app is backend
and infra work, whenever you want it:

1. Serve `/.well-known/assetlinks.json` and
   `/.well-known/apple-app-site-association` from the public origin. Spring's
   context path is `/api`, so these have to come from the reverse proxy at the
   root, not from the app.
2. `assetlinks.json` needs the Android package name and the signing cert
   SHA-256. The app's `applicationId` is still the template default
   `com.example.mobile` — that has to become a real id first.
3. Then point `INVITE_URL` at the https deep link. The mobile side already
   accepts that form and needs no change.
