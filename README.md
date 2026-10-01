# دفتر معین شخصی — Flutter (offline, single user)

This is the Flutter port of the web app (NestJS + Angular). It runs offline for one user and keeps everything in a local SQLite database. It has no login or sign-up.

## First-time setup (on a machine with Flutter + Android SDK)

The `android/` folder is checked in, already patched by `tool/setup_android.dart`:

```bash
flutter pub get
flutter test        # unit tests (formatting, statement text, backup parsing)
flutter run         # on a connected device / emulator
```

To regenerate `android/` from scratch, delete it and run:

```bash
flutter create . --platforms android --org ir.daftarmoein --project-name daftar_moein
dart tool/setup_android.dart
```

`flutter create` never overwrites files that already exist, so `lib/`, `pubspec.yaml` and the other project files stay unchanged.

`android/build.gradle.kts` compiles plugins against SDK platform 36, and `android/settings.gradle.kts` makes plugins reuse the project's AGP version, so a build doesn't need SDK platform 35 or older AGP versions.

On Windows, if your Flutter SDK path contains a space, Dart build hooks fail. Run Flutter through the 8.3 short path (e.g. `C:\Users\SAJADS~1\develop\flutter\bin\flutter.bat`) and set the same path as `flutter.sdk` in `android/local.properties`.

`tool/setup_android.dart` makes these changes:
- sets `applicationId` to `ir.daftarmoein.app`
- sets the app label to "دفتر معین" and enables `supportsRtl`
- adds the `<queries>` entries Android 11+ needs to open the SMS app
- removes the template `test/widget_test.dart`

Release build: `flutter build apk --release`. You still need to configure signing in `android/app/build.gradle(.kts)`.

## Structure

```
lib/
  main.dart                      MaterialApp (fa locale, RTL, Vazirmatn, light/dark) + alert host
  models/                        Customer, LedgerTransaction, TransactionSummary
  data/
    app_database.dart            sqflite schema (customers, transactions)
    customer_repository.dart     = backend CustomerService
    transaction_repository.dart  = backend TransactionService (+ summary SQL)
    backup_service.dart          JSON export / import
  services/statement_share_service.dart   = web ExportService.shareStatement
  utils/persian_format.dart      Persian digits, number & Jalali formatting
  theme/                         Material 3 ThemeData, debit/credit colors, Phosphor icons
  widgets/                       bottom sheet, confirm dialog, snackbar alerts,
                                 Jalali date picker dialog, empty state, avatar
  screens/
    customer_list/               /customers page
    transaction_view/            /transactions/:id page
assets/fonts/                    Vazirmatn TTF
tool/setup_android.dart          post-`flutter create` patcher
```

## Differences from the web app

- **No auth.** Login, logout and the "welcome {name}" line are removed. Data is not scoped by user.
- **Backup.** Where the logout button was, there is now a "پشتیبان‌گیری" button. It has two actions:
  - *Save backup* writes a `daftar-moein-backup-YYYY-MM-DD.json` file (Jalali date) to a location you pick with the system file dialog.
  - *Restore* picks such a file, validates it, asks for confirmation, then replaces all data in one SQLite transaction.
- **Bug fixes:**
  1. Editing a customer now saves the description. The backend used to ignore it. In the transaction-page edit form, clearing the description clears it. Clearing the phone keeps the old number, same as the web app.
  2. The new-transaction form resets after a successful save to: today, بستانکار, empty amount and empty description.
  3. Transaction dates are stored as plain local `yyyy-MM-dd`. The web app sent a UTC timestamp, which could save the previous day in Iran's time zone.
- After archiving or unarchiving, the list reloads, so with "show archived" off an archived customer disappears right away.
- Amounts are whole toman (integer). The amount field also accepts Persian digits.

## Backup file format (v1)

```json
{
  "app": "daftar-moein",
  "formatVersion": 1,
  "exportedAt": "2026-10-01T10:00:00.000Z",
  "customers":    [{ "id", "name", "description", "phoneNumber", "isArchived", "createdAt", "updatedAt" }],
  "transactions": [{ "id", "amount", "type": "CREDIT|DEBIT", "date": "yyyy-MM-dd",
                     "description", "customerId", "createdAt", "updatedAt" }]
}
```
