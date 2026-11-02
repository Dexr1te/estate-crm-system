# Submitting the iOS app

The build is ready and so is the account App Review signs in with. Production is
not: it is running an older backend than the one the app is built against, and
that has to be fixed before any of the rest of this is worth doing. After that,
what is left is one switch to throw on the host and the part App Store Connect
asks a person for.

## A paid Apple team, before anything is uploaded

The Xcode project signs with `9746P6DV47`, a free personal team (see
[`firebase.md`](firebase.md#ios-push-once-there-is-a-paid-apple-team)). A
personal team can install on a device but cannot upload to App Store Connect at
all: an archive signed by it has no distribution certificate to be exported
with. Enrol in the Apple Developer Program, then in Xcode → Runner → Signing &
Capabilities choose the paid team (it rewrites `DEVELOPMENT_TEAM` in
`project.pbxproj`), and register `com.sultan.estatecrm` under it.

While there, add the **Push Notifications** capability and upload the APNs key
to Firebase (same section of `firebase.md`). Without it every upload gets an
**ITMS-90078 "Missing Push Notification Entitlement"** e-mail — a warning, not a
rejection, because Firebase Messaging is linked — and iPhones receive no pushes.
The app copes either way: it does not ask an iPhone for push permission until an
APNs token exists.

## Already handled in the build

Verified against `build/ios/iphoneos/Runner.app`, not just read off the source:

- **No undeclared permissions.** `file_picker` compiles three pickers, and each
  one App Store Connect finds in the binary must be answered for: it refuses the
  upload with **ITMS-90683** unless `Info.plist` declares a purpose string.
  `mobile/ios/Podfile` keeps the document picker (a deal's paperwork) and the
  media picker (a listing's photographs, which live in the photo library and
  nowhere else), so `NSPhotoLibraryUsageDescription`,
  `NSPhotoLibraryAddUsageDescription` and `NSCameraUsageDescription` are
  declared and have to be answered for in the privacy questionnaire. The audio
  picker stays compiled out — nothing in the app picks a song, and leaving it on
  would add `MPMediaPickerController` and a fourth permission for code nothing
  reaches.
- **Account deletion, in the app.** Profile → Delete account, with a successor
  picker for the records that belong to the agency rather than to the person
  (Guideline 5.1.1(v)). Someone with nobody to hand them to — a reviewer who
  has just signed up, a manager alone in a new agency — skips the picker and
  goes straight to the confirmation; reviewers do exactly this.
- **Russian and Kazakh declared in the bundle.** `CFBundleLocalizations` lists
  en, ru and kk, and `InfoPlist.strings` in each `.lproj` translates the
  permission prompts, so the store lists all three languages and iOS draws its
  own screens (pickers, share sheet, prompts) in the phone's language.
- **The first tap of the day does not time out.** Sign-in, "Try the demo",
  sign-up and accepting an invite wait up to 90 s for a host that is waking
  up, instead of failing after 20 s.
- **No pointless notification prompt.** Push permission is asked only when a
  push could arrive (on iOS: once there is an APNs token). Meeting reminders
  ask for it in context, when someone turns them on.
- **Privacy policy and support pages**, served by the backend at `/privacy` and
  `/support`, public so a reviewer reaches them without signing in, and linked
  from the profile screen.
- **`PrivacyInfo.xcprivacy`**, declaring the contact data and the listing
  photographs collected, no tracking, and `CA92.1` for `shared_preferences`'
  use of `NSUserDefaults`.
- **iPhone-only, portrait-only**, matching the layouts that are actually tested.
- **`ITSAppUsesNonExemptEncryption` = false** — the app only uses HTTPS and the
  Keychain, both exempt.

## Deploy the backend first

The submitted build talks to production, and production is behind the
repository. What it was missing when this was first written — `DELETE /auth/me`,
`/deals/{dealId}/documents`, `/privacy`, `/support` — is answered now. What is
still missing is everything open sign-up brought:

```
/auth/register            /team                  /me/team
                          /team/members          /me/team-requests
                          /team/members/{id}     /me/team-requests/{id}/accept
                          /team/requests         /me/team-requests/{id}/decline
                          /team/requests/{id}
```

Twelve endpoints, and between them the only way into the app for someone
without an invite. A reviewer who taps "Create account" is answered 403 by a
host that has never heard of the endpoint, and every team screen fails the same
way. (`/search` is not on this list and never was: the app's search fans out
over the list endpoints it already calls, and no such endpoint exists in this
repository.)

Nothing else in this document works until that is fixed, the demo seeder
included — it ships in the same build. Redeploy, then confirm:

```sh
curl -s https://estate-crm-system.onrender.com/api/v3/api-docs \
  | python3 -c "import json,sys; p=json.load(sys.stdin)['paths']; \
      print(sorted(k for k in ('/auth/register','/team','/me/team','/auth/me') if k in p))"
# expect all four, and /auth/me carrying a delete verb

curl -sI https://estate-crm-system.onrender.com/api/privacy   # expect 200
```

Give the first call a generous `--max-time`. The host sleeps when nothing has
called it, and a cold start runs well past a minute — which is also why the app
retries its first request on a longer budget rather than reporting the network
as down.

## What the host has to carry

Production runs on Render now, so these are environment variables on the
service rather than lines in a `.env` a compose file forwards. Everything the
backend reads has a default in `application.yml`; these are the ones whose
default is wrong for a submission host:

| Variable | Why review cares |
|---|---|
| `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` | No default. The service does not start without them. |
| `JWT_SECRET` | No default. Signing key, Base64. |
| `APP_BASE_URL` | Defaults to `localhost`. The invite email's button is built from it. |
| `INVITE_URL` | Only if invites should point somewhere other than `<base>/api/invite`. |
| `MAIL_ENABLED`, `MAIL_USERNAME`, `MAIL_PASSWORD` | Off by default. Invites, password resets and team requests are mailed with them; sign-up does not use them. Gmail wants a 16-character App Password, not the account password. |
| `FIREBASE_CREDENTIALS_PATH` | Sign-up needs it: Firebase emails the link that confirms a new account. On Render, upload the service-account key as a Secret File and set this to `/etc/secrets/<its name>`. Without it, `POST /auth/register` answers 503 `VERIFICATION_UNAVAILABLE` and creates nothing. |
| `MAIL_PROVIDER=brevo`, `BREVO_API_KEY`, `MAIL_FROM` | For a host that blocks outbound SMTP, as Render's free plan does (ports 25, 465 and 587): mail then leaves through Brevo's HTTPS API instead, and `MAIL_USERNAME`/`MAIL_PASSWORD` are not used. `MAIL_ENABLED=true` is still required. `MAIL_FROM` has to be a sender verified in Brevo (Senders, Domains & Dedicated IPs → Senders); the key is under SMTP & API → API Keys. |
| `ADMIN_PASSWORD` | No default, and nothing works without it: `V18` retires the admin passwords the migrations used to carry, so this is the only thing that opens the admin console. Set it **before** deploying, or the console is shut until you do. |
| `DEMO_ENABLED`, `DEMO_PASSWORD` | Off by default, and the seeder refuses to run without a password. This is the account App Review signs in with. |
| `DEMO_TRY_ENABLED` | On by default. Backs "Try the demo" on the sign-in screen: each tap opens a separate `[Demo] Agency` with sample records, rate-limited per address and deleted after 24 hours. It never sends email. `false` hides it behind a 404, and the app then says the demo is unavailable. |
| `APP_SUPPORT_EMAIL`, `APP_OPERATOR_NAME` | Default to `support@estatecrm.app` / `EstateCRM`, both printed on the privacy and support pages a reviewer opens. |
| `DOCUMENTS_STORAGE` | Defaults to `database`. `s3` moves the bytes to a bucket and needs the `S3_*` variables with it — the right answer once attachments are photographs rather than contracts, since the database's own size limit is the ceiling otherwise. Set it to `filesystem` only where a real volume is mounted, and point `DOCUMENTS_DIR` at that mount — on a container host with no disk, anything written to the filesystem is gone on the next deploy or wake from sleep. |

## The account App Review signs in with

Anyone can sign up now, so a reviewer *could* make their own account — but a new
account lands on an empty agency it has just created, or on a screen waiting for
a manager to add it. Neither shows the app. **App Review Information must carry
working credentials** or Guideline 2.1 is decided on a blank screen.

Do not hand over an account on the agency's own records — a reviewer would be
reading real clients' names and phone numbers. `DemoDataSeeder` creates a
separate one instead: an ordinary agent on own-data scope, in a team of its own
(`[Demo] Agency`), whose only records are six clients, five listings, five deals
(one per pipeline column) and four meetings that it seeds itself. A team is the
wall between agencies, so the real ones cannot see these records and the reviewer
cannot see theirs.

### Turning it on

It has to run against production, because that is the host the submitted build
talks to. On Render, that is the service's **Environment** tab:

```ini
DEMO_ENABLED=true
DEMO_PASSWORD=<something long, this is a real password on a real host>
# Optional; these are the defaults.
DEMO_EMAIL=reviewer@demo.estatecrm.app
DEMO_FULL_NAME=App Review
```

Saving restarts the service. Read the log afterwards — it says what it created,
or why it refused. With no `DEMO_PASSWORD` it declines rather than putting a
guessable account on a live deployment. (On a self-hosted deployment the same
values go in `.env`, which `docker-compose.prod.yml` forwards whole.)

Then verify on a real device, signed in as that account:

- The dashboard, clients, properties, deals and meetings all have content.
- Profile → Delete account completes and returns to the sign-in screen.
- Profile → Privacy Policy and Support both open.

Deletion is real, so recreate the account afterwards: delete it from the admin
console if it is still there, then restart with `DEMO_ENABLED=true`. Re-running
clears the previous set first, so this can happen as many times as review takes.

Put the credentials in the App Review notes, with a line explaining that signing
up creates an empty agency, so the demo account is the one that shows the app.

### If a reviewer signs up anyway

Worth knowing, because they may: sign-up asks for a role, then Firebase emails a
link that has to be opened before the account works. That means the Firebase
key on the submission host (`FIREBASE_CREDENTIALS_PATH`). Once in, a manager lands
on "create your agency", an agent on a screen waiting to be added to one. Neither
shows the app, which is why the notes have to point at the demo account.

### Afterwards

Set `DEMO_ENABLED=false` and restart once the app is approved. Then delete the
demo account from the admin console; its records are labelled `[Demo]` and sit on
the `@demo.estatecrm.app` email domain, so they are easy to find. "Try the demo"
agencies carry the same markers, on `demo-…` addresses, and delete themselves
within a day.

## The listing has to read like a product

The backend has no tenancy: one deployment is one agency, and the app is built
against one host. Apple rejects apps that only work for one company's staff and
points them at Custom Apps in Apple Business Manager, usually citing Guideline
4.2. What keeps a submission on the right side of that is the listing describing
software agencies buy, not one agency's internal tool.

So, in App Store Connect:

- Name and subtitle should say what it is for the category, not for the client —
  "CRM for real-estate agencies", not the agency's own name.
- The description addresses agencies generally: what an agent, a manager and an
  administrator each get out of it.
- No agency's branding, logo or name anywhere in the icon, screenshots or copy.
- Nothing in the copy implies a closed audience: avoid "for our staff", "internal".
- The support page should read as product support, which
  `LegalController.support()` already does.

If it really is going to serve one agency only, the honest route is a Custom App
through Apple Business Manager rather than a public listing — private
distribution, and this whole question disappears.

## The App Store Connect form

- **Privacy questionnaire** — the answers have to match
  `mobile/ios/Runner/PrivacyInfo.xcprivacy`: name, email address, phone number,
  photographs and user content, all linked to the user, all for app
  functionality, none for tracking. Add one more: **Identifiers → Device ID**,
  for app functionality, not used for tracking. Firebase Cloud Messaging
  collects it (its own privacy manifest declares it, and App Store Connect
  merges the SDKs' manifests into the report it shows you), and the answers
  must not contradict that report.
- **Privacy policy URL** — `https://<host>/api/privacy`. It must resolve before
  review starts, and the `/api` is not a typo: the backend is mounted under a
  servlet context path, so the root copy of that path does not exist. Check it
  with `curl -sI` before pasting it in.
- **Support URL** — `https://<host>/api/support`, for the same reason.
- **Screenshots** — 6.9" and 6.5" iPhone only, since the app ships iPhone-only.
  Portrait.
- **Export compliance** — "No" to non-exempt encryption, matching the plist.

## Before the build goes up

- `app.support-email` and `app.operator-name` are what `LegalController` prints
  on both pages. They default to `support@estatecrm.app` / `EstateCRM`. Set them
  to something real — a reviewer may write to that address.
- **The privacy policy is out of date, and has to be fixed first.**
  `LegalController.privacy()` still says "there is no public sign-up" and that
  accounts are created by an administrator — the sign-up screen that links to it
  says otherwise — and it does not name Firebase (Google), which receives the
  e-mail address at sign-up and a device identifier for push. A policy that
  contradicts the app is a 5.1.1(i) rejection. Rewrite it for open sign-up and
  list Firebase as a processor. It has not been through a lawyer either.
- Universal Links are off: the Associated Domains entitlement was dropped so
  the app could be signed by the free team, and invite links open the app
  through the `estatecrm://` scheme instead. Not a rejection. To bring them
  back on the paid team, add the capability with `applinks:` for the API host,
  and see `invite-deep-link-deploy.md` for the root rewrite the association
  file needs.
- The backend host is baked in as `estate-crm-system.onrender.com` as the
  fallback when Remote Config has no `api_base_url`. It is also what
  `WellKnownController` signs the association file for. If that host ever
  changes, both change together, and `API_BASE_URL` is overridable at build
  time:

  ```sh
  fvm flutter build ipa --dart-define=API_BASE_URL=https://api.example.com/api
  ```
