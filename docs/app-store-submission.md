# Submitting the iOS app

The build is ready and so is the account App Review signs in with. Production is
not: it is running an older backend than the one the app is built against, and
that has to be fixed before any of the rest of this is worth doing. After that,
what is left is one switch to throw on the host and the part App Store Connect
asks a person for.

## Already handled in the build

Verified against `build/ios/iphoneos/Runner.app`, not just read off the source:

- **No undeclared permissions.** `file_picker` used to compile its media and
  audio pickers in, which put `PHPhotoLibrary`, `PHAssetCreationRequest`,
  `PHPickerViewController`, `UIImagePickerController` and
  `MPMediaPickerController` in the binary. App Store Connect scans for exactly
  those and refuses the upload with **ITMS-90683** unless `Info.plist` declares a
  purpose string for each. The app only ever picks documents, so both pickers are
  now compiled out in `mobile/ios/Podfile` — four embedded frameworks gone with
  them, and no symbol left for the scanner to find.
- **Account deletion, in the app.** Profile → Delete account, with a successor
  picker for the records that belong to the agency rather than to the person
  (Guideline 5.1.1(v)).
- **Privacy policy and support pages**, served by the backend at `/privacy` and
  `/support`, public so a reviewer reaches them without signing in, and linked
  from the profile screen.
- **`PrivacyInfo.xcprivacy`**, declaring the contact data collected, no tracking,
  and `CA92.1` for `shared_preferences`' use of `NSUserDefaults`.
- **iPhone-only, portrait-only**, matching the layouts that are actually tested.
- **`ITSAppUsesNonExemptEncryption` = false** — the app only uses HTTPS and the
  Keychain, both exempt.

## Deploy the backend first

The submitted build talks to production, and production is behind the
repository. Checked against the live OpenAPI, it is missing `DELETE /auth/me` —
the endpoint behind "Delete account" — along with `/search`,
`/deals/{dealId}/documents`, `/privacy` and `/support`. A reviewer following
Guideline 5.1.1(v) would tap Delete account and get a 405.

Nothing else in this document works until that is fixed, the demo seeder
included — it ships in the same build. Redeploy, then confirm:

```sh
curl -s https://estate-crm-system.onrender.com/api/v3/api-docs \
  | python3 -c "import json,sys; p=json.load(sys.stdin)['paths']; \
      print([k for k in ('/privacy','/support','/search','/auth/me') if k in p])"
# expect all four, and /auth/me carrying a delete verb

curl -sI https://estate-crm-system.onrender.com/api/privacy   # expect 200
```

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
talks to. On the VM, add to `.env` — `docker-compose.prod.yml` forwards the whole
file, so nothing else has to be edited:

```ini
DEMO_ENABLED=true
DEMO_PASSWORD=<something long, this is a real password on a real host>
# Optional; these are the defaults.
DEMO_EMAIL=reviewer@demo.estatecrm.app
DEMO_FULL_NAME=App Review
```

Restart the container and read the log — it says what it created, or why it
refused. With no `DEMO_PASSWORD` it declines rather than putting a guessable
account on a live deployment.

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

Worth knowing, because they may: sign-up asks for a role, then mails a six-digit
code that has to be typed before the account works. That means `MAIL_ENABLED=true`
with working SMTP credentials on the submission host — with mail off, a reviewer
who tries to register is stuck on a code that was never sent, and the demo
credentials will not save the review if they never reach the sign-in screen again.

### Afterwards

Set `DEMO_ENABLED=false` and restart once the app is approved. Then delete the
demo account from the admin console; its records are labelled `[Demo]` and sit on
the `@demo.estatecrm.app` email domain, so they are easy to find and are the only
things that carry those markers.

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
  `mobile/ios/Runner/PrivacyInfo.xcprivacy`: name, email address, phone number
  and user content, all linked to the user, all for app functionality, none for
  tracking. Nothing else is collected.
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
- The privacy text is a working draft written against what the app actually
  collects, and has not been through a lawyer. Read it before you submit.
- Universal Links do not work yet: the entitlement claims the domain but the
  association file is not served where Apple fetches it. Not a rejection —
  invite links fall back to the custom scheme — but see
  `invite-deep-link-deploy.md` for the one proxy rule that fixes it.
- The backend host is baked in as `estate-crm-system.onrender.com`. It is also
  what `Runner.entitlements` claims for Universal Links and what
  `WellKnownController` signs the association file for. If that host ever
  changes, all three change together, and `API_BASE_URL` is overridable at build
  time:

  ```sh
  fvm flutter build ipa --dart-define=API_BASE_URL=https://api.example.com/api
  ```
