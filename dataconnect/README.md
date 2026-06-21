# Firebase Data Connect — case study

A relational (PostgreSQL on Cloud SQL) modeling of Sawad Finnix, alongside the
existing Firestore implementation. Firestore remains the live datastore for the
app; this is a parallel relational design.

**Status (validated against UAT):**
- ✅ Wired into `firebase.json` (`"dataconnect": { "source": "dataconnect" }`).
- ✅ Schema + connector **compile cleanly** against the real UAT service
  `sawad-finnix-uat-service` (`firebase dataconnect:compile` → exit 0).
- ✅ Typed Dart SDK **generated** into `lib/dataconnect_generated/default/`.
- ⛔️ **DB schema NOT migrated** — no tables have been created in the Cloud SQL
  instance, and the connector is **not deployed**. The app still uses Firestore
  exclusively. Creating tables is a deliberate step (see below).

Real UAT service it targets:
- Service: `sawad-finnix-uat-service` (location `asia-southeast1`)
- Cloud SQL instance: `sawad-finnix-uat-instance`
- Database: `sawad-finnix-uat-database`

## Layout

```
dataconnect/
  dataconnect.yaml          # service: region, Cloud SQL instance, Postgres db
  schema/
    schema.gql              # @table types -> Postgres tables
  connector/
    connector.yaml          # connector id + Dart SDK codegen target
    queries.gql             # the only reads the app may call
    mutations.gql           # the only writes the app may call
```

## Firestore → relational mapping

| Firestore (live today)                         | Data Connect table        |
|------------------------------------------------|---------------------------|
| `users/{sha256(thaiId)}`                       | `User` (key = `id`)       |
| `users/../loanRequests/{id}`                   | `LoanRequest` (FK `user`) |
| &nbsp;&nbsp;embedded `contacts[]`              | `LoanContact` (FK `request`) |
| &nbsp;&nbsp;embedded `statements[]`            | `StatementFile` (FK `request`) |
| `users/../loans/{loanId}`                      | `Loan` (key = `id`, FK `user`) |
| `users/../loans/{loanId}/payments/{id}`        | `Payment` (FK `loan`)     |

The big structural change: Firestore **embeds** `contacts` and `statements` as
arrays inside the request document. Relationally those become **child tables**
with foreign keys — independently queryable, indexable, and joinable.

## Why this maps well to a lending app

- **Joins**: "request + its contacts + its statement files" in one query
  (`GetLoanRequestDetail`) instead of unpacking embedded arrays client-side.
- **Aggregates**: `LoanPaymentSummary` does server-side `SUM`/`COUNT`/`MAX` —
  Firestore needs extra reads or a counter doc for this.
- **Atomic multi-write**: `RecordPayment` inserts a `Payment` *and* updates the
  `Loan` in one operation. The current `LoanAccountRepository.pay` does two
  separate Firestore writes that can partially fail.

## Operation ↔ current code mapping

| Operation (this connector) | Current Firestore code |
|----------------------------|------------------------|
| `UpsertUser`               | `UserRepository.saveThaidProfile` / `saveProfile` |
| `GetUser`                  | `UserRepository.loadProfileByThaiId` |
| `CreateLoanRequest` + `AddLoanContact` + `AddStatementFile` | `LoanRepository.submit` (one doc + embedded arrays) |
| `ApproveLoan`              | `LoanAccountRepository` mock approval (`Loan.approved`) |
| `GetActiveLoan`            | `LoanAccountRepository.loadActiveLoan` |
| `RecordPayment`            | `LoanAccountRepository.pay` (set + payments.add) |
| `GetLoanWithPayments`      | loan detail + payment history |

## How it would plug into Flutter (illustrative)

`firebase dataconnect:sdk:generate` produces a typed Dart client. A repository
would then look like (pseudo, not added to `lib/`):

```dart
import 'package:default_connector/default_connector.dart';

final connector = DefaultConnector.instance;

// Read the active loan (replaces LoanAccountRepository.loadActiveLoan)
final res = await connector.getActiveLoan(userId: sha256ThaiId).execute();
final loan = res.data.loans.firstOrNull;

// Pay (replaces the two-write LoanAccountRepository.pay)
await connector.recordPayment(
  loanId: loan.id,
  amount: amount,
  outstandingAfter: updated.outstandingBalance,
  installmentsPaid: updated.installmentsPaid,
  newPaidAmount: updated.paidAmount,
  status: updated.status,
).execute();
```

## How to run it (commands that work today)

```bash
# Validate schema + connector and (re)generate the typed Dart SDK — no cost,
# already done; regenerate after editing schema/operations:
firebase dataconnect:compile --project uat

# See what tables WOULD be created vs the current Cloud SQL schema:
firebase dataconnect:sql:diff --project uat

# Local emulator (embedded Postgres; no Cloud SQL cost):
firebase emulators:start --only dataconnect
```

To actually create the tables / go live (deliberate, modifies the UAT database):

```bash
# 1. Create the tables in the linked Cloud SQL instance (runs DDL):
firebase dataconnect:sql:migrate --project uat

# 2. Deploy the schema + connector so the generated SDK can call it:
firebase deploy --only dataconnect --project uat
```

The generated Dart SDK lives in `lib/dataconnect_generated/default/` (one file
per operation). Using it from the app also requires adding the
`firebase_data_connect` package to `pubspec.yaml`.

`firebase.json` already references this service:

```json
"dataconnect": { "source": "dataconnect" }
```

## Auth caveat (same as Firestore)

`@auth(level: USER)` only requires a signed-in Firebase user — and your auth is
**anonymous** with a rotating uid. So, exactly like the Firestore rules, true
per-owner enforcement here waits on a backend minting **custom tokens** bound to
the Thai ID. Switching databases does not change that.
