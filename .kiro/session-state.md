# Session state — Sawad Finnix

> Working notes so the next session can resume quickly. Last updated:
> 2026-06-20. Branch: `main` (pushing to `main` auto-deploys UAT hosting).

## How to resume

1. `flutter pub get`
2. Verify gate (run before every push — CI deploys UAT from `main`):
   ```bash
   flutter analyze lib        # expect only 2 pre-existing infos in phone_page.dart
   flutter test               # 11 tests
   flutter build web --release --dart-define=ENV=uat
   ```
3. Commit + push to `main` after each change (user's workflow: push = UAT deploy).

## What was built this session (commits, newest first)

- `e4f6ff3` Loan lifecycle: approval → home loan card → detail → pay → QR save → deduct.
- `4191e46` Group statement files by `requestId`; persist `requestId` on the request doc.
- `5d3c5e6` PIN/biometric login, functional loan-request, Firebase Storage uploads
  (also included earlier uncommitted login-session work).

## Feature status (all verified by analyze/test/web-build, NOT on a device)

- [x] Returning-user **PIN + biometric** login (`splash_page`, `pin_login_page`,
      `biometric_service`). Biometric-first when enabled; prompt-to-enable; PIN
      fallback. Profile re-fetched from Firestore on login.
- [x] **Loan request** fully functional: profile-driven ID step, controllers,
      dropdowns, per-step validation, summary review, Firestore persist
      (`loan_repository`).
- [x] **Device permissions** step requests real OS permissions
      (`core/permissions/app_permissions.dart` + `permission_handler`).
- [x] **Statement upload** to Firebase Storage (`storage_repository`, `file_picker`),
      grouped per `requestId`, links saved on the request doc.
- [x] **Loan lifecycle**: mock approval (`loan.dart`, `loan_account_repository`),
      home loan card, detail, pay (installment/custom), QR **save to gallery**
      (`gal`), simulated success **deducts** installment, receipt.

## Key conventions / decisions

- **State**: single `AppState` ChangeNotifier singleton (`AppState.instance`),
  provided via `provider`. Now also holds `activeLoan`, `pendingPaymentAmount`,
  `applyPayment()`. Use `AppState.instance` in async/non-widget code (avoids
  BuildContext-across-async lint).
- **IDs**: Firestore docs keyed by `sha256(thaiId)` via `ThaiId.hash`. Loan +
  loanRequest share the same generated `requestId`.
- **Loan math** lives in app state (single source of truth for UI); Firestore
  writes for loans/payments are **best-effort** (try/catch, never block UX) so
  the demo works even if Firestore rules block subcollection writes.
- **Platform graceful-degradation**: `AppPermissions` marks iOS sms/phone-state
  and web as `unsupported`; `gal` save guarded by `kIsWeb`; secure storage
  errors in `SplashPage` fall back to onboarding (also keeps widget test green).
- **Deps added this session**: `local_auth ^2.3.0`, `permission_handler ^11.3.1`,
  `firebase_storage ^12.3.7`, `file_picker ^8.1.4`, `gal ^2.3.0`.
- **Native config touched**: Android `MainActivity` → `FlutterFragmentActivity`;
  AndroidManifest perms (USE_BIOMETRIC, READ_CONTACTS, FINE/COARSE_LOCATION,
  READ_PHONE_STATE, READ_SMS, WRITE_EXTERNAL_STORAGE maxSdk29, ACCESS_MEDIA_LOCATION,
  requestLegacyExternalStorage); iOS Info.plist (NSFaceIDUsageDescription,
  NSContactsUsageDescription, NSLocationWhenInUseUsageDescription,
  NSPhotoLibraryAddUsageDescription).

## Open follow-ups (good next tasks)

1. **Firestore security rules** — user only provided Storage rules. Add rules for
   `users/{id}`, `users/{id}/loanRequests/{*}`, `users/{id}/loans/{*}/payments/{*}`.
   Without them, the best-effort writes silently fail (UI still works).
2. **Tighten Storage rules** to per-owner paths (currently any authed user).
3. **Custom-token auth** — bind the Firebase session to the verified identity
   (uid = `sha256(thaiId)`). Needs a backend (Admin SDK) to mint tokens; client
   swap is `signInWithCustomToken`. No backend yet.
4. **Loan amount/term selection** in the request so approval isn't a fixed mock
   (currently 30,000 @ 28% / 12mo flat in `Loan.approved`).
5. **On-device QA**: biometric prompt, OS permission dialogs, file picker,
   Storage upload, gallery save — none run on a real device yet.
6. **iOS App Store**: add permission_handler Podfile macros to strip unused
   permissions; Play Store needs SMS/contacts declarations.
7. Optional: CI gate running `flutter analyze` + `flutter test` before the
   deploy job so a broken commit never reaches UAT.

## Gotchas

- `widget_test.dart` mocks secure storage (`FlutterSecureStorage.setMockInitialValues({})`)
  and expects boot → splash → phone onboarding. Keep that if you touch the splash gate.
- `DropdownButtonFormField` uses `initialValue` (not `value`) on this Flutter version.
- App boots at `/` (`SplashPage`); deep link `/onboarding/success` still works.
