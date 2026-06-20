# Sawad Finnix

A Flutter lending app: ThaiID onboarding, PIN/biometric sign-in, a multi-step
loan request, and a full loan repayment lifecycle. Backed by Firebase
(Auth + Firestore + Storage) with prod/uat environments and CI auto-deploy to
Firebase Hosting.

## Tech stack

- **Flutter** 3.38.5 (Dart 3.10)
- **State**: `provider` (single global `AppState` singleton)
- **Routing**: `go_router`
- **Firebase**: `firebase_core`, `firebase_auth` (anonymous), `cloud_firestore`,
  `firebase_storage`
- **Device/UX**: `local_auth` (biometrics), `permission_handler`,
  `file_picker`, `gal` (save to gallery), `qr_flutter`, `flutter_secure_storage`

## Environments

Selected at build time via `--dart-define=ENV=uat|prod` (defaults to `uat`).
Config lives in `lib/core/config/env_config.dart` (per-service base URLs) and
`lib/firebase_options_*.dart`.

- **uat** → Firebase project `sawad-finnix-uat`
- **prod** → Firebase project `sawad-finnix`

## Run locally

```bash
flutter pub get
flutter run --dart-define=ENV=uat        # mobile
flutter run -d chrome --dart-define=ENV=uat   # web
```

## Verify

```bash
flutter analyze lib
flutter test
flutter build web --release --dart-define=ENV=uat
```

(Current known analyzer infos: 2 pre-existing in `lib/features/auth/pages/phone_page.dart`.)

## CI / Deploy

`.github/workflows/deploy.yml`:

- **UAT** auto-deploys Firebase Hosting on **every push to `main`** (there is no
  `uat` branch — `main` is the UAT line).
- **PROD** deploys on a `v*` tag or a manual `workflow_dispatch` with
  `environment=prod`.

So: **push to `main` → UAT site rebuilds and deploys.**

## App flows

### 1. Onboarding & auth
`phone → otp → thaid-info → thaid-verify (deep link) → success → set-pin → home`

- OTP verified client-side against the send-OTP response.
- ThaiID verification via deep link `sawadfinnix://sawadfinnix.com/onboarding/success`.
- Profile upserted to Firestore `users/{sha256(thaiId)}`; an **anonymous**
  Firebase Auth session backs Firestore/Storage access.
- 6-digit PIN hashed (SHA-256, salted by Thai ID) and stored on-device via
  `flutter_secure_storage`. Never written to Firestore.

### 2. Returning-user sign-in (second app open)
`splash → pin-login → home`

- `SplashPage` routes to **pin-login** if a local PIN exists, else onboarding.
- **PIN + biometric**. When biometrics are enabled they are the first prompt
  (auto), with PIN fallback. If available but not enabled, the user is prompted
  to turn them on. On success the profile is **re-fetched from Firestore** so
  `AppState` reflects server-side changes.

### 3. Loan request (multi-step)
`/loan/request` — profile-driven, validated, persisted.

Steps: device permissions → ID card (from ThaiID profile) → personal info →
contacts → statements (upload) → bank → summary + consents.

- **Device permissions** request real OS permissions (`permission_handler`):
  contacts, phone-state (device info), location, SMS. Graceful on iOS
  (no SMS/phone-state) and web. Permanently-denied → opens app settings.
- **Statement upload** to Firebase Storage at
  `loan_statements/{sha256(thaiId)}/{requestId}/{ts}_{file}` with progress and
  delete. PDF/PNG/JPG, 10 MB/file.
- **Submit** writes all fields to Firestore
  `users/{sha256(thaiId)}/loanRequests/{requestId}` (including the statement
  file links and the document's own `requestId`).

### 4. Loan lifecycle (mock approval)
On submit the request is **auto-approved** into an active loan, then:

`home loan card → loan detail → payment channels → pay → QR → receipt`

- **Approval (mock)**: 30,000 THB, 28%/yr, 12 installments, flat interest
  (38,400 total, 3,200/mo). Persisted best-effort to
  `users/{sha256(thaiId)}/loans/{loanId}` (loanId = requestId).
- **Home**: shows outstanding balance, progress (`paid/term`), installment,
  next due date; buttons to detail and payment.
- **Detail**: applicant + masked ID, per-month schedule, principal/interest,
  amount paid.
- **Payment**: pay the installment or a custom amount (capped at outstanding).
- **QR**: real amount; **save QR image to the photo gallery** (`gal`);
  "simulate success" deducts the payment, advancing installments and closing the
  loan at zero.
- **Receipt**: real paid amount + remaining balance + status.

## Project structure

```
lib/
  core/
    config/        env_config.dart (prod/uat, per-service endpoints)
    firebase/      firebase_init.dart
    network/       api_client.dart (Dio per service)
    permissions/   app_permissions.dart (permission_handler wrapper)
    router/        app_router.dart, app_routes.dart
    security/      pin_service.dart, biometric_service.dart
    state/         app_state.dart (global ChangeNotifier singleton)
    theme/         app_theme.dart (brand: #db771a / text #003063 / bg #fcefe4)
    utils/         thai_id.dart, formatters.dart
    widgets/       app_scaffold.dart, placeholder_page.dart
  features/
    auth/
      data/        auth_repository.dart, user_repository.dart
      models/      user_profile.dart, thaid_status.dart, auth_responses.dart
      pages/       phone, otp, thaid_*, onboarding_success, set_pin,
                   splash, pin_login
    home/
      models/      loan_summary.dart
      pages/       home_page.dart
    loan/
      data/        loan_repository.dart, loan_account_repository.dart,
                   storage_repository.dart
      models/      loan_request.dart, loan.dart, uploaded_file.dart
      pages/       loan_request, loan_detail, payment_channels, pay_loan,
                   payment_qr, receipt
```

## Firestore / Storage layout

```
users/{sha256(thaiId)}                      profile (uid = anon auth uid)
users/{sha256(thaiId)}/loanRequests/{id}    full request + statement links
users/{sha256(thaiId)}/loans/{loanId}       approved loan
users/{sha256(thaiId)}/loans/{loanId}/payments/{id}
Storage: loan_statements/{sha256(thaiId)}/{requestId}/{ts}_{file}
```

## Known limitations / follow-ups

- **Auth is anonymous.** Tokens are real but not bound to identity; binding
  needs a backend that mints Firebase **custom tokens** (no backend yet).
- **Firestore rules**: only Storage rules were provided. The `loanRequests` /
  `loans` subcollection writes need matching Firestore rules; loan/payment math
  is kept in app state so the demo works regardless.
- **Storage rules** currently allow any authenticated user full access — tighten
  to per-owner paths before release.
- **Loan approval is a fixed mock** (amount/rate/term constants); the request
  doesn't capture a requested amount yet.
- **On-device behaviors not yet run by the author**: biometric prompt, real OS
  permission dialogs, file picker, Storage upload, and gallery save are verified
  by compile/analysis/web-build and logic — not a live device run.
- **App Store/Play**: SMS/contacts/location/phone permissions need store
  declarations; iOS would want permission_handler Podfile macros to strip unused
  permissions.
```
