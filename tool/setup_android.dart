// Post-`flutter create` patcher for the Android project.
//
// Usage (from the project root, after `flutter create`):
//   dart run tool/setup_android.dart
//
// It is idempotent, so running it twice is safe.
import 'dart:io';

const applicationId = 'ir.daftarmoein.app';
const appLabel = 'دفتر معین';

void main() {
  if (!Directory('android').existsSync()) {
    stderr.writeln('android/ folder not found. Run this first:\n'
        '  flutter create . --platforms android --org ir.daftarmoein --project-name daftar_moein');
    exit(1);
  }

  _patchGradle();
  _patchManifest();
  _removeTemplateTest();

  stdout.writeln('\nDone. Now run:\n  flutter pub get\n  flutter run');
}

void _patchGradle() {
  final candidates = [
    File('android/app/build.gradle.kts'),
    File('android/app/build.gradle'),
  ];
  final file = candidates.firstWhere(
    (f) => f.existsSync(),
    orElse: () {
      stderr.writeln('android/app/build.gradle(.kts) not found.');
      exit(1);
    },
  );

  var content = file.readAsStringSync();
  // Kotlin DSL:  applicationId = "x.y.z"   Groovy:  applicationId "x.y.z"
  content = content.replaceAllMapped(
    RegExp(r'''applicationId(\s*=?\s*)["'][^"']*["']'''),
    (m) => 'applicationId${m.group(1)}"$applicationId"',
  );
  file.writeAsStringSync(content);
  stdout.writeln('✔ applicationId set to $applicationId in ${file.path}');
}

void _patchManifest() {
  final file = File('android/app/src/main/AndroidManifest.xml');
  if (!file.existsSync()) {
    stderr.writeln('AndroidManifest.xml not found.');
    exit(1);
  }
  var content = file.readAsStringSync();

  // App name
  content = content.replaceFirst(
    RegExp(r'android:label="[^"]*"'),
    'android:label="$appLabel"',
  );

  // RTL support
  if (!content.contains('android:supportsRtl')) {
    content = content.replaceFirst(
      '<application',
      '<application\n        android:supportsRtl="true"',
    );
  }

  // Package visibility for opening the SMS app (url_launcher, Android 11+).
  const smsIntents = '''
        <intent>
            <action android:name="android.intent.action.SENDTO" />
            <data android:scheme="sms" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="sms" />
        </intent>''';

  if (!content.contains('android:scheme="sms"')) {
    if (content.contains('<queries>')) {
      content = content.replaceFirst('<queries>', '<queries>$smsIntents');
    } else {
      content = content.replaceFirst(
        '</manifest>',
        '    <queries>$smsIntents\n    </queries>\n</manifest>',
      );
    }
  }

  file.writeAsStringSync(content);
  stdout.writeln('✔ AndroidManifest.xml patched (label, RTL, SMS queries)');
}

/// `flutter create` adds a counter-app test that references `MyApp`,
/// which does not exist in this project.
void _removeTemplateTest() {
  final file = File('test/widget_test.dart');
  if (file.existsSync() && file.readAsStringSync().contains('MyApp')) {
    file.deleteSync();
    stdout.writeln('✔ Removed template test/widget_test.dart');
  }
}
