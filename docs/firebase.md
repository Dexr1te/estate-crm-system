# Firebase

One Firebase project, `estatecrm-3e55a`, serves the whole product. It does three
separate jobs, and only the first one involves the backend:

| Job | Who talks to Firebase | Where it lives |
| --- | --- | --- |
| Email verification at sign-up | backend (Admin SDK) and the app (`firebase_auth`) | [`backend/README.md`](../backend/README.md#firebase), [`FirebaseIdentityService`](../backend/src/main/java/com/crm/realestate/service/FirebaseIdentityService.java) |
| Remote Config: addresses the app reads at run time | the app only | [`mobile/lib/core/config/remote_config.dart`](../mobile/lib/core/config/remote_config.dart) |
| Cloud Messaging: push notifications | the app only; messages are sent from the Firebase Console | [`mobile/lib/core/notifications/`](../mobile/lib/core/notifications/) |

The backend does not send push notifications.
`backend/.../FirebaseNotificationService.java` exists but nothing calls it.

---

## Contents

- [Project and apps](#project-and-apps)
- [Remote Config](#remote-config)
- [Cloud Messaging](#cloud-messaging)
- [Console checklist](#console-checklist)
- [Verifying it end to end](#verifying-it-end-to-end)
- [iOS push, once there is a paid Apple team](#ios-push-once-there-is-a-paid-apple-team)
- [Troubleshooting](#troubleshooting)

---

## Project and apps

| Platform | Bundle / package | App ID | Config file |
| --- | --- | --- | --- |
| Android | `com.sultan.estatecrm` | `1:672413418618:android:409ea634fb6cfe5466e7c3` | [`mobile/android/app/google-services.json`](../mobile/android/app/google-services.json) |
| iOS | `com.sultan.estatecrm` | `1:672413418618:ios:4c7155052e7bbb3b66e7c3` | [`mobile/ios/Runner/GoogleService-Info.plist`](../mobile/ios/Runner/GoogleService-Info.plist) |

The app initialises Firebase from [`lib/firebase_options.dart`](../mobile/lib/firebase_options.dart)
in `main.dart`. If that fails (no network on a first start, a misconfigured
build), the app still starts: every Firebase feature has a fallback and logs why
it is off.

Android also applies the `com.google.gms.google-services` Gradle plugin. It
reads `google-services.json`, so the native Firebase SDK is up before any Dart
code runs. FCM needs that when a push arrives while the app is not running at
all. The values in the JSON and in `firebase_options.dart` are the same app.
If the app is ever re-registered, regenerate all three files with
`flutterfire configure`.

The client config files are committed on purpose. They identify the app, and
they are not secrets. The backend's service-account key
(`backend/firebase-service-account.json`) is a secret and is gitignored.

---

## Remote Config

The app reads three string parameters. Each has a built-in default that is
identical to what the app shipped with before Remote Config existed, so an empty
or missing Remote Config changes nothing.

| Key | Default | Controls | Accepted when |
| --- | --- | --- | --- |
| `api_base_url` | `https://estate-crm-system.onrender.com/api` | every API request, plus the Privacy and Support pages | `https://`, has a host. A trailing `/` is dropped. Must include the `/api` context path |
| `map_tile_url` | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` | where map tiles come from | `https://` and contains `{z}`, `{x}` and `{y}` |
| `map_attribution` | `© OpenStreetMap contributors` | the credit in the map's corner | not blank |

A value that is not accepted is ignored and the default is used, so a typo
cannot point the app at plain HTTP or at a tile URL with no coordinates. A
build made with `--dart-define=API_BASE_URL=...` ignores `api_base_url` from
Firebase. That keeps a local or staging build pinned where its developer
pointed it.

### When a change reaches a phone

1. **At launch** the values fetched on the previous run are applied before the
   first request. It is a local read, so start-up does not wait for the network.
2. **Right after launch** a fetch runs in the background. Release builds fetch
   at most once an hour; debug builds fetch on every launch. New values are
   applied the moment the fetch lands.
3. **While the app is open** the realtime listener (`onConfigUpdated`) applies a
   published change within seconds.

Applying a value updates `ApiEndpoint.baseUrl`, the base URL of both Dio
clients (`ApiClient.useBaseUrl`), `MapTiles.urlTemplate` and
`MapTiles.attribution`. Requests already in flight finish against the old
address.

### Moving the backend

1. Bring the new host up and check `https://new-host/api/swagger-ui.html`.
2. Keep the old host running.
3. Publish `api_base_url = https://new-host/api`.
4. Shut the old host down once the old address stops getting traffic. Phones
   that were offline catch up on their next launch.

Anyone who can publish Remote Config can redirect the app's traffic, bearer
tokens included. Keep edit access to the Firebase project to people you trust.

### Code

| Piece | File |
| --- | --- |
| Keys, defaults, validation (`RemoteSettings`) | [`core/config/remote_config.dart`](../mobile/lib/core/config/remote_config.dart) |
| Firebase source (`FirebaseRemoteConfigSource`) and the sync that applies values (`RemoteConfigSync`) | same file |
| Wiring: started in `Injector.bootstrap()` | [`core/di/injector.dart`](../mobile/lib/core/di/injector.dart) |
| Mutable base URL (`ApiEndpoint`, `ApiClient.useBaseUrl`) | [`core/network/api_client.dart`](../mobile/lib/core/network/api_client.dart) |
| Tests | [`test/remote_config_test.dart`](../mobile/test/remote_config_test.dart) |

To add a parameter: add its key to `RemoteKeys`, a field and its validation to
`RemoteSettings`, its default to `RemoteSettings.defaults`, apply it in
`RemoteConfigSync._apply`, and cover the rejection cases in the test.

---

## Cloud Messaging

Pushes are composed in the Firebase Console and sent to **topics**. The app
keeps its own subscriptions in step with who is signed in and which language
the app is in.

### Topics

| Topic | Subscribed while |
| --- | --- |
| `all` | always, signed in or not |
| `lang_en`, `lang_ru`, `lang_kk` | the app is in that language; switching language moves the subscription |
| `role_agent`, `role_manager`, `role_admin` | someone with that role is signed in; signing out leaves it |

The set the device is subscribed to is remembered in `SharedPreferences`
(`push_topics`), so a topic from an earlier run that no longer applies is
unsubscribed, not left behind. A subscription that fails, for example offline,
is tried again on the next sign-in, sign-out or language change.

Topics are not access-controlled: any client can subscribe to any topic. Send
announcements, never a client's or a deal's details.

### Permission

The notification permission is requested once per run, the first time
somebody is signed in. On iOS it is the same prompt the meeting reminders use.
Nobody is asked on the sign-in screen.

### What a push can carry

Set these under **Additional options → Custom data** in the campaign:

| Key | Value | Effect of a tap |
| --- | --- | --- |
| `route` | an in-app path starting with `/`, e.g. `/tasks`, `/deals/12`, `/clients/34`, `/properties/56`, `/meetings`, `/notifications` | opens that screen once the session is known and the PIN lock is open; ignored when nobody is signed in. A shell tab (`/dashboard`, `/clients`, `/properties`, `/deals`, `/meetings`, `/admin`, `/team-console`) is switched to; anything else is pushed on top |
| `url` | an `https://` link | opens in the browser, signed in or not. Wins over `route` when both are set |

Anything else is ignored. `//host` paths and non-https links are rejected.

### How it shows

| App state | What the person sees |
| --- | --- |
| Not running, or in the background | the system notification. On Android it goes to the **Activity** channel (`activity`, high importance); a tap opens the app and then the `route` or `url` |
| On screen | an in-app banner at the bottom with the title and body, and **Open** when there is somewhere to go. No system notification, on either platform |

### Debug token

Debug builds print the device's FCM token after sign-in:

```text
[push] FCM token: dXk2...
```

Paste it into **Send test message** in a campaign to reach just that device.
Release builds never print it.

### Code

| Piece | File |
| --- | --- |
| `PushMessage` (`route`, `link`, `hasText`), `PushGateway`, `FirebasePushGateway`, the Android channel | [`core/notifications/push_gateway.dart`](../mobile/lib/core/notifications/push_gateway.dart) |
| `PushHandler` (topics, permission, opening), `openPushRoute`, `showPushBanner`, `PushLanguage` | [`core/notifications/push_handler.dart`](../mobile/lib/core/notifications/push_handler.dart) |
| Wiring | [`my_app.dart`](../mobile/lib/my_app.dart), `Injector.pushGateway` |
| Default channel for FCM | `com.google.firebase.messaging.default_notification_channel_id` in [`AndroidManifest.xml`](../mobile/android/app/src/main/AndroidManifest.xml) |
| Tests | [`test/push_handler_test.dart`](../mobile/test/push_handler_test.dart) |

`PushHandler` follows the same pattern as `DeepLinkHandler` and
`ShortcutHandler`: a tapped push waits until `AuthBloc.isSessionResolved` and
the app lock (`LaunchGate`) is open, then opens once.

---

## Console checklist

| Where | What |
| --- | --- |
| Firebase → Project settings → Cloud Messaging | **Firebase Cloud Messaging API (V1)** is Enabled |
| Firebase → Remote Config | the three parameters above, type String, no conditions, **Publish changes** |
| Google Cloud → APIs & Services → Credentials | if the Android or iOS key (auto created by Firebase) has API restrictions, they include Firebase Installations API, FCM Registration API, Firebase Remote Config API and Firebase Remote Config Realtime API |
| Firebase → Project settings → Users and permissions | only trusted people can edit; Remote Config decides where the app sends its traffic |
| Google Play → Data safety | "Device or other IDs", for app functionality (FCM token, Firebase Installation ID) |
| App Store Connect → App Privacy | "Device ID", app functionality, not linked to identity, not used for tracking |

---

## Verifying it end to end

**Remote Config**

1. Open a screen with a map.
2. Publish `map_attribution = © test`. The credit changes within seconds.
3. Publish it back to `© OpenStreetMap contributors`. OpenStreetMap requires it.

**Push (Android)**

Use a device or an emulator with a **Google Play** image; a "Google APIs" image
has no Play services and gets no token.

1. `cd mobile && .fvm/flutter_sdk/bin/flutter run -d <device>`, sign in, allow
   notifications, copy the `[push] FCM token` line.
2. Messaging → New campaign → Firebase Notification messages → title and text
   → **Send test message** → paste the token.
3. Try it with the app closed, in the background and on screen.
4. Add custom data `route = /tasks`, send again, tap: the tasks screen opens.
5. Send a campaign to the topic `all`. A fresh subscription can take a few
   minutes to receive its first message.

---

## iOS push, once there is a paid Apple team

The project signs with a free personal team (`9746P6DV47`), and a personal team
cannot carry the `aps-environment` entitlement. Adding it stops Xcode from
producing a provisioning profile, so no device build installs. Until then iOS
has no APNs token: `token()` returns null, topic calls fail and are logged, and
everything else, Remote Config included, works.

When the app moves to a paid team:

1. developer.apple.com → Keys → new key with **Apple Push Notifications service
   (APNs)** → download the `.p8`, note the Key ID and the Team ID.
2. Firebase → Project settings → Cloud Messaging → Apple app configuration →
   **APNs Authentication Key** → upload the `.p8` with both IDs.
3. In Xcode, switch signing to the paid team and add the **Push Notifications**
   capability. That writes `aps-environment` to `Runner.entitlements`.

No Dart change is needed.

---

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| No `[push] FCM token` line | not signed in, a release build, iOS without APNs, or an emulator without Google Play | sign in on a debug build on a Google Play image |
| `[push] topics not updated` in the log | offline, or iOS without an APNs token | Android: it retries on the next sign-in, sign-out or language change. iOS: expected until push is set up |
| A test message never arrives | notifications denied in system settings, or a stale token after reinstalling | allow notifications for EstateCRM, relaunch, take the new token |
| A topic campaign never arrives | the app has not been opened since it was installed, or the subscription has not propagated | open the app once, wait a few minutes, send again |
| A tap does not open the screen | nobody signed in, `route` does not start with `/`, or no such route | check the path against `core/utils/router.dart` |
| A Remote Config change does not apply | not published, rejected by validation, or a build with `--dart-define=API_BASE_URL` | publish, fix the value, or rebuild without the define |
| The app stops loading data | `api_base_url` points at a live but wrong host | publish the previous value; open apps pick it up within seconds |
| `[remote-config] ... unavailable` in a test run | tests have no Firebase | expected; the tests use fake sources |
